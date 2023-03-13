# python implementation
using PyCall

py"""
def py_sum(X):
    s = 0.0
    for x in X:
        s += x
    return s
"""
py_sum = py"py_sum"
py_builtin_sum = pybuiltin("sum")

x = rand(10^7)
sum(x)
isapprox(py_sum(x), sum(x))
isapprox(py_builtin_sum(x), sum(x))

# NumPy implementation
numpy_sum = pyimport("numpy").sum
isapprox(numpy_sum(x), sum(x))

# Julia implementation
function ju_sum(X)
    s = 0.0
    for x in X
        s += x 
    end
    s
end

ju_builtin_sum = sum

function ju_simd_sum(X)
    s = 0.0
    @simd for x in X
        s += x         
    end
    s 
end
isapprox(ju_sum(x), sum(x))
isapprox(ju_simd_sum(x), sum(x))

using BenchmarkTools
impls = [py_sum, py_builtin_sum, numpy_sum,
         ju_sum, ju_builtin_sum, ju_simd_sum]

label = ["Python", "Python built-in", "NumPy",
         "Julia", "Julia built-in", "Julia SIMD"]

@time begin
# loop over implementations
times = map(impls) do impl
    # call function multiple times
    bench = @benchmark ($impl)($x)
    # minimum time in milliseconds
    minimum(bench.times) / 1e6
end 
end

using UnicodePlots

# sort times in increasing order
idx = sortperm(times)
label = label[idx]
times = times[idx]
barplot(label, times, title="Time [milliseconds]")
barplot(label, round.(Int, times[end] ./ times),
        title="Speedup relative to slowest ($(label[end]))")