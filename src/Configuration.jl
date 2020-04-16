module Configuration

Settings = Dict(
    :dev => false,
    :engine => "HTTP",
    :html_base_filename => "html/base",
    :html_favicon_name => "html/favicon",
    :log_filename => "log/dancejl",
    :routes_filename => "routes",
    :server_host => "",
    :server_port => ""
)


"""
    is_prod(file_path)

Check if is Production environment
"""
function is_prod() :: Bool
    return !parse(Bool, Settings[:dev])
end


"""
    populate(file_path)

- Read settings/Global.jl from project
- Populate/update Settings dict accordingly
"""
function populate(file_path) :: Bool
    is_success:Bool = false

    ### Parse project settings ###
    function parse() :: Nothing
        function _parse_file(path) :: Nothing
            open(path) do file
                for line in eachline(file)
                    if length(line) > 0
                        # Trim left space
                        line = lstrip(line)

                        if startswith(line, "include(")
                            _parse_file(joinpath(
                                file_path, "settings",
                                replace(replace(line, "include(\"" => ""), "\")" => "")
                            ))
                        elseif line[1]==':'
                            line_split::Array{String} = split(line, "=")
                            key::String = lstrip(rstrip(line_split[1]), ':')
                            value::String = lstrip(line_split[2])

                            # Remove trailing comment
                            if occursin(" #", value)
                                value = rstrip(split(value, " #")[1])
                            end

                            # Remove enclosing quotation marks if is String value
                            if value[1]=='"'
                                value = lstrip(rstrip(value, '"'), '"')
                            end

                            # Populate/update Settings dict
                            if haskey(Settings, Symbol(key))
                                Settings[Symbol(key)] = value
                            else
                                push!(Settings, Symbol(key) => value)
                            end
                        end
                    end
                end
            end
        end

        return _parse_file(joinpath(file_path, "settings/Global.jl"))
    end

    parse()
    is_success = true

    ### Set default server values for Dev environment ###
    if !is_prod()
        if Settings[:server_host]==""
            Settings[:server_host] = "127.0.0.1"
        end
        if Settings[:server_port] ==""
            Settings[:server_port] = 8000
        end
    end

    ### Server values cannot be blank for Prod environment, as no default ###
    for key in [:server_host, :server_port]
        if Settings[key] == ""
            @error "Please set valid $key value, cannot be blank"
            is_success = false
        end
    end

    return is_success
end

end
