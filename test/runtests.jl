using IMFData
using Test

@testset "get datasets" begin
    ds = imf_datasets()
    @test any(occursin.("IFS", ds.value))
end

@testset "get datastructure" begin
    dstr = imf_datastructure("IFS")
    @test haskey(dstr, "dimensions")
end

@testset "get data" begin
    indic = "NGDP_SA_XDC"
    area  = "US"
    data  = get_ifs_data(area, indic, "Q", 2015, 2016)
    @test typeof(data) <: IMFSeries
end
