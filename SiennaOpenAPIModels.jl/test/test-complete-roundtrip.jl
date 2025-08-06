using SiennaOpenAPIModels
using OpenAPI
using PowerSystemCaseBuilder
import InfrastructureSystems
const IS = InfrastructureSystems
import PowerSystems
const PSY = PowerSystems
using JSON

@testset "c_sys5_pjm Complete RoundTrip to JSON" begin
    c_sys5 =
        PowerSystemCaseBuilder.build_system(PowerSystemCaseBuilder.PSISystems, "c_sys5_pjm")
    @testset "ACBus to JSON and Back" begin
        acbus = PSY.get_bus(c_sys5, 1)
        @test isa(acbus, PSY.ACBus)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(acbus, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, c_sys5)
        acbus_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(acbus, acbus_copy, exclude=Set([:internal, :ext]))
    end
    @testset "Arc to JSON and Back" begin
        arc = first(PSY.get_components(PSY.Arc, c_sys5))
        @test isa(arc, PSY.Arc)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(arc, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, c_sys5)
        arc_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(arc, arc_copy, exclude=Set([:internal, :ext]))
    end
    @testset "DiscreteControlledACBranch to JSON and Back" begin
        discrete = PSY.DiscreteControlledACBranch(
            name="discrete_ac",
            available=true,
            active_power_flow=0.5,
            reactive_power_flow=0.0,
            arc=first(PSY.get_components(PSY.Arc, c_sys5)),
            r=0.00108,
            x=0.0108,
            rating=15.0,
        )
        PSY.add_component!(c_sys5, discrete)
        @test isa(discrete, PSY.DiscreteControlledACBranch)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(discrete, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, c_sys5)
        discrete_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(discrete, discrete_copy, exclude=Set([:internal, :ext]))
    end
    @testset "HydroPumpTurbine to JSON" begin
        head_hydro_res = PSY.HydroReservoir(
            name="head",
            available=true,
            storage_level_limits=(min=0.0, max=50.0),
            initial_level=32.0,
            spillage_limits=nothing,
            inflow=3.0,
            outflow=5.0,
            level_targets=nothing,
            travel_time=nothing,
            intake_elevation=32.0,
            head_to_volume_factor=100.0,
        )
        PSY.add_component!(c_sys5, head_hydro_res)
        tail_hydro_res = PSY.HydroReservoir(
            name="tail",
            available=true,
            storage_level_limits=(min=0.0, max=50.0),
            initial_level=32.0,
            spillage_limits=nothing,
            inflow=3.0,
            outflow=5.0,
            level_targets=nothing,
            travel_time=nothing,
            intake_elevation=32.0,
            head_to_volume_factor=100.0,
        )
        PSY.add_component!(c_sys5, tail_hydro_res)
        hydro_pump = PSY.HydroPumpTurbine(
            name="hydro_pump",
            available=true,
            bus=PSY.get_bus(c_sys5, 2),
            active_power=32.0,
            reactive_power=3.0,
            rating=5.0,
            active_power_limits=(min=0.0, max=50.0),
            reactive_power_limits=(min=0.0, max=5.0),
            active_power_limits_pump=(min=0.0, max=50.0),
            outflow_limits=(min=0.0, max=50.0),
            head_reservoir=PSY.get_component(PSY.HydroReservoir, c_sys5, "head"),
            tail_reservoir=PSY.get_component(PSY.HydroReservoir, c_sys5, "tail"),
            powerhouse_elevation=32.0,
            ramp_limits=(up=0.0, down=50.0),
            time_limits=(up=0.0, down=5.0),
            base_power=100.0,
        )
        PSY.add_component!(c_sys5, hydro_pump)
        @test isa(hydro_pump, PSY.HydroPumpTurbine)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(hydro_pump, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, c_sys5)
        hydro_pump_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(hydro_pump, hydro_pump_copy, exclude=Set([:internal, :ext]))
    end
    @testset "HydroReservoir to JSON" begin
        hydro_res = PSY.HydroReservoir(
            name="hydro_res",
            available=true,
            storage_level_limits=(min=0.0, max=50.0),
            initial_level=32.0,
            spillage_limits=nothing,
            inflow=3.0,
            outflow=5.0,
            level_targets=nothing,
            travel_time=nothing,
            intake_elevation=32.0,
            head_to_volume_factor=100.0,
        )
        PSY.add_component!(c_sys5, hydro_res)
        @test isa(hydro_res, PSY.HydroReservoir)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(hydro_res, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, c_sys5)
        hydro_res_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(hydro_res, hydro_res_copy, exclude=Set([:internal, :ext]))
    end
    @testset "HydroTurbine to JSON" begin
        turbine = PSY.HydroTurbine(
            name="hydro_turbine",
            available=true,
            bus=PSY.get_bus(c_sys5, 2),
            active_power=32.0,
            reactive_power=3.0,
            rating=5.0,
            active_power_limits=(min=0.0, max=50.0),
            reactive_power_limits=(min=0.0, max=5.0),
            outflow_limits=(min=0.0, max=50.0),
            powerhouse_elevation=32.0,
            ramp_limits=(up=0.0, down=50.0),
            time_limits=(up=0.0, down=5.0),
            base_power=100.0,
        )
        PSY.add_component!(c_sys5, turbine)
        @test isa(turbine, PSY.HydroTurbine)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(turbine, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, c_sys5)
        turbine_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(turbine, turbine_copy, exclude=Set([:internal, :ext]))
    end
    @testset "Line to JSON and Back" begin
        line = PSY.get_component(PSY.Line, c_sys5, "4")
        @test isa(line, PSY.Line)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(line, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, c_sys5)
        line_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(line, line_copy, exclude=Set([:internal, :ext]))
    end
    @testset "MotorLoad to JSON" begin
        motor_load = PSY.MotorLoad(
            name="motor_load",
            available=true,
            bus=PSY.get_bus(c_sys5, 2),
            active_power=0.5,
            reactive_power=0.2,
            base_power=10.0,
            rating=1.0,
            max_active_power=0.75,
            reactive_power_limits=(min=0.0, max=10.0),
        )
        PSY.add_component!(c_sys5, motor_load)
        @test isa(load, PSY.MotorLoad)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(motor_load, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, c_sys5)
        motor_load_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(motor_load, motor_load_copy, exclude=Set([:internal, :ext]))
    end
    @testset "PowerLoad to JSON and Back" begin
        load = PSY.get_component(PSY.PowerLoad, c_sys5, "Bus2")
        @test isa(load, PSY.PowerLoad)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(load, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, c_sys5)
        load_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(load, load_copy, exclude=Set([:internal, :ext]))
    end
    @testset "RenewableDispatch to JSON and Back" begin
        renew = PSY.get_component(PSY.RenewableDispatch, c_sys5, "PVBus5")
        @test isa(renew, PSY.RenewableDispatch)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(renew, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, c_sys5)
        renew_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(renew, renew_copy, exclude=Set([:internal, :ext]))
    end
    @testset "ShiftablePowerLoad to JSON and Back" begin
        shift_load = PSY.ShiftablePowerLoad(
            name="shift_load",
            available=true,
            bus=PSY.get_bus(c_sys5, 2),
            active_power=0.5,
            active_power_limits=(min=0.0, max=10.0),
            reactive_power=0.2,
            max_active_power=0.75,
            max_reactive_power=0.75,
            base_power=10.0,
            load_balance_time_horizon=5,
            operation_cost=PSY.LoadCost(nothing),
        )
        PSY.add_component!(c_sys5, shift_load)
        @test isa(shift_load, PSY.ShiftablePowerLoad)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(shift_load, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, c_sys5)
        shift_load_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(shift_load, shift_load_copy, exclude=Set([:internal, :ext]))
    end
    @testset "SynchronousCondenser to JSON" begin
        synch = PSY.SynchronousCondenser(
            name="synch",
            bus=PSY.get_bus(c_sys5, 2),
            available=true,
            reactive_power=0.5,
            reactive_power_limits=(min=0.0, max=5.0),
            rating=1.0,
            base_power=32.0,
        )
        PSY.add_component!(c_sys5, synch)
        @test isa(synch, PSY.SynchronousCondenser)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(synch, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, c_sys5)
        synch_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(synch, synch_copy, exclude=Set([:internal, :ext]))
    end
    @testset "ThermalStandard to JSON and Back" begin
        thermal = PSY.get_component(PSY.ThermalStandard, c_sys5, "Solitude")
        @test isa(thermal, PSY.ThermalStandard)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(thermal, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, c_sys5)
        thermal_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(thermal, thermal_copy, exclude=Set([:internal, :ext]))
    end
