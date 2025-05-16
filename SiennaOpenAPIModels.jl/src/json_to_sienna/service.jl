function openapi2psy(agc::AGC, resolver::Resolver)
    PSY.AGC(
        name=agc.name,
        available=agc.available,
        bias=agc.bias,
        K_p=agc.K_p,
        K_i=agc.K_i,
        K_d=agc.K_d,
        delta_t=agc.delta_t,
        area=resolver(agc.area),
        initial_ace=agc.initial_ace,
    )
end

function openapi2psy(reserve::ConstantReserve, resolver::Resolver)
    if PSY.get_base_power(resolver.sys) == 0.0
        error("base power is 0.0")
    end
    PSY.ConstantReserve{get_reserve_enum(reserve.reserve_direction)}(
        name=reserve.name,
        available=reserve.available,
        time_frame=reserve.time_frame,
        requirement=reserve.requirement / PSY.get_base_power(resolver.sys),
        sustained_time=reserve.sustained_time,
        max_output_fraction=reserve.max_output_fraction,
        max_participation_factor=reserve.max_participation_factor,
        deployed_fraction=reserve.deployed_fraction,
    )
end

function openapi2psy(reserve::ConstantReserveGroup, resolver::Resolver)
    if PSY.get_base_power(resolver.sys) == 0.0
        error("base power is 0.0")
    end
    PSY.ConstantReserveGroup{get_reserve_enum(reserve.reserve_direction)}(
        name=reserve.name,
        available=reserve.available,
        requirement=reserve.requirement / PSY.get_base_power(resolver.sys),
    )
end

function openapi2psy(reserve::ConstantReserveNonSpinning, resolver::Resolver)
    if PSY.get_base_power(resolver.sys) == 0.0
        error("base power is 0.0")
    end
    PSY.ConstantReserveNonSpinning(
        name=reserve.name,
        available=reserve.available,
        time_frame=reserve.time_frame,
        requirement=reserve.requirement / PSY.get_base_power(resolver.sys),
        sustained_time=reserve.sustained_time,
        max_output_fraction=reserve.max_output_fraction,
        max_participation_factor=reserve.max_participation_factor,
        deployed_fraction=reserve.deployed_fraction,
    )
end

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

function openapi2psy(reserve::VariableReserveNonSpinning, resolver::Resolver)
    if PSY.get_base_power(resolver.sys) == 0.0
        error("base power is 0.0")
    end
    PSY.VariableReserveNonSpinning(
        name=reserve.name,
        available=reserve.available,
        time_frame=reserve.time_frame,
        requirement=reserve.requirement / PSY.get_base_power(resolver.sys),
        sustained_time=reserve.sustained_time,
        max_output_fraction=reserve.max_output_fraction,
        max_participation_factor=reserve.max_participation_factor,
        deployed_fraction=reserve.deployed_fraction,
    )
end
