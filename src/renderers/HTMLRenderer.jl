module HTMLRenderer

import DataFrames
import JSON

import Dance.Configuration
import Dance.Logger
import Dance.PayloadUtils


"""
    populate(;html_file::String="", data::Union{DataFrames.DataFrame, Dict, String})

Populate supplied HTML with data, by replacing `@data` param
"""
function populate(;html_file::String="", data::Union{DataFrames.DataFrame, Dict, String}) :: String
    output_data::String = ""

    if isa(data, DataFrames.DataFrame)
        output_data = JSON.json(PayloadUtils.convert_dataframe_to_array(data))
    elseif isa(data, Dict)
        output_data = JSON.json(data)
    else
        output_data = data
    end

    html_output::String = read(html_file, String)
    html_output = replace(html_output, "@data" => output_data)

    return html_output
end


"""
    render(;headers::Dict{String, String}, status_code::Int16, data::Union{DataFrames.DataFrame, Dict, String}, html_file::String) :: Dict{Symbol, Union{Dict{String, String}, Int16, String}}

HTML renderer

`status code` is pre-supplied

Cannot set `headers type to `Dict{String, String} here, as can be blank (status_code !=200)
"""
function render(;headers::Dict{String, String}, status_code::Int16, data::Union{DataFrames.DataFrame, Dict, String}, html_file::String) :: Dict{Symbol, Union{Dict{String, String}, Int16, String}}
    if status_code==500
        Logger.log("500 Internal Server Error when rendering page with $data")
    end

    return Dict(
        :headers => headers,
        :status_code => status_code,
        :content_type => "text/html; charset=UTF-8",
        :body => populate(;html_file=html_file, data=data)
    )
end

end
