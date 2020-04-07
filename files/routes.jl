using Dance.Router


function hello() :: String
    return "Hello World"
end

route("/", hello; method=GET, endpoint=HTML)
