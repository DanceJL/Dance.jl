module PayloadUtils

import DataFrames


"""
    convert_array_to_dataframe(array::Array{Any,1})

Convert Array{Any,1} to DataFrame
"""
function convert_array_to_dataframe(array::Array{Any,1}) :: DataFrames.DataFrame
    df::DataFrames.DataFrame = DataFrames.DataFrame()

    namelist::Array = Symbol.(array[1])

    for (i, name) in enumerate(namelist)
        df[!, name] = [array[j][i] for j in 2:length(array)]
    end

    return df
end


"""
    convert_dataframe_to_array(df::DataFrames.DataFrame)

Convert DataFrame to Dict{Array}, including column names via first line of array
"""
function convert_dataframe_to_array(df::DataFrames.DataFrame) :: Array{Any,1}
    array::Array{Any, 1} = []

    push!(array, names(df))
    for row in eachrow(df)
        push!(array, [row[name] for name in names(df)])
    end

    return array
end

end
