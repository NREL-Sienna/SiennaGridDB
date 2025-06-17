import InfrastructureSystems

function (::InfrastructureSystems.FunctionData)(x)
    error("Function data has no function implementation")
end

function check_input_on_bounds(x_coords, x)
    if x < first(x_coords) || x > last(x_coords)
        throw(DomainError(x, "Limited to [$(first(x_coords)), $(last(x_coords))]"))
    end
end

function (psd::InfrastructureSystems.PiecewiseStepData)(x::T) where {T}
    if isapprox(x, zero(T))
        return zero(T)
    end
    breakpoints = InfrastructureSystems.get_x_coords(psd)
    slopes = InfrastructureSystems.get_y_coords(psd)

    check_input_on_bounds(breakpoints, x)
    i_leq = findlast(<=(x), breakpoints)
    value_up_to =
        sum(slopes[1:(i_leq - 1)] .* (breakpoints[2:i_leq] .- breakpoints[1:(i_leq - 1)]))
    if x > breakpoints[i_leq]
        value_up_to += slopes[i_leq] * (x - breakpoints[i_leq])
    end
    return value_up_to
end

function (lfd::InfrastructureSystems.LinearFunctionData)(x)
    return InfrastructureSystems.get_proportional_term(lfd) * x +
           InfrastructureSystems.get_constant_term(lfd)
end

function (qfd::InfrastructureSystems.QuadraticFunctionData)(x)
    return InfrastructureSystems.get_quadratic_term(qfd) * x^2 +
           InfrastructureSystems.get_proportional_term(qfd) * x +
           InfrastructureSystems.get_constant_term(qfd)
end

function (pld::InfrastructureSystems.PiecewiseLinearData)(x)
    points = InfrastructureSystems.get_points(pld)
    x_coords = [p.x for p in points]
    y_coords = [p.y for p in points]

    check_input_on_bounds(x_coords, x)
    idx = findlast(<=(x), x_coords)
    if idx == length(x_coords)
        return last(y_coords)
    end
    # Technically this assert should never be run since we use findlast
    @assert x_coords[idx + 1] != x_coords[idx] "X coordinates cannot be equal"
    t = (x - x_coords[idx]) / (x_coords[idx + 1] - x_coords[idx])
    return (1 - t) * y_coords[idx] + t * y_coords[idx + 1]
end

function (valuecurve::InfrastructureSystems.ValueCurve)(x)
    error("Value curve does not have function application defined!")
end

function (iocurve::InfrastructureSystems.InputOutputCurve)(x)
    iocurve.function_data(x)
end

function (average::InfrastructureSystems.AverageRateCurve)(x)
    average.function_data(x) * x
end

function (incrementalcurve::InfrastructureSystems.IncrementalCurve)(x)
    incrementalcurve.function_data(x)
end
