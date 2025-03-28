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
        d[row.key] = JSON.parse(row.value)
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
        @test collect(DBInterface.execute(db, "SELECT * FROM bus")) == []
        SiennaOpenAPIModels.load_to_db!(db, test_convert)

        rows = Tables.rowtable(DBInterface.execute(db, "SELECT * FROM bus"))
        @test length(rows) == 1
        @test isequal(
            first(rows),
            (id=1, name="nodeA", obj_type="ACBus", area_id=missing, loadzone_id=missing),
        )
        attributes = Tables.columntable(
            DBInterface.execute(
                db,
                "SELECT id, entity_id, entity_type, key, json(value) as value FROM attributes",
            ),
        )
        @test length(attributes.id) == 6
        @test length(unique(attributes.id)) == 6
        @test all(attributes.entity_id .== 1)
        @test all(attributes.entity_type .== "bus")
        @test attributes_to_dict(attributes) == Dict(
            "voltage_limits" => Dict{String, Any}("max" => 1.05, "min" => 0.9),
            "base_voltage" => 230.0,
            "number" => 1,
            "magnitude" => 1.0,
            "angle" => 0.0,
            "bustype" => "PV",
        )
    end
    @testset "Full sys to DB" begin
        db = SQLite.DB()
        SiennaOpenAPIModels.make_sqlite!(db)
        SiennaOpenAPIModels.sys2db!(db, c_sys5, IDGenerator())
        acbuses = Tables.columntable(DBInterface.execute(db, "SELECT * FROM bus"))
        @test sort(acbuses.id) == [1, 2, 3, 4, 5]
        loads = Tables.columntable(DBInterface.execute(db, "SELECT * FROM load"))
        @test length(loads.id) == 3
        @test length(unique(loads.id)) == 3
        loads_attribute = Tables.columntable(
            DBInterface.execute(db, "SELECT * FROM attributes where entity_id=1"),
        )
        @test all(loads_attribute.entity_type .== "bus")
    end
end

@testset "118_bus to DB" begin
    # Get 118_bus_rt.json from directory of this file
    sys = PSY.System(joinpath(dirname(@__FILE__), "118_bus.json"))
    db = SQLite.DB()
    SiennaOpenAPIModels.make_sqlite!(db)
    SiennaOpenAPIModels.sys2db!(db, sys, IDGenerator())
    acbuses = Tables.columntable(DBInterface.execute(db, "SELECT * FROM bus"))
    @test length(acbuses.id) == 118
end