end

@testset "RTS_GMLC_RT_sys Complete RoundTrip to JSON" begin
    RTS_GMLC_RT_sys = PowerSystemCaseBuilder.build_system(
        PowerSystemCaseBuilder.PSISystems,
        "RTS_GMLC_RT_sys",
    )
    @testset "ConstantReserve UP to JSON and Back" begin
        reserve = PSY.ConstantReserve{PSY.ReserveUp}(
            name="constant_reserve_up",
            available=true,
            time_frame=300.0,
            requirement=0.77,
        )
        PSY.add_component!(RTS_GMLC_RT_sys, reserve)
        @test isa(reserve, PSY.ConstantReserve{PSY.ReserveUp})
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(reserve, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, RTS_GMLC_RT_sys)
        reserve_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(reserve, reserve_copy, exclude=Set([:internal, :ext]))
    end
    @testset "ConstantReserveGroup SYMMETRIC to JSON and Back" begin
        reserve = PSY.ConstantReserveGroup{PSY.ReserveSymmetric}(
            name="constant_reserve_group",
            available=true,
            requirement=0.77,
        )
        PSY.add_component!(RTS_GMLC_RT_sys, reserve)
        @test isa(reserve, PSY.ConstantReserveGroup{PSY.ReserveSymmetric})
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(reserve, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, RTS_GMLC_RT_sys)
        reserve_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(reserve, reserve_copy, exclude=Set([:internal, :ext]))
    end
    @testset "ConstantReserveNonSpinning to JSON" begin
        reserve = PSY.ConstantReserveNonSpinning(
            name="reserve_non_spinning",
            available=true,
            time_frame=300.0,
            requirement=0.77,
        )
        PSY.add_component!(RTS_GMLC_RT_sys, reserve)
        @test isa(reserve, PSY.ConstantReserveNonSpinning)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(reserve, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, RTS_GMLC_RT_sys)
        reserve_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(reserve, reserve_copy, exclude=Set([:internal, :ext]))
    end
    @testset "EnergyReservoirStorage to JSON and Back" begin
        energy_res =
            PSY.get_component(PSY.EnergyReservoirStorage, RTS_GMLC_RT_sys, "313_STORAGE_1")
        @test isa(energy_res, PSY.EnergyReservoirStorage)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(energy_res, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, RTS_GMLC_RT_sys)
        energy_res_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(energy_res, energy_res_copy, exclude=Set([:internal, :ext]))
    end
    @testset "FixedAdmittance to JSON and Back" begin
        fixed = PSY.get_component(PSY.FixedAdmittance, RTS_GMLC_RT_sys, "Camus")
        @test isa(fixed, PSY.FixedAdmittance)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(fixed, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, RTS_GMLC_RT_sys)
        fixed_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(fixed, fixed_copy, exclude=Set([:internal, :ext]))
    end
    @testset "PhaseShiftingTransformer3W to JSON and Back" begin
        phase3w = PSY.PhaseShiftingTransformer3W(
            name="phase3w",
            available=true,
            primary_star_arc=PSY.get_component(PSY.Arc, RTS_GMLC_RT_sys, "Agricola -> Ali"),
            secondary_star_arc=PSY.get_component(PSY.Arc, RTS_GMLC_RT_sys, "Adler -> Ali"),
            tertiary_star_arc=PSY.get_component(PSY.Arc, RTS_GMLC_RT_sys, "Alger -> Ali"),
            star_bus=PSY.get_component(PSY.ACBus, RTS_GMLC_RT_sys, "Ali"),
            active_power_flow_primary=0.0,
            reactive_power_flow_primary=0.0,
            active_power_flow_secondary=0.0,
            reactive_power_flow_secondary=0.0,
            active_power_flow_tertiary=0.0,
            reactive_power_flow_tertiary=0.0,
            r_primary=0.0002295,
            x_primary=0.036619,
            r_secondary=0.00083,
            x_secondary=-0.00052,
            r_tertiary=0.0041235,
            x_tertiary=0.201563,
            r_12=0.001059,
            x_12=0.036097,
            r_23=0.004954,
            x_23=0.20104,
            r_13=0.004353,
            x_13=0.238183,
            α_primary=0.0175,
            α_secondary=0.0175,
            α_tertiary=0.0175,
            base_power_12=144.0,
            base_power_23=100.0,
            base_power_13=100.0,
        )
        PSY.add_component!(RTS_GMLC_RT_sys, phase3w)
        @test isa(phase3w, PSY.PhaseShiftingTransformer3W)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(phase3w, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, RTS_GMLC_RT_sys)
        phase3w_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(phase3w, phase3w_copy, exclude=Set([:internal, :ext]))
    end
    @testset "RenewableNonDispatch to JSON and Back" begin
        renewnon =
            PSY.get_component(PSY.RenewableNonDispatch, RTS_GMLC_RT_sys, "313_RTPV_1")
        @test isa(renewnon, PSY.RenewableNonDispatch)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(renewnon, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, RTS_GMLC_RT_sys)
        renewnon_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(renewnon, renewnon_copy, exclude=Set([:internal, :ext]))
    end
    @testset "TwoTerminalGenericHVDCLine to JSON and Back" begin
        hvdc = PSY.get_component(PSY.TwoTerminalGenericHVDCLine, RTS_GMLC_RT_sys, "DC1")
        @test isa(hvdc, PSY.TwoTerminalGenericHVDCLine)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(hvdc, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, RTS_GMLC_RT_sys)
        hvdc_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(hvdc, hvdc_copy, exclude=Set([:internal, :ext]))
    end
    @testset "VariableReserve DOWN to JSON and Back" begin
        reg_down = PSY.get_component(PSY.VariableReserve, RTS_GMLC_RT_sys, "Reg_Down")
        @test isa(reg_down, PSY.VariableReserve{PSY.ReserveDown})
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(reg_down, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, RTS_GMLC_RT_sys)
        reg_down_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(reg_down, reg_down_copy, exclude=Set([:internal, :ext]))
    end
    @testset "VariableReserveNonSpinning to JSON and Back" begin
        reserve = PSY.VariableReserveNonSpinning(
            name="variable_non_spinning",
            available=true,
            time_frame=300.0,
            requirement=0.77,
        )
        PSY.add_component!(RTS_GMLC_RT_sys, reserve)
        @test isa(reserve, PSY.VariableReserveNonSpinning)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(reserve, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, RTS_GMLC_RT_sys)
        reserve_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(reserve, reserve_copy, exclude=Set([:internal, :ext]))
    end
