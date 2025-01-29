using SiennaOpenAPIModels
using PowerSystemCaseBuilder
import PowerSystems
const PSY = PowerSystems
using JSON
import SQLite
import DBInterface
import Tables

function attributes_to_dict(column_table)
    d = Dict()
    for row in Tables.rows(column_table)
        d[row.key] = row.value
    end
    return d
end

@testset "c_sys5_pjm to DB" begin
    c_sys5 =
        PowerSystemCaseBuilder.build_system(PowerSystemCaseBuilder.PSISystems, "c_sys5_pjm")
    @testset "ACBus to DB" begin
        acbus = PSY.get_bus(c_sys5, 1)
        test_convert = SiennaOpenAPIModels.psy2openapi(acbus, IDGenerator())
        db = SQLite.DB()
        SiennaOpenAPIModels.make_sqlite!(db)
        @test collect(DBInterface.execute(db, "SELECT * FROM balancing_topology")) == []
        SiennaOpenAPIModels.load_to_db!(db, test_convert)

        rows = Tables.rowtable(DBInterface.execute(db, "SELECT * FROM balancing_topology"))
        @test length(rows) == 1
        @test isequal(first(rows), (id=1, name="nodeA", obj_type="ACBus", area_id=missing))
        attributes = Tables.columntable(DBInterface.execute(db, "SELECT * FROM attributes"))
        @test length(attributes.id) == 6
        @test length(unique(attributes.id)) == 6
        @test all(attributes.entity_type .== "")
        @test all(attributes.entity_id .== 1)
        @test attributes_to_dict(attributes) == Dict(
            "voltage_limits" => Dict{String, Any}("max" => 1.05, "min" => 0.9),
            "base_voltage" => 230.0,
            "number" => 1,
            "magnitude" => 1.0,
            "angle" => 0.0,
            "bustype" => "PV",
        )
    end
end
