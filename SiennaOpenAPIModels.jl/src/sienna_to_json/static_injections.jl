function psy2openapi(energy_res::PSY.EnergyReservoirStorage, ids::IDGenerator)
    EnergyReservoirStorage(
        id=getid!(ids, energy_res),
        name=energy_res.name,
        available=energy_res.available,
        bus=getid!(ids, energy_res.bus),
        prime_mover_type=string(energy_res.prime_mover_type),
        storage_technology_type=string(energy_res.storage_technology_type),
        storage_capacity=energy_res.storage_capacity * PSY.get_base_power(energy_res),
        storage_level_limits=get_min_max(energy_res.storage_level_limits),
        initial_storage_capacity_level=energy_res.initial_storage_capacity_level,
        rating=energy_res.rating * PSY.get_base_power(energy_res),
        active_power=energy_res.active_power * PSY.get_base_power(energy_res),
        input_active_power_limits=get_min_max(
            scale(energy_res.input_active_power_limits, PSY.get_base_power(energy_res)),
        ),
        output_active_power_limits=get_min_max(
            scale(energy_res.output_active_power_limits, PSY.get_base_power(energy_res)),
        ),
        efficiency=get_in_out(energy_res.efficiency),
        reactive_power=energy_res.reactive_power * PSY.get_base_power(energy_res),
        reactive_power_limits=get_min_max(
            scale(energy_res.reactive_power_limits, PSY.get_base_power(energy_res)),
        ),
        base_power=energy_res.base_power,
        operation_cost=get_operation_cost(energy_res.operation_cost),
        conversion_factor=energy_res.conversion_factor,
        storage_target=energy_res.storage_target,
        cycle_limits=energy_res.cycle_limits,
        dynamic_injector=getid!(ids, energy_res.dynamic_injector),
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
        operation_cost=get_operation_cost(hydro.operation_cost),
        rating=hydro.rating * PSY.get_base_power(hydro),
        base_power=hydro.base_power,
        time_limits=get_up_down(hydro.time_limits),
        dynamic_injector=getid!(ids, hydro.dynamic_injector),
    )
end

function psy2openapi(hydro_res::PSY.HydroEnergyReservoir, ids::IDGenerator)
    HydroEnergyReservoir(
        id=getid!(ids, hydro_res),
        name=hydro_res.name,
        available=hydro_res.available,
        bus=getid!(ids, hydro_res.bus),
        active_power=hydro_res.active_power * PSY.get_base_power(hydro_res),
        reactive_power=hydro_res.reactive_power * PSY.get_base_power(hydro_res),
        rating=hydro_res.rating * PSY.get_base_power(hydro_res),
        prime_mover_type=string(hydro_res.prime_mover_type),
        active_power_limits=get_min_max(
            scale(hydro_res.active_power_limits, PSY.get_base_power(hydro_res)),
        ),
        reactive_power_limits=get_min_max(
            scale(hydro_res.reactive_power_limits, PSY.get_base_power(hydro_res)),
        ),
        ramp_limits=get_up_down(
            scale(hydro_res.ramp_limits, PSY.get_base_power(hydro_res)),
        ),
        time_limits=get_up_down(hydro_res.time_limits),
        base_power=hydro_res.base_power,
        storage_capacity=hydro_res.storage_capacity * PSY.get_base_power(hydro_res),
        inflow=hydro_res.inflow * PSY.get_base_power(hydro_res),
        initial_storage=hydro_res.initial_storage * PSY.get_base_power(hydro_res),
        operation_cost=HydroStorageGenerationCost(
            get_operation_cost(hydro_res.operation_cost),
        ),
        storage_target=hydro_res.storage_target,
        conversion_factor=hydro_res.conversion_factor,
        status=hydro_res.status,
        time_at_status=hydro_res.time_at_status,
        dynamic_injector=getid!(ids, hydro_res.dynamic_injector),
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
        operation_cost=HydroStorageGenerationCost(get_operation_cost(hydro.operation_cost)),
        storage_target=get_up_down(hydro.storage_target),
        pump_efficiency=hydro.pump_efficiency,
        conversion_factor=hydro.conversion_factor,
        status=string(hydro.status),
        time_at_status=hydro.time_at_status,
        dynamic_injector=getid!(ids, hydro.dynamic_injector),
    )
end

