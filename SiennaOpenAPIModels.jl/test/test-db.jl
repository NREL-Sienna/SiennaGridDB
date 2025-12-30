using SiennaOpenAPIModels
using PowerSystemCaseBuilder
import PowerSystems as PSY
import InfrastructureSystems as IS
using JSON
import SQLite
import DBInterface
import Tables
using Test

function attributes_to_dict(column_table)
    d = Dict()
    for row in Tables.rows(column_table)
        d[row.name] = JSON.parse(row.value)
    end
    return d
end

function test_component_each_type(sys, copy_of_sys)
    for T in SiennaOpenAPIModels.ALL_DESERIALIZABLE_TYPES
        SIENNA_T = SiennaOpenAPIModels.OPENAPI_TYPE_TO_PSY[T]
        @test length(PSY.get_components(SIENNA_T, sys)) ==
              length(PSY.get_components(SIENNA_T, copy_of_sys))
        if SIENNA_T <: PSY.Arc
            continue
        end
        if isempty(PSY.get_components(SIENNA_T, sys))
            continue
        end
        component = first(PSY.get_components(SIENNA_T, sys))
        new_component = PSY.get_component(SIENNA_T, copy_of_sys, component.name)
        @test IS.compare_values(
            custom_isequivalent,
            component,
            new_component,
            compare_uuids=true,
            exclude=Set([:units_info, :ext, :services]),
        )
    end

    arcs = [c.from.name => c.to.name for c in PSY.get_components(PSY.Arc, sys)]
    arcs_copy = [c.from.name => c.to.name for c in PSY.get_components(PSY.Arc, copy_of_sys)]
    @test sort(arcs) == sort(arcs_copy)
end

@testset "c_sys5_pjm to DB" begin
    c_sys5 =
        PowerSystemCaseBuilder.build_system(PowerSystemCaseBuilder.PSISystems, "c_sys5_pjm")
    @testset "ACBus to DB" begin
        acbus = PSY.get_bus(c_sys5, 1)
        db = SQLite.DB()
        SiennaOpenAPIModels.make_sqlite!(db)
        @test collect(DBInterface.execute(db, "SELECT * FROM balancing_topologies")) == []
        SiennaOpenAPIModels.send_table_to_db!(
            SiennaOpenAPIModels.ACBus,
            db,
            [acbus],
            IDGenerator(),
        )

        rows =
            Tables.rowtable(DBInterface.execute(db, "SELECT * FROM balancing_topologies"))
        @test length(rows) == 1
        @test isequal(first(rows), (id=1, name="nodeA", area=missing, description=missing))
        attributes = Tables.columntable(
            DBInterface.execute(
                db,
                "SELECT id, entity_id, name, json(value) as value FROM attributes",
            ),
        )
        @test length(attributes.id) == 8
        @test length(unique(attributes.id)) == 8
        @test all(attributes.entity_id .== 1)
        @test attributes_to_dict(attributes) == Dict(
            "voltage_limits" => Dict{String, Any}("max" => 1.05, "min" => 0.9),
            "available" => true,
            "base_voltage" => 230.0,
            "number" => 1,
            "magnitude" => 1.0,
            "angle" => 0.0,
            "bustype" => "PV",
            "uuid" => string(IS.get_uuid(acbus)),
        )
    end
    @testset "Full sys to DB" begin
        db = SQLite.DB()
        SiennaOpenAPIModels.make_sqlite!(db)
        SiennaOpenAPIModels.sys2db!(db, c_sys5, IDGenerator())
        acbuses = Tables.columntable(
            DBInterface.execute(db, "SELECT * FROM balancing_topologies"),
        )
        @test sort(acbuses.id) == [1, 2, 3, 4, 5]
        loads = Tables.columntable(DBInterface.execute(db, "SELECT * FROM loads"))
        @test length(loads.id) == 3
        @test length(unique(loads.id)) == 3
        loads_attribute = Tables.columntable(
            DBInterface.execute(db, "SELECT * FROM attributes where entity_id=1"),
        )
        #@test all(loads_attribute.entity_type .== "bus")
    end

    @testset "DB to Sys" begin
        db = SQLite.DB()
        SiennaOpenAPIModels.make_sqlite!(db)
        id_generator = IDGenerator()
        SiennaOpenAPIModels.sys2db!(db, c_sys5, id_generator)
        copy_of_sys = SiennaOpenAPIModels.db2sys(db)
        @test copy_of_sys isa PSY.System
        for T in SiennaOpenAPIModels.ALL_DESERIALIZABLE_TYPES
            SIENNA_T = SiennaOpenAPIModels.OPENAPI_TYPE_TO_PSY[T]
            @test length(PSY.get_components(SIENNA_T, c_sys5)) ==
                  length(PSY.get_components(SIENNA_T, copy_of_sys))
            if SIENNA_T <: PSY.Arc
                continue
            end
            for component in PSY.get_components(SIENNA_T, c_sys5)
                new_component = PSY.get_component(SIENNA_T, copy_of_sys, component.name)
                @test IS.compare_values(
                    custom_isequivalent,
                    component,
                    new_component,
                    exclude=Set([:internal]),
                )
            end
        end
    end
