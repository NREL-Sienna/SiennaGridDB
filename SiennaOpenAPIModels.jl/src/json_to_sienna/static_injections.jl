function openapi2psy(energy_res::EnergyReservoirStorage, resolver::Resolver)
    if energy_res.base_power == 0.0
        error("base power is 0.0")
    end
    PSY.EnergyReservoirStorage(;
        name=energy_res.name,
        available=energy_res.available,
        bus=resolver(energy_res.bus),
        prime_mover_type=get_prime_mover_enum(energy_res.prime_mover_type),
        storage_technology_type=get_storage_tech_enum(energy_res.storage_technology_type),
        storage_capacity=(energy_res.storage_capacity / energy_res.base_power),
        storage_level_limits=get_tuple_min_max(energy_res.storage_level_limits),
        initial_storage_capacity_level=energy_res.initial_storage_capacity_level,
        rating=(energy_res.rating / energy_res.base_power),
        active_power=(energy_res.active_power / energy_res.base_power),
        input_active_power_limits=divide(
            get_tuple_min_max(energy_res.input_active_power_limits),
            energy_res.base_power,
        ),
        output_active_power_limits=divide(
            get_tuple_min_max(energy_res.output_active_power_limits),
            energy_res.base_power,
        ),
        efficiency=get_tuple_in_out(energy_res.efficiency),
        reactive_power=(energy_res.reactive_power / energy_res.base_power),
        reactive_power_limits=divide(
            get_tuple_min_max(energy_res.reactive_power_limits),
            energy_res.base_power,
        ),
        base_power=energy_res.base_power,
        operation_cost=get_sienna_operation_cost(energy_res.operation_cost),
        conversion_factor=energy_res.conversion_factor,
        storage_target=energy_res.storage_target,
        cycle_limits=energy_res.cycle_limits,
    )
end

function openapi2psy(fixed::FixedAdmittance, resolver::Resolver)
    PSY.FixedAdmittance(
        name=fixed.name,
        available=fixed.available,
        bus=resolver(fixed.bus),
        Y=get_julia_complex(fixed.Y),
    )
end

function openapi2psy(hydro::HydroDispatch, resolver::Resolver)
    if hydro.base_power == 0.0
        error("base power is 0.0")
    end
    PSY.HydroDispatch(;
        name=hydro.name,
        available=hydro.available,
        bus=resolver(hydro.bus),
        active_power=(hydro.active_power / hydro.base_power),
        reactive_power=(hydro.reactive_power / hydro.base_power),
        rating=(hydro.rating / hydro.base_power),
        prime_mover_type=get_prime_mover_enum(hydro.prime_mover_type),
        active_power_limits=divide(
            get_tuple_min_max(hydro.active_power_limits),
            hydro.base_power,
        ),
        reactive_power_limits=divide(
            get_tuple_min_max(hydro.reactive_power_limits),
            hydro.base_power,
        ),
        ramp_limits=divide(get_tuple_up_down(hydro.ramp_limits), hydro.base_power),
        time_limits=get_tuple_up_down(hydro.time_limits),
        base_power=hydro.base_power,
        operation_cost=get_sienna_operation_cost(hydro.operation_cost),
    )
end

function openapi2psy(hydro_res::HydroEnergyReservoir, resolver::Resolver)
    if hydro_res.base_power == 0.0
        error("base power is 0.0")
    end
    PSY.HydroEnergyReservoir(
        name=hydro_res.name,
        available=hydro_res.available,
        bus=resolver(hydro_res.bus),
        active_power=(hydro_res.active_power / hydro_res.base_power),
        reactive_power=(hydro_res.reactive_power / hydro_res.base_power),
        rating=(hydro_res.rating / hydro_res.base_power),
        prime_mover_type=get_prime_mover_enum(hydro_res.prime_mover_type),
        active_power_limits=divide(
            get_tuple_min_max(hydro_res.active_power_limits),
            hydro_res.base_power,
        ),
        reactive_power_limits=divide(
            get_tuple_min_max(hydro_res.reactive_power_limits),
            hydro_res.base_power,
        ),
        ramp_limits=divide(get_tuple_up_down(hydro_res.ramp_limits), hydro_res.base_power),
        time_limits=get_tuple_up_down(hydro_res.time_limits),
        base_power=hydro_res.base_power,
        storage_capacity=(hydro_res.storage_capacity / hydro_res.base_power),
        inflow=(hydro_res.inflow / hydro_res.base_power),
        initial_storage=(hydro_res.initial_storage / hydro_res.base_power),
        operation_cost=get_sienna_operation_cost(hydro_res.operation_cost),
        storage_target=hydro_res.storage_target,
        conversion_factor=hydro_res.conversion_factor,
        status=hydro_res.status,
        time_at_status=hydro_res.time_at_status,
    )
end

