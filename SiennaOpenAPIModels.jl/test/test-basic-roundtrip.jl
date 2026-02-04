using SiennaOpenAPIModels
using OpenAPI
using PowerSystemCaseBuilder
import PowerSystems as PSY
using JSON

function jsondiff(j1::S, j2::S) where {S <: Union{String, Int64, Float64, Bool}}
    if j1 == j2
        return true
    else
        @warn "Values $j1 does not match $j2"
        return false
    end
end

function jsondiff(j1::S, j2::S) where {S}
    error("Unsuported type $S")
end

function jsondiff(j1::S, j2::T) where {S, T}
    @warn "Type $j1 :: $S does not match $j2 :: $T"
    return false
end

function jsondiff(j1::AbstractDict{K, S}, j2::AbstractDict{K, T}) where {K, S, T}
    if keys(j1) != keys(j2)
        k1_sub_k2 = setdiff(keys(j1), keys(j2))
        k2_sub_k1 = setdiff(keys(j2), keys(j1))
        @warn "Keys do not match: $k1_sub_k2 and $k2_sub_k1"
        return false
    end
    for k in keys(j1)
        jsondiff(j1[k], j2[k]) || return false
    end
    return true
end

function jsondiff(j1::AbstractArray{S}, j2::AbstractArray{T}) where {S, T}
    if length(j1) != length(j2)
        @warn "Length $j1 does not match $j2"
        return false
    end
    for k in keys(j1)
        jsondiff(j1[k], j2[k]) || return false
    end
    return true
end

function test_roundtrip(openapi_model, data)
    post_json = OpenAPI.from_json(openapi_model, JSON.parse(OpenAPI.to_json(data)))
    @test typeof(data) == typeof(post_json)
    @test data == post_json
    @test jsondiff(
        JSON.parse(OpenAPI.to_json(data)),
        JSON.parse(OpenAPI.to_json(post_json)),
    )
end

