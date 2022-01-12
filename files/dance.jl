#=
    Multi-processing case.
    Requires Distributed to be installed.
    - Uncomment below, specifying number of desired processes (default is number of system cores)
    - Comment `import Dance` below
=#
#=using Distributed
addprocs(length(Sys.cpu_info()))
@everywhere =#

import Pkg
Pkg.pkg"activate ."

# using .MyPkg
include("src/MyPkg.jl")
Settings = MyPkg.Settings
MyPkg.main(ARGS)
