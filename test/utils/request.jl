import Dates
import JSON


function compare_http_date_header(header_value::String, timestamp_request_completed::Dates.DateTime) :: Nothing
    header_value_timestamp::Dates.DateTime = Dates.DateTime(split(header_value, " UTC")[1], "e, d u Y H:M:S")
    @test header_value_timestamp <= timestamp_request_completed
    nothing
end


function compare_http_header(headers::Array, key::String, value::String) :: Nothing
    @test header_get_value(headers::Array, key::String)==value
    nothing
end


function header_get_value(headers::Array, key::String) :: String
    for item in headers
        if item[1]==key
            return item[2]
        end
    end
end


function extract_html_body_content(html_body::Array{UInt8,1}) :: String
    return split(
        split(String(html_body), "<div id=\"js-dance-json-data\">")[2],
        "</div>"
    )[1]
end


function extract_json_content(json_body::Array{UInt8,1}) :: String
    return String(json_body)
end


function parse_and_test_request(r::HTTP.Messages.Response, status::Int64, headers::Dict{String, String}, content_length::Int64, is_json_body::Bool, body::Any)
    timestamp_request_completed::Dates.DateTime = Dates.now(Dates.UTC)

    @test r.status==status

    for (key, value) in headers
        compare_http_header(r.headers, key, value)
    end
    # TODO: fix Windows HTML file longer due to line final char
    if !Sys.iswindows()
        compare_http_header(r.headers, "Content-Length", string(content_length))
    end
    compare_http_date_header(header_get_value(r.headers, "Date"), timestamp_request_completed)

    if is_json_body
        if header_get_value(r.headers, "Content-Type")=="text/html; charset=UTF-8"
            @test JSON.parse(extract_html_body_content(r.body))==body
        else
            @test JSON.parse(extract_json_content(r.body))==body
        end
    else
        if header_get_value(r.headers, "Content-Type")=="text/html; charset=UTF-8"
            @test extract_html_body_content(r.body)==body
        else
            # Static file case
            @test r.body==body
        end
    end

    nothing
end

