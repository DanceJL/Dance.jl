module Dance

import Pkg
import REPL

include("Configuration.jl")
include("Logger.jl")
include("utils/URIUtils.jl")
include("Router.jl")
include("utils/PayloadUtils.jl")
include("renderers/HTMLRenderer.jl")
include("renderers/JSONRenderer.jl")
include("renderers/StaticRenderer.jl")
include("renderers/CoreRenderer.jl")
include("engines/CoreEngine.jl")


export start_project


"""
    launch(start_server::Bool)

Launch either (depending on `start_server` param):

- Web server via selected engine
- REPL
"""
function launch(start_server::Bool) :: Union{REPL.REPLBackend, Nothing}
    if start_server
        server_host::String = Configuration.Settings[:server_host]
        server_port::Int64 = Configuration.Settings[:server_port]

        @info "Web server started at $server_host:$server_port"
        CoreEngine.start_server(server_host, server_port)
    else
        # https://github.com/JuliaLang/julia/blob/master/stdlib/REPL/src/REPL.jl
        terminal = REPL.Terminals.TTYTerminal("", stdin, stdout, stderr)
        repl = REPL.LineEditREPL(terminal, true)
        REPL.run_repl(repl)
    end
end


"""
    populate_load_path(file_path::String; ignore_dirs::Array{String, 1})

- Read Settings dict for routes filepath
- Get static dir by parsing routes.jl

- Optional: array of other paths to ignore
"""
function populate_load_path(file_path::String; ignore_dirs::Array{String, 1}) :: Array{String, 1}
    dirs_ignore_array::Array{String, 1} = [".git", ".hg", "node_modules"]
    load_path_array::Array{String, 1} = [abspath(file_path)]

    function _get_static_dir() :: String
        static_dir::String = ""

        for line in readlines(joinpath(file_path, Configuration.Settings[:routes_filename]*".jl"))
            if occursin("static_dir(", line)
                static_dir = replace(
                    strip(
                        split(
                            split(
                                split(line, ",")[2],
                                ")"
                            )[1],
                            "/"
                        )[1]
                    ),
                    "\"" => ""
                )
            end
        end

        return static_dir
    end

    function _populate_load_path() :: Nothing
        for item in readdir(file_path)
            if isdir(item) && !(item in filter(x -> !occursin("/", x), dirs_ignore_array))
                for (root, dirs, files) in walkdir(item)
                    push!(load_path_array, abspath(root))
                    for dir in dirs
                        if size(split(root, "/"))[1]==1
                            for ignore_dir in dirs_ignore_array
                                if !occursin(abspath(ignore_dir), abspath(joinpath(root)))
                                    if !(abspath(root) in load_path_array)
                                        push!(load_path_array, abspath(root))
                                    end
                                end
                            end
                        end

                        ignore_dirs_contains_dir_counter::Int8 = 0
                        for ignore_dir in dirs_ignore_array
                            if occursin(abspath(ignore_dir), abspath(joinpath(root, dir)))
                                ignore_dirs_contains_dir_counter = 1
                                break
                            end
                        end
                        if ignore_dirs_contains_dir_counter==0
                            if !(abspath(joinpath(root, dir)) in load_path_array)
                                push!(load_path_array, abspath(joinpath(root, dir)))
                            end
                        end
                    end
                end
            end
        end
        nothing
    end

    if _get_static_dir()!=""
        push!(dirs_ignore_array, _get_static_dir())
    end
    dirs_ignore_array = vcat(dirs_ignore_array, ignore_dirs)
    _populate_load_path()

    return load_path_array
end


"""
    populate_router(file_path::String)

Populate Router.ROUTES OrderedDict (when including/compiling Julia files)
"""
function populate_router(file_path::String) :: Bool
    return Router.populate(file_path)
end


"""
    populate_settings(file_path::String)

Populate Configuration.Settings dict
"""
function populate_settings(file_path::String) :: Bool
    return Configuration.populate(file_path)
end


"""
    start_project(project_name::String, path::String=".")

- Specify new project name
- Copy `files` dir to root of new project
"""
function start_project(project_name::String, path::String=".") :: Nothing
    project_directory::String = joinpath(abspath(path), project_name)

    Pkg.generate(project_name)
    rm(joinpath(project_directory, "src"); recursive=true)
    for (root, dirs, files) in walkdir(joinpath(@__DIR__, "../files"))
        for file in files
            cp(joinpath(root, file), joinpath(project_directory, file); force=true)
        end
        for dir in dirs
            mkdir(joinpath(project_directory, dir))
            for (root2, dirs2, files2) in walkdir(joinpath(root, dir))
                for file in files2
                    cp(joinpath(root, dir, file), joinpath(project_directory, dir, file); force=true)
                end
            end
        end
    end

    project_name = titlecase(project_name)
    mv(
        joinpath(project_directory, "src/MyPkg.jl"),
        joinpath(project_directory, "src/$project_name.jl")
    )
    for file_name in [
        joinpath(project_directory, "src/$project_name.jl"),
        joinpath(project_directory, "dance.jl"),
    ]
        lines = readlines(file_name)
        open(file_name, "w") do io
            for line in lines
                if match(r"MyPkg", line) !== nothing
                    line = replace(line, "MyPkg" => project_name)
                end
                println(io, line)
            end
        end
    end

    if Sys.iswindows()
        run(`icacls.exe $project_name /reset /T /Q`)
        run(`icacls "$project_name" /reset /T /Q`)
        username::String = read(run(`whoami`), String)
        run(`icacls.exe $project_name /grant $username:F /T /Q`)
        run(`icacls "$project_name" /grant "$username:(OI)(CI)(IO)F" /T /Q`)
        run(`icacls "$project_name" /grant "$username:F" /Q`)

        #= TODO: fix Windows PowerShell escape issue
        See: https://discourse.julialang.org/t/how-to-quote-special-characters-in-run-function/21359/4 =#
        @info "Please run REPL command `run(`attrib –r \"$project_name\\*.*\" /s`)` to finish (due to Julia <-> Windows PowerShell issue)"
    else
        run(`chmod -R 755 $project_directory`)
    end
    @info "Project files created for $project_name"
end

end
