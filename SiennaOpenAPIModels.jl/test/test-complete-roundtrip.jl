using SiennaOpenAPIModels
using OpenAPI
using PowerSystemCaseBuilder
import InfrastructureSystems as IS
import PowerSystems as PSY
using JSON

@testset "AC_TWO_RTO_RTS_5min_sys Complete RoundTrip to JSON" begin
    AC_TWO_RTS = PowerSystemCaseBuilder.build_system(
        PowerSystemCaseBuilder.PSISystems,
        "AC_TWO_RTO_RTS_5min_sys",
    )
    @testset "ACBus to JSON and Back" begin
        acbus = PSY.get_bus(AC_TWO_RTS, 10201)
        @test isa(acbus, PSY.ACBus)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(acbus, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, AC_TWO_RTS)
        acbus_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(acbus, acbus_copy, exclude=Set([:internal, :ext]))
    end
    @testset "AGC to JSON and Back" begin
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
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(agc, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, AC_TWO_RTS)
        agc_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(agc, agc_copy, exclude=Set([:internal, :ext]))
    end
    @testset "Arc to JSON and Back" begin
        arc = first(PSY.get_components(PSY.Arc, AC_TWO_RTS))
        @test isa(arc, PSY.Arc)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(arc, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, AC_TWO_RTS)
        arc_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(arc, arc_copy, exclude=Set([:internal, :ext]))
    end
    @testset "Area to JSON and Back" begin
        area = PSY.get_component(PSY.Area, AC_TWO_RTS, "1")
        @test isa(area, PSY.Area)
        area.peak_active_power = 1.0
        area.peak_reactive_power = 2.0
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(area, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, AC_TWO_RTS)
        area_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(area, area_copy, exclude=Set([:internal, :ext]))
    end
    @testset "ConstantReserve UP to JSON and Back" begin
        reserve = PSY.ConstantReserve{PSY.ReserveUp}(
            name="constant_reserve_up",
            available=true,
            time_frame=300.0,
            requirement=0.77,
        )
        PSY.add_component!(AC_TWO_RTS, reserve)
        @test isa(reserve, PSY.ConstantReserve{PSY.ReserveUp})
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(reserve, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, AC_TWO_RTS)
        reserve_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(reserve, reserve_copy, exclude=Set([:internal, :ext]))
    end
    @testset "ConstantReserveGroup SYMMETRIC to JSON and Back" begin
        reserve = PSY.ConstantReserveGroup{PSY.ReserveSymmetric}(
            name="constant_reserve_group",
            available=true,
            requirement=0.77,
        )
        PSY.add_component!(AC_TWO_RTS, reserve)
        @test isa(reserve, PSY.ConstantReserveGroup{PSY.ReserveSymmetric})
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(reserve, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, AC_TWO_RTS)
        reserve_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(reserve, reserve_copy, exclude=Set([:internal, :ext]))
    end
    @testset "ConstantReserveNonSpinning to JSON and Back" begin
        reserve = PSY.ConstantReserveNonSpinning(
            name="reserve_non_spinning",
            available=true,
            time_frame=300.0,
            requirement=0.77,
        )
        PSY.add_component!(AC_TWO_RTS, reserve)
        @test isa(reserve, PSY.ConstantReserveNonSpinning)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(reserve, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, AC_TWO_RTS)
        reserve_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(reserve, reserve_copy, exclude=Set([:internal, :ext]))
    end
    @testset "EnergyReservoirStorage to JSON and Back" begin
        energy_res =
            PSY.get_component(PSY.EnergyReservoirStorage, AC_TWO_RTS, "313_STORAGE_1")
        @test isa(energy_res, PSY.EnergyReservoirStorage)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(energy_res, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, AC_TWO_RTS)
        energy_res_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(energy_res, energy_res_copy, exclude=Set([:internal, :ext]))
    end
    @testset "FixedAdmittance to JSON and Back" begin
        fixed = PSY.get_component(PSY.FixedAdmittance, AC_TWO_RTS, "Camus")
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(fixed, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, AC_TWO_RTS)
        fixed_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(fixed, fixed_copy, exclude=Set([:internal, :ext]))
    end
    @testset "HydroDispatch to JSON and Back" begin
        hydro = PSY.get_component(PSY.HydroDispatch, AC_TWO_RTS, "201_HYDRO_4")
        @test isa(hydro, PSY.HydroDispatch)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(hydro, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, AC_TWO_RTS)
        hydro_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(hydro, hydro_copy, exclude=Set([:internal, :ext]))
    end
    @testset "HydroReservoir to JSON and Back" begin
        hydro_res = PSY.get_component(
            PSY.HydroReservoir,
            AC_TWO_RTS,
            "222_HYDRO_4_RESERVOIR_head_twin",
        )
        @test isa(hydro_res, PSY.HydroReservoir)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(hydro_res, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, AC_TWO_RTS)
        hydro_res_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(hydro_res, hydro_res_copy, exclude=Set([:internal, :ext]))
    end
    @testset "HydroTurbine to JSON and Back" begin
        turbine = PSY.get_component(PSY.HydroTurbine, AC_TWO_RTS, "215_HYDRO_3")
        @test isa(turbine, PSY.HydroTurbine)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(turbine, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, AC_TWO_RTS)
        turbine_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(turbine, turbine_copy, exclude=Set([:internal, :ext]))
    end
    @testset "Line to JSON and Back" begin
        line = PSY.get_component(PSY.Line, AC_TWO_RTS, "B27")
        @test isa(line, PSY.Line)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(line, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, AC_TWO_RTS)
        line_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(line, line_copy, exclude=Set([:internal, :ext]))
    end
    @testset "LoadZone to JSON and Back" begin
        load_zone = PSY.get_component(PSY.LoadZone, AC_TWO_RTS, "13.0_twin")
        @test isa(load_zone, PSY.LoadZone)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(load_zone, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, AC_TWO_RTS)
        load_zone_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(load_zone, load_zone_copy, exclude=Set([:internal, :ext]))
    end
    @testset "MonitoredLine to JSON and Back" begin
        monitored = only(collect(PSY.get_components(PSY.MonitoredLine, AC_TWO_RTS)))
        @test isa(monitored, PSY.MonitoredLine)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(monitored, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, AC_TWO_RTS)
        monitored_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(monitored, monitored_copy, exclude=Set([:internal, :ext]))
    end
    @testset "MotorLoad to JSON and Back" begin
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
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(motor_load, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, AC_TWO_RTS)
        motor_load_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(motor_load, motor_load_copy, exclude=Set([:internal, :ext]))
    end
    @testset "PowerLoad to JSON and Back" begin
        load = PSY.get_component(PSY.PowerLoad, AC_TWO_RTS, "Arnold_twin")
        @test isa(load, PSY.PowerLoad)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(load, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, AC_TWO_RTS)
        load_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(load, load_copy, exclude=Set([:internal, :ext]))
    end
    @testset "RenewableDispatch to JSON and Back" begin
        renew = PSY.get_component(PSY.RenewableDispatch, AC_TWO_RTS, "314_PV_3")
        @test isa(renew, PSY.RenewableDispatch)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(renew, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, AC_TWO_RTS)
        renew_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(
            renew,
            renew_copy,
            exclude=Set([:internal, :ext, :services]),
        )
    end
    @testset "RenewableNonDispatch to JSON and Back" begin
        renewnon =
            PSY.get_component(PSY.RenewableNonDispatch, AC_TWO_RTS, "313_RTPV_8_twin")
        @test isa(renewnon, PSY.RenewableNonDispatch)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(renewnon, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, AC_TWO_RTS)
        renewnon_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(renewnon, renewnon_copy, exclude=Set([:internal, :ext]))
    end
    @testset "ShiftablePowerLoad to JSON and Back" begin
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
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(shift_load, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, AC_TWO_RTS)
        shift_load_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(shift_load, shift_load_copy, exclude=Set([:internal, :ext]))
    end
    @testset "StandardLoad to JSON and Back" begin
        load = PSY.StandardLoad(
            name="standard_load",
            available=true,
            bus=PSY.get_bus(AC_TWO_RTS, 10201),
            base_power=32.0,
            constant_active_power=0.5,
            max_constant_active_power=0.75,
        )
        PSY.add_component!(AC_TWO_RTS, load)
        @test isa(load, PSY.StandardLoad)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(load, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, AC_TWO_RTS)
        load_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(load, load_copy, exclude=Set([:internal, :ext]))
    end
    @testset "SynchronousCondenser to JSON and Back" begin
        synch =
            PSY.get_component(PSY.SynchronousCondenser, AC_TWO_RTS, "114_SYNC_COND_1_twin")
        PSY.set_base_power!(synch, 10.0)
        @test isa(synch, PSY.SynchronousCondenser)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(synch, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, AC_TWO_RTS)
        synch_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(synch, synch_copy, exclude=Set([:internal, :ext]))
    end
    @testset "ThermalStandard to JSON and Back" begin
        thermal = PSY.get_component(PSY.ThermalStandard, AC_TWO_RTS, "223_STEAM_2_twin")
        @test isa(thermal, PSY.ThermalStandard)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(thermal, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, AC_TWO_RTS)
        thermal_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(
            custom_isequivalent,
            thermal,
            thermal_copy,
            exclude=Set([:internal, :ext, :services]),
        )
    end
    @testset "TwoTerminalGenericHVDCLine to JSON and Back" begin
        hvdc = PSY.get_component(PSY.TwoTerminalGenericHVDCLine, AC_TWO_RTS, "DC1")
        @test isa(hvdc, PSY.TwoTerminalGenericHVDCLine)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(hvdc, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, AC_TWO_RTS)
        hvdc_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(hvdc, hvdc_copy, exclude=Set([:internal, :ext]))
    end
    @testset "VariableReserve DOWN to JSON and Back" begin
        reg_down = PSY.get_component(PSY.VariableReserve, AC_TWO_RTS, "Reg_Down")
        @test isa(reg_down, PSY.VariableReserve{PSY.ReserveDown})
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(reg_down, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, AC_TWO_RTS)
        reg_down_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(reg_down, reg_down_copy, exclude=Set([:internal, :ext]))
    end
    @testset "VariableReserve UP to JSON and Back" begin
        reg_up = PSY.get_component(PSY.VariableReserve, AC_TWO_RTS, "Reg_Up")
        @test isa(reg_up, PSY.VariableReserve{PSY.ReserveUp})
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(reg_up, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, AC_TWO_RTS)
        reg_up_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(reg_up, reg_up_copy, exclude=Set([:internal, :ext]))
    end
    @testset "VariableReserveNonSpinning to JSON and Back" begin
        reserve = PSY.VariableReserveNonSpinning(
            name="variable_non_spinning",
            available=true,
            time_frame=300.0,
            requirement=0.77,
        )
        PSY.add_component!(AC_TWO_RTS, reserve)
        @test isa(reserve, PSY.VariableReserveNonSpinning)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(reserve, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, AC_TWO_RTS)
        reserve_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(reserve, reserve_copy, exclude=Set([:internal, :ext]))
    end
