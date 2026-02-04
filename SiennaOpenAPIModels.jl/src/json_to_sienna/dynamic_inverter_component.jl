function openapi2psy(controller::ActiveRenewableControllerAB, resolver::Resolver)
    PSY.ActiveRenewableControllerAB(
        bus_control=controller.bus_control,
        from_branch_control=controller.from_branch_control,
        to_branch_control=controller.to_branch_control,
        branch_id_control=controller.branch_id_control,
        # above 4 variables are ints representing objects id, 0 indicates a special case
        # I am not sure if i need to wrap them in resolver
        Freq_Flag=Int(controller.Freq_Flag), # parses true as 1, false as 0
        K_pg=controller.K_pg,
        K_ig=controller.K_ig,
        T_p=controller.T_p,
        fdbd_pnts=get_tuple_fdbd_pnts(controller.fdbd_pnts),
        fe_lim=get_tuple_min_max(controller.fe_lim),
        P_lim=get_tuple_min_max(controller.P_lim),
        T_g=controller.T_g,
        D_dn=controller.D_dn,
        D_up=controller.D_up,
        dP_lim=get_tuple_min_max(controller.dP_lim),
        P_lim_inner=get_tuple_min_max(controller.P_lim_inner),
        T_pord=controller.T_pord,
        P_ref=controller.P_ref,
    )
end

function openapi2psy(controller::RECurrentControlB, resolver::Resolver)
    PSY.RECurrentControlB(
        Q_Flag=Int(controller.Q_Flag),
        PQ_Flag=Int(controller.PQ_Flag),
        Vdip_lim=get_tuple_min_max(controller.Vdip_lim),
        T_rv=controller.T_rv,
        dbd_pnts=get_tuple_dbd_pnts(controller.dbd_pnts),
        K_qv=controller.K_qv,
        Iqinj_lim=get_tuple_min_max(controller.Iqinj_lim),
        V_ref0=controller.V_ref0,
        K_vp=controller.K_vp,
        K_vi=controller.K_vi,
        T_iq=controller.T_iq,
        I_max=controller.I_max,
    )
end

function openapi2psy(controller::ReactiveRenewableControllerAB, resolver::Resolver)
    PSY.ReactiveRenewableControllerAB(
        bus_control=controller.bus_control,
        from_branch_control=controller.from_branch_control,
        to_branch_control=controller.to_branch_control,
        branch_id_control=controller.branch_id_control,
        # above 4 variables are ints representing objects id, 0 indicates a special case
        # I am not sure if i need to wrap them in resolver
        VC_Flag=Int(controller.VC_Flag),
        Ref_Flag=Int(controller.Ref_Flag),
        PF_Flag=Int(controller.PF_Flag),
        V_Flag=Int(controller.V_Flag),
        T_fltr=controller.T_fltr,
        K_p=controller.K_p,
        K_i=controller.K_i,
        T_ft=controller.T_ft,
        T_fv=controller.T_fv,
        V_frz=controller.V_frz,
        R_c=controller.R_c,
        X_c=controller.X_c,
        K_c=controller.K_c,
        e_lim=get_tuple_min_max(controller.e_lim),
        dbd_pnts=get_tuple_dbd_pnts(controller.dbd_pnts),
        Q_lim=get_tuple_min_max(controller.Q_lim),
        T_p=controller.T_p,
        Q_lim_inner=get_tuple_min_max(controller.Q_lim_inner),
        V_lim=get_tuple_min_max(controller.V_lim),
        K_qp=controller.K_qp,
        K_qi=controller.K_qi,
        Q_ref=controller.Q_ref,
        V_ref=controller.V_ref,
    )
end

function openapi2psy(energy_conv::RenewableEnergyConverterTypeA, resolver::Resolver)
    PSY.RenewableEnergyConverterTypeA(
        T_g=energy_conv.T_g,
        Rrpwr=energy_conv.Rrpwr,
        Brkpt=energy_conv.Brkpt,
        Zerox=energy_conv.Zerox,
        Lvpl1=energy_conv.Lvpl1,
        Vo_lim=energy_conv.Vo_lim,
        Lv_pnts=get_tuple_min_max(energy_conv.Lv_pnts),
        Io_lim=energy_conv.Io_lim,
        T_fltr=energy_conv.T_fltr,
        K_hv=energy_conv.K_hv,
        Iqr_lims=get_tuple_min_max(energy_conv.Iqr_lims),
        Accel=energy_conv.Accel,
        Lvpl_sw=Int(energy_conv.Lvpl_sw),
        Q_ref=energy_conv.Q_ref,
        R_source=energy_conv.R_source,
        X_source=energy_conv.X_source,
    )
end
