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
        @test IS.compare_values(acbus, acbus_copy, exclude=Set([:internal]))
    end
    @testset "Arc to JSON and Back" begin
        arc = first(PSY.get_components(PSY.Arc, c_sys5))
        @test isa(arc, PSY.Arc)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(arc, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, c_sys5)
        arc_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(arc, arc_copy, exclude=Set([:internal]))
    end
    @testset "ExponentialLoad to JSON and Back" begin
        exp_load = PSY.ExponentialLoad(
            name="exp_load",
            available=true,
            bus=PSY.get_bus(c_sys5, "nodeE"),
            active_power=4.0,
            reactive_power=1.3147,
            α=0.0,
            β=0.0,
            base_power=100.0,
            max_active_power=3.801843804166639,
            max_reactive_power=1.3147,
        )
        PSY.add_component!(c_sys5, exp_load)
        @test isa(exp_load, PSY.ExponentialLoad)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(exp_load, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, c_sys5)
        exp_load_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(exp_load, exp_load_copy, exclude=Set([:internal]))
    end
    @testset "Line to JSON and Back" begin
        line = PSY.get_component(PSY.Line, c_sys5, "4")
        @test isa(line, PSY.Line)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(line, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, c_sys5)
        line_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(line, line_copy, exclude=Set([:internal]))
    end
    @testset "PowerLoad to JSON and Back" begin
        load = PSY.get_component(PSY.PowerLoad, c_sys5, "Bus2")
        @test isa(load, PSY.PowerLoad)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(load, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, c_sys5)
        load_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(load, load_copy, exclude=Set([:internal]))
    end
    @testset "RenewableDispatch to JSON and Back" begin
        renew = PSY.get_component(PSY.RenewableDispatch, c_sys5, "PVBus5")
        @test isa(renew, PSY.RenewableDispatch)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(renew, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, c_sys5)
        renew_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(renew, renew_copy, exclude=Set([:internal]))
    end
    @testset "SwitchedAdmittance to JSON and Back" begin
        switch = PSY.SwitchedAdmittance(
            name="switch",
            available=true,
            bus=PSY.get_bus(c_sys5, 3),
            Y=0.0 - 1.0im,
            number_of_steps=1,
            Y_increase=0.0 - 0.1im,
        )
        PSY.add_component!(c_sys5, switch)
        @test isa(switch, PSY.SwitchedAdmittance)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(switch, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, c_sys5)
        switch_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(switch, switch_copy, exclude=Set([:internal]))
    end
    @testset "ThermalStandard to JSON and Back" begin
        thermal = PSY.get_component(PSY.ThermalStandard, c_sys5, "Solitude")
        @test isa(thermal, PSY.ThermalStandard)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(thermal, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, c_sys5)
        thermal_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(thermal, thermal_copy, exclude=Set([:internal]))
    end
    @testset "TwoTerminalVSCDCLine to JSON and Back" begin
        vscdc = PSY.TwoTerminalVSCDCLine(
            name="vscdc",
            available=true,
            active_power_flow=0.0,
            arc=PSY.get_component(PSY.Arc, c_sys5, "nodeB -> nodeC"),
            rectifier_tap_limits=(min=-2.0, max=2.0),
            rectifier_xrc=0.02,
            rectifier_firing_angle=(min=-0.7, max=0.7),
            inverter_tap_limits=(min=-2.0, max=2.0),
            inverter_xrc=0.02,
            inverter_extinction_angle=(min=-0.7, max=0.7),
        )
        PSY.add_component!(c_sys5, vscdc)
        @test isa(vscdc, PSY.TwoTerminalVSCDCLine)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(vscdc, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, c_sys5)
        vscdc_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(vscdc, vscdc_copy, exclude=Set([:internal]))
    end
end

