# OmniPackage

[![Build Status](https://github.com/chriselrod/OmniPackage.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/chriselrod/OmniPackage.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/chriselrod/OmniPackage.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/chriselrod/OmniPackage.jl)

The purpose of this package is to be big, to answer the question "what happens if we load a huge chunk of the open source ecosytem at the same time?"
In the future, it may be worth additionally adding code snippets making use of these open repositories.

Great example:
```julia
@time using OmniPackage, Test
x = create_array_of_ps()
@testset "Compiling in a TestSet makes this slow" begin
  @test x[1] isa Vector{OmniPackage.ParametricStruct{Float64,Float64,Float64,Float64,Float64,Float64,Int}}
end
# even in a fresh session, this is fast
@time @eval x[1] isa Vector{OmniPackage.ParametricStruct{Float64,Float64,Float64,Float64,Float64,Float64,Int}}
versioninfo()
```
Sample result:
```julia
julia> @time using OmniPackage, Test
 29.925019 seconds (37.83 M allocations: 2.529 GiB, 3.58% gc time, 70.85% compilation time: 49% of which was recompilation)

julia> x = create_array_of_ps()
2-element Vector{Vector{OmniPackage.ParametricStruct{Float64, Float64, Float64, Float64, Float64, Float64, Int64}}}:
 [OmniPackage.ParametricStruct{Float64, Float64, Float64, Float64, Float64, Float64, Int64}(1.0, 2.0, 3, 4.0, 5.0, 6.0, 7.0, OmniPackage.apple, 1, 2), OmniPackage.ParametricStruct{Float64, Float64, Float64, Float64, Float64, Float64, Int64}(1.0, 2.0, 3, 4.0, 5.0, 6.0, 7.0, OmniPackage.apple, 1, 2)]
 [OmniPackage.ParametricStruct{Float64, Float64, Float64, Float64, Float64, Float64, Int64}(1.0, 2.0, 3, 4.0, 5.0, 6.0, 7.0, OmniPackage.apple, 1, 2), OmniPackage.ParametricStruct{Float64, Float64, Float64, Float64, Float64, Float64, Int64}(1.0, 2.0, 3, 4.0, 5.0, 6.0, 7.0, OmniPackage.apple, 1, 2)]

julia> @testset "Compiling in a TestSet makes this slow" begin
         @test x[1] isa Vector{OmniPackage.ParametricStruct{Float64,Float64,Float64,Float64,Float64,Float64,Int}}
       end
Test Summary:                          | Pass  Total   Time
Compiling in a TestSet makes this slow |    1      1  14.7s
Test.DefaultTestSet("Compiling in a TestSet makes this slow", Any[], 1, false, false, true, 1.683043618670673e9, 1.683043633367204e9, false)

julia> # even in a fresh session, this is fast
       @time @eval x[1] isa Vector{OmniPackage.ParametricStruct{Float64,Float64,Float64,Float64,Float64,Float64,Int}}   
  0.000217 seconds (68 allocations: 3.719 KiB)
true

julia> versioninfo()
Julia Version 1.10.0-DEV.1159
Commit 1a973c7a7a (2023-05-02 03:46 UTC)
Platform Info:
  OS: Linux (x86_64-generic-linux)
  CPU: 28 × Intel(R) Core(TM) i9-9940X CPU @ 3.30GHz
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-14.0.6 (ORCJIT, skylake-avx512)
  Threads: 41 on 28 virtual cores
Environment:
  JULIA_PATH = @.
  LD_LIBRARY_PATH = /usr/local/lib/
  JULIA_NUM_THREADS = 28
```
The compile time seems far too high for such a trivial function.


The examples can be made better:
```julia
julia> @time using OmniPackage
109.203194 seconds (145.90 M allocations: 10.906 GiB, 3.72% gc time, 33.63% compilation time: 67% of which was recompilation)

julia> @time @eval OmniPackage.ode_bench0();
 22.158457 seconds (66.41 M allocations: 4.468 GiB, 4.42% gc time, 1621.91% compilation time: <1% of which was recompilation)

julia> @time @eval OmniPackage.ode_bench1();
 23.134631 seconds (63.82 M allocations: 4.685 GiB, 7.40% gc time, 2412.01% compilation time)

julia> @time @eval OmniPackage.ode_bench2();
 28.841720 seconds (70.07 M allocations: 8.748 GiB, 8.43% gc time, 2841.13% compilation time)

julia> @time @eval OmniPackage.ode_bench3();
 52.567942 seconds (81.21 M allocations: 24.759 GiB, 9.31% gc time, 3084.69% compilation time)

julia> @time @eval OmniPackage.expm_bench0();
  1.210070 seconds (1.52 M allocations: 97.891 MiB, 129.45% compilation time)

julia> @time @eval OmniPackage.expm_bench1();
 40.579424 seconds (25.14 M allocations: 1.713 GiB, 1.64% gc time, 2861.26% compilation time)

julia> @time @eval OmniPackage.expm_bench2();
  8.791431 seconds (16.71 M allocations: 1.068 GiB, 3.72% gc time, 2136.02% compilation time)

julia> @time @eval OmniPackage.expm_bench3();
 17.525862 seconds (24.00 M allocations: 1.504 GiB, 2.02% gc time, 3543.73% compilation time)

julia> @benchmark OmniPackage.ode_bench0()
BenchmarkTools.Trial: 5 samples with 1 evaluation.
 Range (min … max):   68.610 ms … 634.197 ms  ┊ GC (min … max):  0.00% … 86.24%
 Time  (median):      91.490 ms               ┊ GC (median):     0.00%
 Time  (mean ± σ):   295.385 ms ± 296.068 ms  ┊ GC (mean ± σ):  69.24% ± 45.24%

  ███                                                      █  █  
  ███▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁█▁▁█ ▁
  68.6 ms          Histogram: frequency by time          634 ms <

 Memory estimate: 1.19 GiB, allocs estimate: 14264981.

julia> @benchmark OmniPackage.ode_bench1()
BenchmarkTools.Trial: 1 sample with 1 evaluation.
 Single result which took 1.009 s (48.32% GC) to evaluate,
 with a memory estimate of 2.50 GiB, over 29699983 allocations.

julia> @benchmark OmniPackage.ode_bench2()
BenchmarkTools.Trial: 1 sample with 1 evaluation.
 Single result which took 1.885 s (52.97% GC) to evaluate,
 with a memory estimate of 6.25 GiB, over 30041702 allocations.

julia> @benchmark OmniPackage.ode_bench3()
BenchmarkTools.Trial: 1 sample with 1 evaluation.
 Single result which took 8.121 s (50.21% GC) to evaluate,
 with a memory estimate of 21.87 GiB, over 30537088 allocations.

julia> @benchmark OmniPackage.expm_bench0()
BenchmarkTools.Trial: 4032 samples with 1 evaluation.
 Range (min … max):   95.260 μs … 744.183 ms  ┊ GC (min … max):  0.00% … 99.94%
 Time  (median):     170.214 μs               ┊ GC (median):     0.00%
 Time  (mean ± σ):   367.274 μs ±  11.717 ms  ┊ GC (mean ± σ):  50.22% ±  1.57%

        ▁▂▄▅█▃▅▅▇█▇▅▆▄▄▃▂▁▂                                      
  ▁▂▂▄▅▆███████████████████▇█▇█▇▇▅▆▆▅▄▄▄▃▄▄▃▃▄▃▄▄▃▂▃▂▂▂▂▂▂▁▁▁▂▁ ▄
  95.3 μs          Histogram: frequency by time          341 μs <

 Memory estimate: 1.34 MiB, allocs estimate: 14828.

julia> @benchmark OmniPackage.expm_bench1()
BenchmarkTools.Trial: 964 samples with 1 evaluation.
 Range (min … max):  512.796 μs … 297.928 ms  ┊ GC (min … max):  0.00% … 99.65%
 Time  (median):     694.463 μs               ┊ GC (median):     0.00%
 Time  (mean ± σ):     1.026 ms ±   9.574 ms  ┊ GC (mean ± σ):  30.00% ±  3.21%

       ▂▅█▇▄▇▄▃▁                                                 
  ▂▂▄▆██████████▅▆▅▃▃▃▃▃▂▂▁▁▁▁▁▁▂▂▂▁▁▁▂▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▂▁▂▁▁▁▂ ▃
  513 μs           Histogram: frequency by time         1.71 ms <

 Memory estimate: 3.10 MiB, allocs estimate: 18846.

julia> @benchmark OmniPackage.expm_bench2()
BenchmarkTools.Trial: 228 samples with 1 evaluation.
 Range (min … max):  1.243 ms … 355.496 ms  ┊ GC (min … max):  0.00% … 99.39%
 Time  (median):     1.544 ms               ┊ GC (median):     0.00%
 Time  (mean ± σ):   4.543 ms ±  32.044 ms  ┊ GC (mean ± σ):  66.09% ±  9.29%

        ▆█▂█▆▁ ▄▇▅▆▂▆▃                                         
  ▅▄▇▆▇▅██████▅███████▇▇▄▄▃▁▄▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▃ ▄
  1.24 ms         Histogram: frequency by time        2.61 ms <

 Memory estimate: 11.92 MiB, allocs estimate: 19996.

julia> @benchmark OmniPackage.expm_bench3()
BenchmarkTools.Trial: 5 samples with 1 evaluation.
 Range (min … max):  212.128 ms … 252.034 ms  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     249.440 ms               ┊ GC (median):    0.00%
 Time  (mean ± σ):   242.600 ms ±  17.116 ms  ┊ GC (mean ± σ):  0.00% ± 0.00%

  ▁                                                     ▁  ▁  █  
  █▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁█▁▁█▁▁█ ▁
  212 ms           Histogram: frequency by time          252 ms <

 Memory estimate: 54.54 MiB, allocs estimate: 20946.
```
Contributions welcome.