end

@testset "pti_case16_complete_sys RoundTrip to JSON" begin
    pti_case16_complete_sys = PowerSystemCaseBuilder.build_system(
        PowerSystemCaseBuilder.PSSEParsingTestSystems,
        "pti_case16_complete_sys",
    )
    @testset "DiscreteControlledACBranch to JSON and Back" begin
        discrete = PSY.get_component(
            PSY.DiscreteControlledACBranch,
            pti_case16_complete_sys,
            "BUS 303-BUS 304-i_1",
        )
        @test isa(discrete, PSY.DiscreteControlledACBranch)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(discrete, id_gen)
        resolver =
            SiennaOpenAPIModels.resolver_from_id_generator(id_gen, pti_case16_complete_sys)
        discrete_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(discrete, discrete_copy, exclude=Set([:internal, :ext]))
    end
    @testset "FACTSControlDevice to JSON and Back" begin
        facts = only(
            collect(PSY.get_components(PSY.FACTSControlDevice, pti_case16_complete_sys)),
        )
        @test isa(facts, PSY.FACTSControlDevice)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(facts, id_gen)
        resolver =
            SiennaOpenAPIModels.resolver_from_id_generator(id_gen, pti_case16_complete_sys)
        facts_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(facts, facts_copy, exclude=Set([:internal, :ext]))
    end
    @testset "InterruptibleStandardLoad to JSON and Back" begin
        interrupt = PSY.get_component(
            PSY.InterruptibleStandardLoad,
            pti_case16_complete_sys,
            "load1031",
        )
        @test isa(interrupt, PSY.InterruptibleStandardLoad)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(interrupt, id_gen)
        resolver =
            SiennaOpenAPIModels.resolver_from_id_generator(id_gen, pti_case16_complete_sys)
        interrupt_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(interrupt, interrupt_copy, exclude=Set([:internal, :ext]))
    end
    @testset "StandardLoad to JSON and Back" begin
        load = PSY.get_component(PSY.StandardLoad, pti_case16_complete_sys, "load1001")
        @test isa(load, PSY.StandardLoad)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(load, id_gen)
        resolver =
            SiennaOpenAPIModels.resolver_from_id_generator(id_gen, pti_case16_complete_sys)
        load_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(load, load_copy, exclude=Set([:internal, :ext]))
    end
    @testset "SwitchedAdmittance to JSON and Back" begin
        switch = PSY.get_component(PSY.SwitchedAdmittance, pti_case16_complete_sys, "301-1")
        @test isa(switch, PSY.SwitchedAdmittance)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(switch, id_gen)
        resolver =
            SiennaOpenAPIModels.resolver_from_id_generator(id_gen, pti_case16_complete_sys)
        switch_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(switch, switch_copy, exclude=Set([:internal, :ext]))
    end
    @testset "TapTransformer to JSON and Back" begin
        taptransform = PSY.get_component(
            PSY.TapTransformer,
            pti_case16_complete_sys,
            "BUS 103-BUS 201-i_1",
        )
        @test isa(taptransform, PSY.TapTransformer)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(taptransform, id_gen)
        resolver =
            SiennaOpenAPIModels.resolver_from_id_generator(id_gen, pti_case16_complete_sys)
        taptransform_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(
            taptransform,
            taptransform_copy,
            exclude=Set([:internal, :ext]),
        )
    end
    @testset "Transformer2W to JSON and Back" begin
        transform = PSY.get_component(
            PSY.Transformer2W,
            pti_case16_complete_sys,
            "BUS 501-BUS 201-i_1",
        )
        @test isa(transform, PSY.Transformer2W)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(transform, id_gen)
        resolver =
            SiennaOpenAPIModels.resolver_from_id_generator(id_gen, pti_case16_complete_sys)
        transform_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(transform, transform_copy, exclude=Set([:internal, :ext]))
    end
    @testset "Transformer3W to JSON and Back" begin
        tr3w = PSY.get_component(
            PSY.Transformer3W,
            pti_case16_complete_sys,
            "BUS 501-BUS 502-BUS 503-i_1",
        )
        @test isa(tr3w, PSY.Transformer3W)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(tr3w, id_gen)
        resolver =
            SiennaOpenAPIModels.resolver_from_id_generator(id_gen, pti_case16_complete_sys)
        tr3w_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(
            custom_isequivalent,
            tr3w,
            tr3w_copy,
            exclude=Set([:internal, :ext]),
        )
    end
    @testset "TwoTerminalLCCLine to JSON and Back" begin
        lcc = PSY.get_component(
            PSY.TwoTerminalLCCLine,
            pti_case16_complete_sys,
            "BUS 102-BUS 103-i_LINE       1",
        )
        @test isa(lcc, PSY.TwoTerminalLCCLine)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(lcc, id_gen)
        resolver =
            SiennaOpenAPIModels.resolver_from_id_generator(id_gen, pti_case16_complete_sys)
        lcc_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(
            custom_isequivalent,
            lcc,
            lcc_copy,
            exclude=Set([:internal, :ext]),
        )
    end
    @testset "TwoTerminalVSCLine to JSON and Back" begin
        vsc = only(
            collect(PSY.get_components(PSY.TwoTerminalVSCLine, pti_case16_complete_sys)),
        )
        @test isa(vsc, PSY.TwoTerminalVSCLine)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(vsc, id_gen)
        resolver =
            SiennaOpenAPIModels.resolver_from_id_generator(id_gen, pti_case16_complete_sys)
        vsc_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(vsc, vsc_copy, exclude=Set([:internal, :ext]))
    end
