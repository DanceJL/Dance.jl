import Dance

include("./utils/main.jl")


Dance.start_project("demo")
project_settings()
routes("regex")


## Test all routes with pending slash, to ensure is removed ##
@testset "HTTP.listen" begin
    @async include(joinpath(abspath(pwd()), "dance.jl"))
    sleep(1)

    # Test hyphen
    make_and_test_request_get("/dict/ab-/123/", 200, Dict("Content-Type" => "text/html; charset=UTF-8"), 217, true, Dict("ab-" => 123))

    # Test underscore
    make_and_test_request_get("/dict/ab_/123/", 200, Dict("Content-Type" => "text/html; charset=UTF-8"), 217, true, Dict("ab_" => 123))

    # Test comma
    make_and_test_request_get("/dict/ab,/123/", 200, Dict("Content-Type" => "text/html; charset=UTF-8"), 217, true, Dict("ab," => 123))

    # Test dot
    make_and_test_request_get("/dict/ab./123/", 200, Dict("Content-Type" => "text/html; charset=UTF-8"), 217, true, Dict("ab." => 123))

    # Test plus symbol
    make_and_test_request_get("/dict/ab+/123/", 200, Dict("Content-Type" => "text/html; charset=UTF-8"), 217, true, Dict("ab+" => 123))

    # Test accent
    make_and_test_request_get("/dict/abç/123/", 200, Dict("Content-Type" => "text/html; charset=UTF-8"), 218, true, Dict("abç" => 123))

    # Test escaped
    make_and_test_request_get("/dict/ab%2F/123/", 200, Dict("Content-Type" => "text/html; charset=UTF-8"), 219, true, Dict("ab%2F" => 123))
end


delete_project()