using SiennaOpenAPIModels
using OpenAPI
using PowerSystemCaseBuilder
import InfrastructureSystems
const IS = InfrastructureSystems
import PowerSystems
const PSY = PowerSystems
using JSON

@testset "c_sys5_pjm RoundTrip to JSON" begin
    c_sys5 =
        PowerSystemCaseBuilder.build_system(PowerSystemCaseBuilder.PSISystems, "c_sys5_pjm")
    @testset "ACBus to JSON" begin
        acbus = PSY.get_bus(c_sys5, 1)
        @test isa(acbus, PSY.ACBus)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(acbus, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, c_sys5)
        acbus_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(acbus, acbus_copy, exclude=Set([:internal]))
    end
    @testset "ThermalStandard to JSON" begin
        thermal = PSY.get_component(PSY.ThermalStandard, c_sys5, "Solitude")
        @test isa(thermal, PSY.ThermalStandard)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(thermal, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, c_sys5)
        thermal_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(thermal, thermal_copy, exclude=Set([:internal]))
    end
    @testset "Arc to JSON" begin
        arc = first(PSY.get_components(PSY.Arc, c_sys5))
        @test isa(arc, PSY.Arc)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(arc, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, c_sys5)
        arc_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(arc, arc_copy, exclude=Set([:internal]))
    end
    @testset "RenewableDispatch to JSON" begin
        renew = PSY.get_component(PSY.RenewableDispatch, c_sys5, "PVBus5")
        @test isa(renew, PSY.RenewableDispatch)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(renew, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, c_sys5)
        renew_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test IS.compare_values(renew, renew_copy, exclude=Set([:internal]))
    end
end
