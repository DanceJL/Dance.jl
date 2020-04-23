import Dance

include("./utils/main.jl")


# Default Prod env does not have :server_host & :server_port defined
Dance.start_project("demo")
@test_logs (:error, "Please set valid server_host value, cannot be blank") (:error, "Please set valid server_port value, cannot be blank") Dance.pre_launch(joinpath(abspath(@__DIR__), "demo"))


project_settings_and_launch()
@test haskey(Dance.Configuration.Settings, :foo)
@test Dance.Configuration.Settings[:foo]=="bar"

@testset "HTTP.listen" begin
    @async Dance.launch(true)
end


delete_project()
