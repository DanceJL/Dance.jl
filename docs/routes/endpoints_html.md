# HTML Endpoints

Dance serves HTML GET request outputs.
For GET requests, Julia Dicts and DataFrames are converted on the go to JSON Dicts, while Lists to JSON objects. Normal HTML strings can also be outputted.

More precisely, `<div id="js-dance-json-data">` HTML tag is where the JSON string/HTML output can be found.

## 1 - Outputs

Covering both String, Dict and DataFrame output cases, `routes.jl` can be similar to below:

```julia
import DataFrames

using Dance.Router


function get_string() :: String
    return "Hello World"
end


function get_df() :: DataFrames.DataFrame
    return DataFrames.DataFrame(A = 1:4, B = ["A", "B", "C", "D"])
end


function get_dict() :: Dict{Symbol, Int64}
    return Dict(:a => 123)
end


route("/", get_string; method=GET, endpoint=HTML)
route("/dict", get_dict; method=GET, endpoint=HTML)
route("/dataframe", get_df; method=GET, endpoint=HTML)
```

- Note that `method=GET` and `endpoint=HTML` have to be specified, as default is `POST` and `JSON` respectively.
- **`html_file` is only should you decide to use different HTML template than default one specified in settings.**
- Named urls are possible by specifying `name`, though including them in static HTML output is a pending feature.
- To parse the JSON string under `<div id="js-dance-json-data">` HTML tag, one has to do so via JavaScript script.
  For instance with jQuery, one would use `jQuery.parseJSON()` function.

HTML output for above routes, will become: 

```html
<!DOCTYPE html>
<html lang="en">

<head>
    <meta http-equiv="Content-type" content="text/html; charset=utf-8">
    <title></title>
</head>

<body>
    <div id="js-dance-json-data">Hello World</div>
</body>

</html>
```

```html
<!DOCTYPE html>
<html lang="en">

<head>
    <meta http-equiv="Content-type" content="text/html; charset=utf-8">
    <title></title>
</head>

<body>
    <div id="js-dance-json-data">{"a":123}</div>
</body>

</html>
```

```html
<!DOCTYPE html>
<html lang="en">

<head>
    <meta http-equiv="Content-type" content="text/html; charset=utf-8">
    <title></title>
</head>

<body>
    <div id="js-dance-json-data">[["A","B"],[1,"A"],[2,"B"],[3,"C"],[4,"D"]]</div>
</body>

</html>
```
