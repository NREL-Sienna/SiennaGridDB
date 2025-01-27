using PowerSystems: PowerSystems
const PSY = PowerSystems

using OpenAPI: OpenAPI

function get_min_max(min_max::NamedTuple{(:min, :max),Tuple{Float64,Float64}})
    MinMax(min = min_max.min, max = min_max.max)
end

get_min_max(::Nothing) = nothing

function get_up_down(up_down::NamedTuple{(:up, :down),Tuple{Float64,Float64}})
    UpDown(up = up_down.up, down = up_down.down)
end

get_up_down(::Nothing) = nothing

function get_startup(startup::Float64)
    return ThermalGenerationCostStartUp(startup)
end

function get_startup(startup::@NamedTuple{hot::Float64, warm::Float64, cold::Float64})
    ThermalGenerationCostStartUp(
        StartUpStages(hot = startup.hot, warm = startup.warm, cold = startup.cold),
    )
end

function get_variable_cost(variable::T) where {T<:PSY.ProductionVariableCostCurve}
    error("Unsupported type $T")
end

function get_cost_value_curve(curve::T) where {T<:PSY.ValueCurve}
    error("Unsupported type $T")
end

function get_cost_value_curve(curve::PSY.InputOutputCurve)
    CostCurveValueCurve(get_input_output_curve(curve))
end

function get_cost_value_curve(curve::PSY.AverageRateCurve)
    CostCurveValueCurve(get_average_rate_curve(curve))
end

function get_cost_value_curve(curve::PSY.IncrementalCurve)
    CostCurveValueCurve(get_incremental_curve(curve))
end


function get_function_data(function_data::PSY.LinearFunctionData)
    LinearFunctionData(
        function_type = "LINEAR",
        proportional_term = function_data.proportional_term,
        constant_term = function_data.constant_term,
    )
end

function get_function_data(function_data::PSY.QuadraticFunctionData)
    QuadraticFunctionData(
        function_type = "QUADRATIC",
        quadratic_term = function_data.quadratic_term,
        proportional_term = function_data.proportional_term,
        constant_term = function_data.constant_term,
    )
end

function get_xy_coords(nt::@NamedTuple{x::Float64, y::Float64})
    PiecewiseLinearDataPointsInner(x = nt.x, y = nt.y)
end

function get_function_data(function_data::PSY.PiecewiseLinearData)
    PiecewiseLinearData(
        function_type = "PIECEWISE_LINEAR",
        points = get_xy_coords.(function_data.points),
    )
end

function get_function_data(function_data::PSY.PiecewiseStepData)
    PiecewiseStepData(
        function_type = "PIECEWISE_STEP",
        x_coords = function_data.x_coords,
        y_coords = function_data.y_coords,
    )
end

function get_input_output_curve(curve::PSY.InputOutputCurve)
    InputOutputCurve(
        curve_type = "INPUT_OUTPUT",
        function_data = InputOutputCurveFunctionData(
            get_function_data(curve.function_data),
        ),
        input_at_zero = curve.input_at_zero,
    )
end

function get_average_rate_curve(curve::PSY.AverageRateCurve)
    AverageRateCurve(
        curve_type = "AVERAGE_RATE",
        function_data = AverageRateCurveFunctionData(
            get_function_data(curve.function_data),
        ),
        initial_input = curve.initial_input,
        input_at_zero = curve.input_at_zero,
    )
end

function get_incremental_curve(curve::PSY.IncrementalCurve)
    IncrementalCurve(
        curve_type = "INCREMENTAL",
        function_data = IncrementalCurveFunctionData(
            get_function_data(curve.function_data),
        ),
        initial_input = curve.initial_input,
        input_at_zero = curve.input_at_zero,
    )
end

function get_variable_cost(variable::PSY.CostCurve)
    ProductionVariableCostCurve(
        CostCurve(
            variable_cost_type = "COST",
            value_curve = get_cost_value_curve(variable.value_curve),
            vom_cost = get_input_output_curve(variable.vom_cost),
            power_units = string(variable.power_units),
        ),
    )
end

function get_variable_cost(variable::PSY.FuelCurve)
    ProductionVariableCostCurve(
        FuelCurve(
            variable_cost_type = "FUEL",
            value_curve = get_cost_value_curve(variable.value_curve),
            power_units = string(variable.power_units),
            fuel_cost = FuelCurveFuelCost(variable.fuel_cost),
            vom_cost = get_input_output_curve(variable.vom_cost),
        ),
    )
end

function convert(cost::PSY.ThermalGenerationCost)
    ThermalGenerationCost(
        start_up = get_startup(cost.start_up),
        shut_down = cost.shut_down,
        fixed = cost.fixed,
        variable = get_variable_cost(cost.variable),
    )
end

function convert(thermal_standard::PSY.ThermalStandard)
    ThermalStandard(
        id = 1,
        name = thermal_standard.name,
        prime_mover = string(thermal_standard.prime_mover_type),
        fuel_type = string(thermal_standard.fuel),
        rating = thermal_standard.rating,
        base_power = thermal_standard.base_power,
        available = thermal_standard.available,
        status = thermal_standard.status,
        time_at_status = thermal_standard.time_at_status,
        active_power = thermal_standard.active_power,
        reactive_power = thermal_standard.reactive_power,
        active_power_limits = get_min_max(thermal_standard.active_power_limits),
        reactive_power_limits = get_min_max(thermal_standard.reactive_power_limits),
        ramp_limits = get_up_down(thermal_standard.ramp_limits),
        operation_cost = convert(thermal_standard.operation_cost),
        time_limits = get_up_down(thermal_standard.time_limits),
        must_run = thermal_standard.must_run,
        bus = 4,
    )
end
