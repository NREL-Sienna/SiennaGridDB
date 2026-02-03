import InfrastructureSystems as IS

# Functions that deserilize strings

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

get_tuple_turbine_pump(::Nothing) = nothing

function get_tuple_turbine_pump(obj::TurbinePump)
    return (turbine=obj.turbine, pump=obj.pump)
end

get_tuple_up_down(::Nothing) = nothing

function get_tuple_up_down(obj::UpDown)
    return (up=obj.up, down=obj.down)
end

get_tuple_xy_coords(::Nothing) = nothing

function get_tuple_xy_coords(obj::XYCoords)
    return (x=obj.x, y=obj.y)
end

# Functions that get operation costs

function get_sienna_operation_cost(cost::HydroGenerationCost)
    PSY.HydroGenerationCost(
        variable=get_sienna_variable_cost(cost.variable),
        fixed=cost.fixed,
    )
end

#function get_sienna_operation_cost(cost::HydroStorageGenerationCost)
#    get_sienna_operation_cost(cost.value)
#end

function get_sienna_operation_cost(cost::HydroReservoirCost)
    PSY.HydroReservoirCost(
        level_shortage_cost=cost.level_shortage_cost,
        level_surplus_cost=cost.level_surplus_cost,
        spillage_cost=cost.spillage_cost,
    )
end

function get_sienna_operation_cost(cost::ImportExportCost)
    PSY.ImportExportCost(
        import_offer_curves=get_sienna_variable_cost(cost.import_offer_curves),
        export_offer_curves=get_sienna_variable_cost(cost.export_offer_curves),
        energy_import_weekly_limit=cost.energy_import_weekly_limit,
        energy_export_weekly_limit=cost.energy_export_weekly_limit,
    )
end

function get_sienna_operation_cost(cost::LoadCost)
    PSY.LoadCost(variable=get_sienna_variable_cost(cost.variable), fixed=cost.fixed)
end

function get_sienna_operation_cost(cost::RenewableGenerationCost)
    PSY.RenewableGenerationCost(
        curtailment_cost=get_sienna_variable_cost(cost.curtailment_cost),
        variable=get_sienna_variable_cost(cost.variable),
        fixed=cost.fixed,
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

function get_sienna_operation_cost(cost::SupplyTechnologyOperationCosts)
    if cost.value.cost_type == "THERMAL"
        PSY.ThermalGenerationCost(
            start_up=get_sienna_startup(cost.value.start_up),
            shut_down=cost.value.shut_down,
            fixed=cost.value.fixed,
            variable=get_sienna_variable_cost(cost.value.variable),
        )
    elseif cost.value.cost_type == "RENEWABLE"
        PSY.RenewableGenerationCost(
            curtailment_cost=get_sienna_variable_cost(cost.value.curtailment_cost),
            variable=get_sienna_variable_cost(cost.value.variable),
            fixed=cost.value.fixed,
        )
    end
end

get_sienna_fuel_dictionary(dict::Dict{String, Float64}) =
    Dict(PSY.ThermalFuels(k) => v for (k, v) in dict)

get_sienna_fuel_dictionary(dict::Dict{String, MinMax}) =
    Dict(PSY.ThermalFuels(k) => get_tuple_min_max(v) for (k, v) in dict)

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
        power_units=PSY.UnitSystem(variable.power_units),
    )
end

function get_sienna_variable_cost(variable::FuelCurve)
    PSY.FuelCurve(
        value_curve=get_sienna_value_curve(variable.value_curve),
        power_units=PSY.UnitSystem(variable.power_units),
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

function get_sienna_value_curve(curve::Float64)
    return curve
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

function get_sienna_value_curve(curve::TwoTerminalLoss)
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

function get_sienna_technology_financial_data(financial_data::TechnologyFinancialData)
    PSIP.TechnologyFinancialData(
        capital_recovery_period=financial_data.capital_recovery_period,
        technology_base_year=financial_data.technology_base_year,
        debt_fraction=financial_data.debt_fraction,
        debt_rate=financial_data.debt_rate,
        return_on_equity=financial_data.return_on_equity,
        tax_rate=financial_data.tax_rate,
    )
end

# Resolver stuff

mutable struct Resolver
    sys::Union{PSY.System, PSIP.Portfolio}
    id2uuid::Dict{Int64, UUID}
end

function resolver_from_id_generator(
    idgen::IDGenerator,
    sys::Union{PSY.System, PSIP.Portfolio},
)
    inverted_dict = Dict()
    for (uuid, id) in idgen.uuid2int
        inverted_dict[id] = uuid
    end
    return Resolver(sys, inverted_dict)
end

function (resolve::Resolver)(id::Int64)
    if isa(resolve.sys, PSIP.Portfolio)
        return IS.get_component(resolve.sys.data, resolve.id2uuid[id])
    else
        PSY.get_component(resolve.sys, resolve.id2uuid[id])
    end
end

function (resolve::Resolver)(id::Nothing)
    nothing
end
