function _read_sql_statements(filepath::AbstractString)
    sql_content = read(filepath, String)
    statements = split(sql_content, ';')
    cleaned_statements = [strip(s) for s in statements if !isempty(strip(s))]
    return cleaned_statements
end

const SQLITE_CREATE_STR = _read_sql_statements(joinpath(@__DIR__, "schema.sql"))
const SQLITE_TRIGGERS_STR = [read(joinpath(@__DIR__, "triggers.sql"), String)]

const TABLE_SCHEMAS = Dict(
    "entities" =>
        Tables.Schema(["id", "entity_table", "entity_type"], [Int64, String, String]),
    "entity_types" => Tables.Schema(["name"], [String]),
    "prime_mover_types" => Tables.Schema(
        ["id", "name", "description"],
        [Int64, String, Union{String, Nothing}],
    ),
    "fuels" => Tables.Schema(
        ["id", "name", "description"],
        [Int64, String, Union{String, Nothing}],
    ),
    "planning_regions" => Tables.Schema(
        ["id", "name", "description"],
        [Int64, String, Union{String, Nothing}],
    ),
    "balancing_topologies" => Tables.Schema(
        ["id", "name", "area", "description"],
        [Int64, String, Union{Int64, Nothing}, Union{String, Nothing}],
    ),
    "arcs" => Tables.Schema(["id", "from_id", "to_id"], [Int64, Int64, Int64]),
    "transmission_lines" => Tables.Schema(
        [
            "id",
            "name",
            "arc_id",
            "continuous_rating",
            "ste_rating",
            "lte_rating",
            "line_length",
        ],
        [
            Int64,
            String,
            Int64,
            Float64,
            Union{Float64, Nothing},
            Union{Float64, Nothing},
            Union{Float64, Nothing},
        ],
    ),
    "transmission_interchanges" => Tables.Schema(
        ["id", "name", "arc_id", "max_flow_from", "max_flow_to"],
        [Int64, String, Int64, Float64, Float64],
    ),
    "generation_units" => Tables.Schema(
        ["id", "name", "prime_mover", "fuel", "balancing_topology", "rating", "base_power"],
        [Int64, String, String, Union{String, Nothing}, Int64, Float64, Float64],
    ),
    "storage_units" => Tables.Schema(
        [
            "id",
            "name",
            "prime_mover",
            "max_capacity",
            "balancing_topology",
            "efficiency_up",
            "efficiency_down",
            "rating",
            "base_power",
        ],
        [
            Int64,
            String,
            String,
            Union{Float64, Nothing},
            Int64,
            Union{Float64, Nothing},
            Union{Float64, Nothing},
            Float64,
            Float64,
        ],
    ),
    "hydro_reservoir" => Tables.Schema(["id", "name"], [Int64, String]),
    "hydro_reservoir_connections" =>
        Tables.Schema(["source_id", "sink_id"], [Int64, Int64]),
    "supply_technologies" => Tables.Schema(
        ["id", "prime_mover", "fuel", "area", "balancing_topology", "scenario"],
        [
            Int64,
            String,
            Union{String, Nothing},
            Union{String, Nothing},
            Union{String, Nothing},
            Union{String, Nothing},
        ],
    ),
    "transport_technologies" => Tables.Schema(
        ["id", "arc_id", "scenario"],
        [Int64, Union{Int64, Nothing}, Union{String, Nothing}],
    ),
    # NOTE: operational_data is now a view (not a table), defined in views.sql
    "attributes" => Tables.Schema(
        ["id", "entity_id", "TYPE", "name", "value"],
        # Note: json_type is a generated column, not included here
        [Int64, Int64, String, String, String],
    ),
    "supplemental_attributes" => Tables.Schema(
        ["id", "TYPE", "value"],
        # Note: json_type is a generated column, not included here
        [Int64, String, String],
    ),
    "supplemental_attributes_association" =>
        Tables.Schema(["attribute_id", "entity_id"], [Int64, Int64]),
    "time_series_associations" => Tables.Schema(
        [
            "id",
            "time_series_uuid",
            "time_series_type",
            "initial_timestamp",
            "resolution",
            "horizon",
            "interval",
            "window_count",
            "length",
            "name",
            "owner_id",
            "owner_type",
            "owner_category",
            "features",
            "scaling_factor_multiplier",
            "metadata_uuid",
            "units",
        ],
        [
            Int64,
            String,
            String,
            String,
            Int64,
            Union{Int64, Nothing},
            Union{Int64, Nothing},
            Union{Int64, Nothing},
            Union{Int64, Nothing},
            Union{String, Nothing},
            String,
            Int64,
            Union{String, Nothing},
            Union{String, Nothing},
            Union{String, Nothing},
            Union{String, Nothing},
            Union{String, Nothing},
        ],
    ),
    "loads" => Tables.Schema(
        ["id", "name", "balancing_topology", "base_power"],
        [Int64, String, Int64, Union{Float64, Nothing}],
    ),
    "static_time_series" =>
        Tables.Schema(["id", "uuid", "idx", "value"], [Int64, String, Int64, Float64]),
)

