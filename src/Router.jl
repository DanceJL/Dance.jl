module Router

import OrderedCollections

import Dance.Configuration
import Dance.Logger
import Dance.URIUtils


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
    has_regex::Bool
    action::Function
    html_file::String
    name::Symbol

    """
        Route(;endpoint::String, method::String, path::String, has_regex::Bool, action::Function, html_file::String, name::Symbol)

    Create new Route object, by validating supplied Route parameters
    """
    function Route(;endpoint::String, method::String, path::String, has_regex::Bool, action::Function, html_file::String, name::Symbol) :: Route
        error::String = ""

        if !(endpoint in ENDPOINTS)
            error = "Invalid endpoint. Must be \"HTML\" or \"JSON\""
        elseif !(method in METHODS)
            error = "Invalid method. Must be \"GET\" or \"POST\""
        elseif path_already_exists(path)
            error = "Path already exists"
        else
            try
                for item in split(path, "/")
                    isa("r\"" * path * "\"", Regex)
                end
            catch e
                error = "Invalid route regex format"
            end
            try
                methods(action)
            catch e
                error = "Action function not defined"
            end
        end

        if length(error)==0
            return new(endpoint, method, path, has_regex, action, html_file, name)
        else
            Logger.log("Route construction for `$path`: $error")
        end
    end
end

const ROUTES = OrderedCollections.OrderedDict{String, Route}()


"""
    create_route_name_from_path(path::String) :: Symbol

Create name from path string by:
- Removing leading slash
- Adding integer suffix to path
"""
function create_route_name_from_path(path::String) :: Symbol
    idx::Int128 = 0
    name= path[2:end]

    # Index url case
    if length(name)==0
        name = "index"
    end

    name_symbol::Symbol = Symbol(name)
    while haskey(ROUTES, name_symbol)
        idx += 1
        name_symbol = Symbol(name, "$idx")
    end

    return name_symbol
end


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
    found_route::Union{Route, Nothing} = nothing

    # Remove trailing slash (if not index url)
    route_path = remove_trailing_slash(route_path)

    for (path, route) in ROUTES
        if !route.has_regex
            if path==route_path
                found_route = route
            end
        else
            request_path_number_of_segments::Int8 = length(URIUtils.get_path_segments(route_path))[1]
            route_number_of_params::Int8 = length(collect(eachmatch(URIUtils.ROUTE_REGEX_BASIC_STRUCTURE, path)))
            if route.has_regex && request_path_number_of_segments==route_number_of_params
                try
                    if isa(match(Regex(path), route_path), RegexMatch)
                        found_route = route
                    end
                catch e
                    nothing
                end
            end
        end
    end

    if isnothing(found_route)
        Logger.log("Getting Route: route with path `$route_path` not defined")
    end

    return found_route
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
    remove_trailing_slash(path::String)

Remove eventual trailing slash, if not index url
"""
function remove_trailing_slash(path::String) :: String
    if length(path)>1 && path[end]=='/'
        path = chop(path)
    end

    return path
end


"""
    route(path::Union{Regex, String}, action::Function; method::String=POST, endpoint=JSON, html_file::String=Configuration.Settings[:html_base_filename]*".html", name::Union{Symbol,Nothing}=nothing)

Create new Route and add to ROUTES ordered dict
- If path is Regex, convert to String for storage (Route has `has_regex` field)
- Remove trailing slash
- If supplied name is nothing, generate from path and eventual number suffix
"""
function route(path::Union{Regex, String}, action::Function; method::String=POST, endpoint=JSON, html_file::String=Configuration.Settings[:html_base_filename]*".html", name::Union{Symbol,Nothing}=nothing) :: OrderedCollections.OrderedDict{String, Route}
    has_regex::Bool = isa(path, Regex)

    if has_regex
        path::String = replace(rstrip(string(path), '"'), "r\""=>"")
    end
    path = remove_trailing_slash(path)

    # No `name` param supplied
    if isnothing(name)
        name = create_route_name_from_path(path)
    end

    push!(ROUTES, path => Route(endpoint=endpoint, method=method, path=path, has_regex=has_regex, action=action, html_file=html_file, name=name))
end

end
