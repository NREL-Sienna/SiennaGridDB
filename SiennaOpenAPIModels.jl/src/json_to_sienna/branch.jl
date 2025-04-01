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

function openapi2psy(transform::Transformer2W, resolver::Resolver)
    if PSY.get_base_power(resolver.sys) == 0.0
        error("base power is 0.0")
    end
    PSY.Transformer2W(;
        name=transform.name,
        available=transform.available,
        active_power_flow=transform.active_power_flow / PSY.get_base_power(resolver.sys),
        reactive_power_flow=transform.reactive_power_flow /
                            PSY.get_base_power(resolver.sys),
        arc=resolver(transform.arc),
        r=transform.r,
        x=transform.x,
        primary_shunt=transform.primary_shunt,
        rating=transform.rating / PSY.get_base_power(resolver.sys),
    )
end

function openapi2psy(taptransform::TapTransformer, resolver::Resolver)
    if PSY.get_base_power(resolver.sys) == 0.0
        error("base power is 0.0")
    end
    PSY.TapTransformer(;
        name=taptransform.name,
        available=taptransform.available,
        active_power_flow=taptransform.active_power_flow / PSY.get_base_power(resolver.sys),
        reactive_power_flow=taptransform.reactive_power_flow /
                            PSY.get_base_power(resolver.sys),
        arc=resolver(taptransform.arc),
        r=taptransform.r,
        x=taptransform.x,
        primary_shunt=taptransform.primary_shunt,
        tap=taptransform.tap,
        rating=taptransform.rating,
    )
end
