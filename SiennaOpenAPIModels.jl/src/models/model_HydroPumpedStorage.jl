# This file was generated by the Julia OpenAPI Code Generator
# Do not modify this file directly. Modify the OpenAPI specification instead.


@doc raw"""HydroPumpedStorage

    HydroPumpedStorage(;
        active_power=nothing,
        active_power_limits=nothing,
        active_power_limits_pump=nothing,
        available=nothing,
        base_power=nothing,
        bus=nothing,
        conversion_factor=1.0,
        id=nothing,
        inflow=nothing,
        initial_storage=nothing,
        name=nothing,
        outflow=nothing,
        operation_cost=nothing,
        prime_mover_type="OT",
        pump_efficiency=1.0,
        ramp_limits=nothing,
        ramp_limits_pump=nothing,
        rating=nothing,
        rating_pump=nothing,
        reactive_power=nothing,
        reactive_power_limits=nothing,
        reactive_power_limits_pump=nothing,
        status="OFF",
        storage_capacity=nothing,
        storage_target=nothing,
        time_at_status=10000.0,
        time_limits=nothing,
        time_limits_pump=nothing,
        dynamic_injector=nothing,
    )

    - active_power::Float64
    - active_power_limits::MinMax
    - active_power_limits_pump::MinMax
    - available::Bool
    - base_power::Float64
    - bus::Int64
    - conversion_factor::Float64
    - id::Int64
    - inflow::Float64
    - initial_storage::UpDown
    - name::String
    - outflow::Float64
    - operation_cost::HydroStorageGenerationCost
    - prime_mover_type::String
    - pump_efficiency::Float64
    - ramp_limits::UpDown
    - ramp_limits_pump::UpDown
    - rating::Float64
    - rating_pump::Float64
    - reactive_power::Float64
    - reactive_power_limits::MinMax
    - reactive_power_limits_pump::MinMax
    - status::String
    - storage_capacity::UpDown
    - storage_target::UpDown
    - time_at_status::Float64
    - time_limits::UpDown
    - time_limits_pump::UpDown
    - dynamic_injector::Any
"""
Base.@kwdef mutable struct HydroPumpedStorage <: OpenAPI.APIModel
    active_power::Union{Nothing, Float64} = nothing
    active_power_limits = nothing # spec type: Union{ Nothing, MinMax }
    active_power_limits_pump = nothing # spec type: Union{ Nothing, MinMax }
    available::Union{Nothing, Bool} = nothing
    base_power::Union{Nothing, Float64} = nothing
    bus::Union{Nothing, Int64} = nothing
    conversion_factor::Union{Nothing, Float64} = 1.0
    id::Union{Nothing, Int64} = nothing
    inflow::Union{Nothing, Float64} = nothing
    initial_storage = nothing # spec type: Union{ Nothing, UpDown }
    name::Union{Nothing, String} = nothing
    outflow::Union{Nothing, Float64} = nothing
    operation_cost = nothing # spec type: Union{ Nothing, HydroStorageGenerationCost }
    prime_mover_type::Union{Nothing, String} = "OT"
    pump_efficiency::Union{Nothing, Float64} = 1.0
    ramp_limits = nothing # spec type: Union{ Nothing, UpDown }
    ramp_limits_pump = nothing # spec type: Union{ Nothing, UpDown }
    rating::Union{Nothing, Float64} = nothing
    rating_pump::Union{Nothing, Float64} = nothing
    reactive_power::Union{Nothing, Float64} = nothing
    reactive_power_limits = nothing # spec type: Union{ Nothing, MinMax }
    reactive_power_limits_pump = nothing # spec type: Union{ Nothing, MinMax }
    status::Union{Nothing, String} = "OFF"
    storage_capacity = nothing # spec type: Union{ Nothing, UpDown }
    storage_target = nothing # spec type: Union{ Nothing, UpDown }
    time_at_status::Union{Nothing, Float64} = 10000.0
    time_limits = nothing # spec type: Union{ Nothing, UpDown }
    time_limits_pump = nothing # spec type: Union{ Nothing, UpDown }
    dynamic_injector::Union{Nothing, Any} = nothing

    function HydroPumpedStorage(active_power, active_power_limits, active_power_limits_pump, available, base_power, bus, conversion_factor, id, inflow, initial_storage, name, outflow, operation_cost, prime_mover_type, pump_efficiency, ramp_limits, ramp_limits_pump, rating, rating_pump, reactive_power, reactive_power_limits, reactive_power_limits_pump, status, storage_capacity, storage_target, time_at_status, time_limits, time_limits_pump, dynamic_injector, )
        OpenAPI.validate_property(HydroPumpedStorage, Symbol("active_power"), active_power)
        OpenAPI.validate_property(HydroPumpedStorage, Symbol("active_power_limits"), active_power_limits)
        OpenAPI.validate_property(HydroPumpedStorage, Symbol("active_power_limits_pump"), active_power_limits_pump)
        OpenAPI.validate_property(HydroPumpedStorage, Symbol("available"), available)
        OpenAPI.validate_property(HydroPumpedStorage, Symbol("base_power"), base_power)
        OpenAPI.validate_property(HydroPumpedStorage, Symbol("bus"), bus)
        OpenAPI.validate_property(HydroPumpedStorage, Symbol("conversion_factor"), conversion_factor)
        OpenAPI.validate_property(HydroPumpedStorage, Symbol("id"), id)
        OpenAPI.validate_property(HydroPumpedStorage, Symbol("inflow"), inflow)
        OpenAPI.validate_property(HydroPumpedStorage, Symbol("initial_storage"), initial_storage)
        OpenAPI.validate_property(HydroPumpedStorage, Symbol("name"), name)
        OpenAPI.validate_property(HydroPumpedStorage, Symbol("outflow"), outflow)
        OpenAPI.validate_property(HydroPumpedStorage, Symbol("operation_cost"), operation_cost)
        OpenAPI.validate_property(HydroPumpedStorage, Symbol("prime_mover_type"), prime_mover_type)
        OpenAPI.validate_property(HydroPumpedStorage, Symbol("pump_efficiency"), pump_efficiency)
        OpenAPI.validate_property(HydroPumpedStorage, Symbol("ramp_limits"), ramp_limits)
        OpenAPI.validate_property(HydroPumpedStorage, Symbol("ramp_limits_pump"), ramp_limits_pump)
        OpenAPI.validate_property(HydroPumpedStorage, Symbol("rating"), rating)
        OpenAPI.validate_property(HydroPumpedStorage, Symbol("rating_pump"), rating_pump)
        OpenAPI.validate_property(HydroPumpedStorage, Symbol("reactive_power"), reactive_power)
        OpenAPI.validate_property(HydroPumpedStorage, Symbol("reactive_power_limits"), reactive_power_limits)
        OpenAPI.validate_property(HydroPumpedStorage, Symbol("reactive_power_limits_pump"), reactive_power_limits_pump)
        OpenAPI.validate_property(HydroPumpedStorage, Symbol("status"), status)
        OpenAPI.validate_property(HydroPumpedStorage, Symbol("storage_capacity"), storage_capacity)
        OpenAPI.validate_property(HydroPumpedStorage, Symbol("storage_target"), storage_target)
        OpenAPI.validate_property(HydroPumpedStorage, Symbol("time_at_status"), time_at_status)
        OpenAPI.validate_property(HydroPumpedStorage, Symbol("time_limits"), time_limits)
        OpenAPI.validate_property(HydroPumpedStorage, Symbol("time_limits_pump"), time_limits_pump)
        OpenAPI.validate_property(HydroPumpedStorage, Symbol("dynamic_injector"), dynamic_injector)
        return new(active_power, active_power_limits, active_power_limits_pump, available, base_power, bus, conversion_factor, id, inflow, initial_storage, name, outflow, operation_cost, prime_mover_type, pump_efficiency, ramp_limits, ramp_limits_pump, rating, rating_pump, reactive_power, reactive_power_limits, reactive_power_limits_pump, status, storage_capacity, storage_target, time_at_status, time_limits, time_limits_pump, dynamic_injector, )
    end
