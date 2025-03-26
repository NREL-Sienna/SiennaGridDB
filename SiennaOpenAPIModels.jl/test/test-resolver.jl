@testset "Test Resolver" begin
    sys =
        PowerSystemCaseBuilder.build_system(PowerSystemCaseBuilder.PSISystems, "c_sys5_pjm")
    component = PSY.get_component(PSY.ThermalStandard, sys, "Solitude")

    id_generator = IDGenerator()
    @test getid!(id_generator, component) == 1
    resolver = SiennaOpenAPIModels.resolver_from_id_generator(id_generator, sys)

    @test resolver(1) == component
    @test_throws KeyError resolver(2)
end
