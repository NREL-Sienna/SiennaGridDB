using SiennaOpenAPIModels
using OpenAPI
using PowerSystemCaseBuilder
import PowerSystems
const PSY = PowerSystems
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

@testset "c_sys5_pjm RoundTrip to JSON" begin
    c_sys5 =
        PowerSystemCaseBuilder.build_system(PowerSystemCaseBuilder.PSISystems, "c_sys5_pjm")
    @testset "ThermalStandard to JSON" begin
        thermal_standard = PSY.get_component(PSY.ThermalStandard, c_sys5, "Solitude")

        test_convert = SiennaOpenAPIModels.psy2openapi(thermal_standard, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.ThermalStandard, test_convert)
        @test test_convert.id == 1
        @test test_convert.bus == 2
        @test test_convert.active_power == 520.0  # test units
    end
    @testset "ACBus to JSON" begin
        acbus = PSY.get_bus(c_sys5, 1)
        @test isa(acbus, PSY.ACBus)
        test_convert = SiennaOpenAPIModels.psy2openapi(acbus, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.ACBus, test_convert)
        @test test_convert.id == 1
        @test test_convert.number == 1
        @test isnothing(test_convert.area)
        @test isnothing(test_convert.load_zone)
        @test test_convert.magnitude == 1.0
    end
    @testset "Arc to JSON" begin
        arc = first(PSY.get_components(PSY.Arc, c_sys5))
        @test isa(arc, PSY.Arc)
        test_convert = SiennaOpenAPIModels.psy2openapi(arc, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.Arc, test_convert)
        @test test_convert.id == 1
        @test test_convert.from == 2
        @test test_convert.to == 3
    end
    @testset "Line to JSON" begin
        line = PSY.get_component(PSY.Line, c_sys5, "4")
        @test isa(line, PSY.Line)
        test_convert = SiennaOpenAPIModels.psy2openapi(line, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.Line, test_convert)
        @test test_convert.id == 1
        @test test_convert.arc == 2
        @test test_convert.rating == 1114.8
    end
    @testset "PowerLoad to JSON" begin
        power_load = PSY.get_component(PSY.PowerLoad, c_sys5, "Bus2")
        @test isa(power_load, PSY.PowerLoad)
        test_convert = SiennaOpenAPIModels.psy2openapi(power_load, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.PowerLoad, test_convert)
        @test test_convert.id == 1
        @test test_convert.bus == 2
        @test test_convert.max_active_power == 369.0024868749973
    end
    @testset "StandardLoad to JSON" begin
        standard_load = PSY.StandardLoad(
            name="standard_load",
            available=true,
            bus=PSY.get_bus(c_sys5, 2),
            base_power=32.0,
            constant_active_power=0.5,
            max_constant_active_power=0.75,
        )
        PSY.add_component!(c_sys5, standard_load)
        @test isa(standard_load, PSY.StandardLoad)
        test_convert = SiennaOpenAPIModels.psy2openapi(standard_load, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.StandardLoad, test_convert)
        @test test_convert.id == 1
        @test test_convert.available
        @test test_convert.bus == 2
        @test test_convert.constant_active_power == 16.0
        @test test_convert.max_constant_active_power == 24.0
    end
    @testset "RenewableDispatch to JSON" begin
        renewable_dispatch = PSY.get_component(PSY.RenewableDispatch, c_sys5, "PVBus5")
        @test isa(renewable_dispatch, PSY.RenewableDispatch)
        test_convert = SiennaOpenAPIModels.psy2openapi(renewable_dispatch, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.RenewableDispatch, test_convert)
        @test test_convert.id == 1
        @test test_convert.available
        @test test_convert.bus == 2
        @test test_convert.active_power == 0.0
        @test test_convert.rating == 384.0
    end
end

