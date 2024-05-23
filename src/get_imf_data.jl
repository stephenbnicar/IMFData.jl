struct ImfSeries <: AbstractIMFSeries
    dataset::AbstractString
    area::AbstractString
    indicator::AbstractString
    description::AbstractString
    frequency::AbstractString
    startyear::Int
    endyear::Int
    time_format::AbstractString
    unit_mult::AbstractString
    series::DataFrame
end

function Base.show(io::IO, imf::ImfSeries)
    println(io, "IMF Data Series")
    println(io, "Database: $(imf.dataset)")
    println(io, "Area: $(imf.area)")
    println(io, "Indicator: $(imf.indicator)")
    println(io, "Description: $(imf.description)")
    println(io, "Frequency: $(imf.frequency)")
    println(io, "Time Period: $(imf.startyear) to $(imf.endyear)")
    println(io, "Data: $(size(imf.series, 1)) x $(size(imf.series, 2)) DataFrame")
end

struct ImfNotDefined <:AbstractIMFSeries
    dataset::AbstractString
    area::AbstractString
    indicator::AbstractString
    startyear::Int
    endyear::Int
end

function Base.show(io::IO, imf::ImfNotDefined)
    println(io, "IMF Data Series")
    println(io, "Database: $(imf.dataset)")
    println(io, "Area: $(imf.area)")
    println(io, "Indicator: $(imf.indicator)")
    println(io, "Time Period: $(imf.startyear) to $(imf.endyear)")
    println(io, "Note: Indicator not defined for the given area or time period")
end

struct ImfNoData <: AbstractIMFSeries
    dataset::AbstractString
    area::AbstractString
    indicator::AbstractString
    frequency::AbstractString
    startyear::Int
    endyear::Int
end

function Base.show(io::IO, imf::ImfNoData)
    println(io, "IMF Data Series")
    println(io, "Database: $(imf.dataset)")
    println(io, "Area: $(imf.area)")
    println(io, "Indicator: $(imf.indicator)")
    println(io, "Frequency: $(imf.frequency)")
    println(io, "Time Period: $(imf.startyear) to $(imf.endyear)")
    println(io, "Note: Data not available for the given frequency or time period")
end

"""
    get_imf_data(dataset::String, area::String, indicator::String, frequency::String, startyear::Int, endyear::Int)

Retrieve data for a single area-indicator pair from IFS dataset
"""
function get_imf_data(dataset::String, area::String, indicator::String, frequency::String, startyear::Int, endyear::Int)
    valid_datasets = ["IFS", "BOP"]
    if dataset ∉ valid_datasets
        error("Dataset $dataset not currently supported.")
    end

    valid_freq = ["M", "Q", "A"]
    if frequency ∉ valid_freq
        error("Frequency must be one of ", valid_freq)
    end

    if startyear > endyear
        error("startyear must be less than endyear")
    end

    method  = "CompactData"
    # dataset = "IFS"

    full_url  = join([IMFData.API_URL, method, dataset], "/")
    params    = join([frequency, area, indicator], ".")
    daterange = string("startPeriod=", startyear, "&endPeriod=", endyear)
    query     = join([full_url, params, daterange], "/", "?")

    response = get_series(query, 10)
    response_body = String(response.body)
    response_json = JSON.parse(response_body)
    dataseries = response_json["CompactData"]["DataSet"]

    if haskey(dataseries, "Series")
        out = parse_series_dict(dataset, dataseries["Series"], frequency, startyear, endyear)
    else
        out = ImfNotDefined(dataset, area, indicator, startyear, endyear)
    end

    return out
end
