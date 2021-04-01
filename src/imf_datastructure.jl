"""
    imf_datastructure(dataset_id::String) -> DataFrame

Return parameter ("dimension") list and parameter values for `dataset_id`.
"""
function imf_datastructure(dataset_id::String)
    api_method = "/DataStructure/"
    query = string(API_URL, api_method, dataset_id)
    response = HTTP.get(query)
    if response.status != 200
        error("Invalid request")
    end
    response_body = String(response.body)
    response_json = JSON.parse(response_body)
    structure = response_json["Structure"]["CodeLists"]["CodeList"]

    # Get the overall structure
    parameter_id = String[]
    parameter_name = String[]
    parameter_values = Dict()
    for param in structure
        push!(parameter_id, param["@id"])
        push!(parameter_name, param["Name"]["#text"])
        parameter_values[param["@id"]] = get_parameter_values(param)
    end
    parameter_table = DataFrame(value = parameter_id, description = parameter_name)

    datastructure = Dict("dimensions" => parameter_table,
        "values" => parameter_values)
end


function get_parameter_values(param)
    # Pull out the part that has the actual dimension information:
    # one dictionary for each paramter/dimension
    cldicts = param["Code"]
    codevals = String[]
    codedescs = String[]
    if isa(cldicts, Dict)
        push!(codevals, cldicts["@value"])
        push!(codedescs, cldicts["Description"]["#text"])
    else
        for dict in cldicts
            push!(codevals, dict["@value"])
            push!(codedescs, dict["Description"]["#text"])
        end
    end
    codelist = DataFrame(value = codevals, description = codedescs)
    return codelist
end
