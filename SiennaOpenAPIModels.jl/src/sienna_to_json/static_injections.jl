function psy2openapi(energy_res::PSY.EnergyReservoirStorage, ids::IDGenerator)
    if energy_res.base_power == 0.0
        error("base power is 0.0")
    end
    EnergyReservoirStorage(
        id=getid!(ids, energy_res),
        name=energy_res.name,
        available=energy_res.available,
        bus=getid!(ids, energy_res.bus),
        prime_mover_type=string(energy_res.prime_mover_type),
        storage_technology_type=string(energy_res.storage_technology_type),
        storage_capacity=energy_res.storage_capacity * energy_res.base_power,
        storage_level_limits=get_min_max(energy_res.storage_level_limits),
        initial_storage_capacity_level=energy_res.initial_storage_capacity_level,
        rating=energy_res.rating * energy_res.base_power,
        active_power=energy_res.active_power * energy_res.base_power,
        input_active_power_limits=get_min_max(
            scale(energy_res.input_active_power_limits, energy_res.base_power),
        ),
        output_active_power_limits=get_min_max(
            scale(energy_res.output_active_power_limits, energy_res.base_power),
        ),
        efficiency=get_in_out(energy_res.efficiency),
        reactive_power=energy_res.reactive_power * energy_res.base_power,
        reactive_power_limits=get_min_max(
            scale(energy_res.reactive_power_limits, energy_res.base_power),
        ),
        base_power=energy_res.base_power,
        operation_cost=get_operation_cost(energy_res.operation_cost),
        conversion_factor=energy_res.conversion_factor,
        storage_target=energy_res.storage_target,
        cycle_limits=energy_res.cycle_limits,
        dynamic_injector=getid!(ids, energy_res.dynamic_injector),
    )
end

function psy2openapi(load::PSY.ExponentialLoad, ids::IDGenerator)
    if load.base_power == 0.0
        error("base power is 0.0")
    end
    ExponentialLoad(
        id=getid!(ids, load),
        name=load.name,
        available=load.available,
        bus=getid!(ids, load.bus),
        active_power=load.active_power * load.base_power,
        reactive_power=load.reactive_power * load.base_power,
        alpha=load.α,
        beta=load.β,
        conformity=string(load.conformity),
        base_power=load.base_power,
        max_active_power=load.max_active_power * load.base_power,
        max_reactive_power=load.max_reactive_power * load.base_power,
        dynamic_injector=getid!(ids, load.dynamic_injector),
    )
end

