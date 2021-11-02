module CoreRenderer

import DataFrames

import Dance.HTMLRenderer
import Dance.JSONRenderer
import Dance.StaticRenderer
import Dance.Router


"""
    render(;headers::Dict{String, String}=Dict("" => ""), status_code::Int16, endpoint::String, data::Union{DataFrames.DataFrame, Dict, String}, html_file::String) :: Dict{Symbol, Union{Dict{String, String}, Int16, String}}

Generic web output rendering function

Depending on `endpoint` field, render JSON or HTML string

Cannot set `headers type to `Dict{String, String} here, as can be blank (status_code !=200)
"""
function render(;headers::Dict{String, String}=Dict("" => ""), status_code::Int16, endpoint::String, data::Union{DataFrames.DataFrame, Dict, String}, html_file::String) :: Dict{Symbol, Union{Dict{String, String}, Int16, String}}
    if endpoint==Router.EP_HTML
        HTMLRenderer.render(;headers=headers, status_code=status_code, data=data, html_file=html_file)
    elseif endpoint==Router.EP_JSON
        if isa(data, String)
            data::Dict = Dict(:error => data)
        end
        JSONRenderer.render(;headers=headers, status_code=status_code, data=data)
    else
        StaticRenderer.render(;headers=headers, status_code=status_code, data=data)
    end
end

end
