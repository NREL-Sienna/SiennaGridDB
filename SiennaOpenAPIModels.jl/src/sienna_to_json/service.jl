function psy2openapi(reserve::PSY.ConstantReserveGroup{T}, ids::IDGenerator) where {T}
    ConstantReserveGroup(
        id=getid!(ids, reserve),
        name=reserve.name,
        available=reserve.available,
        requirement=reserve.requirement * PSY.get_base_power(reserve),
        reserve_direction=get_reserve_direction(T),
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
