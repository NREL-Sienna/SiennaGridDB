function openapi2psy(reserve::VariableReserve, resolver::Resolver)
    if PSY.get_base_power(resolver.sys) == 0.0
        error("base power is 0.0")
    end
    PSY.VariableReserve{get_reserve_enum(reserve.reserve_direction)}(
        name=reserve.name,
        available=reserve.available,
        deployed_fraction=reserve.deployed_fraction,
        max_output_fraction=reserve.max_output_fraction,
        max_participation_factor=reserve.max_participation_factor,
        requirement=reserve.requirement / PSY.get_base_power(resolver.sys),
        sustained_time=reserve.sustained_time,
        time_frame=reserve.time_frame,
    )
end
