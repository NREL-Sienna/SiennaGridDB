using SiennaOpenAPIModels
using OpenAPI
using PowerSystemCaseBuilder
import InfrastructureSystems
const IS = InfrastructureSystems
import PowerSystems
const PSY = PowerSystems
using JSON
using Infiltrator

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
    @testset "ThermalStandard to JSON" begin
        thermal = PSY.get_component(PSY.ThermalStandard, c_sys5, "Solitude")
        @test isa(thermal, PSY.ThermalStandard)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(thermal, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, c_sys5)
        thermal_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test thermal.name == thermal_copy.name
        @test thermal.bus == thermal_copy.bus
        @test thermal.active_power == thermal_copy.active_power
        @test thermal.reactive_power == thermal_copy.reactive_power
        @test thermal.rating == thermal_copy.rating
        @test thermal.active_power_limits == thermal_copy.active_power_limits
        @test IS.compare_values(thermal.operation_cost, thermal_copy.operation_cost)
        @test thermal.prime_mover_type == thermal_copy.prime_mover_type
    end
    @testset "RenewableDispatch to JSON" begin
        renew = PSY.get_component(PSY.RenewableDispatch, c_sys5, "PVBus5")
        @test isa(renew, PSY.RenewableDispatch)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(renew, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, c_sys5)
        renew_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test renew.name == renew_copy.name
        @test renew.available == renew_copy.available
        @test renew.bus == renew_copy.bus
        @test renew.active_power == renew_copy.active_power
        @test renew.reactive_power == renew_copy.reactive_power
        @test renew.rating == renew_copy.rating
        @test renew.prime_mover_type == renew_copy.prime_mover_type
        @test renew.reactive_power_limits == renew_copy.reactive_power_limits
        @test IS.compare_values(renew.operation_cost, renew_copy.operation_cost)
    end
    @testset "Line to JSON" begin
        line = PSY.get_component(PSY.Line, c_sys5, "4")
        @test isa(line, PSY.Line)
        id_gen = IDGenerator()
        test_convert = SiennaOpenAPIModels.psy2openapi(line, id_gen)
        resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_gen, c_sys5)
        line_copy = SiennaOpenAPIModels.openapi2psy(test_convert, resolver)
        @test line.name == line_copy.name
        @test line.available == line_copy.available
        @test line.active_power_flow == line_copy.active_power_flow
        @test line.arc == line_copy.arc
        @test line.b == line_copy.b
        @test line.rating == line_copy.rating
        @test line.angle_limits == line_copy.angle_limits
        @test line.g == line_copy.g
        @infiltrate
    end
end
