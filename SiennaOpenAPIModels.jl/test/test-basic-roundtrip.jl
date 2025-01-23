using SiennaOpenAPIModels
using OpenAPI: OpenAPI
using PowerSystemCaseBuilder: PowerSystemCaseBuilder
using PowerSystems: PowerSystems
const PSY = PowerSystems
using JSON: JSON

@testset "c_sys5_pjm ThermalStandard to JSON" begin
    sys =
        PowerSystemCaseBuilder.build_system(PowerSystemCaseBuilder.PSISystems, "c_sys5_pjm")

    thermal_standard = PSY.get_component(PSY.ThermalStandard, sys, "Solitude")

    test_convert = SiennaOpenAPIModels.convert(thermal_standard)
    post_json = OpenAPI.from_json(
        SiennaOpenAPIModels.ThermalStandard,
        JSON.parse(OpenAPI.to_json(test_convert)),
    )
    @test test_convert == post_json
end
