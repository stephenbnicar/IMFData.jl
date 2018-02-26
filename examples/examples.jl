using IMFData
using DataFrames
using DataFramesMeta
using CSV

datasets = get_imf_datasets()
# Use @where macro from DataFramesMeta to filter based on dataset name
ds_ifs = @where(datasets, contains.(:dataset_id, "IFS"))
ds_dot = @where(datasets, contains.(:dataset_id, "DOT"))

ifs_structure  = get_imf_datastructure("IFS")
# Search for GDP indicators
ifs_indicators = ifs_structure["Parameter Values"]["CL_INDICATOR_IFS"]
gdp_indicators = @where(ifs_indicators,
                 contains.(:description, "Gross Domestic Product"),
                 contains.(:description, "Domestic Currency"))
CSV.write("ifs_gdp_indicators.csv", gdp_indicators; delim='\t')

indic = "NGDP_SA_XDC"
area  = "US"
data_available = get_ifs_data(area, indic, "Q", 1947, 2016)
data_not_available = get_ifs_data(area, indic, "M", 2000, 2015)
data_not_defined = get_ifs_data(area, "NGDP_SA", "Q", 2000, 2005)
