import Dance

include("./utils/main.jl")


function _build_path(sub_dir::String="") :: String
    path::String = abspath(pwd())

    if length(sub_dir) > 0
        path = joinpath(abspath(pwd()), sub_dir)
    end

    if Sys.iswindows()
        path = replace(path, "/" => "\\")
    end

    return path
end


# Test project settings check
@testset "Settings - Project Settings Check" begin
    # Default Prod env does not have :server_host & :server_port defined
    Dance.start_project("demo")
    @test_logs (:error, "Please set valid server_host value, cannot be blank") (:error, "Please set valid server_port value, cannot be blank") Dance.populate_settings(joinpath(abspath(@__DIR__), "demo"))

    project_settings()
    Dance.populate_settings(joinpath(abspath(@__DIR__), "demo"))
    @test haskey(Dance.Configuration.Settings, :foo)
    @test Dance.Configuration.Settings[:foo]=="bar"

    delete_project(false)
end


# Test LOAD_PATH: single-dir project case
@testset "Settings - LOAD_PATH single-dir" begin
    Dance.start_project("demo")
    project_settings()
    dirs_add_single()

    @async include(joinpath(abspath(pwd()), "dance.jl"))
    sleep(5)

    @test abspath(pwd()) * "/" in LOAD_PATH
    @test _build_path("html") in LOAD_PATH
    @test _build_path("settings") in LOAD_PATH
    @test _build_path("code") in LOAD_PATH

    delete_project(false)
end


# Test LOAD_PATH: multiple sub-dirs case
@testset "Settings - LOAD_PATH multiple sub-dirs" begin
    Dance.start_project("demo")
    project_settings()
    dirs_add_multiple()

    @async include(joinpath(abspath(pwd()), "dance.jl"))
    sleep(2)

    @test abspath(pwd()) * "/" in LOAD_PATH
    @test _build_path("html") in LOAD_PATH
    @test _build_path("settings") in LOAD_PATH
    @test _build_path("code") in LOAD_PATH
    @test _build_path("code/sub-dir1") in LOAD_PATH
    @test _build_path("code/sub-dir1/sub-dir2") in LOAD_PATH

    delete_project(false)
end


# Test `files/routes.jl` default contents
@testset "Settings - default routes contents" begin
    Dance.start_project("demo")
    project_settings()

    @async include(joinpath(abspath(pwd()), "dance.jl"))
    sleep(1)

    make_and_test_request_get("/", 200, Dict("Content-Type" => "text/html; charset=UTF-8"), 217, false, "Hello World")

    delete_project()
end
