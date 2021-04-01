"""
    imf_datasets() -> `DataFrame`

Return the list of datasets that are accessible from the IMF API, along with their dataset IDs, as a `DataFrame`.
"""
function imf_datasets()
    # Get list of datasets and IDs
    api_method = "/Dataflow"
    query = string(API_URL, api_method)
    response = HTTP.get(query)
    if response.status != 200
        error("Invalid request")
    end
    response_body = String(response.body)
    response_json = JSON.parse(response_body)

    dsets_dicts = response_json["Structure"]["Dataflows"]["Dataflow"]
    dbid = String[]
    dbname = String[]
    for dict in dsets_dicts
        push!(dbid, dict["KeyFamilyRef"]["KeyFamilyID"])
        push!(dbname, dict["Name"]["#text"])
    end
    datasets = DataFrame(value = dbid, description = dbname)
    sort!(datasets, [:value])

    return datasets
end
