function psy2openapi(area_interchange::PSY.AreaInterchange, ids::IDGenerator)
    if PSY.get_base_power(area_interchange) == 0.0
        error("base power is 0.0")
    end
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
    if PSY.get_base_power(branch) == 0.0
        error("base power is 0.0")
    end
    DiscreteControlledACBranch(
        id=getid!(ids, branch),
        name=branch.name,
        available=branch.available,
        active_power_flow=branch.active_power_flow * PSY.get_base_power(branch),
        reactive_power_flow=branch.reactive_power_flow * PSY.get_base_power(branch),
        arc=getid!(ids, branch.arc),
        r=branch.r * get_Z_fraction(
            PSY.get_base_voltage(PSY.get_arc(branch).from),
            PSY.get_base_power(branch),
        ),
        x=branch.x * get_Z_fraction(
            PSY.get_base_voltage(PSY.get_arc(branch).from),
            PSY.get_base_power(branch),
        ),
        rating=branch.rating * PSY.get_base_power(branch),
        discrete_branch_type=string(branch.discrete_branch_type),
        branch_status=string(branch.branch_status),
    )
end

function psy2openapi(line::PSY.Line, ids::IDGenerator)
    if PSY.get_base_power(line) == 0.0
        error("base power is 0.0")
    end
    Line(
        id=getid!(ids, line),
        name=line.name,
        available=line.available,
        active_power_flow=line.active_power_flow * PSY.get_base_power(line),
        reactive_power_flow=line.reactive_power_flow * PSY.get_base_power(line),
        arc=getid!(ids, line.arc),
        r=line.r * get_Z_fraction(
            PSY.get_base_voltage(PSY.get_arc(line).from),
            PSY.get_base_power(line),
        ),
        x=line.x * get_Z_fraction(
            PSY.get_base_voltage(PSY.get_arc(line).from),
            PSY.get_base_power(line),
        ),
        b=get_from_to(
            divide(
                line.b,
                get_Z_fraction(
                    PSY.get_base_voltage(PSY.get_arc(line).from),
                    PSY.get_base_power(line),
                ),
            ),
        ),
        rating=line.rating * PSY.get_base_power(line),
        angle_limits=get_min_max(line.angle_limits),
        rating_b=scale(line.rating_b, PSY.get_base_power(line)),
        rating_c=scale(line.rating_c, PSY.get_base_power(line)),
        g=get_from_to(
            divide(
                line.g,
                get_Z_fraction(
                    PSY.get_base_voltage(PSY.get_arc(line).from),
                    PSY.get_base_power(line),
                ),
            ),
        ),
    )
end

function psy2openapi(monitored::PSY.MonitoredLine, ids::IDGenerator)
    if PSY.get_base_power(monitored) == 0.0
        error("base power is 0.0")
    end
    MonitoredLine(
        id=getid!(ids, monitored),
        name=monitored.name,
        available=monitored.available,
        active_power_flow=monitored.active_power_flow * PSY.get_base_power(monitored),
        reactive_power_flow=monitored.reactive_power_flow * PSY.get_base_power(monitored),
        arc=getid!(ids, monitored.arc),
        r=monitored.r * get_Z_fraction(
            PSY.get_base_voltage(PSY.get_arc(monitored).from),
            PSY.get_base_power(monitored),
        ),
        x=monitored.x * get_Z_fraction(
            PSY.get_base_voltage(PSY.get_arc(monitored).from),
            PSY.get_base_power(monitored),
        ),
        b=get_from_to(
            divide(
                monitored.b,
                get_Z_fraction(
                    PSY.get_base_voltage(PSY.get_arc(monitored).from),
                    PSY.get_base_power(monitored),
                ),
            ),
        ),
        flow_limits=get_fromto_tofrom(
            scale(monitored.flow_limits, PSY.get_base_power(monitored)),
        ),
        rating=monitored.rating * PSY.get_base_power(monitored),
        angle_limits=get_min_max(monitored.angle_limits),
        rating_b=scale(monitored.rating_b, PSY.get_base_power(monitored)),
        rating_c=scale(monitored.rating_c, PSY.get_base_power(monitored)),
        g=get_from_to(
            divide(
                monitored.g,
                get_Z_fraction(
                    PSY.get_base_voltage(PSY.get_arc(monitored).from),
                    PSY.get_base_power(monitored),
                ),
            ),
        ),
    )