function make_sqlite!(db)
    for table in SQLITE_CREATE_STR
        DBInterface.execute(db, table)
    end
    for table in SQLITE_TRIGGERS_STR
        DBInterface.execute(db, table)
    end

    entity_type_stmt = DBInterface.prepare(db, "INSERT INTO entity_types (name) VALUES (?)")
    for type_name in keys(TYPE_NAMES)
        DBInterface.execute(entity_type_stmt, (type_name,))
    end

    # Insert default prime mover types based on PowerSystems.PrimeMovers
    pm_stmt = DBInterface.prepare(
        db,
        "INSERT INTO prime_mover_types (id, name, description) VALUES (?, ?, ?)",
    )
    # List derived from PowerSystems.PrimeMovers enums
    # Descriptions are set to the name for simplicity, adjust if needed.
    default_prime_movers = [
        (1, "BA", "Battery Energy Storage"), # Battery
        (2, "BT", "Binary Cycle Turbine"), # Binary Cycle Turbine (Geothermal)
        (3, "CA", "Compressed Air Energy Storage"), # Compressed Air
        (4, "CC", "Combined Cycle"), # Combined Cycle
        (5, "CE", "Reciprocating Engine"), # Combustion Engine (IC)
        (6, "CP", "Concentrated Solar Power"), # Concentrated Solar Power
        (7, "CS", "Combined Cycle Steam"), # Combined Cycle Steam part
        (8, "CT", "Combustion (Gas) Turbine"), # Combustion Turbine
        (9, "ES", "Energy Storage"), # Generic Energy Storage
        (10, "FC", "Fuel Cell"), # Fuel Cell
        (11, "FW", "Flywheel Energy Storage"), # Flywheel
        (12, "GT", "Gas Turbine"), # Gas Turbine (part of CC)
        (13, "HA", "Hydro Francis"), # Hydro Aggregated
        (14, "HB", "Hydro Bulb"), # Hydro Bulb
        (15, "HK", "Hydro Kaplan"), # Hydro Kaplan
        (16, "HY", "Hydro"), # Hydro Generic
        (17, "IC", "Internal Combustion Engine"), # Internal Combustion
        (18, "OT", "Other"), # Other
        (19, "PS", "Pumped Storage"), # Pumped Storage
        (20, "PVe", "Photovoltaic"), # Photovoltaic
        (21, "ST", "Steam Turbine"), # Steam Turbine
        (22, "WS", "Wind Offshore"), # Wind Offshore
        (23, "WT", "Wind Onshore"), # Wind Onshore
    ]
    for (id, name, desc) in default_prime_movers
        DBInterface.execute(pm_stmt, (id, name, desc))
    end

    # Insert default fuels based on PowerSystems.ThermalFuels and existing entries
    fuel_stmt = DBInterface.prepare(
        db,
        "INSERT INTO fuels (id, name, description) VALUES (?, ?, ?)",
    )
    default_fuels = [
        (1, "COAL", "Coal"),
        (2, "NATURAL_GAS", "Natural Gas"),
        (3, "DISTILLATE_FUEL_OIL", "Distillate Fuel Oil"),
        (4, "RESIDUAL_FUEL_OIL", "Residual Fuel Oil"),
        (5, "NUCLEAR", "Nuclear"),
        (6, "HYDRO", "Hydro"),
        (7, "OTHER", "Other"),
        (8, "WASTE", "Waste"),
        (9, "BIOMASS", "Biomass"),
        (10, "WIND", "Wind"),
        (11, "SOLAR", "Solar"),
        (12, "GEOTHERMAL", "Geothermal"),
        (13, "OIL", "Oil"),
        (14, "GAS", "Gas"),
    ]
    for (id, name, desc) in default_fuels
        DBInterface.execute(fuel_stmt, (id, name, desc))
    end
end