@testset "AC_TWO_RTO_RTS_5min_sys RoundTrip to JSON" begin
    AC_TWO_RTS = PowerSystemCaseBuilder.build_system(
        PowerSystemCaseBuilder.PSISystems,
        "AC_TWO_RTO_RTS_5min_sys",
    )
    @testset "ACBus to JSON" begin
        acbus = PSY.get_bus(AC_TWO_RTS, 10201)
        @test isa(acbus, PSY.ACBus)
        test_convert = SiennaOpenAPIModels.psy2openapi(acbus, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.ACBus, test_convert)
        @test test_convert.id == 1
        @test test_convert.number == 10201
        @test test_convert.area == 2
        @test isnothing(test_convert.load_zone)
        @test test_convert.magnitude == 1.04841
    end
    @testset "AGC to JSON" begin
        agc = PSY.AGC(
            name="agc",
            available=true,
            bias=1.6,
            K_p=3.0,
            K_i=1.0,
            K_d=4.0,
            delta_t=0.1,
        )
        PSY.add_component!(AC_TWO_RTS, agc)
        @test isa(agc, PSY.AGC)
        test_convert = SiennaOpenAPIModels.psy2openapi(agc, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.AGC, test_convert)
        @test test_convert.id == 1
        @test test_convert.available
        @test test_convert.bias == 1.6
        @test test_convert.K_i == 1.0
        @test test_convert.delta_t == 0.1
        @test isnothing(test_convert.area)
        @test test_convert.initial_ace == 0.0
    end
    @testset "Arc to JSON" begin
        arc = first(PSY.get_components(PSY.Arc, AC_TWO_RTS))
        @test isa(arc, PSY.Arc)
        test_convert = SiennaOpenAPIModels.psy2openapi(arc, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.Arc, test_convert)
        @test test_convert.id == 1
        @test test_convert.from == 2
        @test test_convert.to == 3
    end
    @testset "Area to JSON" begin
        area = PSY.get_component(PSY.Area, AC_TWO_RTS, "1")
        @test isa(area, PSY.Area)
        area.peak_active_power = 1.0
        area.peak_reactive_power = 2.0
        test_convert = SiennaOpenAPIModels.psy2openapi(area, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.Area, test_convert)
        @test test_convert.id == 1
        @test test_convert.name == "1"
        @test test_convert.peak_active_power == 100.0
        @test test_convert.peak_reactive_power == 200.0
    end
    @testset "ConstantReserve UP to JSON" begin
        reserve = PSY.ConstantReserve{PSY.ReserveUp}(
            name="constant_reserve_up",
            available=true,
            time_frame=300.0,
            requirement=0.77,
        )
        PSY.add_component!(AC_TWO_RTS, reserve)
        @test reserve isa PSY.ConstantReserve{PSY.ReserveUp}
        test_convert = SiennaOpenAPIModels.psy2openapi(reserve, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.ConstantReserve, test_convert)
        @test test_convert.id == 1
        @test test_convert.time_frame == 300.0
        @test test_convert.requirement == 77.0
        @test test_convert.sustained_time == 3600.0
        @test test_convert.max_output_fraction == 1.0
        @test test_convert.reserve_direction == "UP"
    end
    @testset "ConstantReserveGroup SYMMETRIC to JSON" begin
        reserve = PSY.ConstantReserveGroup{PSY.ReserveSymmetric}(
            name="constant_reserve_group",
            available=true,
            requirement=0.77,
        )
        PSY.add_component!(AC_TWO_RTS, reserve)
        @test reserve isa PSY.ConstantReserveGroup{PSY.ReserveSymmetric}
        test_convert = SiennaOpenAPIModels.psy2openapi(reserve, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.ConstantReserveGroup, test_convert)
        @test test_convert.id == 1
        @test test_convert.requirement == 77.0
        @test test_convert.reserve_direction == "SYMMETRIC"
    end
    @testset "ConstantReserveNonSpinning to JSON" begin
        reserve = PSY.ConstantReserveNonSpinning(
            name="reserve_non_spinning",
            available=true,
            time_frame=300.0,
            requirement=0.77,
        )
        PSY.add_component!(AC_TWO_RTS, reserve)
        @test isa(reserve, PSY.ConstantReserveNonSpinning)
        test_convert = SiennaOpenAPIModels.psy2openapi(reserve, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.ConstantReserveNonSpinning, test_convert)
        @test test_convert.id == 1
        @test test_convert.available
        @test test_convert.time_frame == 300.0
        @test test_convert.requirement == 77.0
        @test test_convert.sustained_time == 3600.0
        @test test_convert.max_output_fraction == 1.0
        @test test_convert.deployed_fraction == 0.0
    end
    @testset "EnergyReservoirStorage to JSON" begin
        energy_res =
            PSY.get_component(PSY.EnergyReservoirStorage, AC_TWO_RTS, "313_STORAGE_1")
        @test isa(energy_res, PSY.EnergyReservoirStorage)
        test_convert = SiennaOpenAPIModels.psy2openapi(energy_res, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.EnergyReservoirStorage, test_convert)
        @test test_convert.id == 1
        @test test_convert.prime_mover_type == "BA"
        @test test_convert.base_power == 500.0
        @test test_convert.cycle_limits == 10000
    end
    @testset "FixedAdmittance to JSON" begin
        fixedadmit = PSY.get_component(PSY.FixedAdmittance, AC_TWO_RTS, "Camus")
        @test isa(fixedadmit, PSY.FixedAdmittance)
        test_convert = SiennaOpenAPIModels.psy2openapi(fixedadmit, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.FixedAdmittance, test_convert)
        @test test_convert.id == 1
        @test test_convert.available
        @test isnothing(test_convert.dynamic_injector)
    end
    @testset "HydroDispatch to JSON" begin
        hydro = PSY.get_component(PSY.HydroDispatch, AC_TWO_RTS, "201_HYDRO_4")
        @test isa(hydro, PSY.HydroDispatch)
        test_convert = SiennaOpenAPIModels.psy2openapi(hydro, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.HydroDispatch, test_convert)
        @test test_convert.id == 1
        @test test_convert.available
        @test test_convert.bus == 2
        @test test_convert.rating == 52.49761899362675
        @test test_convert.prime_mover_type == "HY"
    end
    @testset "HydroReservoir to JSON" begin
        hydro_res = PSY.get_component(
            PSY.HydroReservoir,
            AC_TWO_RTS,
            "222_HYDRO_4_RESERVOIR_head_twin",
        )
        @test isa(hydro_res, PSY.HydroReservoir)
        test_convert = SiennaOpenAPIModels.psy2openapi(hydro_res, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.HydroReservoir, test_convert)
        @test test_convert.id == 1
        @test test_convert.available
        @test test_convert.storage_level_limits.max == 20.0
        @test test_convert.initial_level == 10.0
        @test first(test_convert.downstream_turbines) == 2
    end
    @testset "HydroTurbine to JSON" begin
        turbine = PSY.get_component(PSY.HydroTurbine, AC_TWO_RTS, "215_HYDRO_3")
        @test isa(turbine, PSY.HydroTurbine)
        test_convert = SiennaOpenAPIModels.psy2openapi(turbine, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.HydroTurbine, test_convert)
        @test test_convert.id == 1
        @test test_convert.bus == 2
        @test test_convert.reactive_power == 16.0
        @test test_convert.active_power_limits.max == 50.0
        @test test_convert.prime_mover_type == "HY"
        @test test_convert.turbine_type == "UNKNOWN"
    end
    @testset "Line to JSON" begin
        line = PSY.get_component(PSY.Line, AC_TWO_RTS, "B27")
        @test isa(line, PSY.Line)
        test_convert = SiennaOpenAPIModels.psy2openapi(line, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.Line, test_convert)
        @test test_convert.id == 1
        @test test_convert.arc == 2
        @test test_convert.rating == 500.0
    end
    @testset "LoadZone to JSON" begin
        load_zone = PSY.get_component(PSY.LoadZone, AC_TWO_RTS, "13.0_twin")
        @test isa(load_zone, PSY.LoadZone)
        test_convert = SiennaOpenAPIModels.psy2openapi(load_zone, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.LoadZone, test_convert)
        @test test_convert.id == 1
        @test test_convert.name == "13.0_twin"
        @test test_convert.peak_active_power == 370.0
        @test test_convert.peak_reactive_power == 76.0
    end
    @testset "MonitoredLine to JSON" begin
        monitored = only(collect(PSY.get_components(PSY.MonitoredLine, AC_TWO_RTS)))
        @test isa(monitored, PSY.MonitoredLine)
        test_convert = SiennaOpenAPIModels.psy2openapi(monitored, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.MonitoredLine, test_convert)
        @test test_convert.id == 1
        @test test_convert.active_power_flow == 0.0
        @test test_convert.rating == 175.0
        @test test_convert.flow_limits.from_to == 200.0
    end
    @testset "MotorLoad to JSON" begin
        motor_load = PSY.MotorLoad(
            name="motor_load",
            available=true,
            bus=PSY.get_bus(AC_TWO_RTS, 10201),
            active_power=0.5,
            reactive_power=0.2,
            base_power=10.0,
            rating=1.0,
            max_active_power=0.75,
            reactive_power_limits=(min=0.0, max=10.0),
        )
        PSY.add_component!(AC_TWO_RTS, motor_load)
        @test isa(motor_load, PSY.MotorLoad)
        test_convert = SiennaOpenAPIModels.psy2openapi(motor_load, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.MotorLoad, test_convert)
        @test test_convert.id == 1
        @test test_convert.available
        @test test_convert.bus == 2
        @test test_convert.active_power == 5.0
        @test test_convert.motor_technology == "UNDETERMINED"
    end
    @testset "PowerLoad to JSON" begin
        power_load = PSY.get_component(PSY.PowerLoad, AC_TWO_RTS, "Arnold_twin")
        @test isa(power_load, PSY.PowerLoad)
        test_convert = SiennaOpenAPIModels.psy2openapi(power_load, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.PowerLoad, test_convert)
        @test test_convert.id == 1
        @test test_convert.bus == 2
        @test test_convert.max_active_power == 194.0
    end
    @testset "RenewableDispatch to JSON" begin
        renewable_dispatch =
            PSY.get_component(PSY.RenewableDispatch, AC_TWO_RTS, "314_PV_3")
        @test isa(renewable_dispatch, PSY.RenewableDispatch)
        test_convert = SiennaOpenAPIModels.psy2openapi(renewable_dispatch, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.RenewableDispatch, test_convert)
        @test test_convert.id == 1
        @test test_convert.available
        @test test_convert.bus == 2
        @test test_convert.active_power == 0.0
        @test test_convert.rating == 100.116
    end
    @testset "RenewableNonDispatch to JSON" begin
        renewnondispatch =
            PSY.get_component(PSY.RenewableNonDispatch, AC_TWO_RTS, "313_RTPV_8_twin")
        @test isa(renewnondispatch, PSY.RenewableNonDispatch)
        test_convert = SiennaOpenAPIModels.psy2openapi(renewnondispatch, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.RenewableNonDispatch, test_convert)
        @test test_convert.id == 1
        @test test_convert.power_factor == 1.0
        @test test_convert.base_power == 79.91999999999999
    end
    @testset "ShiftablePowerLoad to JSON" begin
        shift_load = PSY.ShiftablePowerLoad(
            name="shift_load",
            available=true,
            bus=PSY.get_bus(AC_TWO_RTS, 10201),
            active_power=0.5,
            active_power_limits=(min=0.0, max=10.0),
            reactive_power=0.2,
            max_active_power=0.75,
            max_reactive_power=0.75,
            base_power=10.0,
            load_balance_time_horizon=5,
            operation_cost=PSY.LoadCost(nothing),
        )
        PSY.add_component!(AC_TWO_RTS, shift_load)
        @test isa(shift_load, PSY.ShiftablePowerLoad)
        test_convert = SiennaOpenAPIModels.psy2openapi(shift_load, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.ShiftablePowerLoad, test_convert)
        @test test_convert.id == 1
        @test test_convert.available
        @test test_convert.bus == 2
        @test test_convert.active_power == 5.0
        @test test_convert.max_reactive_power == 7.5
    end
    @testset "StandardLoad to JSON" begin
        standard_load = PSY.StandardLoad(
            name="standard_load",
            available=true,
            bus=PSY.get_bus(AC_TWO_RTS, 10201),
            base_power=32.0,
            constant_active_power=0.5,
            max_constant_active_power=0.75,
        )
        PSY.add_component!(AC_TWO_RTS, standard_load)
        @test isa(standard_load, PSY.StandardLoad)
        test_convert = SiennaOpenAPIModels.psy2openapi(standard_load, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.StandardLoad, test_convert)
        @test test_convert.id == 1
        @test test_convert.available
        @test test_convert.bus == 2
        @test test_convert.constant_active_power == 16.0
        @test test_convert.max_constant_active_power == 24.0
    end
    @testset "SynchronousCondenser to JSON" begin
        synch =
            PSY.get_component(PSY.SynchronousCondenser, AC_TWO_RTS, "114_SYNC_COND_1_twin")
        PSY.set_base_power!(synch, 10.0)
        @test isa(synch, PSY.SynchronousCondenser)
        test_convert = SiennaOpenAPIModels.psy2openapi(synch, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.SynchronousCondenser, test_convert)
        @test test_convert.id == 1
        @test test_convert.bus == 2
        @test test_convert.available
        @test test_convert.reactive_power == 0.0
        @test test_convert.reactive_power_limits.max == 0.0
    end
    @testset "ThermalStandard to JSON" begin
        thermal_standard =
            PSY.get_component(PSY.ThermalStandard, AC_TWO_RTS, "223_STEAM_2_twin")
        @test isa(thermal_standard, PSY.ThermalStandard)
        test_convert = SiennaOpenAPIModels.psy2openapi(thermal_standard, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.ThermalStandard, test_convert)
        @test test_convert.id == 1
        @test test_convert.bus == 2
        @test test_convert.active_power == 155.0  # test units
    end
    @testset "TwoTerminalGenericHVDCLine to JSON" begin
        hvdc = PSY.get_component(PSY.TwoTerminalGenericHVDCLine, AC_TWO_RTS, "DC1")
        @test isa(hvdc, PSY.TwoTerminalGenericHVDCLine)
        test_convert = SiennaOpenAPIModels.psy2openapi(hvdc, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.TwoTerminalGenericHVDCLine, test_convert)
        @test test_convert.id == 1
        @test test_convert.available
        @test test_convert.active_power_flow == 0.0
        @test test_convert.reactive_power_limits_to.max == 100.0
    end
    @testset "VariableReserve DOWN to JSON" begin
        reg_down = PSY.get_component(PSY.VariableReserve, AC_TWO_RTS, "Reg_Down")
        @test reg_down isa PSY.VariableReserve{PSY.ReserveDown}
        test_convert = SiennaOpenAPIModels.psy2openapi(reg_down, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.VariableReserve, test_convert)
        @test test_convert.id == 1
        @test test_convert.max_output_fraction == 1.0
        @test test_convert.time_frame == 300.0
        @test test_convert.requirement == 77.0
        @test test_convert.reserve_direction == "DOWN"
        @test test_convert.sustained_time == 3600.0
    end
    @testset "VariableReserve UP to JSON" begin
        reg_up = PSY.get_component(PSY.VariableReserve, AC_TWO_RTS, "Reg_Up")
        @test reg_up isa PSY.VariableReserve{PSY.ReserveUp}
        test_convert = SiennaOpenAPIModels.psy2openapi(reg_up, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.VariableReserve, test_convert)
        @test test_convert.id == 1
        @test test_convert.max_output_fraction == 1.0
        @test test_convert.time_frame == 300.0
        @test test_convert.requirement == 72.0
        @test test_convert.reserve_direction == "UP"
        @test test_convert.sustained_time == 3600.0
    end
    @testset "VariableReserveNonSpinning to JSON" begin
        reserve = PSY.VariableReserveNonSpinning(
            name="variable_non_spinning",
            available=true,
            time_frame=300.0,
            requirement=0.77,
        )
        PSY.add_component!(AC_TWO_RTS, reserve)
        @test isa(reserve, PSY.VariableReserveNonSpinning)
        test_convert = SiennaOpenAPIModels.psy2openapi(reserve, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.VariableReserveNonSpinning, test_convert)
        @test test_convert.id == 1
        @test test_convert.available
        @test test_convert.max_participation_factor == 1.0
        @test test_convert.time_frame == 300.0
        @test test_convert.requirement == 77.0
        @test test_convert.sustained_time == 14400.0
    end
