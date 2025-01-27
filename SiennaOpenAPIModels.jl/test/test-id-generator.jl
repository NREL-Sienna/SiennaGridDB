@testset "Test ID Generator" begin
    sys =
        PowerSystemCaseBuilder.build_system(PowerSystemCaseBuilder.PSISystems, "c_sys5_pjm")
    component = PSY.get_component(PSY.ThermalStandard, sys, "Solitude")

    id_generator = IDGenerator()
    @test getid!(id_generator, PSY.InfrastructureSystems.get_uuid(component)) == 1
    @test getid!(id_generator, PSY.InfrastructureSystems.get_uuid(component)) == 1
    @test getid!(id_generator, component) == 1

    id_generator = IDGenerator(3)
    @test getid!(id_generator, component) == 3
    @test getid!(id_generator, component) == 3
    @test getid!(id_generator, component.bus) == 4

    @test isnothing(component.bus.area)
    @test isnothing(getid!(id_generator, component.bus.area))
end
