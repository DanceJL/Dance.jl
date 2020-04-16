#!/usr/bin/env julia

using Test, SafeTestsets


@time begin
@time @safetestset "New project settings" begin include("settings_test.jl") end
@time @safetestset "Routes HTML" begin include("routes_html_test.jl") end
@time @safetestset "Routes JSON" begin include("routes_json_test.jl") end
@time @safetestset "Routes Static" begin include("routes_static_test.jl") end
end