end

@testset "pti_case16_complete_sys RoundTrip to JSON" begin
    pti_case16_complete_sys = PowerSystemCaseBuilder.build_system(
        PowerSystemCaseBuilder.PSSEParsingTestSystems,
        "pti_case16_complete_sys",
    )
    @testset "DiscreteControlledACBranch to JSON" begin
        discrete = PSY.get_component(
            PSY.DiscreteControlledACBranch,
            pti_case16_complete_sys,
            "BUS 303-BUS 304-i_1",
        )
        @test isa(discrete, PSY.DiscreteControlledACBranch)
        test_convert = SiennaOpenAPIModels.psy2openapi(discrete, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.DiscreteControlledACBranch, test_convert)
        @test test_convert.id == 1
        @test test_convert.arc == 2
        @test test_convert.active_power_flow == 0.0
        @test test_convert.reactive_power_flow == 0.0
        @test test_convert.r == -0.0
        @test test_convert.discrete_branch_type == "BREAKER"
        @test test_convert.branch_status == "CLOSED"
    end
    @testset "FACTSControlDevice to JSON" begin
        facts = only(
            collect(PSY.get_components(PSY.FACTSControlDevice, pti_case16_complete_sys)),
        )
        @test isa(facts, PSY.FACTSControlDevice)
        test_convert = SiennaOpenAPIModels.psy2openapi(facts, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.FACTSControlDevice, test_convert)
        @test test_convert.id == 1
        @test test_convert.control_mode == "NML"
        @test test_convert.max_shunt_current == 9999.0
        @test test_convert.reactive_power_required == 100.0
    end
    @testset "InterruptibleStandardLoad to JSON" begin
        interrupt = PSY.get_component(
            PSY.InterruptibleStandardLoad,
            pti_case16_complete_sys,
            "load1031",
        )
        @test isa(interrupt, PSY.InterruptibleStandardLoad)
        test_convert = SiennaOpenAPIModels.psy2openapi(interrupt, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.InterruptibleStandardLoad, test_convert)
        @test test_convert.id == 1
        @test test_convert.bus == 2
        @test test_convert.conformity == "CONFORMING"
        @test test_convert.impedance_reactive_power == -0.0
        @test test_convert.current_active_power == 0.0
        @test test_convert.max_constant_active_power == 8.0
        @test test_convert.max_current_reactive_power == 0.0
    end
    @testset "StandardLoad to JSON" begin
        standard_load =
            PSY.get_component(PSY.StandardLoad, pti_case16_complete_sys, "load1001")
        @test isa(standard_load, PSY.StandardLoad)
        test_convert = SiennaOpenAPIModels.psy2openapi(standard_load, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.StandardLoad, test_convert)
        @test test_convert.id == 1
        @test test_convert.available
        @test test_convert.bus == 2
        @test test_convert.constant_active_power == 15.0
    end
    @testset "SwitchedAdmittance to JSON" begin
        switch = PSY.get_component(PSY.SwitchedAdmittance, pti_case16_complete_sys, "301-1")
        @test isa(switch, PSY.SwitchedAdmittance)
        test_convert = SiennaOpenAPIModels.psy2openapi(switch, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.SwitchedAdmittance, test_convert)
        @test test_convert.id == 1
        @test test_convert.number_of_steps == [2]
        @test test_convert.Y.imag == 0.005
        @test test_convert.Y_increase[1].imag == 0.0025
        @test test_convert.admittance_limits.max == 1.0
        @test isnothing(test_convert.dynamic_injector)
    end
    @testset "TapTransformer to JSON" begin
        taptransformer = PSY.get_component(
            PSY.TapTransformer,
            pti_case16_complete_sys,
            "BUS 103-BUS 201-i_1",
        )
        @test isa(taptransformer, PSY.TapTransformer)
        test_convert = SiennaOpenAPIModels.psy2openapi(taptransformer, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.TapTransformer, test_convert)
        @test test_convert.id == 1
        @test test_convert.rating ≈ 24233.565282942757
        @test test_convert.primary_shunt.real == 0.0
        @test test_convert.x == 1.1109
    end
    @testset "Transformer2W to JSON" begin
        transformer2w = PSY.get_component(
            PSY.Transformer2W,
            pti_case16_complete_sys,
            "BUS 501-BUS 201-i_1",
        )
        @test isa(transformer2w, PSY.Transformer2W)
        test_convert = SiennaOpenAPIModels.psy2openapi(transformer2w, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.Transformer2W, test_convert)
        @test test_convert.id == 1
        @test test_convert.r == 17.986
        @test test_convert.primary_shunt.imag == 0.0
    end
    @testset "Transformer3W to JSON" begin
        tr3w = PSY.get_component(
            PSY.Transformer3W,
            pti_case16_complete_sys,
            "BUS 501-BUS 502-BUS 503-i_1",
        )
        @test isa(tr3w, PSY.Transformer3W)
        test_convert = SiennaOpenAPIModels.psy2openapi(tr3w, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.Transformer3W, test_convert)
        @test test_convert.id == 1
        @test test_convert.r_secondary == 0.0828414
        @test test_convert.rating == 0.0
        @test test_convert.base_voltage_primary == 230.0
        @test test_convert.control_objective_tertiary == "FIXED"
    end
    @testset "TwoTerminalLCCLine to JSON" begin
        lcc = PSY.get_component(
            PSY.TwoTerminalLCCLine,
            pti_case16_complete_sys,
            "BUS 102-BUS 103-i_LINE       1",
        )
        @test isa(lcc, PSY.TwoTerminalLCCLine)
        test_convert = SiennaOpenAPIModels.psy2openapi(lcc, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.TwoTerminalLCCLine, test_convert)
        @test test_convert.id == 1
        @test test_convert.arc == 2
        @test test_convert.r == 0.03780718336483932
        @test test_convert.transfer_setpoint == 50.0
        @test test_convert.rectifier_base_voltage == 230.0
        @test test_convert.inverter_extinction_angle_limits.min == 0.3141592653589793
        @test test_convert.power_mode == true
        @test test_convert.min_compounding_voltage == 0.0
        @test test_convert.rectifier_tap_limits.max == 1.5
        @test test_convert.inverter_tap_step == 0.00625
        @test test_convert.active_power_limits_from.min == 0.0
        @test test_convert.reactive_power_limits_to.max == 0.0
    end
    @testset "TwoTerminalVSCLine to JSON" begin
        vsc = only(
            collect(PSY.get_components(PSY.TwoTerminalVSCLine, pti_case16_complete_sys)),
        )
        @test isa(vsc, PSY.TwoTerminalVSCLine)
        test_convert = SiennaOpenAPIModels.psy2openapi(vsc, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.TwoTerminalVSCLine, test_convert)
        @test test_convert.id == 1
        @test test_convert.arc == 2
        @test test_convert.active_power_flow == -96.0
        @test test_convert.rating == 360.0
        @test test_convert.active_power_limits_from.min == -353.1288716601915
        @test test_convert.reactive_power_from == 0.0
        @test test_convert.ac_setpoint_from == 1.02
        @test test_convert.max_dc_current_from == 1032.0
        @test test_convert.rating_from == 360.0
        @test test_convert.reactive_power_limits_from.min == -70.0
        @test test_convert.rating_to == 360.0
        @test test_convert.reactive_power_limits_to.max == -11.0
        @test test_convert.power_factor_weighting_fraction_to == 0.5
        @test test_convert.voltage_limits_to.max == 999.9
    end
