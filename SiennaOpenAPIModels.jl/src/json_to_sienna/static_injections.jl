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
        operation_cost=get_sienna_thermal_cost(thermal.operation_cost),
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
        operation_cost=get_sienna_renewable_cost(renew.operation_cost),
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

function openapi2psy(renewnon::RenewableNonDispatch, resolver::Resolver)
    if renewnon.base_power == 0.0
        error("base power is 0.0")
    end
    PSY.RenewableNonDispatch(;
        name=renewnon.name,
        available=renewnon.available,
        bus=resolver(renewnon.bus),
        active_power=renewnon.active_power / renewnon.base_power,
        reactive_power=renewnon.reactive_power / renewnon.base_power,
        rating=renewnon.rating / renewnon.base_power,
        prime_mover_type=get_prime_mover_enum(renewnon.prime_mover_type),
        power_factor=renewnon.power_factor,
        base_power=renewnon.base_power,
    )
end
