module JSONRenderer

import DataFrames
import JSON

import Dance.Configuration
import Dance.Logger
import Dance.PayloadUtils


const HTTP_STATUS_UNAUTHORIZED = "Unauthorized"
const HTTP_STATUS_PAYMENT_REQUIRED = "Payment Required"
const HTTP_STATUS_FORBIDDEN = "Forbidden"
const HTTP_STATUS_REQUEST_TIMEOUT = "Request Timeout"

const HTTP_STATUS_ERROR_CODES = Dict{String, Int16}(
    HTTP_STATUS_UNAUTHORIZED => 401,
    HTTP_STATUS_PAYMENT_REQUIRED => 402,
    HTTP_STATUS_FORBIDDEN => 403,
    HTTP_STATUS_REQUEST_TIMEOUT => 408
)


"""
    render(;headers::Dict{String, String}, status_code::Int16, data::Union{DataFrames.DataFrame, Dict}) :: Dict{Symbol, Union{Dict{String, String}, Int16, String}}

Output JSON renderer

Though `status code` is pre-supplied, can become 500

Cannot set `headers type to `Dict{String, String} here, as can be blank (status_code !=200)
"""
function render(;headers::Dict{String, String}, status_code::Int16, data::Union{DataFrames.DataFrame, Dict}) :: Dict{Symbol, Union{Dict{String, String}, Int16, String}}
    body::Union{Array{Any,1}, Dict} = Dict()

    # One of HTTP_STATUS_ERROR_CODES is supplied as data{Dict}
    if status_code==200 && isa(data, Dict)
        if length(data)==1 && :error in keys(data)
            try
                status_code = HTTP_STATUS_ERROR_CODES[data[:error]]
                body = Dict(
                    :error => string(status_code, ": ", data[:error])
                )
            catch e
                status_code = 500
                body = Dict(
                    :error => "500:  Internal Server Error"
                )

                data_string::String = string(data)
                Logger.log("500 Internal Server Error when rendering page with $data_string: $e")
            end
        else
            body = data
        end
    else
        if isa(data, DataFrames.DataFrame)
            body = PayloadUtils.convert_dataframe_to_array(data)
        else
            body = data
        end
    end

    headers["Access-Control-Allow-Origin"] = Configuration.Settings[:api_access_control_allow_origin]
    return Dict(
        :headers => headers,
        :status_code => status_code,
        :content_type => "application/json",
        :body => JSON.json(body)
    )
end

end