end

function psy2openapi(transformer::PSY.PhaseShiftingTransformer, ids::IDGenerator)
    if transformer.base_power == 0.0
        error("base power is 0.0")
    end
    PhaseShiftingTransformer(
        id=getid!(ids, transformer),
        name=transformer.name,
        available=transformer.available,
        active_power_flow=transformer.active_power_flow * transformer.base_power,
        reactive_power_flow=transformer.reactive_power_flow * transformer.base_power,
        arc=getid!(ids, transformer.arc),
        r=transformer.r *
          get_Z_fraction(transformer.base_voltage_primary, transformer.base_power), # assuming primary, not secondary, base voltage
        x=transformer.x *
          get_Z_fraction(transformer.base_voltage_primary, transformer.base_power), # assuming primary, not secondary, base voltage
        primary_shunt=get_complex_number(
            divide(
                transformer.primary_shunt,
                get_Z_fraction(transformer.base_voltage_primary, transformer.base_power),
            ),
        ), # assuming primary, not secondary, base voltage
        tap=transformer.tap,
        alpha=transformer.α,
        rating=scale(transformer.rating, transformer.base_power),
        base_power=transformer.base_power,
        base_voltage_primary=transformer.base_voltage_primary,
        base_voltage_secondary=transformer.base_voltage_secondary,
        rating_b=scale(transformer.rating_b, transformer.base_power),
        rating_c=scale(transformer.rating_c, transformer.base_power),
        phase_angle_limits=get_min_max(transformer.phase_angle_limits),
    )
end