function psy2openapi(facts::PSY.FACTSControlDevice, ids::IDGenerator)
    FACTSControlDevice(
        id=getid!(ids, facts),
        name=facts.name,
        available=facts.available,
        bus=getid!(ids, facts.bus),
        control_mode=string(facts.control_mode),
        voltage_setpoint=facts.voltage_setpoint,
        max_shunt_current=facts.max_shunt_current,
        reactive_power_required=facts.reactive_power_required,
        dynamic_injector=getid!(ids, facts.dynamic_injector),
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
    if hydro.base_power == 0.0
        error("base power is 0.0")
    end
    HydroDispatch(
        id=getid!(ids, hydro),
        name=hydro.name,
        available=hydro.available,
        bus=getid!(ids, hydro.bus),
        active_power=hydro.active_power * hydro.base_power,
        reactive_power=hydro.reactive_power * hydro.base_power,
        active_power_limits=get_min_max(scale(hydro.active_power_limits, hydro.base_power)),
        reactive_power_limits=get_min_max(
            scale(hydro.reactive_power_limits, hydro.base_power),
        ),
        prime_mover_type=string(hydro.prime_mover_type),
        ramp_limits=get_up_down(scale(hydro.ramp_limits, hydro.base_power)),
        operation_cost=get_operation_cost(hydro.operation_cost),
        rating=hydro.rating * hydro.base_power,
        base_power=hydro.base_power,
        time_limits=get_up_down(hydro.time_limits),
        dynamic_injector=getid!(ids, hydro.dynamic_injector),
    )
end

function psy2openapi(hydro_res::PSY.HydroEnergyReservoir, ids::IDGenerator)
    if hydro_res.base_power == 0.0
        error("base power is 0.0")
    end
    HydroEnergyReservoir(
        id=getid!(ids, hydro_res),
        name=hydro_res.name,
        available=hydro_res.available,
        bus=getid!(ids, hydro_res.bus),
        active_power=hydro_res.active_power * hydro_res.base_power,
        reactive_power=hydro_res.reactive_power * hydro_res.base_power,
        rating=hydro_res.rating * hydro_res.base_power,
        prime_mover_type=string(hydro_res.prime_mover_type),
        active_power_limits=get_min_max(
            scale(hydro_res.active_power_limits, hydro_res.base_power),
        ),
        reactive_power_limits=get_min_max(
            scale(hydro_res.reactive_power_limits, hydro_res.base_power),
        ),
        ramp_limits=get_up_down(scale(hydro_res.ramp_limits, hydro_res.base_power)),
        time_limits=get_up_down(hydro_res.time_limits),
        base_power=hydro_res.base_power,
        storage_capacity=hydro_res.storage_capacity * hydro_res.base_power,
        inflow=hydro_res.inflow * hydro_res.base_power,
        initial_storage=hydro_res.initial_storage * hydro_res.base_power,
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

function psy2openapi(hydro::PSY.HydroPumpTurbine, ids::IDGenerator)
    if hydro.base_power == 0.0
        error("base power is 0.0")
    end
    HydroPumpTurbine(
        id=getid!(ids, hydro),
        name=hydro.name,
        available=hydro.available,
        bus=getid!(ids, hydro.bus),
        active_power=hydro.active_power * hydro.base_power,
        reactive_power=hydro.reactive_power * hydro.base_power,
        rating=hydro.rating * hydro.base_power,
        active_power_limits=get_min_max(scale(hydro.active_power_limits, hydro.base_power)),
        reactive_power_limits=get_min_max(
            scale(hydro.reactive_power_limits, hydro.base_power),
        ),
        active_power_limits_pump=get_min_max(
            scale(hydro.active_power_limits_pump, hydro.base_power),
        ),
        outflow_limits=get_min_max(hydro.outflow_limits),
        head_reservoir=getid!(ids, hydro.head_reservoir),
        tail_reservoir=getid!(ids, hydro.tail_reservoir),
        powerhouse_elevation=hydro.powerhouse_elevation,
        ramp_limits=get_up_down(scale(hydro.ramp_limits, hydro.base_power)),
        time_limits=get_up_down(hydro.time_limits),
        base_power=hydro.base_power,
        operation_cost=HydroStorageGenerationCost(get_operation_cost(hydro.operation_cost)),
        active_power_pump=hydro.active_power_pump * hydro.base_power,
        efficiency=get_turbine_pump(hydro.efficiency),
        transition_time=get_turbine_pump(hydro.transition_time),
        minimum_time=get_turbine_pump(hydro.minimum_time),
        conversion_factor=hydro.conversion_factor,
        must_run=hydro.must_run,
        prime_mover_type=string(hydro.prime_mover_type),
        dynamic_injector=getid!(ids, hydro.dynamic_injector),
    )
end

function psy2openapi(hydro::PSY.HydroReservoir, ids::IDGenerator)
    HydroReservoir(
        id=getid!(ids, hydro),
        name=hydro.name,
        available=hydro.available,
        storage_level_limits=get_min_max(hydro.storage_level_limits),
        initial_level=hydro.initial_level,
        spillage_limits=get_min_max(hydro.spillage_limits),
        inflow=hydro.inflow,
        outflow=hydro.outflow,
        level_targets=hydro.level_targets,
        travel_time=hydro.travel_time,
        intake_elevation=hydro.intake_elevation,
        head_to_volume_factor=ValueCurve(get_value_curve(hydro.head_to_volume_factor)),
        operation_cost=get_operation_cost(hydro.operation_cost),
        level_data_type=string(hydro.level_data_type),
    )
end

function psy2openapi(hydro::PSY.HydroTurbine, ids::IDGenerator)
    if hydro.base_power == 0.0
        error("base power is 0.0")
    end
    HydroTurbine(
        id=getid!(ids, hydro),
        name=hydro.name,
        available=hydro.available,
        bus=getid!(ids, hydro.bus),
        active_power=hydro.active_power * hydro.base_power,
        reactive_power=hydro.reactive_power * hydro.base_power,
        rating=hydro.rating * hydro.base_power,
        active_power_limits=get_min_max(scale(hydro.active_power_limits, hydro.base_power)),
        reactive_power_limits=get_min_max(
            scale(hydro.reactive_power_limits, hydro.base_power),
        ),
        outflow_limits=get_min_max(hydro.outflow_limits),
        powerhouse_elevation=hydro.powerhouse_elevation,
        ramp_limits=get_up_down(scale(hydro.ramp_limits, hydro.base_power)),
        time_limits=get_up_down(hydro.time_limits),
        base_power=hydro.base_power,
        operation_cost=get_operation_cost(hydro.operation_cost),
        efficiency=hydro.efficiency,
        conversion_factor=hydro.conversion_factor,
        reservoirs=map(c -> getid!(ids, c), hydro.reservoirs), # this is a vector of reservoirs
        dynamic_injector=getid!(ids, hydro.dynamic_injector),
    )
end

function psy2openapi(inter::PSY.InterconnectingConverter, ids::IDGenerator)
    if inter.base_power == 0.0
        error("base power is 0.0")
    end
    InterconnectingConverter(
        id=getid!(ids, inter),
        name=inter.name,
        available=inter.available,
        bus=getid!(ids, inter.bus),
        dc_bus=getid!(ids, inter.dc_bus),
        active_power=inter.active_power * inter.base_power,
        rating=inter.rating * inter.base_power,
        active_power_limits=get_min_max(scale(inter.active_power_limits, inter.base_power)),
        base_power=inter.base_power,
        dc_current=inter.dc_current,
        max_dc_current=inter.max_dc_current,
        loss_function=get_value_curve(inter.loss_function),
        dynamic_injector=getid!(ids, inter.dynamic_injector),
    )
end

function psy2openapi(interrupt::PSY.InterruptiblePowerLoad, ids::IDGenerator)
    if interrupt.base_power == 0.0
        error("base power is 0.0")
    end
    InterruptiblePowerLoad(
        id=getid!(ids, interrupt),
        name=interrupt.name,
        available=interrupt.available,
        bus=getid!(ids, interrupt.bus),
        active_power=interrupt.active_power * interrupt.base_power,
        reactive_power=interrupt.reactive_power * interrupt.base_power,
        max_active_power=interrupt.max_active_power * interrupt.base_power,
        max_reactive_power=interrupt.max_reactive_power * interrupt.base_power,
        base_power=interrupt.base_power,
        operation_cost=get_operation_cost(interrupt.operation_cost),
        dynamic_injector=getid!(ids, interrupt.dynamic_injector),
    )
end

function psy2openapi(power_load::PSY.PowerLoad, ids::IDGenerator)
    if power_load.base_power == 0.0
        error("base power is 0.0")
    end
    PowerLoad(
        id=getid!(ids, power_load),
        name=power_load.name,
        available=power_load.available,
        bus=getid!(ids, power_load.bus),
        active_power=power_load.active_power * power_load.base_power,
        reactive_power=power_load.reactive_power * power_load.base_power,
        base_power=power_load.base_power,
        max_active_power=power_load.max_active_power * power_load.base_power,
        max_reactive_power=power_load.max_reactive_power * power_load.base_power,
        conformity=string(power_load.conformity),
        dynamic_injector=getid!(ids, power_load.dynamic_injector),
    )
end

function psy2openapi(renewable::PSY.RenewableDispatch, ids::IDGenerator)
    if renewable.base_power == 0.0
        error("base power is 0.0")
    end
    RenewableDispatch(
        id=getid!(ids, renewable),
        name=renewable.name,
        available=renewable.available,
        bus=getid!(ids, renewable.bus),
        active_power=renewable.active_power * renewable.base_power,
        reactive_power=renewable.reactive_power * renewable.base_power,
        rating=renewable.rating * renewable.base_power,
        prime_mover_type=string(renewable.prime_mover_type),
        reactive_power_limits=get_min_max(
            scale(renewable.reactive_power_limits, renewable.base_power),
        ),
        power_factor=renewable.power_factor,
        operation_cost=get_operation_cost(renewable.operation_cost),
        base_power=renewable.base_power,
        dynamic_injector=getid!(ids, renewable.dynamic_injector),
    )
end

function psy2openapi(renewnondispatch::PSY.RenewableNonDispatch, ids::IDGenerator)
    if renewnondispatch.base_power == 0.0
        error("base power is 0.0")
    end
    RenewableNonDispatch(
        id=getid!(ids, renewnondispatch),
        name=renewnondispatch.name,
        available=renewnondispatch.available,
        bus=getid!(ids, renewnondispatch.bus),
        active_power=renewnondispatch.active_power * renewnondispatch.base_power,
        reactive_power=renewnondispatch.reactive_power * renewnondispatch.base_power,
        rating=renewnondispatch.rating * renewnondispatch.base_power,
        prime_mover_type=string(renewnondispatch.prime_mover_type),
        power_factor=renewnondispatch.power_factor,
        base_power=renewnondispatch.base_power,
        dynamic_injector=getid!(ids, renewnondispatch.dynamic_injector),
    )
end

function psy2openapi(power_load::PSY.ShiftablePowerLoad, ids::IDGenerator)
    if power_load.base_power == 0.0
        error("base power is 0.0")
    end
    ShiftablePowerLoad(
        id=getid!(ids, power_load),
        name=power_load.name,
        available=power_load.available,
        bus=getid!(ids, power_load.bus),
        active_power=power_load.active_power * power_load.base_power,
        active_power_limits=get_min_max(
            scale(power_load.active_power_limits, power_load.base_power),
        ),
        reactive_power=power_load.reactive_power * power_load.base_power,
        max_active_power=power_load.max_active_power * power_load.base_power,
        max_reactive_power=power_load.max_reactive_power * power_load.base_power,
        base_power=power_load.base_power,
        load_balance_time_horizon=power_load.load_balance_time_horizon,
        operation_cost=get_operation_cost(power_load.operation_cost),
        dynamic_injector=getid!(ids, power_load.dynamic_injector),
    )
end

function psy2openapi(source::PSY.Source, ids::IDGenerator)
    if source.base_power == 0.0
        error("base power is 0.0")
    end
    Source(
        id=getid!(ids, source),
        name=source.name,
        available=source.available,
        bus=getid!(ids, source.bus),
        active_power=source.active_power * source.base_power,
        reactive_power=source.reactive_power * source.base_power,
        active_power_limits=get_min_max(
            scale(source.active_power_limits, source.base_power),
        ),
        reactive_power_limits=get_min_max(
            scale(source.reactive_power_limits, source.base_power),
        ),
        R_th=source.R_th,
        X_th=source.X_th,
        internal_voltage=source.internal_voltage,
        internal_angle=source.internal_angle,
        base_power=source.base_power,
        operation_cost=get_operation_cost(source.operation_cost),
        dynamic_injector=getid!(ids, source.dynamic_injector),
    )
end

function psy2openapi(standard_load::PSY.StandardLoad, ids::IDGenerator)
    if standard_load.base_power == 0.0
        error("base power is 0.0")
    end
    StandardLoad(
        id=getid!(ids, standard_load),
        name=standard_load.name,
        available=standard_load.available,
        bus=getid!(ids, standard_load.bus),
        constant_active_power=standard_load.constant_active_power *
                              standard_load.base_power,
        constant_reactive_power=standard_load.constant_reactive_power *
                                standard_load.base_power,
        impedance_active_power=standard_load.impedance_active_power *
                               standard_load.base_power,
        impedance_reactive_power=standard_load.impedance_reactive_power *
                                 standard_load.base_power,
        current_active_power=standard_load.current_active_power * standard_load.base_power,
        current_reactive_power=standard_load.current_reactive_power *
                               standard_load.base_power,
        max_constant_active_power=standard_load.max_constant_active_power *
                                  standard_load.base_power,
        max_constant_reactive_power=standard_load.max_constant_reactive_power *
                                    standard_load.base_power,
        max_impedance_active_power=standard_load.max_impedance_active_power *
                                   standard_load.base_power,
        max_impedance_reactive_power=standard_load.max_impedance_reactive_power *
                                     standard_load.base_power,
        max_current_active_power=standard_load.max_current_active_power *
                                 standard_load.base_power,
        max_current_reactive_power=standard_load.max_current_reactive_power *
                                   standard_load.base_power,
        conformity=string(standard_load.conformity),
        base_power=standard_load.base_power,
        dynamic_injector=getid!(ids, standard_load.dynamic_injector),
    )
end

function psy2openapi(switch::PSY.SwitchedAdmittance, ids::IDGenerator)
    SwitchedAdmittance(
        id=getid!(ids, switch),
        name=switch.name,
        available=switch.available,
        bus=getid!(ids, switch.bus),
        Y=get_complex_number(switch.Y),
        number_of_steps=switch.number_of_steps,
        Y_increase=map(get_complex_number, switch.Y_increase),
        admittance_limits=get_min_max(switch.admittance_limits),
        dynamic_injector=getid!(ids, switch.dynamic_injector),
    )
end

function psy2openapi(synch::PSY.SynchronousCondenser, ids::IDGenerator)
    if synch.base_power == 0.0
        error("base power is 0.0")
    end
    SynchronousCondenser(
        id=getid!(ids, synch),
        name=synch.name,
        available=synch.available,
        bus=getid!(ids, synch.bus),
        reactive_power=synch.reactive_power * synch.base_power,
        rating=synch.rating * synch.base_power,
        reactive_power_limits=get_min_max(
            scale(synch.reactive_power_limits, synch.base_power),
        ),
        base_power=synch.base_power,
        must_run=synch.must_run,
        active_power_losses=synch.active_power_losses * synch.base_power,
        dynamic_injector=getid!(ids, synch.dynamic_injector),
    )
end

function psy2openapi(multi::PSY.ThermalMultiStart, ids::IDGenerator)
    if multi.base_power == 0.0
        error("base power is 0.0")
    end
    ThermalMultiStart(
        id=getid!(ids, multi),
        name=multi.name,
        available=multi.available,
        status=multi.status,
        bus=getid!(ids, multi.bus),
        active_power=multi.active_power * multi.base_power,
        reactive_power=multi.reactive_power * multi.base_power,
        rating=multi.rating * multi.base_power,
        prime_mover_type=string(multi.prime_mover_type),
        fuel=string(multi.fuel),
        active_power_limits=get_min_max(scale(multi.active_power_limits, multi.base_power)),
        reactive_power_limits=get_min_max(
            scale(multi.reactive_power_limits, multi.base_power),
        ),
        ramp_limits=get_up_down(scale(multi.ramp_limits, multi.base_power)),
        power_trajectory=get_startup_shutdown(
            scale(multi.power_trajectory, multi.base_power),
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
    if thermal_standard.base_power == 0.0
        error("base power is 0.0")
    end
    ThermalStandard(
        id=getid!(ids, thermal_standard),
        name=thermal_standard.name,
        prime_mover_type=string(thermal_standard.prime_mover_type),
        fuel_type=string(thermal_standard.fuel),
        rating=thermal_standard.rating * thermal_standard.base_power,
        base_power=thermal_standard.base_power,
        available=thermal_standard.available,
        status=thermal_standard.status,
        time_at_status=thermal_standard.time_at_status,
        active_power=thermal_standard.active_power * thermal_standard.base_power,
        reactive_power=thermal_standard.reactive_power * thermal_standard.base_power,
        active_power_limits=get_min_max(
            scale(thermal_standard.active_power_limits, thermal_standard.base_power),
        ),
        reactive_power_limits=get_min_max(
            scale(thermal_standard.reactive_power_limits, thermal_standard.base_power),
        ),
        ramp_limits=get_up_down(
            scale(thermal_standard.ramp_limits, thermal_standard.base_power),
        ),
        operation_cost=get_operation_cost(thermal_standard.operation_cost),
        time_limits=get_up_down(thermal_standard.time_limits),
        must_run=thermal_standard.must_run,
        bus=getid!(ids, thermal_standard.bus),
    )
end
