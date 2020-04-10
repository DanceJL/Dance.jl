# JSON Endpoints

Dance serves as JSON API for both GET and POST requests.
For GET requests, Julia Dicts and DataFrames are converted on the go to JSON Dicts and Lists.
For POST requests reverse conversion occurs.

## 1 - GET endpoint

For API GET endpoints, covering both Dict and DataFrame output cases, `routes.jl` can be similar to below:

```julia
import DataFrames

using Dance.Router


function get_df() :: DataFrames.DataFrame
    return DataFrames.DataFrame(A = 1:4, B = ["A", "B", "C", "D"])
end


function get_dict() :: Dict
    return Dict(:a => 123)
end


route("/dict", get_dict; method=GET)
route("/dataframe", get_df; method=GET)
```

Note that `method=GET` had to be specified, as default is `POST`.

JSON output for both routes, will become:

```json
{"a":123}
```

```json
[
  ["A","B"],
  [1,"A"],
  [2,"B"],
  [3,"C"],
  [4,"D"]
]
```

## 2 - POST endpoint

For API POST endpoints, covering both Dict and DataFrame output cases, `routes.jl` can be similar to below:

```julia
import DataFrames

using Dance.Router


function post_df(df::DataFrames.DataFrame) :: DataFrames.DataFrame
    return df
end


function post_dict(dict::Dict) :: Dict
    return dict
end


route("/dict", post_dict)
route("/dataframe", post_df)
```

Above examples will output same data as received.

For following JSON inputs:

```json
[
  ["A","B"],
  [1,"A"],
  [2,"B"],
  [3,"C"],
  [4,"D"]
]
```

```json
{"a":123}
```

Data converted to Julia will be:

```julia
4×2 DataFrames.DataFrame
│ Row │ A     │ B      │
│     │ Int64 │ String │
├─────┼───────┼────────┤
│ 1   │ 1     │ A      │
│ 2   │ 2     │ B      │
│ 3   │ 3     │ C      │
│ 4   │ 4     │ D      │
```

```julia
Dict{String,Any}("a" => 123)
```

## 3 - Pre-defined HTTP status codes
 
Additionally to facilitate API development, a few standard HTTP response types can easily be integrated.

By importing `JSONRenderer`, a return such as:

```julia
using Dance.Router
import Dance.JSONRenderer


function post_dict(dict::Dict) :: Dict
    return Dict(:error => JSONRenderer.HTTP_STATUS_UNAUTHORIZED)
end


route("/dict", post_dict)
```
is possible.

This will automatically set HTTP status code to 401.

Currently, possibilities are: 

```julia
HTTP_STATUS_UNAUTHORIZED = "Unauthorized"
HTTP_STATUS_PAYMENT_REQUIRED = "Payment Required"
HTTP_STATUS_FORBIDDEN = "Forbidden"
HTTP_STATUS_REQUEST_TIMEOUT = "Request Timeout"
```

**CAREFUL when creating the function return dicts, as `:error` key is reserved for this use case**