@testset "RTS_GMLC_RT_sys Complete RoundTrip to JSON" begin
    RTS_GMLC_RT_sys = PowerSystemCaseBuilder.build_system(
        PowerSystemCaseBuilder.PSISystems,
        "RTS_GMLC_RT_sys",
    )
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
        @test IS.compare_values(reserve, reserve_copy, exclude=Set([:internal]))
    end
    @testset "EnergyReservoirStorage to JSON and Back" begin
        energy_res =
            PSY.get_component(PSY.EnergyReservoirStorage, RTS_GMLC_RT_sys, "313_STORAGE_1")
        @test isa(energy_res, PSY.EnergyReservoirStorage)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(energy_res, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, RTS_GMLC_RT_sys)
        energy_res_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(energy_res, energy_res_copy, exclude=Set([:internal]))
    end
    @testset "FixedAdmittance to JSON and Back" begin
        fixed = PSY.get_component(PSY.FixedAdmittance, RTS_GMLC_RT_sys, "Camus")
        @test isa(fixed, PSY.FixedAdmittance)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(fixed, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, RTS_GMLC_RT_sys)
        fixed_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(fixed, fixed_copy, exclude=Set([:internal]))
    end
    @testset "RenewableNonDispatch to JSON and Back" begin
        renewnon =
            PSY.get_component(PSY.RenewableNonDispatch, RTS_GMLC_RT_sys, "313_RTPV_1")
        @test isa(renewnon, PSY.RenewableNonDispatch)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(renewnon, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, RTS_GMLC_RT_sys)
        renewnon_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(renewnon, renewnon_copy, exclude=Set([:internal]))
    end
    @testset "TwoTerminalHVDCLine to JSON and Back" begin
        hvdc = PSY.get_component(PSY.TwoTerminalHVDCLine, RTS_GMLC_RT_sys, "DC1")
        @test isa(hvdc, PSY.TwoTerminalHVDCLine)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(hvdc, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, RTS_GMLC_RT_sys)
        hvdc_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(hvdc, hvdc_copy, exclude=Set([:internal]))
    end
    @testset "VariableReserve DOWN to JSON and Back" begin
        reg_down = PSY.get_component(PSY.VariableReserve, RTS_GMLC_RT_sys, "Reg_Down")
        @test isa(reg_down, PSY.VariableReserve{PSY.ReserveDown})
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(reg_down, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, RTS_GMLC_RT_sys)
        reg_down_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(reg_down, reg_down_copy, exclude=Set([:internal]))
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
        @test IS.compare_values(reserve, reserve_copy, exclude=Set([:internal]))
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
        @test IS.compare_values(dcbus, dcbus_copy, exclude=Set([:internal]))
    end
    @testset "InterconnectingConverter to JSON and Back" begin
        inter =
            PSY.get_component(PSY.InterconnectingConverter, sys10_pjm_ac_dc, "IPC-nodeD2")
        @test isa(inter, PSY.InterconnectingConverter)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(inter, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, sys10_pjm_ac_dc)
        inter_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(inter, inter_copy, exclude=Set([:internal]))
    end
    @testset "TModelHVDCLine to JSON and Back" begin
        tmodel =
            PSY.get_component(PSY.TModelHVDCLine, sys10_pjm_ac_dc, "nodeD_DC-nodeD2_DC")
        @test isa(tmodel, PSY.TModelHVDCLine)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(tmodel, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, sys10_pjm_ac_dc)
        tmodel_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(tmodel, tmodel_copy, exclude=Set([:internal]))
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
        @test IS.compare_values(area, area_copy, exclude=Set([:internal]))
    end
    @testset "LoadZone to JSON and Back" begin
        load_zone = PSY.get_component(PSY.LoadZone, sys, "1")
        @test isa(load_zone, PSY.LoadZone)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(load_zone, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, sys)
        load_zone_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(load_zone, load_zone_copy, exclude=Set([:internal]))
    end
    @testset "Source to JSON and Back" begin
        source = PSY.get_component(PSY.Source, sys, "generator-102-1")
        @test isa(source, PSY.Source)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(source, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, sys)
        source_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(source, source_copy, exclude=Set([:internal]))
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
        @test IS.compare_values(hydro, hydro_copy, exclude=Set([:internal]))
    end
    @testset "StandardLoad to JSON and Back" begin
        load = PSY.get_component(PSY.StandardLoad, c_sys5_all, "Bus3")
        @test isa(load, PSY.StandardLoad)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(load, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, c_sys5_all)
        load_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(load, load_copy, exclude=Set([:internal]))
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
        @test IS.compare_values(hydro_res, hydro_res_copy, exclude=Set([:internal]))
    end
    @testset "InterruptiblePowerLoad to JSON and Back" begin
        interrupt =
            only(collect(PSY.get_components(PSY.InterruptiblePowerLoad, c_sys5_hy_ed)))
        @test isa(interrupt, PSY.InterruptiblePowerLoad)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(interrupt, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, c_sys5_hy_ed)
        interrupt_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(interrupt, interrupt_copy, exclude=Set([:internal]))
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
        @test IS.compare_values(taptransform, taptransform_copy, exclude=Set([:internal]))
    end
    @testset "Transformer2W to JSON and Back" begin
        transform = PSY.get_component(PSY.Transformer2W, sys_14_bus, "BUS 08-BUS 07-i_1")
        @test isa(transform, PSY.Transformer2W)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(transform, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, sys_14_bus)
        transform_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(transform, transform_copy, exclude=Set([:internal]))
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
            exclude=Set([:internal]),
        )
    end
    @testset "MonitoredLine to JSON and Back" begin
        monitored = only(collect(PSY.get_components(PSY.MonitoredLine, two_area_pjm_DA)))
        @test isa(monitored, PSY.MonitoredLine)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(monitored, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, two_area_pjm_DA)
        monitored_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(monitored, monitored_copy, exclude=Set([:internal]))
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
        @test IS.compare_values(agc, agc_copy, exclude=Set([:internal]))
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
        @test IS.compare_values(phase, phase_copy, exclude=Set([:internal]))
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
        @test IS.compare_values(multi, multi_copy, exclude=Set([:internal]))
    end
end

@testset "c_sys5_phes_ed Complete Roundtrip to JSON" begin
    c_sys5_phes_ed = PowerSystemCaseBuilder.build_system(
        PowerSystemCaseBuilder.PSITestSystems,
        "c_sys5_phes_ed",
    )
    @testset "HydroPumpedStorage to JSON and Back" begin
        pumped =
            PSY.get_component(PSY.HydroPumpedStorage, c_sys5_phes_ed, "HydroPumpedStorage")
        @test isa(pumped, PSY.HydroPumpedStorage)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(pumped, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, c_sys5_phes_ed)
        pumped_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(pumped, pumped_copy, exclude=Set([:internal]))
    end
end