end

@testset "sys10_pjm_ac_dc Complete Roundtrip to JSON" begin
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

@testset "psse_3bus_gen_cls_sys Complete Roundtrip to JSON" begin
    sys = PowerSystemCaseBuilder.build_system(
        PowerSystemCaseBuilder.PSYTestSystems,
        "psse_3bus_gen_cls_sys",
    )
    @testset "Area to JSON and Back" begin
        area = PSY.get_component(PSY.Area, sys, "1")
        @test isa(area, PSY.Area)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(area, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, sys)
        area_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(area, area_copy, exclude=Set([:internal, :ext]))
    end
    @testset "LoadZone to JSON and Back" begin
        load_zone = PSY.get_component(PSY.LoadZone, sys, "1")
        @test isa(load_zone, PSY.LoadZone)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(load_zone, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, sys)
        load_zone_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(load_zone, load_zone_copy, exclude=Set([:internal, :ext]))
    end
    @testset "Source to JSON and Back" begin
        source = PSY.get_component(PSY.Source, sys, "generator-102-1")
        @test isa(source, PSY.Source)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(source, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, sys)
        source_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(source, source_copy, exclude=Set([:internal, :ext]))
    end
end

@testset "c_sys5_all Complete Roundtrip to JSON" begin
    c_sys5_all = PowerSystemCaseBuilder.build_system(
        PowerSystemCaseBuilder.PSITestSystems,
        "c_sys5_all_components",
    )
    @testset "HydroDispatch to JSON and Back" begin
        hydro = PSY.get_component(PSY.HydroDispatch, c_sys5_all, "HydroDispatch")
        @test isa(hydro, PSY.HydroDispatch)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(hydro, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, c_sys5_all)
        hydro_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(hydro, hydro_copy, exclude=Set([:internal, :ext]))
    end
    @testset "StandardLoad to JSON and Back" begin
        load = PSY.get_component(PSY.StandardLoad, c_sys5_all, "Bus3")
        @test isa(load, PSY.StandardLoad)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(load, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, c_sys5_all)
        load_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(load, load_copy, exclude=Set([:internal, :ext]))
    end
