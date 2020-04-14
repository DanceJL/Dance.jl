# Dance

| **Build Status**                                       |
|:------------------------------------------------------:|
| [![Build Status](https://travis-ci.com/DanceJL/Dance.jl.svg?branch=master)](https://travis-ci.com/DanceJL/Dance.jl)  [![codecov](https://codecov.io/gh/DanceJL/Dance.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/DanceJL/Dance.jl)|

## 1 - Introduction

Julia is an excellent backend language ([read more](https://cloud4scieng.org/2018/12/13/julia-distributed-computing-in-the-cloud/)), powering numerous Artificial Intelligence and Big Data applications.
However integrating these results into web output is not job of a data scientist, nor should it be complicated.

That said, aim of Dance is to facilitate process by allowing output/reception of:

- Dict {Symbol, Any}
- DataFrame

to/from:

- JSON API
- Javascript string in HTML page

simply by adding rendering function as a parameter, when building route list.

That way you can take advantage of powerful frontend JavaScript frameworks, through easy collaboration with frontend developers.

Dance can be used as starting base of new project, as well as web layer addition to existing project.

---

## 2 - Installation

Package can be installed with Julia's package manager, either by using Pkg REPL mode (*press ]*):

```
pkg> add https://github.com/DanceJL/Dance.jl
```

or by using Pkg functions

```julia
julia> using Pkg; Pkg.add("https://github.com/DanceJL/Dance.jl")
```

Compatibility is with Julia 1.1 upward.


## 3 - Setup

Invoke terminal in working directory and:

```julia
using Dance
start_project("project name")
```

This will create a new directory specified by `project name` parameter and copy necessary files over.

Files include:

- `dance.jl` : main entry point of Dance to be always called from terminal
- `routes.jl` : main routes list file
- `settings/Global.jl` : main project settings
- `html/base.html` : for HTML outputs this is default template

Depending on environment, other files can be included under `settings` directory to overwrite those under `Global.jl`:

- One can add other parameters under these settings files, that will be accessible in project by reading `Dance.Configuration.Settings` dict.
- As this has to be done from same `import Dance` as launch of project, best to do under `dance.jl` file as follows:

	```julia
	## Add custom scripts here that need be run before launching Dance ##
	function populate(dict::Dict)
    for (key, value) in dict
        ENV[String(key)] = value
    end
	end

	populate(Dance.Configuration.Settings)
	```

- **Is recommended to use `secrets.jl` file included under `Global.jl` that will not be stored in version control, for sensitive authentication data.**

Can be overwritten/moved:

- `routes.jl`: move/rename and update `Settings[:routes_filename]` accordingly
- `html/base.html`: move/rename and update `Settings[:html_base_filename]` accordingly

## 4 - Routes

### 4.1 - General

Routes can be included in main routes file (`routes.jl` by default), as follows:

```julia
route(path::Union{Regex, String}, action::Function; method::String=POST, endpoint=JSON, html_file::String=Configuration.Settings[:html_base_filename]*".html", name::Union{Symbol,Nothing}=nothing)
```

- Just `path`and `function` are mandatory, *kwargs* can overwrite default values as necessary.

That said, note that:
- `path` can either be fixed string or contain PCRE regex containing parameter names.
- Adding an ending slash (`/`) tp `path` is optional, as incoming requests will have pending slash stripped.
- Named urls are possible by specifying `name`, though including them in static HTML output is a pending feature.

Please see:
- [Common Parameters](docs/routes/common_parameters.md)
- [JSON Endpoints](docs/routes/endoints_json.md)
- [HTML Endpoints](docs/routes/endpoints_html.md)

for all cases.

### 4.2 - Groups for common parameter routes

If some routes share same path prefix or if you want to avoid repeating kwarg parameters, routes can be grouped into route groups as follows:

```julia
route_group(route_prefix="/dict", method=GET, endpoint=HTML, [
    (path=r"/(?<value>\d.)", action=dict_1)
    (path=r"/(?<key>\w+)/(?<value>\d{3})", action=dict_2, html_file="html/file")
])
```

After specifying the common kwargs for routes in question, routes are passed as array of named tuples.

As for common kwargs, only set named tuple keys that are necessary to overwrite.

## 5 - Launching

Calling:

```
julia dance.jl
```
will start Dance as web server.
Press `ctrl` + `c` to stop.

By calling:

```
julia dance.jl repl
```
one can enter REPL mode after project environment has been loaded.
Press `ctrl` + `d` to exit.

## 6 - Module loading & custom startup script
Note that when launching, Dance will add current dir as module import path.

Should you require to load modules from other locations or run a custom startup script, once can add that by editing `dance.jl` as specified within file.