function openapi2psy(hydro::HydroPumpTurbine, resolver::Resolver)
    if hydro.base_power == 0.0
        error("base power is 0.0")
    end
    PSY.HydroPumpTurbine(
        name=hydro.name,
        available=hydro.available,
        bus=resolver(hydro.bus),
        active_power=(hydro.active_power / hydro.base_power),
        reactive_power=(hydro.reactive_power / hydro.base_power),
        rating=(hydro.rating / hydro.base_power),
        base_power=hydro.base_power,
        rating_pump=(hydro.rating_pump / hydro.base_power),
        prime_mover_type=get_prime_mover_enum(hydro.prime_mover_type),
        active_power_limits=divide(
            get_tuple_min_max(hydro.active_power_limits),
            hydro.base_power,
        ),
        reactive_power_limits=divide(
            get_tuple_min_max(hydro.reactive_power_limits),
            hydro.base_power,
        ),
        ramp_limits=divide(get_tuple_up_down(hydro.ramp_limits), hydro.base_power),
        time_limits=get_tuple_up_down(hydro.time_limits),
        active_power_limits_pump=divide(
            get_tuple_min_max(hydro.active_power_limits_pump),
            hydro.base_power,
        ),
        reactive_power_limits_pump=divide(
            get_tuple_min_max(hydro.reactive_power_limits_pump),
            hydro.base_power,
        ),
        ramp_limits_pump=divide(
            get_tuple_up_down(hydro.ramp_limits_pump),
            hydro.base_power,
        ),
        time_limits_pump=get_tuple_up_down(hydro.time_limits_pump),
        storage_capacity=divide(
            get_tuple_up_down(hydro.storage_capacity),
            hydro.base_power,
        ),
        inflow=(hydro.inflow / hydro.base_power),
        outflow=hydro.outflow,
        initial_storage=divide(get_tuple_up_down(hydro.initial_storage), hydro.base_power),
        operation_cost=get_sienna_operation_cost(hydro.operation_cost),
        storage_target=get_tuple_up_down(hydro.storage_target),
        pump_efficiency=hydro.pump_efficiency,
        conversion_factor=hydro.conversion_factor,
        status=get_pump_status_enum(hydro.status),
        time_at_status=hydro.time_at_status,
    )
end

function openapi2psy(inter::InterconnectingConverter, resolver::Resolver)
    if inter.base_power == 0.0
        error("base power is 0.0")
    end
    PSY.InterconnectingConverter(
        name=inter.name,
        available=inter.available,
        bus=resolver(inter.bus),
        dc_bus=resolver(inter.dc_bus),
        active_power=(inter.active_power / inter.base_power),
        rating=(inter.rating / inter.base_power),
        active_power_limits=divide(
            get_tuple_min_max(inter.active_power_limits),
            inter.base_power,
        ),
        base_power=inter.base_power,
        dc_current=inter.dc_current,
        max_dc_current=inter.max_dc_current,
        loss_function=get_sienna_value_curve(inter.loss_function),
    )
end

function openapi2psy(interrupt::InterruptiblePowerLoad, resolver::Resolver)
    if interrupt.base_power == 0.0
        error("base power is 0.0")
    end
    PSY.InterruptiblePowerLoad(
        name=interrupt.name,
        available=interrupt.available,
        bus=resolver(interrupt.bus),
        active_power=(interrupt.active_power / interrupt.base_power),
        reactive_power=(interrupt.reactive_power / interrupt.base_power),
        max_active_power=(interrupt.max_active_power / interrupt.base_power),
        max_reactive_power=(interrupt.max_reactive_power / interrupt.base_power),
        base_power=interrupt.base_power,
        operation_cost=get_sienna_operation_cost(interrupt.operation_cost),
    )
end

function openapi2psy(load::PowerLoad, resolver::Resolver)
    if load.base_power == 0.0
        error("base power is 0.0")
    end
    PSY.PowerLoad(;
        name=load.name,
        available=load.available,
        bus=resolver(load.bus),
        active_power=(load.active_power / load.base_power),
        reactive_power=(load.reactive_power / load.base_power),
        base_power=load.base_power,
        max_active_power=(load.max_active_power / load.base_power),
        max_reactive_power=(load.max_reactive_power / load.base_power),
    )
end

function openapi2psy(renew::RenewableDispatch, resolver::Resolver)
    if renew.base_power == 0.0
        error("base power is 0.0")
    end
    PSY.RenewableDispatch(;
        name=renew.name,
        available=renew.available,
        bus=resolver(renew.bus),
        active_power=(renew.active_power / renew.base_power),
        reactive_power=(renew.reactive_power / renew.base_power),
        rating=(renew.rating / renew.base_power),
        prime_mover_type=get_prime_mover_enum(renew.prime_mover_type),
        reactive_power_limits=divide(
            get_tuple_min_max(renew.reactive_power_limits),
            renew.base_power,
        ),
        power_factor=renew.power_factor,
        operation_cost=get_sienna_operation_cost(renew.operation_cost),
        base_power=renew.base_power,
    )
end

