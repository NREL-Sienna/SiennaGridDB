function psy2openapi(agc::PSY.AGC, ids::IDGenerator)
    AGC(
        id=getid!(ids, agc),
        name=agc.name,
        available=agc.available,
        bias=agc.bias,
        K_p=agc.K_p,
        K_i=agc.K_i,
        K_d=agc.K_d,
        delta_t=agc.delta_t,
        area=getid!(ids, agc.area),
        initial_ace=agc.initial_ace,
    )
end

function psy2openapi(reserve::PSY.VariableReserve{T}, ids::IDGenerator) where {T}
    VariableReserve(
        id=getid!(ids, reserve),
        name=reserve.name,
        available=reserve.available,
        deployed_fraction=reserve.deployed_fraction,
        max_output_fraction=reserve.max_output_fraction,
        max_participation_factor=reserve.max_participation_factor,
        requirement=reserve.requirement * PSY.get_base_power(reserve),
        reserve_direction=get_reserve_direction(T),
        sustained_time=reserve.sustained_time,
        time_frame=reserve.time_frame,
    )
end
