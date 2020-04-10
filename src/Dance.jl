module Dance

import REPL

include("Configuration.jl")
include("Logger.jl")
include("utils/URIUtils.jl")
include("Router.jl")
include("utils/PayloadUtils.jl")
include("renderers/HTMLRenderer.jl")
include("renderers/JSONRenderer.jl")
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
        server_port::Int32 = Configuration.Settings[:server_port]
        @info "Web server started at $server_host:$server_port"
        CoreEngine.start_server()
    else
        # https://github.com/JuliaLang/julia/blob/master/stdlib/REPL/src/REPL.jl
        terminal = REPL.Terminals.TTYTerminal("", stdin, stdout, stderr)
        repl = REPL.LineEditREPL(terminal, true)
        REPL.run_repl(repl)
    end
end


"""
    pre_launch(file_path::String)

- Populate Configuration.Settings dict
- Populate Router.ROUTES OrderedDict (when including/compiling Julia files)
"""
function pre_launch(file_path::String) :: Bool
    if Configuration.populate(file_path)
        Router.populate(file_path)
    else
        false
    end
end


"""
    start_project(project_name::String, path::String=".")

- Specify new project name
- Copy `files` dir to root of new project
"""
function start_project(project_name::String, path::String=".") :: Nothing
    project_directory::String = joinpath(abspath(path), project_name)

    mkdir(project_directory)
    cp(joinpath(@__DIR__, "../files"), project_directory; force=true)
    @info "Project files created for $project_name"
end

end