end

@testset "sys10_pjm_ac_dc RoundTrip to JSON" begin
    sys10_pjm_ac_dc = PowerSystemCaseBuilder.build_system(
        PowerSystemCaseBuilder.PSISystems,
        "sys10_pjm_ac_dc",
    )
    @testset "DCBus to JSON and Back" begin
        dcbus = PSY.get_component(PSY.DCBus, sys10_pjm_ac_dc, "nodeD2_DC")
        @test isa(dcbus, PSY.DCBus)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(dcbus, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, sys10_pjm_ac_dc)
        dcbus_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(dcbus, dcbus_copy, exclude=Set([:internal, :ext]))
    end
    @testset "InterconnectingConverter to JSON and Back" begin
        inter =
            PSY.get_component(PSY.InterconnectingConverter, sys10_pjm_ac_dc, "IPC-nodeD2")
        @test isa(inter, PSY.InterconnectingConverter)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(inter, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, sys10_pjm_ac_dc)
        inter_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(inter, inter_copy, exclude=Set([:internal, :ext]))
    end
    @testset "TModelHVDCLine to JSON and Back" begin
        tmodel =
            PSY.get_component(PSY.TModelHVDCLine, sys10_pjm_ac_dc, "nodeD_DC-nodeD2_DC")
        @test isa(tmodel, PSY.TModelHVDCLine)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(tmodel, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, sys10_pjm_ac_dc)
        tmodel_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(tmodel, tmodel_copy, exclude=Set([:internal, :ext]))
    end