end

@testset "WECC 240 RoundTrip to JSON" begin
    wecc240 = PowerSystemCaseBuilder.build_system(
        PowerSystemCaseBuilder.PSIDSystems,
        "WECC 240 Bus",
    )
    dyn_gen_type = PSY.DynamicGenerator{PSY.RoundRotorQuadratic, PSY.SingleMass, PSY.SEXS, PSY.SteamTurbineGov1, PSY.PSSFixed}
    wecc240_dyn_gens = collect(PSY.get_components(x -> typeof(PSY.get_dynamic_injector(x)) == dyn_gen_type, PSY.Generator, wecc240));
#    dyn_inv_type = PSY.DynamicInverter{PSY.RenewableEnergyConverterTypeA, PSY.OuterControl, PSY.RECurrentControlB, PSY.FixedDCSource, PSY.FixedFrequency, PSY.RLFilter, Nothing}
    wecc240_dyn_invs = collect(PSY.get_components(x -> typeof(PSY.get_dynamic_injector(x)) != dyn_gen_type, PSY.Generator, wecc240));
    @testset "ActiveRenewableControllerAB to JSON" begin
        activeAB = wecc240_dyn_invs[1].dynamic_injector.outer_control.active_power_control
        @test isa(activeAB, PSY.ActiveRenewableControllerAB)
        test_convert = SiennaOpenAPIModels.psy2openapi(activeAB, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.ActiveRenewableControllerAB, test_convert)
    end
    @testset "ReactiveRenewableControllerAB to JSON" begin
        reactiveAB = wecc240_dyn_invs[1].dynamic_injector.outer_control.reactive_power_control
        @test isa(reactiveAB, PSY.ReactiveRenewableControllerAB)
        test_convert = SiennaOpenAPIModels.psy2openapi(reactiveAB, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.ReactiveRenewableControllerAB, test_convert)
    end
    @testset "RECurrentControlB to JSON" begin
        recurrentB = wecc240_dyn_invs[1].dynamic_injector.inner_control
        @test isa(recurrentB, PSY.RECurrentControlB)
        test_convert = SiennaOpenAPIModels.psy2openapi(recurrentB, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.RECurrentControlB, test_convert)
    end
    @testset "RenewableEnergyConverterTypeA to JSON" begin
        renew_typeA = wecc240_dyn_invs[1].dynamic_injector.converter
        @test isa(renew_typeA, PSY.RenewableEnergyConverterTypeA)
        test_convert = SiennaOpenAPIModels.psy2openapi(renew_typeA, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.RenewableEnergyConverterTypeA, test_convert)
    end
    @testset "RoundRotorMachine to JSON" begin
        rotor_machine = wecc240_dyn_gens[1].dynamic_injector.machine.base_machine
        @test isa(rotor_machine, PSY.RoundRotorMachine)
        test_convert = SiennaOpenAPIModels.psy2openapi(rotor_machine, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.RoundRotorMachine, test_convert)
    end
    @testset "SEXS to JSON" begin
        sexs = wecc240_dyn_gens[1].dynamic_injector.avr
        @test isa(sexs, PSY.SEXS)
        test_convert = SiennaOpenAPIModels.psy2openapi(sexs, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.SEXS, test_convert)
    end
    @testset "SteamTurbineGov1 to JSON" begin
        steamgov1 = wecc240_dyn_gens[1].dynamic_injector.prime_mover
        @test isa(steamgov1, PSY.SteamTurbineGov1)
        test_convert = SiennaOpenAPIModels.psy2openapi(steamgov1, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.SteamTurbineGov1, test_convert)
    end
