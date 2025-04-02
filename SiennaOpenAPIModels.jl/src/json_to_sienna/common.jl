import InfrastructureSystems
const IS = InfrastructureSystems

function get_bustype_enum(bustype::String)
    if bustype == "PQ"
        return PSY.ACBusTypes.PQ
    elseif bustype == "PV"
        return PSY.ACBusTypes.PV
    elseif bustype == "REF"
        return PSY.ACBusTypes.REF
    elseif bustype == "ISOLATED"
        return PSY.ACBusTypes.ISOLATED
    elseif bustype == "SLACK"
        return PSY.ACBusTypes.SLACK
    else
        error("Unknown bus type: $bustype")
    end
end

function get_prime_mover_enum(prime_mover_type::String)
    IS.deserialize(PSY.PrimeMovers, prime_mover_type)
end

function get_fuel_type_enum(fuel_type::String)
    IS.deserialize(PSY.ThermalFuels, fuel_type)
end

get_tuple_min_max(::Nothing) = nothing

function get_tuple_min_max(obj::MinMax)
    return (min=obj.min, max=obj.max)
end

get_tuple_up_down(::Nothing) = nothing

function get_tuple_up_down(obj::UpDown)
    return (up=obj.up, down=obj.down)
end

function get_tuple_from_to(obj::FromTo)
    return (from=obj.from, to=obj.to)
end

function convert_complex_number(obj::ComplexNumber)
    Complex(obj.real, obj.imag)
end

function get_tuple_xy_coords(obj::XYCoords)
    return (x=nt.x, y=nt.y)
end

function get_sienna_thermal_cost(cost::ThermalGenerationCost)
    PSY.ThermalGenerationCost(
        start_up=get_sienna_startup(cost.start_up),
        shut_down=cost.shut_down,
        fixed=cost.fixed,
        variable=get_sienna_variable_cost(cost.variable),
    )
end

function get_sienna_renewable_cost(cost::RenewableGenerationCost)
    PSY.RenewableGenerationCost(
        curtailment_cost=get_sienna_variable_cost(cost.curtailment_cost),
        variable=get_sienna_variable_cost(cost.variable),
    )
end

function get_sienna_hydro_cost(cost::HydroGenerationCost)
    PSY.HydroGenerationCost(
        variable=get_sienna_variable_cost(cost.variable),
        fixed=cost.fixed,
    )
end

function get_sienna_startup(startup::ThermalGenerationCostStartUp)
    return startup.value
end

function get_sienna_stages(stages::StartUpStages)
    (hot=stages.hot, warm=stages.warm, cold=stages.cold)
end

function get_sienna_variable_cost(variable::ProductionVariableCostCurve)
    get_sienna_variable_cost(variable.value)
end

function get_sienna_unit_system(units::String)
    if units == "SYSTEM_BASE"
        return PSY.UnitSystem.SYSTEM_BASE
    elseif units == "DEVICE_BASE"
        return PSY.UnitSystem.DEVICE_BASE
    elseif units == "NATURAL_UNITS"
        return PSY.UnitSystem.NATURAL_UNITS
    else
        error("Unknown unit setting $units")
    end
end

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
        fuel_cost=PSY.FuelCurveFuelCost(variable.fuel_cost),
        vom_cost=get_sienna_input_output_curve(variable.vom_cost),
    )
end

function get_sienna_value_curve(curve::ValueCurve)
    get_sienna_value_curve(curve.value)
end

function get_sienna_value_curve(curve::InputOutputCurve)
    PSY.InputOutputCurve(
        function_data=get_sienna_function_data(curve.function_data),
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

function get_sienna_value_curve(curve::AverageRateCurve)
    PSY.AverageRateCurve(
        function_data=PSY.AverageRateCurveFunctionData(
            get_sienna_function_data(curve.function_data),
        ),
        initial_input=curve.initial_input,
        input_at_zero=curve.input_at_zero,
    )
end

function get_sienna_function_data(function_data::InputOutputCurveFunctionData)
    return get_sienna_function_data(function_data.value)
end

function get_sienna_function_data(function_data::LinearFunctionData)
    PSY.LinearFunctionData(
        proportional_term=function_data.proportional_term,
        constant_term=function_data.constant_term,
    )
end

function get_sienna_function_data(function_data::QuadraticFunctionData)
    PSY.QuadraticFunctionData(
        quadratic_term=function_data.quadratic_term,
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

"""
Divide both values of all NamedTuple by a scalar
"""
function divide(nt::NamedTuple{T, Tuple{Float64, Float64}}, scalar::Float64) where {T}
    NamedTuple{T, Tuple{Float64, Float64}}((nt[1] / scalar, nt[2] / scalar))
end

divide(::Nothing, ::Float64) = nothing
divide(x::Float64, scalar::Float64) = x / scalar
