module StaticRenderer

"""
    render(;headers::Dict, status_code::Int64, data::String)

Renderer to output static file as string
"""
function render(;headers::Dict, status_code::Int64, data::String) :: Dict{Symbol, Union{Dict, Int64, String}}
    return Dict(
        :headers => headers,
        :status_code => status_code,
        :content_type => headers["content_type"],
        :body => data
    )
end

end