end

@testset "sys10_pjm_ac_dc RoundTrip to JSON" begin
    sys10_pjm_ac_dc = PowerSystemCaseBuilder.build_system(
        PowerSystemCaseBuilder.PSISystems,
        "sys10_pjm_ac_dc",
    )
    @testset "DCBus to JSON" begin
        dcbus = PSY.get_component(PSY.DCBus, sys10_pjm_ac_dc, "nodeD2_DC")
        @test isa(dcbus, PSY.DCBus)
        test_convert = SiennaOpenAPIModels.psy2openapi(dcbus, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.DCBus, test_convert)
        @test test_convert.id == 1
        @test test_convert.voltage_limits.min == 0.9
        @test test_convert.base_voltage == 500
        @test isnothing(test_convert.area)
    end
    @testset "InterconnectingConverter to JSON" begin
        inter =
            PSY.get_component(PSY.InterconnectingConverter, sys10_pjm_ac_dc, "IPC-nodeD2")
        @test isa(inter, PSY.InterconnectingConverter)
        test_convert = SiennaOpenAPIModels.psy2openapi(inter, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.InterconnectingConverter, test_convert)
        @test test_convert.id == 1
        @test test_convert.rating == 200.0
        @test test_convert.active_power_limits.max == 100.0
        @test test_convert.max_dc_current == 100000000.0
    end
    @testset "TModelHVDCLine to JSON" begin
        tmodel =
            PSY.get_component(PSY.TModelHVDCLine, sys10_pjm_ac_dc, "nodeD_DC-nodeD2_DC")
        @test isa(tmodel, PSY.TModelHVDCLine)
        test_convert = SiennaOpenAPIModels.psy2openapi(tmodel, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.TModelHVDCLine, test_convert)
        @test test_convert.id == 1
        @test test_convert.arc == 2
        @test test_convert.r == 0.01
        @test test_convert.active_power_limits_to.min == -1000.0
    end