function psy2openapi(phase3w::PSY.PhaseShiftingTransformer3W, ids::IDGenerator)
    if phase3w.base_power_12 == 0.0
        error("primary base power is 0.0")
    elseif phase3w.base_power_23 == 0.0
        error("secondary base power is 0.0")
    elseif phase3w.base_power_13 == 0.0
        error("tertiary base power is 0.0")
    end
    PhaseShiftingTransformer3W(
        id=getid!(ids, phase3w),
        name=phase3w.name,
        available=phase3w.available,
        primary_star_arc=getid!(ids, phase3w.primary_star_arc),
        secondary_star_arc=getid!(ids, phase3w.secondary_star_arc),
        tertiary_star_arc=getid!(ids, phase3w.tertiary_star_arc),
        star_bus=getid!(ids, phase3w.star_bus),
        active_power_flow_primary=phase3w.active_power_flow_primary * phase3w.base_power_12,
        reactive_power_flow_primary=phase3w.reactive_power_flow_primary *
                                    phase3w.base_power_12,
        active_power_flow_secondary=phase3w.active_power_flow_secondary *
                                    phase3w.base_power_23,
        reactive_power_flow_secondary=phase3w.reactive_power_flow_secondary *
                                      phase3w.base_power_23,
        active_power_flow_tertiary=phase3w.active_power_flow_tertiary *
                                   phase3w.base_power_13,
        reactive_power_flow_tertiary=phase3w.reactive_power_flow_tertiary *
                                     phase3w.base_power_13,
        r_primary=phase3w.r_primary *
                  get_Z_fraction(phase3w.base_voltage_primary, phase3w.base_power_12),
        x_primary=phase3w.x_primary *
                  get_Z_fraction(phase3w.base_voltage_primary, phase3w.base_power_12),
        r_secondary=phase3w.r_secondary *
                    get_Z_fraction(phase3w.base_voltage_secondary, phase3w.base_power_23),
        x_secondary=phase3w.x_secondary *
                    get_Z_fraction(phase3w.base_voltage_secondary, phase3w.base_power_23),
        r_tertiary=phase3w.r_tertiary *
                   get_Z_fraction(phase3w.base_voltage_tertiary, phase3w.base_power_13),
        x_tertiary=phase3w.x_tertiary *
                   get_Z_fraction(phase3w.base_voltage_tertiary, phase3w.base_power_13),
        rating=scale(phase3w.rating, phase3w.base_power_12),
        r_12=phase3w.r_12 *
             get_Z_fraction(phase3w.base_voltage_primary, phase3w.base_power_12),
        x_12=phase3w.x_12 *
             get_Z_fraction(phase3w.base_voltage_primary, phase3w.base_power_12),
        r_23=phase3w.r_23 *
             get_Z_fraction(phase3w.base_voltage_secondary, phase3w.base_power_23),
        x_23=phase3w.x_23 *
             get_Z_fraction(phase3w.base_voltage_secondary, phase3w.base_power_23),
        r_13=phase3w.r_13 *
             get_Z_fraction(phase3w.base_voltage_tertiary, phase3w.base_power_13),
        x_13=phase3w.x_13 *
             get_Z_fraction(phase3w.base_voltage_tertiary, phase3w.base_power_13),
        alpha_primary=phase3w.α_primary,
        alpha_secondary=phase3w.α_secondary,
        alpha_tertiary=phase3w.α_tertiary,
        base_power_12=phase3w.base_power_12,
        base_power_23=phase3w.base_power_23,
        base_power_13=phase3w.base_power_13,
        base_voltage_primary=phase3w.base_voltage_primary,
        base_voltage_secondary=phase3w.base_voltage_secondary,
        base_voltage_tertiary=phase3w.base_voltage_tertiary,
        g=phase3w.g / get_Z_fraction(phase3w.base_voltage_primary, phase3w.base_power_12),
        b=phase3w.b / get_Z_fraction(phase3w.base_voltage_primary, phase3w.base_power_12),
        primary_turns_ratio=phase3w.primary_turns_ratio,
        secondary_turns_ratio=phase3w.secondary_turns_ratio,
        tertiary_turns_ratio=phase3w.tertiary_turns_ratio,
        available_primary=phase3w.available_primary,
        available_secondary=phase3w.available_secondary,
        available_tertiary=phase3w.available_tertiary,
        rating_primary=phase3w.rating_primary * phase3w.base_power_12,
        rating_secondary=phase3w.rating_secondary * phase3w.base_power_23,
        rating_tertiary=phase3w.rating_tertiary * phase3w.base_power_13,
        phase_angle_limits=get_min_max(phase3w.phase_angle_limits),
    )
end

function psy2openapi(transformer::PSY.TapTransformer, ids::IDGenerator)
    if transformer.base_power == 0.0
        error("base power is 0.0")
    end
    TapTransformer(
        id=getid!(ids, transformer),
        name=transformer.name,
        available=transformer.available,
        active_power_flow=transformer.active_power_flow * transformer.base_power,
        reactive_power_flow=transformer.reactive_power_flow * transformer.base_power,
        arc=getid!(ids, transformer.arc),
        r=transformer.r *
          get_Z_fraction(transformer.base_voltage_primary, transformer.base_power), # assuming primary, not secondary, base voltage
        x=transformer.x *
          get_Z_fraction(transformer.base_voltage_primary, transformer.base_power), # assuming primary, not secondary, base voltage
        primary_shunt=get_complex_number(
            divide(
                transformer.primary_shunt,
                get_Z_fraction(transformer.base_voltage_primary, transformer.base_power),
            ),
        ), # assuming primary, not secondary, base voltage
        tap=transformer.tap,
        rating=transformer.rating,
        base_power=transformer.base_power,
        base_voltage_primary=transformer.base_voltage_primary,
        base_voltage_secondary=transformer.base_voltage_secondary,
        rating_b=scale(transformer.rating_b, transformer.base_power),
        rating_c=scale(transformer.rating_c, transformer.base_power),
    )
