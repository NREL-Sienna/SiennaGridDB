using SiennaOpenAPIModels
using PowerSystemCaseBuilder
import PowerSystems as PSY
using JSON
import SQLite
using Test
import OpenAPI

"""
Validate schema and counts for all component types.
"""
function validate_export(data::Dict, sys)
    for OpenAPI_T in SiennaOpenAPIModels.ALL_DESERIALIZABLE_TYPES
        type_name = string(nameof(OpenAPI_T))
        items = get(data["components"], type_name, [])

        # Validate each dict deserializes to OpenAPI type
        for (i, dict) in enumerate(items)
            try
                OpenAPI.from_json(OpenAPI_T, dict)
            catch e
                error("Failed to validate $type_name[$i]: $e\nDict: $dict")
            end
        end

        # Validate count matches original system
        PSY_T = SiennaOpenAPIModels.OPENAPI_TYPE_TO_PSY[OpenAPI_T]
        @test length(items) == length(PSY.get_components(PSY_T, sys))
    end
end

function export_and_parse(sys; kwargs...)
    db = SQLite.DB()
    SiennaOpenAPIModels.make_sqlite!(db)
    SiennaOpenAPIModels.sys2db!(db, sys, SiennaOpenAPIModels.IDGenerator())
    path = tempname() * ".json"
    SiennaOpenAPIModels.db2openapi_json(db, path; kwargs...)
    data = JSON.parsefile(path)
    rm(path)
    return data
end

@testset "db2openapi_json" begin
    c_sys5 = build_system(PSISystems, "c_sys5_pjm")

    @testset "schema and counts" begin
        validate_export(export_and_parse(c_sys5), c_sys5)
    end

    @testset "system metadata" begin
        data = export_and_parse(
            c_sys5;
            system_name="test",
            base_power=200.0,
            description="desc",
        )
        @test data["system"] ==
              Dict("name" => "test", "base_power" => 200.0, "description" => "desc")

        data = export_and_parse(c_sys5)
        @test data["system"] ==
              Dict("name" => "", "base_power" => 100.0, "description" => "")
    end
end

@testset "db2openapi_json RTS" begin
    rts = build_system(PSITestSystems, "test_RTS_GMLC_sys")
    validate_export(export_and_parse(rts), rts)
end
