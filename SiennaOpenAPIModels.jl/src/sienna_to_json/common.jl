import UUIDs: UUID

function get_min_max(min_max::NamedTuple{(:min, :max), Tuple{Float64, Float64}})
    MinMax(min=min_max.min, max=min_max.max)
end

get_min_max(::Nothing) = nothing

function get_up_down(up_down::NamedTuple{(:up, :down), Tuple{Float64, Float64}})
    UpDown(up=up_down.up, down=up_down.down)
end

get_up_down(::Nothing) = nothing

function get_from_to(from_to::NamedTuple{(:from, :to), Tuple{Float64, Float64}})
    FromTo(from=from_to.from, to=from_to.to)
end

function get_startup(startup::Float64)
    return ThermalGenerationCostStartUp(startup)
end

function get_startup(startup::@NamedTuple{hot::Float64, warm::Float64, cold::Float64})
    ThermalGenerationCostStartUp(
        StartUpStages(hot=startup.hot, warm=startup.warm, cold=startup.cold),
    )
end

function get_variable_cost(variable::T) where {T <: PSY.ProductionVariableCostCurve}
    error("Unsupported type $T")
end

function get_value_curve(curve::T) where {T <: PSY.ValueCurve}
    error("Unsupported type $T")
end

function get_value_curve(curve::PSY.InputOutputCurve)
    ValueCurve(get_input_output_curve(curve))
end

function get_value_curve(curve::PSY.AverageRateCurve)
    ValueCurve(get_average_rate_curve(curve))
end

function get_value_curve(curve::PSY.IncrementalCurve)
    ValueCurve(get_incremental_curve(curve))
end

function get_function_data(function_data::PSY.LinearFunctionData)
    LinearFunctionData(
        function_type="LINEAR",
        proportional_term=function_data.proportional_term,
        constant_term=function_data.constant_term,
    )
end

function get_function_data(function_data::PSY.QuadraticFunctionData)
    QuadraticFunctionData(
        function_type="QUADRATIC",
        quadratic_term=function_data.quadratic_term,
        proportional_term=function_data.proportional_term,
        constant_term=function_data.constant_term,
    )
end

function get_xy_coords(nt::@NamedTuple{x::Float64, y::Float64})
    XYCoords(x=nt.x, y=nt.y)
end

function get_function_data(function_data::PSY.PiecewiseLinearData)
    PiecewiseLinearData(
        function_type="PIECEWISE_LINEAR",
        points=get_xy_coords.(function_data.points),
    )
end

function get_function_data(function_data::PSY.PiecewiseStepData)
    PiecewiseStepData(
        function_type="PIECEWISE_STEP",
        x_coords=function_data.x_coords,
        y_coords=function_data.y_coords,
    )
end

function get_input_output_curve(curve::PSY.InputOutputCurve)
    InputOutputCurve(
        curve_type="INPUT_OUTPUT",
        function_data=InputOutputCurveFunctionData(get_function_data(curve.function_data)),
        input_at_zero=curve.input_at_zero,
    )
end

function get_average_rate_curve(curve::PSY.AverageRateCurve)
    AverageRateCurve(
        curve_type="AVERAGE_RATE",
        function_data=AverageRateCurveFunctionData(get_function_data(curve.function_data)),
        initial_input=curve.initial_input,
        input_at_zero=curve.input_at_zero,
    )
end

function get_incremental_curve(curve::PSY.IncrementalCurve)
    IncrementalCurve(
        curve_type="INCREMENTAL",
        function_data=IncrementalCurveFunctionData(get_function_data(curve.function_data)),
        initial_input=curve.initial_input,
        input_at_zero=curve.input_at_zero,
    )
end

function get_variable_cost(variable::PSY.CostCurve)
    CostCurve(
        variable_cost_type="COST",
        value_curve=get_value_curve(variable.value_curve),
        vom_cost=get_input_output_curve(variable.vom_cost),
        power_units=string(variable.power_units),
    )
end

function get_variable_cost(variable::PSY.FuelCurve)
    FuelCurve(
        variable_cost_type="FUEL",
        value_curve=get_value_curve(variable.value_curve),
        power_units=string(variable.power_units),
        fuel_cost=FuelCurveFuelCost(variable.fuel_cost),
        vom_cost=get_input_output_curve(variable.vom_cost),
    )
end

function get_thermal_cost(cost::PSY.ThermalGenerationCost)
    ThermalGenerationCost(
        start_up=get_startup(cost.start_up),
        shut_down=cost.shut_down,
        fixed=cost.fixed,
        variable=ProductionVariableCostCurve(get_variable_cost(cost.variable)),
    )
end

function get_renewable_cost(cost::PSY.RenewableGenerationCost)
    RenewableGenerationCost(
        curtailment_cost=get_variable_cost(cost.curtailment_cost),
        variable=get_variable_cost(cost.variable),
    )
end

mutable struct IDGenerator
    nextid::Int64
    uuid2int::Dict{UUID, Int64}
end

function IDGenerator(nextid=1)
    IDGenerator(nextid, Dict{UUID, Int64}())
end

"""
Get id from the id generator. If the UUID/Component is not in the dictionary, add it
and increments internal id counter.
"""
function getid!(idgen::IDGenerator, uuid::UUID)
    if haskey(idgen.uuid2int, uuid)
        return idgen.uuid2int[uuid]
    else
        idgen.uuid2int[uuid] = idgen.nextid
        idgen.nextid += 1
        return idgen.uuid2int[uuid]
    end
end

function getid!(idgen::IDGenerator, component::PSY.Component)
    getid!(idgen, PSY.InfrastructureSystems.get_uuid(component))
end

function getid!(::IDGenerator, ::Nothing)
    nothing
end

"""
Multiply both values of all NamedTuple by a scalar
"""
function scale(nt::NamedTuple{T, Tuple{Float64, Float64}}, scalar::Float64) where {T}
    NamedTuple{T, Tuple{Float64, Float64}}((nt[1] * scalar, nt[2] * scalar))
end

scale(::Nothing, ::Float64) = nothing
