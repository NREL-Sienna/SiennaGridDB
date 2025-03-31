function openapi2psy(line::Line, resolver::Resolver)
    if line.base_power == 0.0
        error("base power is 0.0")
    end
    PSY.Line(;
        name=line.name,
        available=line.available,
        active_power_flow=line.active_power_flow / line.base_power,
        reactive_power_flow=line.reactive_power_flow / line.base_power,
        arc=resolver(line.arc),
        r=line.r,
        x=line.x,
        b=get_tuple_from_to(line.b),
        rating=line.rating / line.base_power,
        rating=line.rating,
        angle_limits=get_tuple_min_max(line.angle_limits),
        g=get_tuple_from_to(line.g),
    )
end
