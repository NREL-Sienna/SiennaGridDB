import InfrastructureSystems
const IS = InfrastructureSystems

# Functions that deserilize strings

function get_bustype_enum(bustype::String)
    IS.deserialize(PSY.ACBusTypes, bustype)
end

function get_fuel_type_enum(fuel_type::String)
    IS.deserialize(PSY.ThermalFuels, fuel_type)
end

function get_prime_mover_enum(prime_mover_type::String)
    IS.deserialize(PSY.PrimeMovers, prime_mover_type)
end

function get_pump_status_enum(status::String)
    IS.deserialize(PSY.PumpHydroStatus, status)
end

function get_reserve_enum(direction::String)
    if direction == "UP"
        return PSY.ReserveUp
    elseif direction == "DOWN"
        return PSY.ReserveDown
    elseif direction == "SYMMETRIC"
        return PSY.ReserveSymmetric
    else
        error("Unsupported Reserve Direction: $(direction)")
    end
end

function get_sienna_unit_system(units::String)
    IS.deserialize(PSY.UnitSystem, units)
end

function get_storage_tech_enum(storage::String)
    IS.deserialize(PSY.StorageTech, storage)
end

# Functions that convert and scale tuples

function get_julia_complex(obj::ComplexNumber)
    Complex(obj.real, obj.imag)
end

function get_tuple_from_to(obj::FromTo)
    return (from=obj.from, to=obj.to)
end

function get_tuple_fromto_tofrom(obj::FromToToFrom)
    return (from_to=obj.from_to, to_from=obj.to_from)
end

get_tuple_in_out(::Nothing) = nothing

function get_tuple_in_out(obj::InOut)
    return (in=obj.in, out=obj.out)
end

get_tuple_min_max(::Nothing) = nothing

function get_tuple_min_max(obj::MinMax)
    return (min=obj.min, max=obj.max)
end

get_tuple_startup_shutdown(::Nothing) = nothing

function get_tuple_startup_shutdown(obj::StartUpShutDown)
    return (startup=obj.startup, shutdown=obj.shutdown)
end

get_tuple_up_down(::Nothing) = nothing

function get_tuple_up_down(obj::UpDown)
    return (up=obj.up, down=obj.down)
end

get_tuple_xy_coords(::Nothing) = nothing

function get_tuple_xy_coords(obj::XYCoords)
    return (x=obj.x, y=obj.y)
end

"""
Divide both values of all NamedTuple by a scalar
"""
function divide(nt::NamedTuple{T, Tuple{Float64, Float64}}, scalar::Float64) where {T}
    NamedTuple{T, Tuple{Float64, Float64}}((nt[1] / scalar, nt[2] / scalar))
end

divide(::Nothing, ::Float64) = nothing
divide(x::Float64, scalar::Float64) = x / scalar

# Functions that get operation costs

function get_sienna_operation_cost(cost::HydroGenerationCost)
    PSY.HydroGenerationCost(
        variable=get_sienna_variable_cost(cost.variable),
        fixed=cost.fixed,
    )
end

function get_sienna_operation_cost(cost::HydroStorageGenerationCost)
    get_sienna_operation_cost(cost.value)
end

function get_sienna_operation_cost(cost::LoadCost)
    PSY.LoadCost(variable=get_sienna_variable_cost(cost.variable), fixed=cost.fixed)
end

function get_sienna_operation_cost(cost::RenewableGenerationCost)
    PSY.RenewableGenerationCost(
        curtailment_cost=get_sienna_variable_cost(cost.curtailment_cost),
        variable=get_sienna_variable_cost(cost.variable),
    )
end

function get_sienna_operation_cost(cost::StorageCost)
    PSY.StorageCost(
        charge_variable_cost=get_sienna_variable_cost(cost.charge_variable_cost),
        discharge_variable_cost=get_sienna_variable_cost(cost.discharge_variable_cost),
        fixed=cost.fixed,
        shut_down=cost.shut_down,
        start_up=get_sienna_startup(cost.start_up),
        energy_shortage_cost=cost.energy_shortage_cost,
        energy_surplus_cost=cost.energy_surplus_cost,
    )
end

function get_sienna_operation_cost(cost::ThermalGenerationCost)
    PSY.ThermalGenerationCost(
        start_up=get_sienna_startup(cost.start_up),
        shut_down=cost.shut_down,
        fixed=cost.fixed,
        variable=get_sienna_variable_cost(cost.variable),
    )
end

# Getter functions used within the operation cost getters, including startups,
# variable costs, value curves, and function data

