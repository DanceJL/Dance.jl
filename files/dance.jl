import Dance


function main(args)
    if Dance.pre_launch(abspath(@__DIR__))
        push!(LOAD_PATH, ".")

        ## Add custom scripts here that need be run before launching Dance ##

        start_server::Bool = true
        if length(args)>0
            if args[1]=="repl"
                start_server = false
            end
        end
        Dance.launch(start_server)
    end
end


main(ARGS)