end

@testset "c_sys5_phes_ed RoundTrip to JSON" begin
    c_sys5_phes_ed = PowerSystemCaseBuilder.build_system(
        PowerSystemCaseBuilder.PSITestSystems,
        "c_sys5_phes_ed",
    )
    @testset "HydroPumpTurbine to JSON" begin
        pump_turbine = only(PSY.get_components(PSY.HydroPumpTurbine, c_sys5_phes_ed))
        @test isa(pump_turbine, PSY.HydroPumpTurbine)
        test_convert = SiennaOpenAPIModels.psy2openapi(pump_turbine, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.HydroPumpTurbine, test_convert)
        @test test_convert.id == 1
        @test test_convert.available
        @test test_convert.bus == 2
        @test test_convert.rating == 50.0
        @test test_convert.prime_mover_type == "PS"
    end
    @testset "InterruptiblePowerLoad to JSON" begin
        interrupt =
            only(collect(PSY.get_components(PSY.InterruptiblePowerLoad, c_sys5_phes_ed)))
        @test isa(interrupt, PSY.InterruptiblePowerLoad)
        test_convert = SiennaOpenAPIModels.psy2openapi(interrupt, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.InterruptiblePowerLoad, test_convert)
        @test test_convert.id == 1
        @test test_convert.bus == 2
        @test test_convert.reactive_power == 0.0
        @test test_convert.max_active_power == 100.0
        @test test_convert.name == "IloadBus4"
    end
