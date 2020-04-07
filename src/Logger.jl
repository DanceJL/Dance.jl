module Logger

import Dates

import Dance.Configuration


"""
    log(error)

Logging of timestamp & error message

- If Prod: Write to log file
- Else: Output te REPL
"""
function log(error)
    error::String = string(Dates.now(Dates.UTC), ": ", error)

    if Configuration.is_prod()
        log_filepath::String = Configuration.Settings[:log_filename]*".log"

        # Create logfile dir if not found
        if !isfile(log_filepath)
            paths::Array{String} = split(log_filepath, '/')
            mkpath(replace(log_filepath, paths[end] => ""))
        end

        open(log_filepath, "a+") do file
            write(file, error * "\n")
        end
    else
        @error error
    end
end

end