get_sienna_startup(::Nothing) = nothing

function get_sienna_startup(startup::Float64)
    return startup
end

function get_sienna_startup(stages::StartUpStages)
    (hot=stages.hot, warm=stages.warm, cold=stages.cold)
end

function get_sienna_startup(startup::StorageCostStartUp)
    get_sienna_startup(startup.value)
end

function get_sienna_startup(startup::StorageCostStartUpOneOf)
    (charge=startup.charge, discharge=startup.discharge)
end

function get_sienna_startup(startup::ThermalGenerationCostStartUp)
    get_sienna_startup(startup.value)
end

get_sienna_variable_cost(::Nothing) = nothing

function get_sienna_variable_cost(variable::CostCurve)
    PSY.CostCurve(
        value_curve=get_sienna_value_curve(variable.value_curve),
        vom_cost=get_sienna_value_curve(variable.vom_cost),
        power_units=get_sienna_unit_system(variable.power_units),
    )
end

function get_sienna_variable_cost(variable::FuelCurve)
    PSY.FuelCurve(
        value_curve=get_sienna_value_curve(variable.value_curve),
        power_units=get_sienna_unit_system(variable.power_units),
        fuel_cost=get_sienna_variable_cost(variable.fuel_cost),
        vom_cost=get_sienna_value_curve(variable.vom_cost),
    )
end

function get_sienna_variable_cost(variable::FuelCurveFuelCost)
    return variable.value
end

function get_sienna_variable_cost(variable::ProductionVariableCostCurve)
    get_sienna_variable_cost(variable.value)
end

get_sienna_value_curve(::Nothing) = nothing

function get_sienna_value_curve(curve::AverageRateCurve)
    PSY.AverageRateCurve(
        function_data=PSY.AverageRateCurveFunctionData(
            get_sienna_function_data(curve.function_data),
        ),
        initial_input=curve.initial_input,
        input_at_zero=curve.input_at_zero,
    )
end

function get_sienna_value_curve(curve::IncrementalCurve)
    PSY.IncrementalCurve(
        function_data=get_sienna_function_data(curve.function_data),
        initial_input=curve.initial_input,
        input_at_zero=curve.input_at_zero,
    )
end

function get_sienna_value_curve(curve::InputOutputCurve)
    PSY.InputOutputCurve(
        function_data=get_sienna_function_data(curve.function_data),
        input_at_zero=curve.input_at_zero,
    )
end

function get_sienna_value_curve(curve::TwoTerminalGenericHVDCLineLoss)
    get_sienna_value_curve(curve.value)
end

function get_sienna_value_curve(curve::ValueCurve)
    get_sienna_value_curve(curve.value)
end

get_sienna_function_data(::Nothing) = nothing

function get_sienna_function_data(function_data::AverageRateCurveFunctionData)
    get_sienna_function_data(function_data.value)
end

function get_sienna_function_data(function_data::IncrementalCurveFunctionData)
    get_sienna_function_data(function_data.value)
end

function get_sienna_function_data(function_data::InputOutputCurveFunctionData)
    get_sienna_function_data(function_data.value)
end

function get_sienna_function_data(function_data::LinearFunctionData)
    PSY.LinearFunctionData(
        proportional_term=function_data.proportional_term,
        constant_term=function_data.constant_term,
    )
end

function get_sienna_function_data(function_data::PiecewiseLinearData)
    PSY.PiecewiseLinearData(points=get_tuple_xy_coords.(function_data.points))
end

function get_sienna_function_data(function_data::PiecewiseStepData)
    PSY.PiecewiseStepData(x_coords=function_data.x_coords, y_coords=function_data.y_coords)
end

function get_sienna_function_data(function_data::QuadraticFunctionData)
    PSY.QuadraticFunctionData(
        quadratic_term=function_data.quadratic_term,
        proportional_term=function_data.proportional_term,
        constant_term=function_data.constant_term,
    )
end

# Resolver stuff

mutable struct Resolver
    sys::PSY.System
    id2uuid::Dict{Int64, UUID}
end

function resolver_from_id_generator(idgen::IDGenerator, sys::PSY.System)
    inverted_dict = Dict()
    for (uuid, id) in idgen.uuid2int
        inverted_dict[id] = uuid
    end
    return Resolver(sys, inverted_dict)
end

function (resolve::Resolver)(id::Int64)
    PSY.get_component(resolve.sys, resolve.id2uuid[id])
end

function (resolve::Resolver)(id::Nothing)
    nothing
end
