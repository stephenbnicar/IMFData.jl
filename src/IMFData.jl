module IMFData

using HTTP
using JSON
using Dates
using DataFrames
import Base.show

const API_URL = "http://dataservices.imf.org/REST/SDMX_JSON.svc"

export
    IMFSeries,
    imf_datasets,
    imf_datastructure,
    get_ifs_data


abstract type IMFSeries end

include("imf_datasets.jl")
include("imf_datastructure.jl")
include("get_ifs_data.jl")

end # module
