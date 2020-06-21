# Dance

| **Build Status**                                       |
|:------------------------------------------------------:|
| [![Build Status](https://travis-ci.com/DanceJL/Dance.jl.svg?branch=master)](https://travis-ci.com/DanceJL/Dance.jl)  [![codecov](https://codecov.io/gh/DanceJL/Dance.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/DanceJL/Dance.jl)|

## 1 - Introduction

Julia is an excellent backend language ([read more](https://cloud4scieng.org/2018/12/13/julia-distributed-computing-in-the-cloud/)), powering numerous Artificial Intelligence and Big Data applications.
However,  integrating these results into web output is not the job of a data scientist, nor should it be complicated.

That said, the aim of Dance is to facilitate process by allowing output/reception of:

- Dict {Symbol, Any}
- DataFrame

to/from:

- JSON API
- JavaScript string in HTML page

simply by adding rendering function as a parameter, when building route list.

That way you can take advantage of powerful frontend JavaScript frameworks, through easy collaboration with frontend developers.

Dance can be used as starting base of new project, as well as web layer addition to existing project.

---

## 2 - Installation

Package can be installed with Julia's package manager, either by *pressing* ] to get the Pkg REPL mode and doing:

```
pkg> add Dance
```

or by using Pkg functions:

```julia
julia> using Pkg; Pkg.add("Dance")
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

- `dance.jl`: main entry point of Dance to be always called from terminal
- `routes.jl`: main routes list file
- `settings/Global.jl`: main project settings
- `html/base.html`: for HTML outputs this is default template
- `html/favicon.ico`: favicon for HTML pages

Depending on environment, other files can be included under `settings` directory to overwrite those under `Global.jl`:

- One can add other parameters under these settings files, that will be accessible in project by reading from `Main.Settings` dict.
ENV has been avoided due to potential leakage security issues.
- **Is recommended to use `secrets.jl` file included under `Global.jl` that will not be stored in version control, for sensitive authentication data.**

Can be overwritten/moved:

- `routes.jl`: move/rename and update `Settings[:routes_filename]` accordingly
- `html/base.html`: move/rename and update `Settings[:html_base_filename]` accordingly
- `html/favicon.ico`: move/rename and update `Settings[:html_favicon_name]` accordingly

## 4 - Routes

### 4.1 - General

Routes can be included in main routes file (`routes.jl` by default), as follows:

```julia
route(path::Union{Regex, String}, action::Function; method::String=POST, endpoint=EP_JSON, html_file::String=Configuration.Settings[:html_base_filename]*".html")
```

- Just `path`and `function` are mandatory, *kwargs* can overwrite default values as necessary.

That said, note that:
- `path` can either be fixed string or contain PCRE regex containing parameter names.
- Adding an ending slash (`/`) tp `path` is optional, as incoming requests will have pending slash stripped.

Please see:
- [Common Parameters](docs/routes/common_parameters.md)
- [JSON Endpoints](docs/routes/endoints_json.md)
- [HTML Endpoints](docs/routes/endpoints_html.md)

for all cases.

### 4.2 - Groups For Common Parameter Routes

If some routes share same path prefix or if you want to avoid repeating kwarg parameters, routes can be grouped into route groups as follows:

```julia
route_group(route_prefix="/dict", method=GET, endpoint=EP_HTML, [
    (path=r"/(?<value>\d.)", action=dict_1)
    (path=r"/(?<key>\w+)/(?<value>\d{3})", action=dict_2, html_file="html/file")
])
```

After specifying the common kwargs for routes in question, routes are passed as array of named tuples.

As for common kwargs, only set named tuple keys that are necessary to overwrite.

### 4.3 - Static Files

Dance can also serve static files.

Recommended method is to specify a static directory whose structure will be parsed when building routes for each of the directory's contents.

For example all contents of `files` directory will be accessible under `static` path:

```julia
static_dir("/static", "files")
```

If you have some other files that you would like to add individually, one can do so by passing path parameter as relative to project's root directory.

For instance if you have `image.jpg` in `files` relative to project root:

```julia
route("/files/image.jpg", output_file_as_string; method=GET, endpoint=EP_STATIC)
```

## 5 - Launching

Calling:

```
julia dance.jl
```
will start Dance as web server.
Press `ctrl` + `C` to stop.

By calling:

```
julia dance.jl repl
```
one can enter the REPL mode after project environment has been loaded.
Press `ctrl` + `d` to exit.

## 6 - Module Loading & Custom Startup Script
Note that when launching, Dance will add the current dir, as well as all sub-directories as module import path.

By `static_dir` as defined in `routes.jl` will be ignored during the procedure, as described under `STEP 1` of `dance.jl` file.
Should you require ignoring other directories for startup performance optimisation, please populate `ignore_dirs` under `STEP 1`.

As outlined under `STEP 3` of `dance.jl` file, any custom scripts can be added, that will be run before Dance launches server/REPL.

## 7 - Running Dance Under Multi-processing Environment

Dance can be run in multi-process environment via Julia Distributed package.
This is also particularly useful should you be planning on using cluster of machines in order to implement load balancer.

**That said please only use this feature should your website expect heavy traffic or output functions be resource intensive, as else performance will degrade as spawning and data transfer between processes are expensive operations.**

To do so edit the upper part of `dance.jl` as indicated in the file.