end

@testset "c_sys5_hy_ed Complete RoundTrip to JSON" begin
    c_sys5_hy_ed = PowerSystemCaseBuilder.build_system(
        PowerSystemCaseBuilder.PSITestSystems,
        "c_sys5_hy_ed",
    )
    @testset "HydroEnergyReservoir to JSON and Back" begin
        hydro_res =
            only(collect(PSY.get_components(PSY.HydroEnergyReservoir, c_sys5_hy_ed)))
        @test isa(hydro_res, PSY.HydroEnergyReservoir)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(hydro_res, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, c_sys5_hy_ed)
        hydro_res_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(hydro_res, hydro_res_copy, exclude=Set([:internal, :ext]))
    end
    @testset "InterruptiblePowerLoad to JSON and Back" begin
        interrupt =
            only(collect(PSY.get_components(PSY.InterruptiblePowerLoad, c_sys5_hy_ed)))
        @test isa(interrupt, PSY.InterruptiblePowerLoad)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(interrupt, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, c_sys5_hy_ed)
        interrupt_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(interrupt, interrupt_copy, exclude=Set([:internal, :ext]))
    end
end

@testset "sys_14_bus Complete RoundTrip to JSON" begin
    sys_14_bus = PowerSystemCaseBuilder.build_system(
        PowerSystemCaseBuilder.PSIDSystems,
        "14 Bus Base Case",
    )
    @testset "TapTransformer to JSON and Back" begin
        taptransform =
            PSY.get_component(PowerSystems.TapTransformer, sys_14_bus, "BUS 04-BUS 07-i_1")
        @test isa(taptransform, PSY.TapTransformer)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(taptransform, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, sys_14_bus)
        taptransform_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(
            taptransform,
            taptransform_copy,
            exclude=Set([:internal, :ext]),
        )
    end
    @testset "Transformer2W to JSON and Back" begin
        transform = PSY.get_component(PSY.Transformer2W, sys_14_bus, "BUS 08-BUS 07-i_1")
        @test isa(transform, PSY.Transformer2W)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(transform, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, sys_14_bus)
        transform_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(transform, transform_copy, exclude=Set([:internal, :ext]))
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
    @testset "MonitoredLine to JSON and Back" begin
        monitored = only(collect(PSY.get_components(PSY.MonitoredLine, two_area_pjm_DA)))
        @test isa(monitored, PSY.MonitoredLine)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(monitored, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, two_area_pjm_DA)
        monitored_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(monitored, monitored_copy, exclude=Set([:internal, :ext]))
    end
