function psy2openapi(thermal_standard::PSY.ThermalStandard, ids::IDGenerator)
    ThermalStandard(
        id=getid!(ids, thermal_standard),
        name=thermal_standard.name,
        prime_mover=string(thermal_standard.prime_mover_type),
        fuel_type=string(thermal_standard.fuel),
        rating=thermal_standard.rating * PSY.get_base_power(thermal_standard),
        base_power=thermal_standard.base_power,
        available=thermal_standard.available,
        status=thermal_standard.status,
        time_at_status=thermal_standard.time_at_status,
        active_power=thermal_standard.active_power * PSY.get_base_power(thermal_standard),
        reactive_power=thermal_standard.reactive_power *
                       PSY.get_base_power(thermal_standard),
        active_power_limits=get_min_max(
            scale(
                thermal_standard.active_power_limits,
                PSY.get_base_power(thermal_standard),
            ),
        ),
        reactive_power_limits=get_min_max(
            scale(
                thermal_standard.reactive_power_limits,
                PSY.get_base_power(thermal_standard),
            ),
        ),
        ramp_limits=get_up_down(
            scale(thermal_standard.ramp_limits, PSY.get_base_power(thermal_standard)),
        ),
        operation_cost=get_thermal_cost(thermal_standard.operation_cost),
        time_limits=get_up_down(thermal_standard.time_limits),
        must_run=thermal_standard.must_run,
        bus=getid!(ids, thermal_standard.bus),
    )
end

function psy2openapi(power_load::PSY.PowerLoad, ids::IDGenerator)
    PowerLoad(
        id=getid!(ids, power_load),
        name=power_load.name,
        available=power_load.available,
        bus=getid!(ids, power_load.bus),
        active_power=power_load.active_power * PSY.get_base_power(power_load),
        reactive_power=power_load.reactive_power * PSY.get_base_power(power_load),
        base_power=power_load.base_power,
        max_active_power=power_load.max_active_power * PSY.get_base_power(power_load),
        max_reactive_power=power_load.max_reactive_power * PSY.get_base_power(power_load),
        dynamic_injector=getid!(ids, power_load.dynamic_injector),
    )
end

function psy2openapi(standard_load::PSY.StandardLoad, ids::IDGenerator)
    StandardLoad(
        id=getid!(ids, standard_load),
        name=standard_load.name,
        available=standard_load.available,
        bus=getid!(ids, standard_load.bus),
        constant_active_power=standard_load.constant_active_power *
                              PSY.get_base_power(standard_load),
        constant_reactive_power=standard_load.constant_reactive_power *
                                PSY.get_base_power(standard_load),
        impedance_active_power=standard_load.impedance_active_power *
                               PSY.get_base_power(standard_load),
        impedance_reactive_power=standard_load.impedance_reactive_power *
                                 PSY.get_base_power(standard_load),
        current_active_power=standard_load.current_active_power *
                             PSY.get_base_power(standard_load),
        current_reactive_power=standard_load.current_reactive_power *
                               PSY.get_base_power(standard_load),
        max_constant_active_power=standard_load.max_constant_active_power *
                                  PSY.get_base_power(standard_load),
        max_constant_reactive_power=standard_load.max_constant_reactive_power *
                                    PSY.get_base_power(standard_load),
        max_impedance_active_power=standard_load.max_impedance_active_power *
                                   PSY.get_base_power(standard_load),
        max_impedance_reactive_power=standard_load.max_impedance_reactive_power *
                                     PSY.get_base_power(standard_load),
        max_current_active_power=standard_load.max_current_active_power *
                                 PSY.get_base_power(standard_load),
        max_current_reactive_power=standard_load.max_current_reactive_power *
                                   PSY.get_base_power(standard_load),
        base_power=standard_load.base_power,
        dynamic_injector=getid!(ids, standard_load.dynamic_injector),
    )
end

function psy2openapi(renewable::PSY.RenewableDispatch, ids::IDGenerator)
    RenewableDispatch(
        id=getid!(ids, renewable),
        name=renewable.name,
        available=renewable.available,
        bus=getid!(ids, renewable.bus),
        active_power=renewable.active_power * PSY.get_base_power(renewable),
        reactive_power=renewable.reactive_power * PSY.get_base_power(renewable),
        rating=renewable.rating * PSY.get_base_power(renewable),
        prime_mover_type=string(renewable.prime_mover_type),
        reactive_power_limits=get_min_max(
            scale(renewable.reactive_power_limits, PSY.get_base_power(renewable)),
        ),
        power_factor=renewable.power_factor,
        operation_cost=get_renewable_cost(renewable.operation_cost),
        base_power=renewable.base_power,
        dynamic_injector=getid!(ids, renewable.dynamic_injector),
    )
end

function psy2openapi(renewnondispatch::PSY.RenewableNonDispatch, ids::IDGenerator)
    RenewableNonDispatch(
        id=getid!(ids, renewnondispatch),
        name=renewnondispatch.name,
        available=renewnondispatch.available,
        bus=getid!(ids, renewnondispatch.bus),
        active_power=renewnondispatch.active_power * PSY.get_base_power(renewnondispatch),
        reactive_power=renewnondispatch.reactive_power *
                       PSY.get_base_power(renewnondispatch),
        rating=renewnondispatch.rating * PSY.get_base_power(renewnondispatch),
        prime_mover_type=string(renewnondispatch.prime_mover_type),
        power_factor=renewnondispatch.power_factor,
        base_power=renewnondispatch.base_power,
        dynamic_injector=getid!(ids, renewnondispatch.dynamic_injector),
    )
end

