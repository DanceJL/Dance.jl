module StaticRenderer

"""
    render(;headers::Dict{String, String}, status_code::Int16, data::String) :: Dict{Symbol, Union{Dict{String, String}, Int16, String}}

Renderer to output static file as string

Cannot set `headers type to `Dict{String, String} here, as can be blank (status_code !=200)
"""
function render(;headers::Dict{String, String}, status_code::Int16, data::String) :: Dict{Symbol, Union{Dict{String, String}, Int16, String}}
    return Dict(
        :headers => headers,
        :status_code => status_code,
        :content_type => headers["Content-Type"],
        :body => data
    )
end

end