end

@testset "pti_case14_with_pst3w_sys RoundTrip to JSON" begin
    pti_case14 = PowerSystemCaseBuilder.build_system(
        PowerSystemCaseBuilder.PSSEParsingTestSystems,
        "pti_case14_with_pst3w_sys",
    )
    @testset "PhaseShiftingTransformer to JSON" begin
        phase_shifting_transformer = PSY.get_component(
            PSY.PhaseShiftingTransformer,
            pti_case14,
            "BUS 110-BUS 109-i_1",
        )
        @test isa(phase_shifting_transformer, PSY.PhaseShiftingTransformer)
        test_convert =
            SiennaOpenAPIModels.psy2openapi(phase_shifting_transformer, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.PhaseShiftingTransformer, test_convert)
        @test test_convert.id == 1
        @test test_convert.arc == 2
        @test test_convert.x == 0.0529
        @test test_convert.rating == 1.210002566077499e6
    end
    @testset "PhaseShiftingTransformer3W to JSON" begin
        pst3w = PSY.get_component(
            PSY.PhaseShiftingTransformer3W,
            pti_case14,
            "BUS 109-BUS 104-BUS 107-i_1",
        )
        @test isa(pst3w, PSY.PhaseShiftingTransformer3W)
        test_convert = SiennaOpenAPIModels.psy2openapi(pst3w, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.PhaseShiftingTransformer3W, test_convert)
        @test test_convert.id == 1
        @test test_convert.x_23 == 0.038088000000000004
        @test test_convert.base_voltage_tertiary == 65.0
        @test test_convert.star_bus == 5
        @test test_convert.phase_angle_limits.min == -3.1416
    end
