function psy2openapi(area_interchange::PSY.AreaInterchange, ids::IDGenerator)
    AreaInterchange(
        id=getid!(ids, area_interchange),
        name=area_interchange.name,
        available=area_interchange.available,
        active_power_flow=area_interchange.active_power_flow *
                          PSY.get_base_power(area_interchange),
        flow_limits=get_fromto_tofrom(
            scale(area_interchange.flow_limits, PSY.get_base_power(area_interchange)),
        ),
        from_area=getid!(ids, area_interchange.from_area),
        to_area=getid!(ids, area_interchange.to_area),
    )
end

function psy2openapi(branch::PSY.DiscreteControlledACBranch, ids::IDGenerator)
    DiscreteControlledACBranch(
        id=getid!(ids, branch),
        name=branch.name,
        available=branch.available,
        active_power_flow=branch.active_power_flow * PSY.get_base_power(branch),
        reactive_power_flow=branch.reactive_power_flow * PSY.get_base_power(branch),
        arc=getid!(ids, branch.arc),
        r=branch.r,
        x=branch.x,
        rating=branch.rating * PSY.get_base_power(branch),
        discrete_branch_type=string(branch.discrete_branch_type),
        branch_status=string(branch.branch_status),
    )
end

function psy2openapi(line::PSY.Line, ids::IDGenerator)
    Line(
        id=getid!(ids, line),
        name=line.name,
        available=line.available,
        active_power_flow=line.active_power_flow * PSY.get_base_power(line),
        reactive_power_flow=line.reactive_power_flow * PSY.get_base_power(line),
        arc=getid!(ids, line.arc),
        r=line.r,
        x=line.x,
        b=get_from_to(line.b),
        rating=line.rating * PSY.get_base_power(line),
        angle_limits=get_min_max(line.angle_limits),
        rating_b=scale(line.rating_b, PSY.get_base_power(line)),
        rating_c=scale(line.rating_c, PSY.get_base_power(line)),
        g=get_from_to(line.g),
    )
end

function psy2openapi(monitored::PSY.MonitoredLine, ids::IDGenerator)
    MonitoredLine(
        id=getid!(ids, monitored),
        name=monitored.name,
        available=monitored.available,
        active_power_flow=monitored.active_power_flow * PSY.get_base_power(monitored),
        reactive_power_flow=monitored.reactive_power_flow * PSY.get_base_power(monitored),
        arc=getid!(ids, monitored.arc),
        r=monitored.r,
        x=monitored.x,
        b=get_from_to(monitored.b),
        flow_limits=get_fromto_tofrom(
            scale(monitored.flow_limits, PSY.get_base_power(monitored)),
        ),
        rating=monitored.rating * PSY.get_base_power(monitored),
        angle_limits=get_min_max(monitored.angle_limits),
        rating_b=scale(monitored.rating_b, PSY.get_base_power(monitored)),
        rating_c=scale(monitored.rating_c, PSY.get_base_power(monitored)),
        g=get_from_to(monitored.g),
    )
end

function psy2openapi(transformer::PSY.PhaseShiftingTransformer, ids::IDGenerator)
    PhaseShiftingTransformer(
        id=getid!(ids, transformer),
        name=transformer.name,
        available=transformer.available,
        active_power_flow=transformer.active_power_flow * PSY.get_base_power(transformer),
        reactive_power_flow=transformer.reactive_power_flow *
                            PSY.get_base_power(transformer),
        arc=getid!(ids, transformer.arc),
        r=transformer.r,
        x=transformer.x,
        primary_shunt=transformer.primary_shunt,
        tap=transformer.tap,
        alpha=transformer.α,
        rating=scale(transformer.rating, PSY.get_base_power(transformer)),
        base_power=transformer.base_power,
        rating_b=scale(transformer.rating_b, PSY.get_base_power(transformer)),
        rating_c=scale(transformer.rating_c, PSY.get_base_power(transformer)),
        phase_angle_limits=get_min_max(transformer.phase_angle_limits),
    )
end