end

@testset "c_sys5_phes_ed RoundTrip to JSON" begin
    c_sys5_phes_ed = PowerSystemCaseBuilder.build_system(
        PowerSystemCaseBuilder.PSITestSystems,
        "c_sys5_phes_ed",
    )
    @testset "HydroPumpTurbine to JSON" begin
        hydro_pump = only(PSY.get_components(PSY.HydroPumpTurbine, c_sys5_phes_ed))
        @test isa(hydro_pump, PSY.HydroPumpTurbine)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(hydro_pump, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, c_sys5_phes_ed)
        hydro_pump_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(hydro_pump, hydro_pump_copy, exclude=Set([:internal, :ext]))
    end
    @testset "InterruptiblePowerLoad to JSON and Back" begin
        interrupt =
            only(collect(PSY.get_components(PSY.InterruptiblePowerLoad, c_sys5_phes_ed)))
        @test isa(interrupt, PSY.InterruptiblePowerLoad)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(interrupt, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, c_sys5_phes_ed)
        interrupt_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(interrupt, interrupt_copy, exclude=Set([:internal, :ext]))
    end
end

@testset "pti_case14_with_pst3w_sys RoundTrip to JSON" begin
    pti_case14 = PowerSystemCaseBuilder.build_system(
        PowerSystemCaseBuilder.PSSEParsingTestSystems,
        "pti_case14_with_pst3w_sys",
    )
    @testset "PhaseShiftingTransformer to JSON and Back" begin
        phase = PSY.get_component(
            PSY.PhaseShiftingTransformer,
            pti_case14,
            "BUS 110-BUS 109-i_1",
        )
        @test isa(phase, PSY.PhaseShiftingTransformer)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(phase, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, pti_case14)
        phase_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(phase, phase_copy, exclude=Set([:internal, :ext]))
    end
    @testset "PhaseShiftingTransformer3W to JSON and Back" begin
        pst3w = PSY.get_component(
            PSY.PhaseShiftingTransformer3W,
            pti_case14,
            "BUS 109-BUS 104-BUS 107-i_1",
        )
        @test isa(pst3w, PSY.PhaseShiftingTransformer3W)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(pst3w, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, pti_case14)
        pst3w_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(
            custom_isequivalent,
            pst3w,
            pst3w_copy,
            exclude=Set([:internal, :ext]),
        )
    end
