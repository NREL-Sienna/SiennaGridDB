function openapi2psy(line::Line, resolver::Resolver)
    if PSY.get_base_power(resolver.sys) == 0.0
        error("base power is 0.0")
    end
    PSY.Line(;
        name=line.name,
        available=line.available,
        active_power_flow=line.active_power_flow / PSY.get_base_power(resolver.sys),
        reactive_power_flow=line.reactive_power_flow / PSY.get_base_power(resolver.sys),
        arc=resolver(line.arc),
        r=line.r,
        x=line.x,
        b=get_tuple_from_to(line.b),
        rating=line.rating / PSY.get_base_power(resolver.sys),
        angle_limits=get_tuple_min_max(line.angle_limits),
        g=get_tuple_from_to(line.g),
    )
end