function psy2openapi(transformer::PSY.TapTransformer, ids::IDGenerator)
    TapTransformer(
        id=getid!(ids, transformer),
        name=transformer.name,
        available=transformer.available,
        active_power_flow=transformer.active_power_flow * PSY.get_base_power(transformer),
        reactive_power_flow=transformer.reactive_power_flow *
                            PSY.get_base_power(transformer),
        arc=getid!(ids, transformer.arc),
        r=transformer.r,
        x=transformer.x,
        primary_shunt=transformer.primary_shunt,
        tap=transformer.tap,
        rating=transformer.rating,
        base_power=transformer.base_power,
        rating_b=scale(transformer.rating_b, PSY.get_base_power(transformer)),
        rating_c=scale(transformer.rating_c, PSY.get_base_power(transformer)),
    )
end

function psy2openapi(tmodel::PSY.TModelHVDCLine, ids::IDGenerator)
    TModelHVDCLine(
        id=getid!(ids, tmodel),
        name=tmodel.name,
        available=tmodel.available,
        active_power_flow=tmodel.active_power_flow * PSY.get_base_power(tmodel),
        arc=getid!(ids, tmodel.arc),
        r=tmodel.r,
        l=tmodel.l,
        c=tmodel.c,
        active_power_limits_from=get_min_max(
            scale(tmodel.active_power_limits_from, PSY.get_base_power(tmodel)),
        ),
        active_power_limits_to=get_min_max(
            scale(tmodel.active_power_limits_to, PSY.get_base_power(tmodel)),
        ),
    )
end

function psy2openapi(transformer2w::PSY.Transformer2W, ids::IDGenerator)
    Transformer2W(
        id=getid!(ids, transformer2w),
        name=transformer2w.name,
        available=transformer2w.available,
        active_power_flow=transformer2w.active_power_flow *
                          PSY.get_base_power(transformer2w),
        reactive_power_flow=transformer2w.reactive_power_flow *
                            PSY.get_base_power(transformer2w),
        arc=getid!(ids, transformer2w.arc),
        r=transformer2w.r,
        x=transformer2w.x,
        rating=scale(transformer2w.rating, PSY.get_base_power(transformer2w)),
        base_power=transformer2w.base_power,
        rating_b=scale(transformer2w.rating_b, PSY.get_base_power(transformer2w)),
        rating_c=scale(transformer2w.rating_c, PSY.get_base_power(transformer2w)),
        primary_shunt=transformer2w.primary_shunt,
    )
end

function psy2openapi(hvdc::PSY.TwoTerminalGenericHVDCLine, ids::IDGenerator)
    TwoTerminalGenericHVDCLine(
        id=getid!(ids, hvdc),
        name=hvdc.name,
        available=hvdc.available,
        active_power_flow=hvdc.active_power_flow * PSY.get_base_power(hvdc),
        arc=getid!(ids, hvdc.arc),
        active_power_limits_from=get_min_max(
            scale(hvdc.active_power_limits_from, PSY.get_base_power(hvdc)),
        ),
        active_power_limits_to=get_min_max(
            scale(hvdc.active_power_limits_to, PSY.get_base_power(hvdc)),
        ),
        reactive_power_limits_from=get_min_max(
            scale(hvdc.reactive_power_limits_from, PSY.get_base_power(hvdc)),
        ),
        reactive_power_limits_to=get_min_max(
            scale(hvdc.reactive_power_limits_to, PSY.get_base_power(hvdc)),
        ),
        loss=TwoTerminalLoss(get_value_curve(hvdc.loss)),
    )
end