end

@testset "2_Bus_Load_Tutorial RoundTrip to JSON" begin
    bus2_load_tutorial = PowerSystemCaseBuilder.build_system(
        PowerSystemCaseBuilder.PSIDSystems,
        "2 Bus Load Tutorial",
    )
    @testset "ExponentialLoad to JSON and Back" begin
        exload = only(collect(PSY.get_components(PSY.ExponentialLoad, bus2_load_tutorial)))
        @test isa(exload, PSY.ExponentialLoad)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(exload, id_gen)
        resolver =
            SiennaOpenAPIModels.resolver_from_id_generator(id_gen, bus2_load_tutorial)
        exload_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(exload, exload_copy, exclude=Set([:internal, :ext]))
    end
end

@testset "c_sys5_pglib Complete RoundTrip to JSON" begin
    c_sys5_pglib = PowerSystemCaseBuilder.build_system(
        PowerSystemCaseBuilder.PSITestSystems,
        "c_sys5_pglib",
    )
    @testset "ThermalMultiStart to JSON and Back" begin
        multi = PSY.get_component(PSY.ThermalMultiStart, c_sys5_pglib, "115_STEAM_1")
        @test isa(multi, PSY.ThermalMultiStart)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(multi, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, c_sys5_pglib)
        multi_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(multi, multi_copy, exclude=Set([:internal, :ext]))
    end
