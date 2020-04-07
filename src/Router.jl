module Router

import OrderedCollections

import Dance.Configuration
import Dance.Logger


const GET= "GET"
const POST= "POST"
const METHODS = [GET, POST]

const HTML = "HTML"
const JSON = "JSON"
const ENDPOINTS = [HTML, JSON]

mutable struct Route
    endpoint::String
    method::String
    path::String
    action::Function
    html_file::String
    name::Symbol

    """
        Route(;endpoint::String, method::String, path::String, action::Function, html_file::String, name::Symbol)

    Create new Route object
    - Remove trailing slash
    - Validate supplied Route parameters
    """
    function Route(;endpoint::String, method::String, path::String, action::Function, html_file::String, name::Symbol) :: Route
        error::String = ""

        # Remove trailing slash (if not index url)
        if length(path)>1 && path[end]=='/'
            path = chop(path)
        end

        if !(endpoint in ENDPOINTS)
            error = "Invalid endpoint. Must be \"HTML\" or \"JSON\""
        elseif !(method in METHODS)
            error = "Invalid method. Must be \"GET\" or \"POST\""
        elseif path_already_exists(path)
            error = "Path already exists"
        else
            try
                methods(action)
            catch e
                error = "Action function not defined"
            end
        end

        if length(error)==0
            return new(endpoint, method, path, action, html_file, name)
        else
            Logger.log("Route construction for `$path`: $error")
        end
    end
end

const ROUTES = OrderedCollections.OrderedDict{String, Route}()


"""
    delete_routes!()

Empty ROUTES ordered dict

Only called from tests as of now
"""
function delete_routes!() :: OrderedCollections.OrderedDict{String, Route}
    empty!(ROUTES)
end


"""
    get_route(route_path::String)

Search ROUTES ordered dict for route component from specified path
"""
function get_route(route_path::String) :: Union{Route, Nothing}
    route::Union{Route, Nothing} = nothing

    # Remove trailing slash (if not index url)
    if length(route_path)>1 && route_path[end]=='/'
        route_path = chop(route_path)
    end

    if haskey(ROUTES, route_path)
        route = ROUTES[route_path]
    else
        Logger.log("Getting Route: route with path `$route_path` not defined")
    end

    return route
end


"""
    path_already_exists(path::String)

Verify if ROUTES ordered dict already has existing entry for specified path
"""
function path_already_exists(path::String) :: Bool
    path_exists = false

    for route_path in keys(ROUTES)
        if route_path == path
            path_exists = true
            break
        end
    end

    return path_exists
end


"""
    populate(file_path)

Register Routes from `Configuration.Settings[:routes_filename]` file
"""
function populate(file_path::String) :: Bool
    is_success::Bool = false
    routes_filepath::String = joinpath(file_path, Configuration.Settings[:routes_filename]*".jl")

    if isfile(routes_filepath)
        include(routes_filepath)
        is_success = true
    else
        @error "Populating Routes: file not found at $routes_filepath"
    end

    return is_success
end


"""
    route(path::String, action::Function; method::String=POST, endpoint=JSON, html_file::String=Configuration.Settings[:html_base_filename]*".html", name::Union{Symbol,Nothing}=nothing)

Create new Route and add to ROUTES ordered dict
- If supplied name is nothing, generate from path and eventual number suffix
"""
function route(path::String, action::Function; method::String=POST, endpoint=JSON, html_file::String=Configuration.Settings[:html_base_filename]*".html", name::Union{Symbol,Nothing}=nothing) :: OrderedCollections.OrderedDict{String, Route}
    if isnothing(name)
        idx::Int128 = 0
        name = path[2:end]

        # Index url case
        if length(name)==0
            name = "index"
        end

        name = Symbol(name)
        while haskey(ROUTES, name)
            idx += 1
            name = Symbol(path, "$idx")
        end
    end

    push!(ROUTES, path => Route(endpoint=endpoint, method=method, path=path, action=action, html_file=html_file, name=name))
end

end
