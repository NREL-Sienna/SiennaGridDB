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

function get_prime_mover_enum(prime_mover::String)
    if prime_mover == "BA"
        return PSY.PrimeMovers.BA
    elseif prime_mover == "BT"
        return PSY.PrimeMovers.BT
    elseif prime_mover == "CA"
        return PSY.PrimeMovers.CA
    elseif prime_mover == "CC"
        return PSY.PrimeMovers.CC
    elseif prime_mover == "CE"
        return PSY.PrimeMovers.CE
    elseif prime_mover == "CP"
        return PSY.PrimeMovers.CP
    elseif prime_mover == "CS"
        return PSY.PrimeMovers.CS
    elseif prime_mover == "CT"
        return PSY.PrimeMovers.CT
    elseif prime_mover == "ES"
        return PSY.PrimeMovers.ES
    elseif prime_mover == "FC"
        return PSY.PrimeMovers.FC
    elseif prime_mover == "FW"
        return PSY.PrimeMovers.FW
    elseif prime_mover == "GT"
        return PSY.PrimeMovers.GT
    elseif prime_mover == "HA"
        return PSY.PrimeMovers.HA
    elseif prime_mover == "HB"
        return PSY.PrimeMovers.HB
    elseif prime_mover == "HK"
        return PSY.PrimeMovers.HK
    elseif prime_mover == "HY"
        return PSY.PrimeMovers.HY
    elseif prime_mover == "IC"
        return PSY.PrimeMovers.IC
    elseif prime_mover == "PS"
        return PSY.PrimeMovers.PS
    elseif prime_mover == "OT"
        return PSY.PrimeMovers.OT
    elseif prime_mover == "ST"
        return PSY.PrimeMovers.ST
    elseif prime_mover == "PVe"
        return PSY.PrimeMovers.PVe
    elseif prime_mover == "WT"
        return PSY.PrimeMovers.WT
    elseif prime_mover == "WS"
        return PSY.PrimeMovers.WS
    else
        error("Unknown prime mover type: $(prime_mover)")
    end
end

function get_fuel_type_enum(fuel_type::String)
    if fuel_type == "COAL"
        return PSY.ThermalFuels.COAL
    elseif fuel_type == "WASTE_COAL"
        return PSY.ThermalFuels.WASTE_COAL
    elseif fuel_type == "DISTILLATE_FUEL_OIL"
        return PSY.ThermalFuels.DISTILLATE_FUEL_OIL
    elseif fuel_type == "WASTE_OIL"
        return PSY.ThermalFuels.WASTE_OIL
    elseif fuel_type == "PETROLEUM_COKE"
        return PSY.ThermalFuels.PETROLEUM_COKE
    elseif fuel_type == "RESIDUAL_FUEL_OIL"
        return PSY.ThermalFuels.RESIDUAL_FUEL_OIL
    elseif fuel_type == "NATURAL_GAS"
        return PSY.ThermalFuels.NATURAL_GAS
    elseif fuel_type == "OTHER_GAS"
        return PSY.ThermalFuels.OTHER_GAS
    elseif fuel_type == "NUCLEAR"
        return PSY.ThermalFuels.NUCLEAR
    elseif fuel_type == "AG_BIPRODUCT"
        return PSY.ThermalFuels.AG_BIPRODUCT
    elseif fuel_type == "MUNICIPAL_WASTE"
        return PSY.ThermalFuels.MUNICIPAL_WASTE
    elseif fuel_type == "WOOD_WASTE"
        return PSY.ThermalFuels.WOOD_WASTE
    elseif fuel_type == "GEOTHERMAL"
        return PSY.ThermalFuels.GEOTHERMAL
    elseif fuel_type == "OTHER"
        return PSY.ThermalFuels.OTHER
    else
        error("Unknown thermal fuel type: $(fuel_type)")
    end
end

function get_tuple_min_max(obj::MinMax)
    return (min=obj.min, max=obj.max)
end

function get_tuple_up_down(obj::UpDown)
    return (up=obj.up, down=obj.down)
end