end

@testset "psse_ACTIVSg2000_sys RoundTrip to JSON" begin
    psse_ACTIVSg2000_sys = PowerSystemCaseBuilder.build_system(
        PowerSystemCaseBuilder.PSSEParsingTestSystems,
        "psse_ACTIVSg2000_sys",
    )
    @testset "Source to JSON and Back" begin
        source = PSY.get_component(PSY.Source, psse_ACTIVSg2000_sys, "generator-6085-1")
        @test isa(source, PSY.Source)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(source, id_gen)
        resolver =
            SiennaOpenAPIModels.resolver_from_id_generator(id_gen, psse_ACTIVSg2000_sys)
        source_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(source, source_copy, exclude=Set([:internal, :ext]))
    end
end

@testset "two_area_pjm_DA Complete Roundtrip to JSON" begin
    two_area_pjm_DA = PowerSystemCaseBuilder.build_system(
        PowerSystemCaseBuilder.PSISystems,
        "two_area_pjm_DA",
    )
    @testset "AreaInterchange to JSON and Back" begin
        area_interchange =
            only(collect(PSY.get_components(PSY.AreaInterchange, two_area_pjm_DA)))
        @test isa(area_interchange, PSY.AreaInterchange)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(area_interchange, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, two_area_pjm_DA)
        area_interchange_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(
            area_interchange,
            area_interchange_copy,
            exclude=Set([:internal, :ext]),
        )
    end
end