end

@testset "5_bus_matpower_RT Complete Roundtrip to JSON" begin
    sys_5bus_matpower_RT = PowerSystemCaseBuilder.build_system(
        PowerSystemCaseBuilder.PSISystems,
        "5_bus_matpower_RT",
    )
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
        PSY.add_component!(sys_5bus_matpower_RT, agc)
        @test isa(agc, PSY.AGC)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(agc, id_gen)
        resolver =
            SiennaOpenAPIModels.resolver_from_id_generator(id_gen, sys_5bus_matpower_RT)
        agc_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(agc, agc_copy, exclude=Set([:internal, :ext]))
    end
    @testset "PhaseShiftingTransformer to JSON and Back" begin
        phase = PSY.get_component(
            PSY.PhaseShiftingTransformer,
            sys_5bus_matpower_RT,
            "bus3-bus4-i_6",
        )
        @test isa(phase, PSY.PhaseShiftingTransformer)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(phase, id_gen)
        resolver =
            SiennaOpenAPIModels.resolver_from_id_generator(id_gen, sys_5bus_matpower_RT)
        phase_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(phase, phase_copy, exclude=Set([:internal, :ext]))
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

@testset "psse_240_parsing_sys Complete RoundTrip to JSON" begin
    psse_240_parsing_sys = PowerSystemCaseBuilder.build_system(
        PowerSystemCaseBuilder.PSYTestSystems,
        "psse_240_parsing_sys",
    )
    @testset "SwitchedAdmittance to JSON and Back" begin
        switch = PSY.get_component(PSY.SwitchedAdmittance, psse_240_parsing_sys, "6104-3")
        @test isa(switch, PSY.SwitchedAdmittance)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(switch, id_gen)
        resolver =
            SiennaOpenAPIModels.resolver_from_id_generator(id_gen, psse_240_parsing_sys)
        switch_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(switch, switch_copy, exclude=Set([:internal, :ext]))
    end
