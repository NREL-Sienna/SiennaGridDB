# This file was generated by the Julia OpenAPI Code Generator
# Do not modify this file directly. Modify the OpenAPI specification instead.


@doc raw"""DCBus

    DCBus(;
        area=nothing,
        base_voltage=nothing,
        id=nothing,
        load_zone=nothing,
        magnitude=nothing,
        name=nothing,
        number=nothing,
        voltage_limits=nothing,
    )

    - area::Int64
    - base_voltage::Float64
    - id::Int64
    - load_zone::Int64
    - magnitude::Float64
    - name::String
    - number::Float64
    - voltage_limits::MinMax
"""
Base.@kwdef mutable struct DCBus <: OpenAPI.APIModel
    area::Union{Nothing, Int64} = nothing
    base_voltage::Union{Nothing, Float64} = nothing
    id::Union{Nothing, Int64} = nothing
    load_zone::Union{Nothing, Int64} = nothing
    magnitude::Union{Nothing, Float64} = nothing
    name::Union{Nothing, String} = nothing
    number::Union{Nothing, Float64} = nothing
    voltage_limits = nothing # spec type: Union{ Nothing, MinMax }

    function DCBus(area, base_voltage, id, load_zone, magnitude, name, number, voltage_limits, )
        OpenAPI.validate_property(DCBus, Symbol("area"), area)
        OpenAPI.validate_property(DCBus, Symbol("base_voltage"), base_voltage)
        OpenAPI.validate_property(DCBus, Symbol("id"), id)
        OpenAPI.validate_property(DCBus, Symbol("load_zone"), load_zone)
        OpenAPI.validate_property(DCBus, Symbol("magnitude"), magnitude)
        OpenAPI.validate_property(DCBus, Symbol("name"), name)
        OpenAPI.validate_property(DCBus, Symbol("number"), number)
        OpenAPI.validate_property(DCBus, Symbol("voltage_limits"), voltage_limits)
        return new(area, base_voltage, id, load_zone, magnitude, name, number, voltage_limits, )
    end
end # type DCBus

const _property_types_DCBus = Dict{Symbol,String}(Symbol("area")=>"Int64", Symbol("base_voltage")=>"Float64", Symbol("id")=>"Int64", Symbol("load_zone")=>"Int64", Symbol("magnitude")=>"Float64", Symbol("name")=>"String", Symbol("number")=>"Float64", Symbol("voltage_limits")=>"MinMax", )
OpenAPI.property_type(::Type{ DCBus }, name::Symbol) = Union{Nothing,eval(Base.Meta.parse(_property_types_DCBus[name]))}

function check_required(o::DCBus)
    o.id === nothing && (return false)
    o.name === nothing && (return false)
    o.number === nothing && (return false)
    true
end

function OpenAPI.validate_property(::Type{ DCBus }, name::Symbol, val)








end
