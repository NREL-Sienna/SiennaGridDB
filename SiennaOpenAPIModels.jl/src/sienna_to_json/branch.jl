function psy2openapi(line::PSY.Line, ids::IDGenerator)
    Line(
        id = getid!(ids, line),
        name = line.name,
        available = line.available,
        active_power_flow = line.active_power_flow * PSY.get_base_power(line),
        reactive_power_flow = line.reactive_power_flow * PSY.get_base_power(line),
        arc = getid!(ids, line.arc),
        r = line.r,
        x = line.x,
        b = get_from_to(line.b),
        rating = line.rating * PSY.get_base_power(line),
        angle_limits = get_min_max(line.angle_limits),
        g = get_from_to(line.g),
    )
end

function psy2openapi(transformer2w::PSY.transformer2w, ids::IDGenerator)
    Transformer2W(
        id = getid!(ids, transformer2w),
        name = transformer2w.name,
        available = transformer2w.available,
        active_power_flow = transformer2w.active_power_flow * PSY.get_base_power(transformer2w),
        reactive_power_flow = transformer2w.reactive_power_flow * PSY.get_base_power(transformer2w),
        arc = getid!(ids, transformer2w.arc),
        r = transformer2w.r,
        x = transformer2w.x,
        rating = transformer2w.rating * PSY.get_base_power(transformer2w),
        primary_shunt = PSY.get_primary_shunt(transformer2w.primary_shunt),
    )
end

