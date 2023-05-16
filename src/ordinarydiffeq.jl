
function lorenz!(du, u, p, t)
  du[1] = 10.0(u[2] - u[1])
  du[2] = u[1] * (28.0 - u[3]) - u[2]
  du[3] = u[1] * u[2] - (8 / 3) * u[3]
end

function ode_work(u0, tspan)
  prob = ODEProblem(lorenz!, u0, tspan)
  sol = solve(prob, AutoVern7(Rodas5()))
  sum(sol.u)
end
function ode_bench0(iters = 1000)
  tspan = (0.0, 100.0)
  ThreadsX.sum(1:iters) do _
    ode_work(rand(3), tspan)
  end
end
function ode_bench1(iters = 1000)
  tspan = (0.0, 100.0)
  ThreadsX.sum(1:iters) do _
    ForwardDiff.gradient(x -> sum(ode_work(x, tspan)), rand(3))
  end
end
function ode_bench2(iters = 1000)
  tspan = (0.0, 100.0)
  ThreadsX.sum(1:iters) do _
    ForwardDiff.hessian(x -> sum(ode_work(x, tspan)), rand(3))
  end
end
function ode_bench3(iters = 1000)
  tspan = (0.0, 100.0)
  ThreadsX.sum(1:iters) do _
    ForwardDiff.gradient(
      y -> sum(ForwardDiff.hessian(x -> sum(ode_work(x, tspan)), y)),
      rand(3)
    )
  end
end