function psy2openapi(inter::PSY.InterconnectingConverter, ids::IDGenerator)
    InterconnectingConverter(
        id=getid!(ids, inter),
        name=inter.name,
        available=inter.available,
        bus=getid!(ids, inter.bus),
        dc_bus=getid!(ids, inter.dc_bus),
        active_power=inter.active_power * PSY.get_base_power(inter),
        rating=inter.rating * PSY.get_base_power(inter),
        active_power_limits=get_min_max(
            scale(inter.active_power_limits, PSY.get_base_power(inter)),
        ),
        base_power=inter.base_power,
        dc_current=inter.dc_current,
        max_dc_current=inter.max_dc_current,
        loss_function=get_value_curve(inter.loss_function),
        dynamic_injector=getid!(ids, inter.dynamic_injector),
    )
end

function psy2openapi(interrupt::PSY.InterruptiblePowerLoad, ids::IDGenerator)
    InterruptiblePowerLoad(
        id=getid!(ids, interrupt),
        name=interrupt.name,
        available=interrupt.available,
        bus=getid!(ids, interrupt.bus),
        active_power=interrupt.active_power * PSY.get_base_power(interrupt),
        reactive_power=interrupt.reactive_power * PSY.get_base_power(interrupt),
        max_active_power=interrupt.max_active_power * PSY.get_base_power(interrupt),
        max_reactive_power=interrupt.max_reactive_power * PSY.get_base_power(interrupt),
        base_power=interrupt.base_power,
        operation_cost=get_operation_cost(interrupt.operation_cost),
        dynamic_injector=getid!(ids, interrupt.dynamic_injector),
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
        operation_cost=get_operation_cost(renewable.operation_cost),
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

function psy2openapi(power_load::PSY.ShiftablePowerLoad, ids::IDGenerator)
    ShiftablePowerLoad(
        id=getid!(ids, power_load),
        name=power_load.name,
        available=power_load.available,
        bus=getid!(ids, power_load.bus),
        active_power=power_load.active_power * PSY.get_base_power(power_load),
        upper_bound_active_power=power_load.upper_bound_active_power *
                                 PSY.get_base_power(power_load),
        lower_bound_active_power=power_load.lower_bound_active_power *
                                 PSY.get_base_power(power_load),
        reactive_power=power_load.reactive_power * PSY.get_base_power(power_load),
        max_active_power=power_load.max_active_power * PSY.get_base_power(power_load),
        max_reactive_power=power_load.max_reactive_power * PSY.get_base_power(power_load),
        base_power=power_load.base_power,
        load_balance_time_horizon=power_load.load_balance_time_horizon,
        operation_cost=get_operation_cost(power_load.operation_cost),
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

function psy2openapi(multi::PSY.ThermalMultiStart, ids::IDGenerator)
    ThermalMultiStart(
        id=getid!(ids, multi),
        name=multi.name,
        available=multi.available,
        status=multi.status,
        bus=getid!(ids, multi.bus),
        active_power=multi.active_power * PSY.get_base_power(multi),
        reactive_power=multi.reactive_power * PSY.get_base_power(multi),
        rating=multi.rating * PSY.get_base_power(multi),
        prime_mover_type=string(multi.prime_mover_type),
        fuel=string(multi.fuel),
        active_power_limits=get_min_max(
            scale(multi.active_power_limits, PSY.get_base_power(multi)),
        ),
        reactive_power_limits=get_min_max(
            scale(multi.reactive_power_limits, PSY.get_base_power(multi)),
        ),
        ramp_limits=get_up_down(scale(multi.ramp_limits, PSY.get_base_power(multi))),
        power_trajectory=get_startup_shutdown(
            scale(multi.power_trajectory, PSY.get_base_power(multi)),
        ),
        time_limits=get_up_down(multi.time_limits),
        start_time_limits=get_startup(multi.start_time_limits),
        start_types=multi.start_types,
        operation_cost=get_operation_cost(multi.operation_cost),
        base_power=multi.base_power,
        time_at_status=multi.time_at_status,
        must_run=multi.must_run,
        dynamic_injector=getid!(ids, multi.dynamic_injector),
    )
end

function psy2openapi(thermal_standard::PSY.ThermalStandard, ids::IDGenerator)
    ThermalStandard(
        id=getid!(ids, thermal_standard),
        name=thermal_standard.name,
        prime_mover_type=string(thermal_standard.prime_mover_type),
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
        operation_cost=get_operation_cost(thermal_standard.operation_cost),
        time_limits=get_up_down(thermal_standard.time_limits),
        must_run=thermal_standard.must_run,
        bus=getid!(ids, thermal_standard.bus),
    )
end
