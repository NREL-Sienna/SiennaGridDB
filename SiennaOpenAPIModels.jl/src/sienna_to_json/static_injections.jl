function psy2openapi(thermal_standard::PSY.ThermalStandard, ids::IDGenerator)
    ThermalStandard(
        id = getid!(ids, thermal_standard),
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
        operation_cost = get_thermal_cost(thermal_standard.operation_cost),
        time_limits = get_up_down(thermal_standard.time_limits),
        must_run = thermal_standard.must_run,
        bus = getid!(ids, thermal_standard.bus),
    )
end
