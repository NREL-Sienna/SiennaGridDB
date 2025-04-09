function openapi2psy(area_interchange::AreaInterchange, resolver::Resolver)
    if PSY.get_base_power(resolver.sys) == 0.0
        error("base power is 0.0")
    end
    PSY.AreaInterchange(
        name=area_interchange.name,
        available=area_interchange.available,
        active_power_flow=area_interchange.active_power_flow /
                          PSY.get_base_power(resolver.sys),
        flow_limits=divide(
            get_tuple_fromto_tofrom(area_interchange.flow_limits),
            PSY.get_base_power(resolver.sys),
        ),
        from_area=resolver(area_interchange.from_area),
        to_area=resolver(area_interchange.to_area),
    )
end

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

function openapi2psy(monitored::MonitoredLine, resolver::Resolver)
    if PSY.get_base_power(resolver.sys) == 0.0
        error("base power is 0.0")
    end
    PSY.MonitoredLine(
        name=monitored.name,
        available=monitored.available,
        active_power_flow=monitored.active_power_flow / PSY.get_base_power(resolver.sys),
        reactive_power_flow=monitored.reactive_power_flow /
                            PSY.get_base_power(resolver.sys),
        arc=resolver(monitored.arc),
        r=monitored.r,
        x=monitored.x,
        b=get_tuple_from_to(monitored.b),
        flow_limits=divide(
            get_tuple_fromto_tofrom(monitored.flow_limits),
            PSY.get_base_power(resolver.sys),
        ),
        rating=monitored.rating / PSY.get_base_power(resolver.sys),
        angle_limits=get_tuple_min_max(monitored.angle_limits),
        g=get_tuple_from_to(monitored.g),
    )
end

function openapi2psy(transformer::PhaseShiftingTransformer, resolver::Resolver)
    if PSY.get_base_power(resolver.sys) == 0.0
        error("base power is 0.0")
    end
    PSY.PhaseShiftingTransformer(
        name=transformer.name,
        available=transformer.available,
        active_power_flow=transformer.active_power_flow / PSY.get_base_power(resolver.sys),
        reactive_power_flow=transformer.reactive_power_flow /
                            PSY.get_base_power(resolver.sys),
        arc=resolver(transformer.arc),
        r=transformer.r,
        x=transformer.x,
        primary_shunt=transformer.primary_shunt,
        tap=transformer.tap,
        α=transformer.alpha,
        rating=divide(transformer.rating, PSY.get_base_power(resolver.sys)),
        phase_angle_limits=get_tuple_min_max(transformer.phase_angle_limits),
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

function openapi2psy(hvdc::TwoTerminalHVDCLine, resolver::Resolver)
    if PSY.get_base_power(resolver.sys) == 0.0
        error("base power is 0.0")
    end
    PSY.TwoTerminalHVDCLine(
        name=hvdc.name,
        available=hvdc.available,
        active_power_flow=hvdc.active_power_flow / PSY.get_base_power(resolver.sys),
        arc=resolver(hvdc.arc),
        active_power_limits_from=divide(
            get_tuple_min_max(hvdc.active_power_limits_from),
            PSY.get_base_power(resolver.sys),
        ),
        active_power_limits_to=divide(
            get_tuple_min_max(hvdc.active_power_limits_to),
            PSY.get_base_power(resolver.sys),
        ),
        reactive_power_limits_from=divide(
            get_tuple_min_max(hvdc.reactive_power_limits_from),
            PSY.get_base_power(resolver.sys),
        ),
        reactive_power_limits_to=divide(
            get_tuple_min_max(hvdc.reactive_power_limits_to),
            PSY.get_base_power(resolver.sys),
        ),
        loss=get_sienna_value_curve(hvdc.loss),
    )
end
