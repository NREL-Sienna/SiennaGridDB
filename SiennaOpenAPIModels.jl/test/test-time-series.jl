@testset "c_sys5_pjm time-series to DB" begin
    sys =
        PowerSystemCaseBuilder.build_system(PowerSystemCaseBuilder.PSISystems, "c_sys5_pjm")

    db = SQLite.DB()
    SiennaOpenAPIModels.make_sqlite!(db)
    ids = IDGenerator()
    SiennaOpenAPIModels.sys2db!(db, sys, ids)

    SiennaOpenAPIModels.serialize_timeseries!(db, sys)

    copy_of_sys = SiennaOpenAPIModels.make_system_from_db(db)
    SiennaOpenAPIModels.deserialize_timeseries!(copy_of_sys, db)
    @test copy_of_sys isa PSY.System
    test_component_each_type(sys, copy_of_sys)
end