function psy2openapi(lcc::PSY.TwoTerminalLCCLine, ids::IDGenerator)
    TwoTerminalLCCLine(
        id=getid!(ids, lcc),
        name=lcc.name,
        available=lcc.available,
        arc=getid!(ids, lcc.arc),
        active_power_flow=lcc.active_power_flow * PSY.get_base_power(lcc),
        r=lcc.r,
        transfer_setpoint=lcc.transfer_setpoint,
        scheduled_dc_voltage=lcc.scheduled_dc_voltage,
        rectifier_bridges=lcc.rectifier_bridges,
        rectifier_delay_angle_limits=get_min_max(lcc.rectifier_delay_angle_limits),
        rectifier_rc=lcc.rectifier_rc,
        rectifier_xc=lcc.rectifier_xc,
        rectifier_base_voltage=lcc.rectifier_base_voltage,
        inverter_bridges=lcc.inverter_bridges,
        inverter_extinction_angle_limits=get_min_max(lcc.inverter_extinction_angle_limits),
        inverter_rc=lcc.inverter_rc,
        inverter_xc=lcc.inverter_xc,
        inverter_base_voltage=lcc.inverter_base_voltage,
        power_mode=lcc.power_mode,
        switch_mode_voltage=lcc.switch_mode_voltage,
        compounding_resistance=lcc.compounding_resistance,
        min_compounding_voltage=lcc.min_compounding_voltage,
        rectifier_transformer_ratio=lcc.rectifier_transformer_ratio,
        rectifier_tap_setting=lcc.rectifier_tap_setting,
        rectifier_tap_limits=get_min_max(lcc.rectifier_tap_limits),
        rectifier_tap_step=lcc.rectifier_tap_step,
        rectifier_delay_angle=lcc.rectifier_delay_angle,
        rectifier_capacitor_reactance=lcc.rectifier_capacitor_reactance,
        inverter_transformer_ratio=lcc.inverter_transformer_ratio,
        inverter_tap_setting=lcc.inverter_tap_setting,
        inverter_tap_limits=get_min_max(lcc.inverter_tap_limits),
        inverter_tap_step=lcc.inverter_tap_step,
        inverter_extinction_angle=lcc.inverter_extinction_angle,
        inverter_capacitor_reactance=lcc.inverter_capacitor_reactance,
        active_power_limits_from=get_min_max(
            scale(lcc.active_power_limits_from, PSY.get_base_power(lcc)),
        ),
        active_power_limits_to=get_min_max(
            scale(lcc.active_power_limits_to, PSY.get_base_power(lcc)),
        ),
        reactive_power_limits_from=get_min_max(
            scale(lcc.reactive_power_limits_from, PSY.get_base_power(lcc)),
        ),
        reactive_power_limits_to=get_min_max(
            scale(lcc.reactive_power_limits_to, PSY.get_base_power(lcc)),
        ),
        loss=TwoTerminalLoss(get_value_curve(lcc.loss)),
    )
end

function psy2openapi(vsc::PSY.TwoTerminalVSCLine, ids::IDGenerator)
    TwoTerminalVSCLine(
        id=getid!(ids, vsc),
        name=vsc.name,
        available=vsc.available,
        arc=getid!(ids, vsc.arc),
        active_power_flow=vsc.active_power_flow * PSY.get_base_power(vsc),
        rating=vsc.rating * PSY.get_base_power(vsc),
        active_power_limits_from=get_min_max(
            scale(vsc.active_power_limits_from, PSY.get_base_power(vsc)),
        ),
        active_power_limits_to=get_min_max(
            scale(vsc.active_power_limits_to, PSY.get_base_power(vsc)),
        ),
        g=vsc.g,
        dc_current=vsc.dc_current,
        reactive_power_from=vsc.reactive_power_from * PSY.get_base_power(vsc),
        dc_voltage_control_from=vsc.dc_voltage_control_from,
        ac_voltage_control_from=vsc.ac_voltage_control_from,
        dc_setpoint_from=vsc.dc_setpoint_from,
        ac_setpoint_from=vsc.ac_setpoint_from,
        converter_loss_from=get_value_curve(vsc.converter_loss_from),
        max_dc_current_from=vsc.max_dc_current_from,
        rating_from=vsc.rating_from * PSY.get_base_power(vsc),
        reactive_power_limits_from=get_min_max(vsc.reactive_power_limits_from),
        power_factor_weighting_fraction_from=vsc.power_factor_weighting_fraction_from,
        voltage_limits_from=get_min_max(vsc.voltage_limits_from),
        reactive_power_to=vsc.reactive_power_to * PSY.get_base_power(vsc),
        dc_voltage_control_to=vsc.dc_voltage_control_to,
        ac_voltage_control_to=vsc.ac_voltage_control_to,
        dc_setpoint_to=vsc.dc_setpoint_to,
        ac_setpoint_to=vsc.ac_setpoint_to,
        converter_loss_to=get_value_curve(vsc.converter_loss_to),
        max_dc_current_to=vsc.max_dc_current_to,
        rating_to=vsc.rating_to,
        reactive_power_limits_to=get_min_max(vsc.reactive_power_limits_to),
        power_factor_weighting_fraction_to=vsc.power_factor_weighting_fraction_to,
        voltage_limits_to=get_min_max(vsc.voltage_limits_to),
    )
end