end # type HydroPumpedStorage

const _property_types_HydroPumpedStorage = Dict{Symbol,String}(Symbol("active_power")=>"Float64", Symbol("active_power_limits")=>"MinMax", Symbol("active_power_limits_pump")=>"MinMax", Symbol("available")=>"Bool", Symbol("base_power")=>"Float64", Symbol("bus")=>"Int64", Symbol("conversion_factor")=>"Float64", Symbol("id")=>"Int64", Symbol("inflow")=>"Float64", Symbol("initial_storage")=>"UpDown", Symbol("name")=>"String", Symbol("outflow")=>"Float64", Symbol("operation_cost")=>"HydroStorageGenerationCost", Symbol("prime_mover_type")=>"String", Symbol("pump_efficiency")=>"Float64", Symbol("ramp_limits")=>"UpDown", Symbol("ramp_limits_pump")=>"UpDown", Symbol("rating")=>"Float64", Symbol("rating_pump")=>"Float64", Symbol("reactive_power")=>"Float64", Symbol("reactive_power_limits")=>"MinMax", Symbol("reactive_power_limits_pump")=>"MinMax", Symbol("status")=>"String", Symbol("storage_capacity")=>"UpDown", Symbol("storage_target")=>"UpDown", Symbol("time_at_status")=>"Float64", Symbol("time_limits")=>"UpDown", Symbol("time_limits_pump")=>"UpDown", Symbol("dynamic_injector")=>"Any", )
OpenAPI.property_type(::Type{ HydroPumpedStorage }, name::Symbol) = Union{Nothing,eval(Base.Meta.parse(_property_types_HydroPumpedStorage[name]))}

function check_required(o::HydroPumpedStorage)
    o.active_power === nothing && (return false)
    o.active_power_limits === nothing && (return false)
    o.active_power_limits_pump === nothing && (return false)
    o.available === nothing && (return false)
    o.base_power === nothing && (return false)
    o.bus === nothing && (return false)
    o.id === nothing && (return false)
    o.inflow === nothing && (return false)
    o.initial_storage === nothing && (return false)
    o.name === nothing && (return false)
    o.outflow === nothing && (return false)
    o.prime_mover_type === nothing && (return false)
    o.rating === nothing && (return false)
    o.rating_pump === nothing && (return false)
    o.reactive_power === nothing && (return false)
    o.storage_capacity === nothing && (return false)
    true
end

function OpenAPI.validate_property(::Type{ HydroPumpedStorage }, name::Symbol, val)














    if name === Symbol("prime_mover_type")
        OpenAPI.validate_param(name, "HydroPumpedStorage", :enum, val, ["BA", "BT", "CA", "CC", "CE", "CP", "CS", "CT", "ES", "FC", "FW", "GT", "HA", "HB", "HK", "HY", "IC", "PS", "OT", "ST", "PVe", "WT", "WS"])
    end










    if name === Symbol("status")
        OpenAPI.validate_param(name, "HydroPumpedStorage", :enum, val, ["PUMP", "GEN", "OFF"])
    end







end
