function psy2openapi(round_rotor::PSY.RoundRotorMachine, ids::IDGenerator)
    RoundRotorMachine(
        id=getid!(ids, round_rotor),
        R=round_rotor.R,
        Td0_p=round_rotor.Td0_p,
        Td0_pp=round_rotor.Td0_pp,
        Tq0_p=round_rotor.Tq0_p,
        Tq0_pp=round_rotor.Tq0_pp,
        Xd=round_rotor.Xd,
        Xq=round_rotor.Xq,
        Xd_p=round_rotor.Xd_p,
        Xq_p=round_rotor.Xq_p,
        Xd_pp=round_rotor.Xd_pp,
        Xl=round_rotor.Xl,
        Se=round_rotor.Se,
        # a generic tuple, psy2openapi(SwitchedAdmittance).initial_status as reference for handling
        gamma_d1=round_rotor.γ_d1, # do not modify (DNM)
        gamma_q1=round_rotor.γ_q1, # DNM
        gamma_d2=round_rotor.γ_d2, # DNM
        gamma_q2=round_rotor.γ_q2, # DNM
        gamma_qd=round_rotor.γ_qd, # DNM
        states=map(string, round_rotor.states), # DNM
        n_states=round_rotor.n_states, # DNM
    )
end

function psy2openapi(sexs::PSY.SEXS, ids::IDGenerator)
    SEXS(
        id=getid!(ids, sexs),
        Ta_Tb=sexs.Ta_Tb,
        Tb=sexs.Tb,
        K=sexs.K,
        Te=sexs.Te,
        V_lim=get_min_max(sexs.V_lim),
        V_ref=sexs.V_ref,
        states=map(string, sexs.states), # DNM
        n_states=sexs.states, # DNM
        states_types=map(string, sexs.states_types), # DNM
    )
end

function psy2openapi(gov1::PSY.SteamTurbineGov1, ids::IDGenerator)
    SteamTurbineGov1(
        id=getid!(ids, gov1),
        R=gov1.R,
        T1=gov1.T1,
        valve_position_limits=get_min_max(gov1.valve_position_limits),
        T2=gov1.T2,
        T3=gov1.T3,
        D_T=gov1.D_T,
        DB_h=gov1.DB_h,
        DB_l=gov1.DB_l,
        T_rate=gov1.T_rate,
        P_ref=gov1.P_ref,
        states=map(string, gov1.states), # DNM
        n_states=gov1.n_states, # DNM
        states_types=map(string, gov1.states_types), # DNM
    )
end
