
function expm(A::AbstractMatrix{S}) where {S}
  # omitted: matrix balancing, i.e., LAPACK.gebal!
  nA = opnorm(A, 1)
  ## For sufficiently small nA, use lower order Padé-Approximations
  if (nA <= 2.1)
    A2 = A * A
    if nA > 0.95
      U = @evalpoly(
        A2,
        S(8821612800) * I,
        S(302702400) * I,
        S(2162160) * I,
        S(3960) * I,
        S(1) * I
      )
      U = A * U
      V = @evalpoly(
        A2,
        S(17643225600) * I,
        S(2075673600) * I,
        S(30270240) * I,
        S(110880) * I,
        S(90) * I
      )
    elseif nA > 0.25
      U = @evalpoly(A2, S(8648640) * I, S(277200) * I, S(1512) * I, S(1) * I)
      U = A * U
      V =
        @evalpoly(A2, S(17297280) * I, S(1995840) * I, S(25200) * I, S(56) * I)
    elseif nA > 0.015
      U = @evalpoly(A2, S(15120) * I, S(420) * I, S(1) * I)
      U = A * U
      V = @evalpoly(A2, S(30240) * I, S(3360) * I, S(30) * I)
    else
      U = @evalpoly(A2, S(60) * I, S(1) * I)
      U = A * U
      V = @evalpoly(A2, S(120) * I, S(12) * I)
    end
    expA = (V - U) \ (V + U)
  else
    s = log2(nA / 5.4)               # power of 2 later reversed by squaring
    if s > 0
      si = ceil(Int, s)
      A = A / S(exp2(si))
    end

    A2 = A * A
    A4 = A2 * A2
    A6 = A2 * A4

    U =
      A6 * (S(1) * A6 + S(16380) * A4 + S(40840800) * A2) +
      (
        S(33522128640) * A6 + S(10559470521600) * A4 + S(1187353796428800) * A2
      ) +
      S(32382376266240000) * I
    U = A * U
    V =
      A6 * (S(182) * A6 + S(960960) * A4 + S(1323241920) * A2) +
      (
        S(670442572800) * A6 +
        S(129060195264000) * A4 +
        S(7771770303897600) * A2
      ) +
      S(64764752532480000) * I
    expA = (V - U) \ (V + U)
    if s > 0            # squaring to reverse dividing by power of 2
      for t = 1:si
        expA = expA * expA
      end
    end
  end
  expA
end

function expwork(A)
  B = expm(A)
  C = similar(B)
  for i = 0:7
    C .= A .* exp(-i)
    B .+= expm(C)
  end
  return B
end
expm_bench0(N = 2, iters = 100) =
  ThreadsX.sum(1:iters) do _
    expwork(rand(N, N))
  end
expm_bench1(N = 2, iters = 100) =
  ThreadsX.sum(1:iters) do _
    ForwardDiff.gradient(sum ∘ expwork, rand(N, N))
  end
expm_bench2(N = 2, iters = 100) =
  ThreadsX.sum(1:iters) do _
    ForwardDiff.hessian(sum ∘ expwork, rand(N, N))
  end
expm_bench3(N = 2, iters = 100) =
  ThreadsX.sum(1:iters) do _
    ForwardDiff.gradient(
      x -> sum(ForwardDiff.hessian(sum ∘ expwork, x)),
      rand(N, N)
    )
  end
