module CoreRenderer

import DataFrames

import Dance.HTMLRenderer
import Dance.JSONRenderer
import Dance.Router


"""
    render(;headers::Dict=Dict(), status_code::Int64, endpoint::String, data::Union{DataFrames.DataFrame, Dict, String}, html_file::String)

Generic web output rendering function

Depending on `endpoint` field, render JSON or HTML string
"""
function render(;headers::Dict=Dict(), status_code::Int64, endpoint::String, data::Union{DataFrames.DataFrame, Dict, String}, html_file::String) :: Dict{Symbol, Union{Dict, Int64, String}}
    if endpoint==Router.HTML
        HTMLRenderer.render(;headers=headers, status_code=status_code, data=data, html_file=html_file)
    else
        if isa(data, String)
            data::Dict = Dict(:error => data)
        end
        JSONRenderer.render(;headers=headers, status_code=status_code, data=data)
    end
end

end