function get_tuple_xy_coords(nt::@NamedTuple{x::Float64, y::Float64})
    PSY.XYCoords(x=nt.x, y=nt.y)
end

function get_sienna_thermal_cost(cost::ThermalGenerationCost)
    PSY.ThermalGenerationCost(
        cost_type="THERMAL",
        start_up=get_sienna_startup(cost.start_up),
        shut_down=cost.shut_down,
        fixed=cost.fixed,
        variable=PSY.ProductionVariableCostCurve(get_sienna_variable_cost(cost.variable)),
    )
end

function get_sienna_startup(startup::Float64)
    return PSY.ThermalGenerationCostStartUp(startup)
end

function get_sienna_startup(
    startup::@NamedTuple{hot::Float64, warm::Float64, cold::Float64}
)
    PSY.ThermalGenerationCostStartUp(
        PSY.StartUpStages(hot=startup.hot, warm=startup.warm, cold=startup.cold),
    )
end

function get_sienna_variable_cost(variable::CostCurve)
    PSY.CostCurve(
        variable_cost_type="COST",
        value_curve=get_sienna_value_curve(variable.value_curve),
        vom_cost=get_sienna_input_output_curve(variable.vom_cost),
        power_units=string(variable.power_units),
    )
end

function get_sienna_variable_cost(variable::FuelCurve)
    PSY.FuelCurve(
        variable_cost_type="FUEL",
        value_curve=get_sienna_value_curve(variable.value_curve),
        power_units=string(variable.power_units),
        fuel_cost=PSY.FuelCurveFuelCost(variable.fuel_cost),
        vom_cost=get_sienna_input_output_curve(variable.vom_cost),
    )
end

function get_sienna_value_curve(curve::InputOutputCurve)
    PSY.ValueCurve(get_sienna_input_output_curve(curve))
end

function get_sienna_value_curve(curve::AverageRateCurve)
    PSY.ValueCurve(get_sienna_average_rate_curve(curve))
end

function get_sienna_value_curve(curve::IncrementalCurve)
    PSY.ValueCurve(get_sienna_incremental_curve(curve))
end

function get_sienna_input_output_curve(curve::InputOutputCurve)
    PSY.InputOutputCurve(
        curve_type="INPUT_OUTPUT",
        function_data=PSY.InputOutputCurveFunctionData(
            get_sienna_function_data(curve.function_data),
        ),
        input_at_zero=curve.input_at_zero,
    )
end

function get_sienna_average_rate_curve(curve::AverageRateCurve)
    PSY.AverageRateCurve(
        curve_type="AVERAGE_RATE",
        function_data=PSY.AverageRateCurveFunctionData(
            get_sienna_function_data(curve.function_data),
        ),
        initial_input=curve.initial_input,
        input_at_zero=curve.input_at_zero,
    )
end

function get_sienna_incremental_curve(curve::IncrementalCurve)
    PSY.IncrementalCurve(
        curve_type="INCREMENTAL",
        function_data=PSY.IncrementalCurveFunctionData(
            get_sienna_function_data(curve.function_data),
        ),
        initial_input=curve.initial_input,
        input_at_zero=curve.input_at_zero,
    )
end

function get_sienna_function_data(function_data::LinearFunctionData)
    PSY.LinearFunctionData(
        function_type="LINEAR",
        proportional_term=function_data.proportional_term,
        constant_term=function_data.constant_term,
    )
end

function get_sienna_function_data(function_data::QuadraticFunctionData)
    PSY.QuadraticFunctionData(
        function_type="QUADRATIC",
        quadratic_term=function_data.quadratic_term,
        proportional_term=function_data.proportional_term,
        constant_term=function_data.constant_term,
    )
end

function get_sienna_function_data(function_data::PiecewiseLinearData)
    PSY.PiecewiseLinearData(
        function_type="PIECEWISE_LINEAR",
        points=get_tuple_xy_coords.(function_data.points),
    )
end

function get_sienna_function_data(function_data::PiecewiseStepData)
    PSY.PiecewiseStepData(
        function_type="PIECEWISE_STEP",
        x_coords=function_data.x_coords,
        y_coords=function_data.y_coords,
    )
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