function psy2openapi(fixedadmit::PSY.FixedAdmittance, ids::IDGenerator)
    FixedAdmittance(
        id=getid!(ids, fixedadmit),
        name=fixedadmit.name,
        available=fixedadmit.available,
        bus=getid!(ids, fixedadmit.bus),
        Y=get_complex_number(fixedadmit.Y),
        dynamic_injector=getid!(ids, fixedadmit.dynamic_injector),
    )
end

function psy2openapi(hydro::PSY.HydroDispatch, ids::IDGenerator)
    HydroDispatch(
        id=getid!(ids, hydro),
        name=hydro.name,
        available=hydro.available,
        bus=getid!(ids, hydro.bus),
        active_power=hydro.active_power * PSY.get_base_power(hydro),
        reactive_power=hydro.reactive_power * PSY.get_base_power(hydro),
        active_power_limits=get_min_max(
            scale(hydro.active_power_limits, PSY.get_base_power(hydro)),
        ),
        reactive_power_limits=get_min_max(
            scale(hydro.reactive_power_limits, PSY.get_base_power(hydro)),
        ),
        prime_mover_type=string(hydro.prime_mover_type),
        ramp_limits=get_up_down(scale(hydro.ramp_limits, PSY.get_base_power(hydro))),
        operation_cost=get_hydro_cost(hydro.operation_cost),
        rating=hydro.rating * PSY.get_base_power(hydro),
        base_power=hydro.base_power,
        time_limits=get_up_down(hydro.time_limits),
        dynamic_injector=getid!(ids, hydro.dynamic_injector),
    )
end

function psy2openapi(hydro::PSY.HydroPumpedStorage, ids::IDGenerator)
    HydroPumpedStorage(
        id=getid!(ids, hydro),
        name=hydro.name,
        available=hydro.available,
        bus=getid!(ids, hydro.bus),
        active_power=hydro.active_power * PSY.get_base_power(hydro),
        reactive_power=hydro.reactive_power * PSY.get_base_power(hydro),
        rating=hydro.rating * PSY.get_base_power(hydro),
        base_power=hydro.base_power,
        prime_mover_type=string(hydro.prime_mover_type),
        active_power_limits=get_min_max(
            scale(hydro.active_power_limits, PSY.get_base_power(hydro)),
        ),
        reactive_power_limits=get_min_max(
            scale(hydro.reactive_power_limits, PSY.get_base_power(hydro)),
        ),
        ramp_limits=get_up_down(scale(hydro.ramp_limits, PSY.get_base_power(hydro))),
        time_limits=get_up_down(hydro.time_limits),
        rating_pump=hydro.rating_pump * PSY.get_base_power(hydro),
        active_power_limits_pump=get_min_max(
            scale(hydro.active_power_limits_pump, PSY.get_base_power(hydro)),
        ),
        reactive_power_limits_pump=get_min_max(
            scale(hydro.reactive_power_limits_pump, PSY.get_base_power(hydro)),
        ),
        ramp_limits_pump=get_up_down(
            scale(hydro.ramp_limits_pump, PSY.get_base_power(hydro)),
        ),
        time_limits_pump=get_up_down(hydro.time_limits_pump),
        storage_capacity=get_up_down(
            scale(hydro.storage_capacity, PSY.get_base_power(hydro)),
        ),
        inflow=hydro.inflow * PSY.get_base_power(hydro),
        outflow=hydro.outflow,
        initial_storage=get_up_down(
            scale(hydro.initial_storage, PSY.get_base_power(hydro)),
        ),
        operation_cost=get_hydrostorage_cost(hydro.operation_cost),
        storage_target=get_up_down(hydro.storage_target),
        pump_efficiency=hydro.pump_efficiency,
        conversion_factor=hydro.conversion_factor,
        status=string(hydro.status),
        time_at_status=hydro.time_at_status,
        dynamic_injector=getid!(ids, hydro.dynamic_injector),
    )
end

function psy2openapi(energy_res::PSY.EnergyReservoirStorage, ids::IDGenerator)
    EnergyReservoirStorage(
        id=getid!(ids, energy_res),
        name=energy_res.name,
        available=energy_res.available,
        bus=getid!(ids, energy_res.bus),
        prime_mover_type=string(energy_res.prime_mover_type),
        storage_technology_type=string(energy_res.storage_technology_type),
        storage_capacity=energy_res.storage_capacity,
        storage_level_limits=get_min_max(
            scale(energy_res.storage_level_limits, PSY.get_base_power(energy_res)),
        ),
        initial_storage_capacity_level=energy_res.initial_storage_capacity_level,
        rating=energy_res.rating * PSY.get_base_power(energy_res),
        active_power=energy_res.active_power * PSY.get_base_power(energy_res),
        input_active_power_limits=get_min_max(
            scale(energy_res.input_active_power_limits, PSY.get_base_power(energy_res)),
        ),
        output_active_power_limits=get_min_max(
            scale(energy_res.output_active_power_limits, PSY.get_base_power(energy_res)),
        ),
        efficiency=energy_res.efficiency,
        reactive_power=energy_res.reactive_power * PSY.get_base_power(energy_res),
        reactive_power_limits=get_min_max(
            scale(energy_res.reactive_power_limits, PSY.get_base_power(energy_res)),
        ),
        base_power=energy_res.base_power,
        operation_cost=get_storage_cost(energy_res.operation_cost),
        conversion_factor=energy_res.conversion_factor,
        storage_target=energy_res.storage_target,
        cycle_limits=energy_res.cycle_limits,
        dynamic_injector=getid!(ids, energy_res.dynamic_injector),
    )
end