function openapi2psy(renewnon::RenewableNonDispatch, resolver::Resolver)
    if renewnon.base_power == 0.0
        error("base power is 0.0")
    end
    PSY.RenewableNonDispatch(;
        name=renewnon.name,
        available=renewnon.available,
        bus=resolver(renewnon.bus),
        active_power=(renewnon.active_power / renewnon.base_power),
        reactive_power=(renewnon.reactive_power / renewnon.base_power),
        rating=(renewnon.rating / renewnon.base_power),
        prime_mover_type=get_prime_mover_enum(renewnon.prime_mover_type),
        power_factor=renewnon.power_factor,
        base_power=renewnon.base_power,
    )
end

function openapi2psy(standard_load::StandardLoad, resolver::Resolver)
    if standard_load.base_power == 0.0
        error("base power is 0.0")
    end
    PSY.StandardLoad(
        name=standard_load.name,
        available=standard_load.available,
        bus=resolver(standard_load.bus),
        constant_active_power=(
            standard_load.constant_active_power / standard_load.base_power
        ),
        constant_reactive_power=(
            standard_load.constant_reactive_power / standard_load.base_power
        ),
        impedance_active_power=(
            standard_load.impedance_active_power / standard_load.base_power
        ),
        impedance_reactive_power=(
            standard_load.impedance_reactive_power / standard_load.base_power
        ),
        current_active_power=(
            standard_load.current_active_power / standard_load.base_power
        ),
        current_reactive_power=(
            standard_load.current_reactive_power / standard_load.base_power
        ),
        max_constant_active_power=(
            standard_load.max_constant_active_power / standard_load.base_power
        ),
        max_constant_reactive_power=(
            standard_load.max_constant_reactive_power / standard_load.base_power
        ),
        max_impedance_active_power=(
            standard_load.max_impedance_active_power / standard_load.base_power
        ),
        max_impedance_reactive_power=(
            standard_load.max_impedance_reactive_power / standard_load.base_power
        ),
        max_current_active_power=(
            standard_load.max_current_active_power / standard_load.base_power
        ),
        max_current_reactive_power=(
            standard_load.max_current_reactive_power / standard_load.base_power
        ),
        base_power=standard_load.base_power,
    )
end

function openapi2psy(switch::SwitchedAdmittance, resolver::Resolver)
    PSY.SwitchedAdmittance(
        name=switch.name,
        available=switch.available,
        bus=resolver(switch.bus),
        Y=get_julia_complex(switch.Y),
        number_of_steps=switch.number_of_steps,
        Y_increase=map(get_julia_complex, switch.Y_increase),
        admittance_limits=get_tuple_min_max(switch.admittance_limits),
    )
end

function openapi2psy(multi::ThermalMultiStart, resolver::Resolver)
    if multi.base_power == 0.0
        error("base power is 0.0")
    end
    PSY.ThermalMultiStart(
        name=multi.name,
        available=multi.available,
        status=multi.status,
        bus=resolver(multi.bus),
        active_power=(multi.active_power / multi.base_power),
        reactive_power=(multi.reactive_power / multi.base_power),
        rating=(multi.rating / multi.base_power),
        prime_mover_type=get_prime_mover_enum(multi.prime_mover_type),
        fuel=get_fuel_type_enum(multi.fuel),
        active_power_limits=divide(
            get_tuple_min_max(multi.active_power_limits),
            multi.base_power,
        ),
        reactive_power_limits=divide(
            get_tuple_min_max(multi.reactive_power_limits),
            multi.base_power,
        ),
        ramp_limits=divide(get_tuple_up_down(multi.ramp_limits), multi.base_power),
        power_trajectory=divide(
            get_tuple_startup_shutdown(multi.power_trajectory),
            multi.base_power,
        ),
        time_limits=get_tuple_up_down(multi.time_limits),
        start_time_limits=get_sienna_startup(multi.start_time_limits),
        start_types=multi.start_types,
        operation_cost=get_sienna_operation_cost(multi.operation_cost),
        base_power=multi.base_power,
        time_at_status=multi.time_at_status,
        must_run=multi.must_run,
    )
end

function openapi2psy(thermal::ThermalStandard, resolver::Resolver)
    if thermal.base_power == 0.0
        error("base power is 0.0")
    end
    PSY.ThermalStandard(;
        name=thermal.name,
        prime_mover_type=get_prime_mover_enum(thermal.prime_mover_type),
        fuel=get_fuel_type_enum(thermal.fuel_type),
        rating=(thermal.rating / thermal.base_power),
        base_power=thermal.base_power,
        available=thermal.available,
        status=thermal.status,
        time_at_status=thermal.time_at_status,
        active_power=(thermal.active_power / thermal.base_power),
        reactive_power=(thermal.reactive_power / thermal.base_power),
        active_power_limits=divide(
            get_tuple_min_max(thermal.active_power_limits),
            thermal.base_power,
        ),
        reactive_power_limits=divide(
            get_tuple_min_max(thermal.reactive_power_limits),
            thermal.base_power,
        ),
        ramp_limits=divide(get_tuple_up_down(thermal.ramp_limits), thermal.base_power),
        operation_cost=get_sienna_operation_cost(thermal.operation_cost),
        time_limits=get_tuple_up_down(thermal.time_limits),
        must_run=thermal.must_run,
        bus=resolver(thermal.bus),
    )
end