@testset "sys_14_bus RoundTrip to JSON" begin
    sys_14_bus = PowerSystemCaseBuilder.build_system(
        PowerSystemCaseBuilder.PSIDSystems,
        "14 Bus Base Case",
    )
    @testset "Transformer2W to JSON" begin
        transformer2w =
            PSY.get_component(PSY.Transformer2W, sys_14_bus, "BUS 08-BUS 07-i_1")
        @test isa(transformer2w, PSY.Transformer2W)
        test_convert = SiennaOpenAPIModels.psy2openapi(transformer2w, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.Transformer2W, test_convert)
        @test test_convert.id == 1
        @test test_convert.r == 0.0
        @test test_convert.primary_shunt == 0.0
    end
    @testset "TapTransformer to JSON" begin
        taptransformer =
            PSY.get_component(PowerSystems.TapTransformer, sys_14_bus, "BUS 04-BUS 07-i_1")
        @test isa(taptransformer, PSY.TapTransformer)
        test_convert = SiennaOpenAPIModels.psy2openapi(taptransformer, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.TapTransformer, test_convert)
        @test test_convert.id == 1
        @test test_convert.rating ≈ 5.786163762803648
        @test test_convert.primary_shunt == 0.0
        @test test_convert.x ≈ 0.20912
    end
end

@testset "RTS_GMLC_RT_sys RoundTrip to JSON" begin
    RTS_GMLC_RT_sys = PowerSystemCaseBuilder.build_system(
        PowerSystemCaseBuilder.PSISystems,
        "RTS_GMLC_RT_sys",
    )
    @testset "RenewableNonDispatch to JSON" begin
        renewnondispatch =
            PSY.get_component(PSY.RenewableNonDispatch, RTS_GMLC_RT_sys, "313_RTPV_1")
        @test isa(renewnondispatch, PSY.RenewableNonDispatch)
        test_convert = SiennaOpenAPIModels.psy2openapi(renewnondispatch, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.RenewableNonDispatch, test_convert)
        @test test_convert.id == 1
        @test test_convert.power_factor == 1.0
        @test test_convert.base_power == 101.7
    end
    @testset "FixedAdmittance to JSON" begin
        fixedadmit = PSY.get_component(PSY.FixedAdmittance, RTS_GMLC_RT_sys, "Camus")
        @test isa(fixedadmit, PSY.FixedAdmittance)
        test_convert = SiennaOpenAPIModels.psy2openapi(fixedadmit, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.FixedAdmittance, test_convert)
        @test test_convert.id == 1
        @test test_convert.available
        @test isnothing(test_convert.dynamic_injector)
    end
    @testset "TwoTerminalHVDCLine to JSON" begin
        hvdc = PSY.get_component(PSY.TwoTerminalHVDCLine, RTS_GMLC_RT_sys, "DC1")
        @test isa(hvdc, PSY.TwoTerminalHVDCLine)
        test_convert = SiennaOpenAPIModels.psy2openapi(hvdc, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.TwoTerminalHVDCLine, test_convert)
        @test test_convert.id == 1
        @test test_convert.available
        @test test_convert.active_power_flow == 0.0
    end
    @testset "EnergyReservoirStorage to JSON" begin
        energy_res =
            PSY.get_component(PSY.EnergyReservoirStorage, RTS_GMLC_RT_sys, "313_STORAGE_1")
        @test isa(energy_res, PSY.EnergyReservoirStorage)
        test_convert = SiennaOpenAPIModels.psy2openapi(energy_res, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.EnergyReservoirStorage, test_convert)
        @test test_convert.id == 1
        @test test_convert.prime_mover_type == "BA"
        @test test_convert.base_power == 50.0
        @test test_convert.cycle_limits == 10000
    end
end

@testset "c_sys5_all" begin
    c_sys5_all = PowerSystemCaseBuilder.build_system(
        PowerSystemCaseBuilder.PSITestSystems,
        "c_sys5_all_components",
    )
    @testset "StandardLoad to JSON" begin
        standard_load = PSY.get_component(PSY.StandardLoad, c_sys5_all, "Bus3")
        @test isa(standard_load, PSY.StandardLoad)
        test_convert = SiennaOpenAPIModels.psy2openapi(standard_load, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.StandardLoad, test_convert)
        @test test_convert.id == 1
        @test test_convert.available
        @test test_convert.bus == 2
        @test test_convert.constant_active_power == 300.0
    end
    @testset "HydroDispatch to JSON" begin
        hydro = PSY.get_component(PSY.HydroDispatch, c_sys5_all, "HydroDispatch")
        @test isa(hydro, PSY.HydroDispatch)
        test_convert = SiennaOpenAPIModels.psy2openapi(hydro, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.HydroDispatch, test_convert)
        @test test_convert.id == 1
        @test test_convert.available
        @test test_convert.bus == 2
        @test test_convert.rating == 600.0
        @test test_convert.prime_mover_type == "HY"
    end
