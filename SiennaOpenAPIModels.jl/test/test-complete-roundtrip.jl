using SiennaOpenAPIModels
using OpenAPI
using PowerSystemCaseBuilder
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
        @test acbus.name == acbus_copy.name
        @test acbus.number == acbus_copy.number
        @test acbus.bustype == acbus_copy.bustype
        @test acbus.angle == acbus_copy.angle
        @test acbus.magnitude == acbus_copy.magnitude
        @test acbus.voltage_limits == acbus_copy.voltage_limits
        @test acbus.base_voltage == acbus_copy.base_voltage
        @test acbus.area == acbus_copy.area
        @test acbus.load_zone == acbus_copy.load_zone
    end
end
