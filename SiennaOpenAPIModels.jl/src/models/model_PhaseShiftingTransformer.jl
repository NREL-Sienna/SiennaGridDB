# This file was generated by the Julia OpenAPI Code Generator
# Do not modify this file directly. Modify the OpenAPI specification instead.


@doc raw"""PhaseShiftingTransformer

    PhaseShiftingTransformer(;
        active_power_flow=nothing,
        alpha=nothing,
        arc=nothing,
        available=nothing,
        id=nothing,
        name=nothing,
        phase_angle_limits=nothing,
        primary_shunt=nothing,
        r=nothing,
        rating=nothing,
        reactive_power_flow=nothing,
        tap=nothing,
        x=nothing,
    )

    - active_power_flow::Float64
    - alpha::Float64
    - arc::Int64
    - available::Bool
    - id::Int64
    - name::String
    - phase_angle_limits::MinMax
    - primary_shunt::Float64
    - r::Float64
    - rating::Float64
    - reactive_power_flow::Float64
    - tap::Float64
    - x::Float64
"""
Base.@kwdef mutable struct PhaseShiftingTransformer <: OpenAPI.APIModel
    active_power_flow::Union{Nothing, Float64} = nothing
    alpha::Union{Nothing, Float64} = nothing
    arc::Union{Nothing, Int64} = nothing
    available::Union{Nothing, Bool} = nothing
    id::Union{Nothing, Int64} = nothing
    name::Union{Nothing, String} = nothing
    phase_angle_limits = nothing # spec type: Union{ Nothing, MinMax }
    primary_shunt::Union{Nothing, Float64} = nothing
    r::Union{Nothing, Float64} = nothing
    rating::Union{Nothing, Float64} = nothing
    reactive_power_flow::Union{Nothing, Float64} = nothing
    tap::Union{Nothing, Float64} = nothing
    x::Union{Nothing, Float64} = nothing

    function PhaseShiftingTransformer(active_power_flow, alpha, arc, available, id, name, phase_angle_limits, primary_shunt, r, rating, reactive_power_flow, tap, x, )
        OpenAPI.validate_property(PhaseShiftingTransformer, Symbol("active_power_flow"), active_power_flow)
        OpenAPI.validate_property(PhaseShiftingTransformer, Symbol("alpha"), alpha)
        OpenAPI.validate_property(PhaseShiftingTransformer, Symbol("arc"), arc)
        OpenAPI.validate_property(PhaseShiftingTransformer, Symbol("available"), available)
        OpenAPI.validate_property(PhaseShiftingTransformer, Symbol("id"), id)
        OpenAPI.validate_property(PhaseShiftingTransformer, Symbol("name"), name)
        OpenAPI.validate_property(PhaseShiftingTransformer, Symbol("phase_angle_limits"), phase_angle_limits)
        OpenAPI.validate_property(PhaseShiftingTransformer, Symbol("primary_shunt"), primary_shunt)
        OpenAPI.validate_property(PhaseShiftingTransformer, Symbol("r"), r)
        OpenAPI.validate_property(PhaseShiftingTransformer, Symbol("rating"), rating)
        OpenAPI.validate_property(PhaseShiftingTransformer, Symbol("reactive_power_flow"), reactive_power_flow)
        OpenAPI.validate_property(PhaseShiftingTransformer, Symbol("tap"), tap)
        OpenAPI.validate_property(PhaseShiftingTransformer, Symbol("x"), x)
        return new(active_power_flow, alpha, arc, available, id, name, phase_angle_limits, primary_shunt, r, rating, reactive_power_flow, tap, x, )
    end
end # type PhaseShiftingTransformer

const _property_types_PhaseShiftingTransformer = Dict{Symbol,String}(Symbol("active_power_flow")=>"Float64", Symbol("alpha")=>"Float64", Symbol("arc")=>"Int64", Symbol("available")=>"Bool", Symbol("id")=>"Int64", Symbol("name")=>"String", Symbol("phase_angle_limits")=>"MinMax", Symbol("primary_shunt")=>"Float64", Symbol("r")=>"Float64", Symbol("rating")=>"Float64", Symbol("reactive_power_flow")=>"Float64", Symbol("tap")=>"Float64", Symbol("x")=>"Float64", )
OpenAPI.property_type(::Type{ PhaseShiftingTransformer }, name::Symbol) = Union{Nothing,eval(Base.Meta.parse(_property_types_PhaseShiftingTransformer[name]))}

function check_required(o::PhaseShiftingTransformer)
    o.active_power_flow === nothing && (return false)
    o.alpha === nothing && (return false)
    o.arc === nothing && (return false)
    o.available === nothing && (return false)
    o.id === nothing && (return false)
    o.name === nothing && (return false)
    o.primary_shunt === nothing && (return false)
    o.r === nothing && (return false)
    o.tap === nothing && (return false)
    o.x === nothing && (return false)
    true
end

function OpenAPI.validate_property(::Type{ PhaseShiftingTransformer }, name::Symbol, val)













end
