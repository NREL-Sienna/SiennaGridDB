function psy2openapi(reserve::PSY.ConstantReserve{T}, ids::IDGenerator) where {T}
    ConstantReserve(
        id=getid!(ids, reserve),
        name=reserve.name,
        available=reserve.available,
        time_frame=reserve.time_frame,
        requirement=reserve.requirement * PSY.get_base_power(reserve),
        sustained_time=reserve.sustained_time,
        max_output_fraction=reserve.max_output_fraction,
        max_participation_factor=reserve.max_participation_factor,
        deployed_fraction=reserve.deployed_fraction,
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
