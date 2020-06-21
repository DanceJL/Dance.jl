import Dance

include("./utils/main.jl")


# Default Prod env does not have :server_host & :server_port defined
Dance.start_project("demo")
@test_logs (:error, "Please set valid server_host value, cannot be blank") (:error, "Please set valid server_port value, cannot be blank") Dance.populate_settings(joinpath(abspath(@__DIR__), "demo"))


project_settings()
Dance.populate_settings(joinpath(abspath(@__DIR__), "demo"))
@test haskey(Dance.Configuration.Settings, :foo)
@test Dance.Configuration.Settings[:foo]=="bar"


# Extra test to test against `files/routes.jl` default contents
@testset "HTTP.listen" begin
    @async include(joinpath(abspath(pwd()), "dance.jl"))
    sleep(1)
    make_and_test_request_get("/", 200, Dict("Content-Type" => "text/html; charset=UTF-8"), 217, false, "Hello World")
end


delete_project()