end

function psy2openapi(tmodel::PSY.TModelHVDCLine, ids::IDGenerator)
    if PSY.get_base_power(tmodel) == 0.0
        error("base power is 0.0")
    end
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
    if transformer2w.base_power == 0.0
        error("base power is 0.0")
    end
    Transformer2W(
        id=getid!(ids, transformer2w),
        name=transformer2w.name,
        available=transformer2w.available,
        active_power_flow=transformer2w.active_power_flow * transformer2w.base_power,
        reactive_power_flow=transformer2w.reactive_power_flow * transformer2w.base_power,
        arc=getid!(ids, transformer2w.arc),
        r=transformer2w.r *
          get_Z_fraction(transformer2w.base_voltage_primary, transformer2w.base_power),
        x=transformer2w.x *
          get_Z_fraction(transformer2w.base_voltage_primary, transformer2w.base_power),
        rating=scale(transformer2w.rating, transformer2w.base_power),
        base_power=transformer2w.base_power,
        base_voltage_primary=transformer2w.base_voltage_primary,
        base_voltage_secondary=transformer2w.base_voltage_secondary,
        rating_b=scale(transformer2w.rating_b, transformer2w.base_power),
        rating_c=scale(transformer2w.rating_c, transformer2w.base_power),
        primary_shunt=get_complex_number(
            divide(
                transformer2w.primary_shunt,
                get_Z_fraction(
                    transformer2w.base_voltage_primary,
                    transformer2w.base_power,
                ),
            ),
        ),
    )
end

