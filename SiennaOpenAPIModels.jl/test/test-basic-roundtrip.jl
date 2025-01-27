using SiennaOpenAPIModels
using OpenAPI: OpenAPI
using PowerSystemCaseBuilder: PowerSystemCaseBuilder
using PowerSystems: PowerSystems
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

@testset "c_sys5_pjm ThermalStandard to JSON" begin
    sys =
        PowerSystemCaseBuilder.build_system(PowerSystemCaseBuilder.PSISystems, "c_sys5_pjm")

    thermal_standard = PSY.get_component(PSY.ThermalStandard, sys, "Solitude")

    test_convert = SiennaOpenAPIModels.convert(thermal_standard)
    post_json = OpenAPI.from_json(
        SiennaOpenAPIModels.ThermalStandard,
        JSON.parse(OpenAPI.to_json(test_convert)),
    )
    @test typeof(test_convert) == typeof(post_json)
    @test jsondiff(
        JSON.parse(OpenAPI.to_json(test_convert)),
        JSON.parse(OpenAPI.to_json(post_json)),
    )
    @test test_convert == post_json
end
