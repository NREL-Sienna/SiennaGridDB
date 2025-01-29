using SiennaOpenAPIModels
using OpenAPI
using PowerSystemCaseBuilder
import PowerSystems
const PSY = PowerSystems
using JSON

function jsondiff(j1::S, j2::S) where {S<:Union{String,Int64,Float64,Bool}}
    if j1 == j2
        return true
    else
        @warn "Values $j1 does not match $j2"
        return false
    end
end

function jsondiff(j1::S, j2::S) where {S}
    error("Unsuported type $S")
end

function jsondiff(j1::S, j2::T) where {S,T}
    @warn "Type $j1 :: $S does not match $j2 :: $T"
    return false
end

function jsondiff(j1::AbstractDict{K,S}, j2::AbstractDict{K,T}) where {K,S,T}
    if keys(j1) != keys(j2)
        k1_sub_k2 = setdiff(keys(j1), keys(j2))
        k2_sub_k1 = setdiff(keys(j2), keys(j1))
        @warn "Keys do not match: $k1_sub_k2 and $k2_sub_k1"
        return false
    end
    for k in keys(j1)
        jsondiff(j1[k], j2[k]) || return false
    end
    return true
end

function jsondiff(j1::AbstractArray{S}, j2::AbstractArray{T}) where {S,T}
    if length(j1) != length(j2)
        @warn "Length $j1 does not match $j2"
        return false
    end
    for k in keys(j1)
        jsondiff(j1[k], j2[k]) || return false
    end
    return true
end

function test_roundtrip(openapi_model, data)
    post_json = OpenAPI.from_json(openapi_model, JSON.parse(OpenAPI.to_json(data)))
    @test typeof(data) == typeof(post_json)
    @test data == post_json
    @test jsondiff(
        JSON.parse(OpenAPI.to_json(data)),
        JSON.parse(OpenAPI.to_json(post_json)),
    )
end

@testset "c_sys5_pjm RoundTrip to JSON" begin
    c_sys5 =
        PowerSystemCaseBuilder.build_system(PowerSystemCaseBuilder.PSISystems, "c_sys5_pjm")
    @testset "ThermalStandard to JSON" begin
        thermal_standard = PSY.get_component(PSY.ThermalStandard, c_sys5, "Solitude")

        test_convert = SiennaOpenAPIModels.psy2openapi(thermal_standard, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.ThermalStandard, test_convert)
        @test test_convert.id == 1
        @test test_convert.bus == 2
        @test test_convert.active_power == 520.0  # test units
    end
    @testset "ACBus to JSON" begin
        acbus = PSY.get_bus(c_sys5, 1)
        @test isa(acbus, PSY.ACBus)
        test_convert = SiennaOpenAPIModels.psy2openapi(acbus, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.ACBus, test_convert)
        @test test_convert.id == 1
        @test test_convert.number == 1
        @test isnothing(test_convert.area)
        @test isnothing(test_convert.load_zone)
        @test test_convert.magnitude == 1.0
    end
    @testset "Arc to JSON" begin
        arc = first(PSY.get_components(PSY.Arc, c_sys5))
        @test isa(arc, PSY.Arc)
        test_convert = SiennaOpenAPIModels.psy2openapi(arc, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.Arc, test_convert)
        @test test_convert.id == 1
        @test test_convert.from == 2
        @test test_convert.to == 3
    end
    @testset "Line to JSON" begin
        line = PSY.get_component(PSY.Line, c_sys5, "4")
        @test isa(line, PSY.Line)
        test_convert = SiennaOpenAPIModels.psy2openapi(line, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.Line, test_convert)
        @test test_convert.id == 1
        @test test_convert.arc == 2
        @test test_convert.rating == 1114.8
    end
end
