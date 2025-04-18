# This file was generated by the Julia OpenAPI Code Generator
# Do not modify this file directly. Modify the OpenAPI specification instead.


@doc raw"""HydroDispatch

    HydroDispatch(;
        active_power=nothing,
        active_power_limits=nothing,
        available=nothing,
        base_power=nothing,
        bus=nothing,
        id=nothing,
        name=nothing,
        operation_cost=nothing,
        prime_mover_type="OT",
        ramp_limits=nothing,
        rating=nothing,
        reactive_power=nothing,
        reactive_power_limits=nothing,
        time_limits=nothing,
        dynamic_injector=nothing,
    )

    - active_power::Float64
    - active_power_limits::MinMax
    - available::Bool
    - base_power::Float64
    - bus::Int64
    - id::Int64
    - name::String
    - operation_cost::HydroGenerationCost
    - prime_mover_type::String
    - ramp_limits::UpDown
    - rating::Float64
    - reactive_power::Float64
    - reactive_power_limits::MinMax
    - time_limits::UpDown
    - dynamic_injector::Any
"""
Base.@kwdef mutable struct HydroDispatch <: OpenAPI.APIModel
    active_power::Union{Nothing, Float64} = nothing
    active_power_limits = nothing # spec type: Union{ Nothing, MinMax }
    available::Union{Nothing, Bool} = nothing
    base_power::Union{Nothing, Float64} = nothing
    bus::Union{Nothing, Int64} = nothing
    id::Union{Nothing, Int64} = nothing
    name::Union{Nothing, String} = nothing
    operation_cost = nothing # spec type: Union{ Nothing, HydroGenerationCost }
    prime_mover_type::Union{Nothing, String} = "OT"
    ramp_limits = nothing # spec type: Union{ Nothing, UpDown }
    rating::Union{Nothing, Float64} = nothing
    reactive_power::Union{Nothing, Float64} = nothing
    reactive_power_limits = nothing # spec type: Union{ Nothing, MinMax }
    time_limits = nothing # spec type: Union{ Nothing, UpDown }
    dynamic_injector::Union{Nothing, Any} = nothing

    function HydroDispatch(active_power, active_power_limits, available, base_power, bus, id, name, operation_cost, prime_mover_type, ramp_limits, rating, reactive_power, reactive_power_limits, time_limits, dynamic_injector, )
        OpenAPI.validate_property(HydroDispatch, Symbol("active_power"), active_power)
        OpenAPI.validate_property(HydroDispatch, Symbol("active_power_limits"), active_power_limits)
        OpenAPI.validate_property(HydroDispatch, Symbol("available"), available)
        OpenAPI.validate_property(HydroDispatch, Symbol("base_power"), base_power)
        OpenAPI.validate_property(HydroDispatch, Symbol("bus"), bus)
        OpenAPI.validate_property(HydroDispatch, Symbol("id"), id)
        OpenAPI.validate_property(HydroDispatch, Symbol("name"), name)
        OpenAPI.validate_property(HydroDispatch, Symbol("operation_cost"), operation_cost)
        OpenAPI.validate_property(HydroDispatch, Symbol("prime_mover_type"), prime_mover_type)
        OpenAPI.validate_property(HydroDispatch, Symbol("ramp_limits"), ramp_limits)
        OpenAPI.validate_property(HydroDispatch, Symbol("rating"), rating)
        OpenAPI.validate_property(HydroDispatch, Symbol("reactive_power"), reactive_power)
        OpenAPI.validate_property(HydroDispatch, Symbol("reactive_power_limits"), reactive_power_limits)
        OpenAPI.validate_property(HydroDispatch, Symbol("time_limits"), time_limits)
        OpenAPI.validate_property(HydroDispatch, Symbol("dynamic_injector"), dynamic_injector)
        return new(active_power, active_power_limits, available, base_power, bus, id, name, operation_cost, prime_mover_type, ramp_limits, rating, reactive_power, reactive_power_limits, time_limits, dynamic_injector, )
    end
end # type HydroDispatch

const _property_types_HydroDispatch = Dict{Symbol,String}(Symbol("active_power")=>"Float64", Symbol("active_power_limits")=>"MinMax", Symbol("available")=>"Bool", Symbol("base_power")=>"Float64", Symbol("bus")=>"Int64", Symbol("id")=>"Int64", Symbol("name")=>"String", Symbol("operation_cost")=>"HydroGenerationCost", Symbol("prime_mover_type")=>"String", Symbol("ramp_limits")=>"UpDown", Symbol("rating")=>"Float64", Symbol("reactive_power")=>"Float64", Symbol("reactive_power_limits")=>"MinMax", Symbol("time_limits")=>"UpDown", Symbol("dynamic_injector")=>"Any", )
OpenAPI.property_type(::Type{ HydroDispatch }, name::Symbol) = Union{Nothing,eval(Base.Meta.parse(_property_types_HydroDispatch[name]))}

function check_required(o::HydroDispatch)
    o.active_power === nothing && (return false)
    o.active_power_limits === nothing && (return false)
    o.available === nothing && (return false)
    o.base_power === nothing && (return false)
    o.bus === nothing && (return false)
    o.id === nothing && (return false)
    o.name === nothing && (return false)
    o.prime_mover_type === nothing && (return false)
    o.rating === nothing && (return false)
    o.reactive_power === nothing && (return false)
    true
end

function OpenAPI.validate_property(::Type{ HydroDispatch }, name::Symbol, val)









    if name === Symbol("prime_mover_type")
        OpenAPI.validate_param(name, "HydroDispatch", :enum, val, ["BA", "BT", "CA", "CC", "CE", "CP", "CS", "CT", "ES", "FC", "FW", "GT", "HA", "HB", "HK", "HY", "IC", "PS", "OT", "ST", "PVe", "WT", "WS"])
    end







end