end

@testset "pti_frankenstein_70_sys Complete RoundTrip to JSON" begin
    pti_frankenstein_70_sys = PowerSystemCaseBuilder.build_system(
        PowerSystemCaseBuilder.PSSEParsingTestSystems,
        "pti_frankenstein_70_sys",
    )
    @testset "FACTSControlDevice to JSON and Back" begin
        facts = PSY.get_component(PSY.FACTSControlDevice, pti_frankenstein_70_sys, "1004_1")
        @test isa(facts, PSY.FACTSControlDevice)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(facts, id_gen)
        resolver =
            SiennaOpenAPIModels.resolver_from_id_generator(id_gen, pti_frankenstein_70_sys)
        facts_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(facts, facts_copy, exclude=Set([:internal, :ext]))
    end
    @testset "Transformer3W to JSON and Back" begin
        tr3w = only(collect(PSY.get_components(PSY.Transformer3W, pti_frankenstein_70_sys)))
        @test isa(tr3w, PSY.Transformer3W)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(tr3w, id_gen)
        resolver =
            SiennaOpenAPIModels.resolver_from_id_generator(id_gen, pti_frankenstein_70_sys)
        tr3w_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(tr3w, tr3w_copy, exclude=Set([:internal, :ext]))
    end
    @testset "TwoTerminalLCCLine to JSON and Back" begin
        lcc = only(
            collect(PSY.get_components(PSY.TwoTerminalLCCLine, pti_frankenstein_70_sys)),
        )
        @test isa(lcc, PSY.TwoTerminalLCCLine)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(lcc, id_gen)
        resolver =
            SiennaOpenAPIModels.resolver_from_id_generator(id_gen, pti_frankenstein_70_sys)
        lcc_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(lcc, lcc_copy, exclude=Set([:internal, :ext]))
    end
    @testset "TwoTerminalVSCLine to JSON and Back" begin
        vsc = only(
            collect(PSY.get_components(PSY.TwoTerminalVSCLine, pti_frankenstein_70_sys)),
        )
        @test isa(vsc, PSY.TwoTerminalVSCLine)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(vsc, id_gen)
        resolver =
            SiennaOpenAPIModels.resolver_from_id_generator(id_gen, pti_frankenstein_70_sys)
        vsc_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(vsc, vsc_copy, exclude=Set([:internal, :ext]))
    end
end