end

# TODO: Add 118-bus to PSCB instead.
#=
@testset "118_bus to DB" begin
    # Get 118_bus.json from directory of this file
    sys = PSY.System(joinpath(dirname(@__FILE__), "118_bus.json"))
    db = SQLite.DB()
    SiennaOpenAPIModels.make_sqlite!(db)
    SiennaOpenAPIModels.sys2db!(db, sys, IDGenerator())
    acbuses =
        Tables.columntable(DBInterface.execute(db, "SELECT * FROM balancing_topologies"))
    @test length(acbuses.id) == 118
    copy_of_sys = SiennaOpenAPIModels.db2sys(db)
    @test copy_of_sys isa PSY.System
    test_component_each_type(sys, copy_of_sys)
end
=#

@testset "RTS-System to DB" begin
    sys = PowerSystemCaseBuilder.build_system(
        PowerSystemCaseBuilder.PSISystems,
        "RTS_GMLC_RT_sys",
    )
    for fixed_admittance in PSY.get_components(PSY.FixedAdmittance, sys)
        PSY.set_name!(sys, fixed_admittance, PSY.get_name(fixed_admittance) * "_admitatnce")
    end
    for thermal_standard in
        PSY.get_components(x -> x.base_power == 0.0, PSY.ThermalStandard, sys)
        PSY.set_base_power!(thermal_standard, 0.001)
    end
    db = SQLite.DB()
    SiennaOpenAPIModels.make_sqlite!(db)
    SiennaOpenAPIModels.sys2db!(db, sys, IDGenerator())
    acbuses = Tables.columntable(
        DBInterface.execute(
            db,
            "SELECT * FROM balancing_topologies bt LEFT JOIN entities e ON bt.id = e.id
WHERE e.entity_type = 'ACBus'",
        ),
    )
    @test length(acbuses.id) == 73

    copy_of_sys = SiennaOpenAPIModels.db2sys(db)
    @test copy_of_sys isa PSY.System
    test_component_each_type(sys, copy_of_sys)
end

@testset "Two Area PJM DA System to DB" begin
    sys = PowerSystemCaseBuilder.build_system(
        PowerSystemCaseBuilder.PSISystems,
        "two_area_pjm_DA",
    )

    db = SQLite.DB()
    SiennaOpenAPIModels.make_sqlite!(db)
    SiennaOpenAPIModels.sys2db!(db, sys, IDGenerator())
    interchanges = Tables.columntable(
        DBInterface.execute(db, "SELECT * FROM transmission_interchanges"),
    )
    @test length(interchanges.id) == 1

    copy_of_sys = SiennaOpenAPIModels.db2sys(db)
    @test copy_of_sys isa PSY.System
    test_component_each_type(sys, copy_of_sys)
end

@testset "c_sys5_phes_ed to DB" begin
    sys = PowerSystemCaseBuilder.build_system(
        PowerSystemCaseBuilder.PSITestSystems,
        "c_sys5_phes_ed",
    )

    db = SQLite.DB()
    SiennaOpenAPIModels.make_sqlite!(db)
    ids = IDGenerator()
    SiennaOpenAPIModels.sys2db!(db, sys, ids)
    # HydroPumpTurbine is now in hydro_generators, not storage_units
    hydro_gens =
        Tables.columntable(DBInterface.execute(db, "SELECT * FROM hydro_generators"))
    @test length(hydro_gens.id) == 1
    reservoirs =
        Tables.columntable(DBInterface.execute(db, "SELECT * from hydro_reservoir"))
    @test length(reservoirs.id) == 2

    copy_of_sys = SiennaOpenAPIModels.db2sys(db)
    @test copy_of_sys isa PSY.System
    test_component_each_type(sys, copy_of_sys)
end

