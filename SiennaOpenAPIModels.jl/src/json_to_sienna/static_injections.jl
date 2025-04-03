function openapi2psy(thermal::ThermalStandard, resolver::Resolver)
    if thermal.base_power == 0.0
        error("base power is 0.0")
    end
    PSY.ThermalStandard(;
        name=thermal.name,
        prime_mover_type=get_prime_mover_enum(thermal.prime_mover_type),
        fuel=get_fuel_type_enum(thermal.fuel_type),
        rating=thermal.rating / thermal.base_power,
        base_power=thermal.base_power,
        available=thermal.available,
        status=thermal.status,
        time_at_status=thermal.time_at_status,
        active_power=thermal.active_power / thermal.base_power,
        reactive_power=thermal.reactive_power / thermal.base_power,
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

function openapi2psy(renew::RenewableDispatch, resolver::Resolver)
    if renew.base_power == 0.0
        error("base power is 0.0")
    end
    PSY.RenewableDispatch(;
        name=renew.name,
        available=renew.available,
        bus=resolver(renew.bus),
        active_power=renew.active_power / renew.base_power,
        reactive_power=renew.reactive_power / renew.base_power,
        rating=renew.rating / renew.base_power,
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

function openapi2psy(load::PowerLoad, resolver::Resolver)
    if load.base_power == 0.0
        error("base power is 0.0")
    end
    PSY.PowerLoad(;
        name=load.name,
        available=load.available,
        bus=resolver(load.bus),
        active_power=load.active_power / load.base_power,
        reactive_power=load.reactive_power / load.base_power,
        base_power=load.base_power,
        max_active_power=load.max_active_power / load.base_power,
        max_reactive_power=load.max_reactive_power / load.base_power,
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
        constant_active_power=standard_load.constant_active_power /
                              standard_load.base_power,
        constant_reactive_power=standard_load.constant_reactive_power /
                                standard_load.base_power,
        impedance_active_power=standard_load.impedance_active_power /
                               standard_load.base_power,
        impedance_reactive_power=standard_load.impedance_reactive_power /
                                 standard_load.base_power,
        current_active_power=standard_load.current_active_power / standard_load.base_power,
        current_reactive_power=standard_load.current_reactive_power /
                               standard_load.base_power,
        max_constant_active_power=standard_load.max_constant_active_power /
                                  standard_load.base_power,
        max_constant_reactive_power=standard_load.max_constant_reactive_power /
                                    standard_load.base_power,
        max_impedance_active_power=standard_load.max_impedance_active_power /
                                   standard_load.base_power,
        max_impedance_reactive_power=standard_load.max_impedance_reactive_power /
                                     standard_load.base_power,
        max_current_active_power=standard_load.max_current_active_power /
                                 standard_load.base_power,
        max_current_reactive_power=standard_load.max_current_reactive_power /
                                   standard_load.base_power,
        base_power=standard_load.base_power,
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
        active_power=hydro.active_power / hydro.base_power,
        reactive_power=hydro.reactive_power / hydro.base_power,
        rating=hydro.rating / hydro.base_power,
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

function openapi2psy(hydro::HydroPumpedStorage, resolver::Resolver)
    if hydro.base_power == 0.0
        error("base power is 0.0")
    end
    PSY.HydroPumpedStorage(
        name=hydro.name,
        available=hydro.available,
        bus=resolver(hydro.bus),
        active_power=hydro.active_power / hydro.base_power,
        reactive_power=hydro.reactive_power / hydro.base_power,
        rating=hydro.rating / hydro.base_power,
        base_power=hydro.base_power,
        rating_pump=hydro.rating_pump / hydro.base_power,
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
        inflow=hydro.inflow / hydro.base_power,
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
