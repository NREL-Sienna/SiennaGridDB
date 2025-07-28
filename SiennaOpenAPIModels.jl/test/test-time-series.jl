import TimeSeries

InfrastructureSystems._is_compare_directly(::TimeSeries.TimeArray, ::TimeSeries.TimeArray) =
    true

function test_all_time_series(sys1::PSY.System, sys2::PSY.System)
    for T in SiennaOpenAPIModels.ALL_DESERIALIZABLE_TYPES
        SIENNA_T = SiennaOpenAPIModels.OPENAPI_TYPE_TO_PSY[T]
        for c in PowerSystems.get_components(SIENNA_T, sys1)
            new_component = PSY.get_component(SIENNA_T, sys2, PSY.get_name(c))
            if PowerSystems.has_time_series(c)
                for key in PowerSystems.get_time_series_keys(c)
                    ts = PowerSystems.get_time_series(c, key)
                    @test PowerSystems.has_time_series(new_component)
                    new_ts = PowerSystems.get_time_series(new_component, key)
                    @test !isnothing(new_ts)
                    @test IS.compare_values(
                        custom_isequivalent,
                        ts,
                        new_ts,
                        compare_uuids=false,
                        exclude=Set([:units_info, :ext, :services]),
                    )
                end
            end
        end
    end
end

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
    test_all_time_series(sys, copy_of_sys)
end

@testset "5bus matpower RT time-series to DB" begin
    sys = PowerSystemCaseBuilder.build_system(
        PowerSystemCaseBuilder.PSISystems,
        "5_bus_matpower_RT",
    )
    db = SQLite.DB()
    SiennaOpenAPIModels.make_sqlite!(db)
    ids = IDGenerator()
    SiennaOpenAPIModels.sys2db!(db, sys, ids)
    SiennaOpenAPIModels.serialize_timeseries!(db, sys)

    copy_of_sys = SiennaOpenAPIModels.make_system_from_db(db)
    SiennaOpenAPIModels.deserialize_timeseries!(copy_of_sys, db)
    @test copy_of_sys isa PSY.System
    #test_component_each_type(sys, copy_of_sys)  # it has dynamic injectors
    test_all_time_series(sys, copy_of_sys)
end

@testset "RTS_GMLC_RT_sys time-series to DB" begin
    sys = PowerSystemCaseBuilder.build_system(
        PowerSystemCaseBuilder.PSISystems,
        "RTS_GMLC_DA_sys",
    )

    # Apply the same fixes as in test-db.jl for RTS system
    for fixed_admittance in PSY.get_components(PSY.FixedAdmittance, sys)
        PSY.set_name!(sys, fixed_admittance, PSY.get_name(fixed_admittance) * "_admitatnce")
    end
    for thermal_standard in
        PSY.get_components(x -> x.base_power == 0.0, PSY.ThermalStandard, sys)
        PSY.set_base_power!(thermal_standard, 0.001)
    end

    db = SQLite.DB()
    SiennaOpenAPIModels.make_sqlite!(db)
    ids = IDGenerator()
    SiennaOpenAPIModels.sys2db!(db, sys, ids)
    SiennaOpenAPIModels.serialize_timeseries!(db, sys)

    copy_of_sys = SiennaOpenAPIModels.make_system_from_db(db)
    SiennaOpenAPIModels.deserialize_timeseries!(copy_of_sys, db)
    @test copy_of_sys isa PSY.System
    test_component_each_type(sys, copy_of_sys)
    test_all_time_series(sys, copy_of_sys)
end