@testset "Uncommon types round-trip" begin
    # Test types that aren't in standard test systems
    sys =
        PowerSystemCaseBuilder.build_system(PowerSystemCaseBuilder.PSISystems, "c_sys5_pjm")
    bus1 = first(PSY.get_components(PSY.ACBus, sys))
    buses = collect(PSY.get_components(PSY.ACBus, sys))
    bus2 = buses[2]
    arc = PSY.Arc(; from=bus1, to=bus2)
    PSY.add_component!(sys, arc)

    # Add ThermalMultiStart (not in any test system)
    thermal_ms = PSY.ThermalMultiStart(
        name="test_thermal_multistart",
        available=true,
        status=true,
        bus=bus1,
        active_power=0.5,
        reactive_power=0.1,
        rating=1.0,
        active_power_limits=(min=0.2, max=1.0),
        reactive_power_limits=(min=-0.5, max=0.5),
        ramp_limits=(up=0.1, down=0.1),
        power_trajectory=(startup=0.3, shutdown=0.2),
        time_limits=(up=4.0, down=2.0),
        start_time_limits=(hot=1.0, warm=2.0, cold=3.0),
        start_types=3,
        prime_mover_type=PSY.PrimeMovers.CT,
        fuel=PSY.ThermalFuels.NATURAL_GAS,
        base_power=100.0,
        operation_cost=PSY.ThermalGenerationCost(nothing),
        must_run=false,
    )
    PSY.add_component!(sys, thermal_ms)

    # Add MonitoredLine (not in any test system)
    monitored_line = PSY.MonitoredLine(
        name="test_monitored_line",
        available=true,
        active_power_flow=0.0,
        reactive_power_flow=0.0,
        arc=arc,
        r=0.01,
        x=0.1,
        b=(from=0.01, to=0.01),
        rating=1.0,
        angle_limits=(min=-0.5, max=0.5),
        flow_limits=(from_to=1.0, to_from=1.0),
    )
    PSY.add_component!(sys, monitored_line)

    # Add PhaseShiftingTransformer (not in any test system)
    pst = PSY.PhaseShiftingTransformer(
        name="test_phase_shifting_transformer",
        available=true,
        active_power_flow=0.0,
        reactive_power_flow=0.0,
        arc=arc,
        r=0.01,
        x=0.1,
        primary_shunt=0.01,
        tap=1.0,
        α=0.0,
        rating=1.0,
        base_power=100.0,
    )
    PSY.add_component!(sys, pst)

    db = SQLite.DB()
    SiennaOpenAPIModels.make_sqlite!(db)
    ids = IDGenerator()
    SiennaOpenAPIModels.sys2db!(db, sys, ids)

    # Verify components were inserted
    thermal_gens = Tables.columntable(
        DBInterface.execute(
            db,
            "SELECT * FROM thermal_generators WHERE name = 'test_thermal_multistart'",
        ),
    )
    @test length(thermal_gens.id) == 1
    @test thermal_gens.fuel[1] == "NATURAL_GAS"

    tx_lines =
        Tables.columntable(DBInterface.execute(db, "SELECT * FROM transmission_lines"))
    @test length(tx_lines.id) >= 2  # MonitoredLine + PhaseShiftingTransformer + existing

    copy_of_sys = SiennaOpenAPIModels.make_system_from_db(db)
    @test copy_of_sys isa PSY.System

    # Verify ThermalMultiStart round-tripped
    @test length(PSY.get_components(PSY.ThermalMultiStart, copy_of_sys)) == 1
    @test IS.compare_values(
        custom_isequivalent,
        first(PSY.get_components(PSY.ThermalMultiStart, sys)),
        first(PSY.get_components(PSY.ThermalMultiStart, copy_of_sys)),
        compare_uuids=true,
        exclude=Set([:units_info, :ext, :services]),
    )

    # Verify MonitoredLine round-tripped
    @test length(PSY.get_components(PSY.MonitoredLine, copy_of_sys)) == 1
    @test IS.compare_values(
        custom_isequivalent,
        first(PSY.get_components(PSY.MonitoredLine, sys)),
        first(PSY.get_components(PSY.MonitoredLine, copy_of_sys)),
        compare_uuids=true,
        exclude=Set([:units_info, :ext, :services]),
    )

    # Verify PhaseShiftingTransformer round-tripped
    @test length(PSY.get_components(PSY.PhaseShiftingTransformer, copy_of_sys)) == 1
    @test IS.compare_values(
        custom_isequivalent,
        first(PSY.get_components(PSY.PhaseShiftingTransformer, sys)),
        first(PSY.get_components(PSY.PhaseShiftingTransformer, copy_of_sys)),
        compare_uuids=true,
        exclude=Set([:units_info, :ext, :services]),
    )
end
