function psy2openapi(thermal_standard::PSY.ThermalStandard, ids::IDGenerator)
    ThermalStandard(
        id = getid!(ids, thermal_standard),
        name = thermal_standard.name,
        prime_mover = string(thermal_standard.prime_mover_type),
        fuel_type = string(thermal_standard.fuel),
        rating = thermal_standard.rating * PSY.get_base_power(thermal_standard),
        base_power = thermal_standard.base_power,
        available = thermal_standard.available,
        status = thermal_standard.status,
        time_at_status = thermal_standard.time_at_status,
        active_power = thermal_standard.active_power * PSY.get_base_power(thermal_standard),
        reactive_power = thermal_standard.reactive_power *
                         PSY.get_base_power(thermal_standard),
        active_power_limits = get_min_max(
            scale(
                thermal_standard.active_power_limits,
                PSY.get_base_power(thermal_standard),
            ),
        ),
        reactive_power_limits = get_min_max(
            scale(
                thermal_standard.reactive_power_limits,
                PSY.get_base_power(thermal_standard),
            ),
        ),
        ramp_limits = get_up_down(
            scale(thermal_standard.ramp_limits, PSY.get_base_power(thermal_standard)),
        ),
        operation_cost = get_thermal_cost(thermal_standard.operation_cost),
        time_limits = get_up_down(thermal_standard.time_limits),
        must_run = thermal_standard.must_run,
        bus = getid!(ids, thermal_standard.bus),
    )
end

function psy2openapi(power_load::PSY.PowerLoad, ids::IDGenerator)
    PowerLoad(
        id = getid!(ids, power_load),
        name = power_load.name,
        available = power_load.available,
        bus = getid!(ids, power_load.bus),
        active_power = power_load.active_power * PSY.get_base_power(power_load),
        reactive_power = power_load.reactive_power * PSY.get_base_power(power_load),
        base_power = power_load.base_power,
        max_active_power = power_load.max_active_power * PSY.get_base_power(power_load),
        max_reactive_power = power_load.max_reactive_power * PSY.get_base_power(power_load),
        dynamic_injector = getid!(ids, power_load.dynamic_injector),
    )
end

function psy2openapi(standard_load::PSY.StandardLoad, ids::IDGenerator)
    StandardLoad(
        id = getid!(ids, standard_load),
        name = standard_load.name,
        available = standard_load.available,
        bus = getid!(ids, standard_load.bus),
        constant_active_power = standard_load.constant_active_power *
                                PSY.get_base_power(standard_load),
        constant_reactive_power = standard_load.constant_reactive_power *
                                  PSY.get_base_power(standard_load),
        impedance_active_power = standard_load.impedance_active_power *
                                 PSY.get_base_power(standard_load),
        impedance_reactive_power = standard_load.impedance_reactive_power *
                                   PSY.get_base_power(standard_load),
        current_active_power = standard_load.current_active_power *
                               PSY.get_base_power(standard_load),
        current_reactive_power = standard_load.current_reactive_power *
                                 PSY.get_base_power(standard_load),
        max_constant_active_power = standard_load.max_constant_active_power *
                                    PSY.get_base_power(standard_load),
        max_constant_reactive_power = standard_load.max_constant_reactive_power *
                                      PSY.get_base_power(standard_load),
        max_impedance_active_power = standard_load.max_impedance_active_power *
                                     PSY.get_base_power(standard_load),
        max_impedance_reactive_power = standard_load.max_impedance_reactive_power *
                                       PSY.get_base_power(standard_load),
        max_current_active_power = standard_load.max_current_active_power *
                                   PSY.get_base_power(standard_load),
        max_current_reactive_power = standard_load.max_current_reactive_power *
                                     PSY.get_base_power(standard_load),
        base_power = standard_load.base_power,
        dynamic_injector = getid!(ids, standard_load.dynamic_injector),
    )
end
