using Markdown
using InteractiveUtils


using Random; Random.seed!(2023)

begin
	using Plots
	f(x) = 3x + 1
	n = 100
	x = range(0, stop=1, length=n)
	y = f.(x) + randn(n)

	𝒟 = zip(x,y)
	plot(x, y, seriestype=:scatter)
end

begin
	using LinearAlgebra
	𝐗 = [x ones(n)]
	𝐲 = y
	𝛉(λ) = (𝐗'*𝐗 + λ*I) \ 𝐗'*𝐲
	# with λ is the Tikhonov regularization parameter
	𝛉(0.)
	g(x, λ=0) = [x 1] ⋅ 𝛉(λ)
	plot!([f, g], 0, 1, color=["blue", "green"])
end

begin
	using Flux
	h(x, θ) = θ[1]*x + θ[2]
	ℒ(x, y, θ) = (h(x,θ) - y)^2
	J(θ) = sum([ℒ(x,y,θ) for (x,y) in 𝒟]) / n
	J((0., 0.))
	gradient(J, [0., 0.])[1]
    ∇J(θ) = gradient(J, θ)[1]
    ∇J([3.,1.])
end

function descend(m; α=0.1)
    θ = randn(2)
    for t in 1:m
        θ -= α * ∇J(θ)
    end
    return θ
end

descend(1000)
q(x) = [x 1] ⋅ θ
plot([f, q], 0, 1, title="Gradient descent solution")