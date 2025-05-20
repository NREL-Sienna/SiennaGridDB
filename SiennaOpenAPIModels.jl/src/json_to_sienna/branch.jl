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

function openapi2psy(branch::DiscreteControlledACBranch, resolver::Resolver)
    if PSY.get_base_power(resolver.sys) == 0.0
        error("base power is 0.0")
    end
    PSY.DiscreteControlledACBranch(
        name=branch.name,
        available=branch.available,
        active_power_flow=branch.active_power_flow / PSY.get_base_power(resolver.sys),
        reactive_power_flow=branch.reactive_power_flow / PSY.get_base_power(resolver.sys),
        arc=resolver(branch.arc),
        r=branch.r,
        x=branch.x,
        rating=branch.rating / PSY.get_base_power(resolver.sys),
        discrete_branch_type=get_branchtype_enum(branch.discrete_branch_type),
        branch_status=get_branchstatus_enum(branch.branch_status),
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
        rating_b=divide(line.rating_b, PSY.get_base_power(resolver.sys)),
        rating_c=divide(line.rating_c, PSY.get_base_power(resolver.sys)),
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
        rating_b=divide(monitored.rating_b, PSY.get_base_power(resolver.sys)),
        rating_c=divide(monitored.rating_c, PSY.get_base_power(resolver.sys)),
        g=get_tuple_from_to(monitored.g),
    )
end

function openapi2psy(transformer::PhaseShiftingTransformer, resolver::Resolver)
    if transformer.base_power == 0.0
        error("base power is 0.0")
    end
    PSY.PhaseShiftingTransformer(
        name=transformer.name,
        available=transformer.available,
        active_power_flow=transformer.active_power_flow / transformer.base_power,
        reactive_power_flow=transformer.reactive_power_flow / transformer.base_power,
        arc=resolver(transformer.arc),
        r=transformer.r,
        x=transformer.x,
        primary_shunt=transformer.primary_shunt,
        tap=transformer.tap,
        α=transformer.alpha,
        rating=divide(transformer.rating, transformer.base_power),
        base_power=transformer.base_power,
        rating_b=divide(transformer.rating_b, transformer.base_power),
        rating_c=divide(transformer.rating_c, transformer.base_power),
        phase_angle_limits=get_tuple_min_max(transformer.phase_angle_limits),
    )
end

function openapi2psy(taptransform::TapTransformer, resolver::Resolver)
    if taptransform.base_power == 0.0
        error("base power is 0.0")
    end
    PSY.TapTransformer(;
        name=taptransform.name,
        available=taptransform.available,
        active_power_flow=taptransform.active_power_flow / taptransform.base_power,
        reactive_power_flow=taptransform.reactive_power_flow / taptransform.base_power,
        arc=resolver(taptransform.arc),
        r=taptransform.r,
        x=taptransform.x,
        primary_shunt=taptransform.primary_shunt,
        tap=taptransform.tap,
        rating=taptransform.rating,
        base_power=taptransform.base_power,
        rating_b=divide(taptransform.rating_b, taptransform.base_power),
        rating_c=divide(taptransform.rating_c, taptransform.base_power),
    )
end

function openapi2psy(tmodel::TModelHVDCLine, resolver::Resolver)
    if PSY.get_base_power(resolver.sys) == 0.0
        error("base power is 0.0")
    end
    PSY.TModelHVDCLine(
        name=tmodel.name,
        available=tmodel.available,
        active_power_flow=tmodel.active_power_flow / PSY.get_base_power(resolver.sys),
        arc=resolver(tmodel.arc),
        r=tmodel.r,
        l=tmodel.l,
        c=tmodel.c,
        active_power_limits_from=divide(
            get_tuple_min_max(tmodel.active_power_limits_from),
            PSY.get_base_power(resolver.sys),
        ),
        active_power_limits_to=divide(
            get_tuple_min_max(tmodel.active_power_limits_to),
            PSY.get_base_power(resolver.sys),
        ),
    )
end

function openapi2psy(transform::Transformer2W, resolver::Resolver)
    if transform.base_power == 0.0
        error("base power is 0.0")
    end
    PSY.Transformer2W(;
        name=transform.name,
        available=transform.available,
        active_power_flow=transform.active_power_flow / transform.base_power,
        reactive_power_flow=transform.reactive_power_flow / transform.base_power,
        arc=resolver(transform.arc),
        r=transform.r,
        x=transform.x,
        primary_shunt=transform.primary_shunt,
        rating=divide(transform.rating, transform.base_power),
        base_power=transform.base_power,
        rating_b=divide(transform.rating_b, transform.base_power),
        rating_c=divide(transform.rating_c, transform.base_power),
    )
end

function openapi2psy(hvdc::TwoTerminalGenericHVDCLine, resolver::Resolver)
    if PSY.get_base_power(resolver.sys) == 0.0
        error("base power is 0.0")
    end
    PSY.TwoTerminalGenericHVDCLine(
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

function openapi2psy(vsc::TwoTerminalVSCLine, resolver::Resolver)
    if PSY.get_base_power(resolver.sys) == 0.0
        error("base power is 0.0")
    end
    PSY.TwoTerminalVSCLine(
        name=vsc.name,
        available=vsc.available,
        arc=resolver(vsc.arc),
        active_power_flow=vsc.active_power_flow / PSY.get_base_power(resolver.sys),
        rating=vsc.rating / PSY.get_base_power(resolver.sys),
        active_power_limits_from=divide(
            get_tuple_min_max(vsc.active_power_limits_from),
            PSY.get_base_power(resolver.sys),
        ),
        active_power_limits_to=divide(
            get_tuple_min_max(vsc.active_power_limits_to),
            PSY.get_base_power(resolver.sys),
        ),
        g=vsc.g,
        dc_current=vsc.dc_current,
        reactive_power_from=vsc.reactive_power_from / PSY.get_base_power(resolver.sys),
        dc_voltage_control_from=vsc.dc_voltage_control_from,
        ac_voltage_control_from=vsc.ac_voltage_control_from,
        dc_setpoint_from=vsc.dc_setpoint_from,
        ac_setpoint_from=vsc.ac_setpoint_from,
        converter_loss_from=get_sienna_value_curve(vsc.converter_loss_from),
        max_dc_current_from=vsc.max_dc_current_from,
        rating_from=vsc.rating_from / PSY.get_base_power(resolver.sys),
        reactive_power_limits_from=get_tuple_min_max(vsc.reactive_power_limits_from),
        power_factor_weighting_fraction_from=vsc.power_factor_weighting_fraction_from,
        voltage_limits_from=get_tuple_min_max(vsc.voltage_limits_from),
        reactive_power_to=vsc.reactive_power_to / PSY.get_base_power(resolver.sys),
        dc_voltage_control_to=vsc.dc_voltage_control_to,
        ac_voltage_control_to=vsc.ac_voltage_control_to,
        dc_setpoint_to=vsc.dc_setpoint_to,
        ac_setpoint_to=vsc.ac_setpoint_to,
        converter_loss_to=get_sienna_value_curve(vsc.converter_loss_to),
        max_dc_current_to=vsc.max_dc_current_to,
        rating_to=vsc.rating_to,
        reactive_power_limits_to=get_tuple_min_max(vsc.reactive_power_limits_to),
        power_factor_weighting_fraction_to=vsc.power_factor_weighting_fraction_to,
        voltage_limits_to=get_tuple_min_max(vsc.voltage_limits_to),
    )
end