end

@testset "3-bus psse parsed system" begin
    sys = PowerSystemCaseBuilder.build_system(
        PowerSystemCaseBuilder.PSYTestSystems,
        "psse_3bus_gen_cls_sys",
    )
    @testset "Area to JSON" begin
        area = PSY.get_component(PSY.Area, sys, "1")
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
    @testset "LoadZone to JSON" begin
        load_zone = PSY.get_component(PSY.LoadZone, sys, "1")
        @test isa(load_zone, PSY.LoadZone)
        test_convert = SiennaOpenAPIModels.psy2openapi(load_zone, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.LoadZone, test_convert)
        @test test_convert.id == 1
        @test test_convert.name == "1"
        # Finally a floating point nummber rounding error matters...
        @test test_convert.peak_active_power == 100.0 * 2.20
        @test test_convert.peak_reactive_power == 100.0 * 0.40
    end
end

@testset "Pumped Hydro 5-bus c_sys5_phes_ed" begin
    c_sys5_phes_ed = PowerSystemCaseBuilder.build_system(
        PowerSystemCaseBuilder.PSITestSystems,
        "c_sys5_phes_ed",
    )
    @testset "PumpedHydroEnergyStorage to JSON" begin
        pumped_hydro_energy_storage =
            PSY.get_component(PSY.HydroPumpedStorage, c_sys5_phes_ed, "HydroPumpedStorage")
        @test isa(pumped_hydro_energy_storage, PSY.HydroPumpedStorage)
        test_convert =
            SiennaOpenAPIModels.psy2openapi(pumped_hydro_energy_storage, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.HydroPumpedStorage, test_convert)
        @test test_convert.id == 1
        @test test_convert.bus == 2
        @test test_convert.base_power == 50.0
        @test test_convert.rating == 50.0
        @test test_convert.rating_pump == 50.0
        @test test_convert.storage_capacity.up == 100.0
        @test test_convert.active_power_limits.max == 50.0
        @test test_convert.ramp_limits.up == 5.0
    end
end

@testset "Two area pjm" begin
    two_area_pjm_DA = PowerSystemCaseBuilder.build_system(
        PowerSystemCaseBuilder.PSISystems,
        "two_area_pjm_DA",
    )
    @testset "AreaInterchange" begin
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
    @testset "MonitoredLine" begin
        monitored = only(collect(PSY.get_components(PSY.MonitoredLine, two_area_pjm_DA)))
        @test isa(monitored, PSY.MonitoredLine)
        test_convert = SiennaOpenAPIModels.psy2openapi(monitored, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.MonitoredLine, test_convert)
        @test test_convert.id == 1
        @test test_convert.active_power_flow == 0.0
        @test test_convert.rating == 1000.0
        @test test_convert.flow_limits.from_to == 700.0
    end
end

@testset "5_bus_matpower_RT roundtrip" begin
    sys_5bus_matpower_RT = PowerSystemCaseBuilder.build_system(
        PowerSystemCaseBuilder.PSISystems,
        "5_bus_matpower_RT",
    )
    @testset "Phase Shifting Transformer" begin
        phase_shifting_transformer = PSY.get_component(
            PSY.PhaseShiftingTransformer,
            sys_5bus_matpower_RT,
            "bus3-bus4-i_6",
        )
        @test isa(phase_shifting_transformer, PSY.PhaseShiftingTransformer)
        test_convert =
            SiennaOpenAPIModels.psy2openapi(phase_shifting_transformer, IDGenerator())
        test_roundtrip(SiennaOpenAPIModels.PhaseShiftingTransformer, test_convert)
        @test test_convert.id == 1
        @test test_convert.arc == 2
        @test test_convert.x == 0.03274425
        @test test_convert.rating == 426.0
    end
end

@testset "sys10_pjm_ac_dc roundtrip" begin
    sys10_pjm_ac_dc = PowerSystemCaseBuilder.build_system(
        PowerSystemCaseBuilder.PSISystems,
        "sys10_pjm_ac_dc",
    )
    @testset "TModelHVDCLine" begin
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