function psy2openapi(trans3w::PSY.Transformer3W, ids::IDGenerator)
    if trans3w.base_power_12 == 0.0
        error("primary base power is 0.0")
    elseif trans3w.base_power_23 == 0.0
        error("secondary base power is 0.0")
    elseif trans3w.base_power_13 == 0.0
        error("tertiary base power is 0.0")
    end
    Transformer3W(
        id=getid!(ids, trans3w),
        name=trans3w.name,
        available=trans3w.available,
        primary_star_arc=getid!(ids, trans3w.primary_star_arc),
        secondary_star_arc=getid!(ids, trans3w.secondary_star_arc),
        tertiary_star_arc=getid!(ids, trans3w.tertiary_star_arc),
        star_bus=getid!(ids, trans3w.star_bus),
        active_power_flow_primary=trans3w.active_power_flow_primary * trans3w.base_power_12,
        reactive_power_flow_primary=trans3w.reactive_power_flow_primary *
                                    trans3w.base_power_12,
        active_power_flow_secondary=trans3w.active_power_flow_secondary *
                                    trans3w.base_power_23,
        reactive_power_flow_secondary=trans3w.reactive_power_flow_secondary *
                                      trans3w.base_power_23,
        active_power_flow_tertiary=trans3w.active_power_flow_tertiary *
                                   trans3w.base_power_13,
        reactive_power_flow_tertiary=trans3w.reactive_power_flow_tertiary *
                                     trans3w.base_power_13,
        r_primary=trans3w.r_primary *
                  get_Z_fraction(trans3w.base_voltage_primary, trans3w.base_power_12),
        x_primary=trans3w.x_primary *
                  get_Z_fraction(trans3w.base_voltage_primary, trans3w.base_power_12),
        r_secondary=trans3w.r_secondary *
                    get_Z_fraction(trans3w.base_voltage_secondary, trans3w.base_power_23),
        x_secondary=trans3w.x_secondary *
                    get_Z_fraction(trans3w.base_voltage_secondary, trans3w.base_power_23),
        r_tertiary=trans3w.r_tertiary *
                   get_Z_fraction(trans3w.base_voltage_tertiary, trans3w.base_power_13),
        x_tertiary=trans3w.x_tertiary *
                   get_Z_fraction(trans3w.base_voltage_tertiary, trans3w.base_power_13),
        rating=scale(trans3w.rating, trans3w.base_power_12),
        r_12=trans3w.r_12 *
             get_Z_fraction(trans3w.base_voltage_primary, trans3w.base_power_12),
        x_12=trans3w.x_12 *
             get_Z_fraction(trans3w.base_voltage_primary, trans3w.base_power_12),
        r_23=trans3w.r_23 *
             get_Z_fraction(trans3w.base_voltage_secondary, trans3w.base_power_23),
        x_23=trans3w.x_23 *
             get_Z_fraction(trans3w.base_voltage_secondary, trans3w.base_power_23),
        r_13=trans3w.r_13 *
             get_Z_fraction(trans3w.base_voltage_tertiary, trans3w.base_power_13),
        x_13=trans3w.x_13 *
             get_Z_fraction(trans3w.base_voltage_tertiary, trans3w.base_power_13),
        base_power_12=trans3w.base_power_12,
        base_power_23=trans3w.base_power_23,
        base_power_13=trans3w.base_power_13,
        base_voltage_primary=trans3w.base_voltage_primary,
        base_voltage_secondary=trans3w.base_voltage_secondary,
        base_voltage_tertiary=trans3w.base_voltage_tertiary,
        g=trans3w.g / get_Z_fraction(trans3w.base_voltage_primary, trans3w.base_power_12),
        b=trans3w.b / get_Z_fraction(trans3w.base_voltage_primary, trans3w.base_power_12),
        primary_turns_ratio=trans3w.primary_turns_ratio,
        secondary_turns_ratio=trans3w.secondary_turns_ratio,
        tertiary_turns_ratio=trans3w.tertiary_turns_ratio,
        available_primary=trans3w.available_primary,
        available_secondary=trans3w.available_secondary,
        available_tertiary=trans3w.available_tertiary,
        rating_primary=trans3w.rating_primary * trans3w.base_power_12,
        rating_secondary=trans3w.rating_secondary * trans3w.base_power_23,
        rating_tertiary=trans3w.rating_tertiary * trans3w.base_power_13,
    )
end

function psy2openapi(hvdc::PSY.TwoTerminalGenericHVDCLine, ids::IDGenerator)
    if PSY.get_base_power(hvdc) == 0.0
        error("base power is 0.0")
    end
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
    if PSY.get_base_power(lcc) == 0.0
        error("base power is 0.0")
    end
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
    if PSY.get_base_power(vsc) == 0.0
        error("base power is 0.0")
    end
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
        reactive_power_limits_from=get_min_max(
            scale(vsc.reactive_power_limits_from, PSY.get_base_power(vsc)),
        ),
        power_factor_weighting_fraction_from=vsc.power_factor_weighting_fraction_from,
        voltage_limits_from=get_min_max(vsc.voltage_limits_from),
        reactive_power_to=vsc.reactive_power_to * PSY.get_base_power(vsc),
        dc_voltage_control_to=vsc.dc_voltage_control_to,
        ac_voltage_control_to=vsc.ac_voltage_control_to,
        dc_setpoint_to=vsc.dc_setpoint_to,
        ac_setpoint_to=vsc.ac_setpoint_to,
        converter_loss_to=get_value_curve(vsc.converter_loss_to),
        max_dc_current_to=vsc.max_dc_current_to,
        rating_to=vsc.rating_to * PSY.get_base_power(vsc),
        reactive_power_limits_to=get_min_max(
            scale(vsc.reactive_power_limits_to, PSY.get_base_power(vsc)),
        ),
        power_factor_weighting_fraction_to=vsc.power_factor_weighting_fraction_to,
        voltage_limits_to=get_min_max(vsc.voltage_limits_to),
    )
end