end

@testset "2_Bus_Load_Tutorial RoundTrip to JSON" begin
    bus2_load_tutorial = PowerSystemCaseBuilder.build_system(
        PowerSystemCaseBuilder.PSIDSystems,
        "2 Bus Load Tutorial",
    )
    @testset "ExponentialLoad to JSON" begin
        exload = only(collect(PSY.get_components(PSY.ExponentialLoad, bus2_load_tutorial)))
        @test isa(exload, PSY.ExponentialLoad)
        test_convert = SiennaOpenAPIModels.psy2openapi(exload, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.ExponentialLoad, test_convert)
        @test test_convert.id == 1
        @test test_convert.alpha == 0.0
        @test test_convert.active_power == 10.0
        @test test_convert.max_reactive_power == 3.2799999999999994
        @test isnothing(test_convert.dynamic_injector)
    end
end

@testset "c_sys5_pglib RoundTrip to JSON" begin
    c_sys5_pglib = PowerSystemCaseBuilder.build_system(
        PowerSystemCaseBuilder.PSITestSystems,
        "c_sys5_pglib",
    )
    @testset "ThermalMultiStart to JSON" begin
        multi = PSY.get_component(PSY.ThermalMultiStart, c_sys5_pglib, "115_STEAM_1")
        @test isa(multi, PSY.ThermalMultiStart)
        test_convert = SiennaOpenAPIModels.psy2openapi(multi, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.ThermalMultiStart, test_convert)
        @test test_convert.id == 1
        @test test_convert.ramp_limits.up == 0.024
        @test test_convert.active_power == 5.0
        @test isnothing(test_convert.dynamic_injector)
    end
end

@testset "psse_ACTIVSg2000_sys RoundTrip to JSON" begin
    psse_ACTIVSg2000_sys = PowerSystemCaseBuilder.build_system(
        PowerSystemCaseBuilder.PSSEParsingTestSystems,
        "psse_ACTIVSg2000_sys",
    )
    @testset "Source to JSON" begin
        source = PSY.get_component(PSY.Source, psse_ACTIVSg2000_sys, "generator-6085-1")
        @test isa(source, PSY.Source)
        test_convert = SiennaOpenAPIModels.psy2openapi(source, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.Source, test_convert)
        @test test_convert.id == 1
        @test test_convert.name == "generator-6085-1"
        @test test_convert.active_power == 1.05
        @test test_convert.active_power_limits.min == 0.0
        @test test_convert.reactive_power_limits.max == 0.0
        @test test_convert.X_th == 59.523809523809526
        @test test_convert.internal_voltage == 1.0
    end
end

@testset "two_area_pjm_DA RoundTrip to JSON" begin
    two_area_pjm_DA = PowerSystemCaseBuilder.build_system(
        PowerSystemCaseBuilder.PSISystems,
        "two_area_pjm_DA",
    )
    @testset "AreaInterchange to JSON" begin
        area_interchange =
            only(collect(PSY.get_components(PSY.AreaInterchange, two_area_pjm_DA)))
        @test isa(area_interchange, PSY.AreaInterchange)
        test_convert = SiennaOpenAPIModels.psy2openapi(area_interchange, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.AreaInterchange, test_convert)
        @test test_convert.id == 1
        @test test_convert.from_area == 2
        @test test_convert.to_area == 3
        @test test_convert.flow_limits.from_to == 150.0
    end
end
