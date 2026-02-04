function openapi2psy(round_rotor::RoundRotorMachine, resolver::Resolver)
    PSY.RoundRotorMachine(
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
        # a generic tuple, openapi2psy(SwitchedAdmittance).initial_status as reference for handling
        γ_d1=round_rotor.gamma_d1, # do not modify (DNM)
        γ_q1=round_rotor.gamma_q1, # DNM
        γ_d2=round_rotor.gamma_d2, # DNM
        γ_q2=round_rotor.gamma_q2, # DNM
        γ_qd=round_rotor.gamma_qd, # DNM
    )
end

function openapi2psy(sexs::SEXS, resolver::Resolver)
    PSY.SEXS(;
        Ta_Tb=sexs.Ta_Tb,
        Tb=sexs.Tb,
        K=sexs.K,
        Te=sexs.Te,
        V_lim=get_tuple_min_max(sexs.V_lim),
        V_ref=sexs.V_ref,
        states=map(string, sexs.states), # DNM
        n_states=sexs.states, # DNM
        states_types=map(string, sexs.states_types), # DNM
        # not sure how else to handle the states/states_types since they aren't an enum in PSY/src/definitions.jl
    )
end

function openapi2psy(gov1::SteamTurbineGov1, resolver::Resolver)
    PSY.SteamTurbineGov1(;
        R=gov1.R,
        T1=gov1.T1,
        valve_position_limits=get_tuple_min_max(gov1.valve_position_limits),
        T2=gov1.T2,
        T3=gov1.T3,
        D_T=gov1.D_T,
        DB_h=gov1.DB_h,
        DB_l=gov1.DB_l,
        T_rate=gov1.T_rate,
        P_ref=gov1.P_ref,
        states_types=map(string, gov1.states_types), # DNM
        # not sure how else to handle the states_types since its not an enum in PSY/src/definitions.jl
    )
end
