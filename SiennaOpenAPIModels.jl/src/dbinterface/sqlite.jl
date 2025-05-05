import SQLite
import DBInterface
import JSON
import Tables

function _read_sql_statements(filepath::AbstractString)
    sql_content = read(filepath, String)
    statements = split(sql_content, ';')
    # Filter out empty strings and trim whitespace
    cleaned_statements = [strip(s) for s in statements if !isempty(strip(s))]
    # If execution fails, consider adding the semicolon back or using a more robust SQL parser.
    return cleaned_statements
end

const SQLITE_CREATE_STR = _read_sql_statements(joinpath(@__DIR__, "schema.sql"))
const SQLITE_TRIGGERS_STR = [read(joinpath(@__DIR__, "triggers.sql"), String)]

using Tables

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
            Float64,
            Int64,
            Union{Float64, Nothing},
            Union{Float64, Nothing},
            Float64,
            Float64,
        ],
    ),
    "hydro_reservoir" => Tables.Schema(["id", "name"], [Int64, String]),
    "hydro_reservoir_connections" =>
        Tables.Schema(["turbine_id", "reservoir_id"], [Int64, Int64]),
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
    "operational_data" => Tables.Schema(
        [
            "id",
            "entity_id",
            "active_power_limit_min",
            "must_run",
            "uptime",
            "downtime",
            "ramp_up",
            "ramp_down",
            "operational_cost",
            "operational_cost_type",
        ],
        [
            Int64,
            Int64,
            Float64,
            Union{Bool, Nothing},
            Float64,
            Float64,
            Float64,
            Float64,
            Union{String, Nothing},
            Union{String, Nothing},
        ],
    ),
    "attributes" => Tables.Schema(
        ["id", "entity_id", "TYPE", "name", "value", "json_type"],
        [Int64, Int64, String, String, String, String],
    ),
    "supplemental_attributes" => Tables.Schema(
        ["id", "TYPE", "value", "json_type"],
        [Int64, String, String, String],
    ),
    "supplemental_attributes_association" =>
        Tables.Schema(["attribute_id", "entity_id"], [Int64, Int64]),
    "time_series" => Tables.Schema(
        [
            "id",
            "time_series_uuid",
            "time_series_type",
            "initial_timestamp",
            "resolution",
            "horizon",
            "INTERVAL",
            "window_count",
            "length",
            "scaling_multiplier",
            "name",
            "owner_id",
            "features",
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
        ],
    ),
    "loads" => Tables.Schema(
        ["id", "name", "balancing_topology", "base_power"],
        [Int64, String, Int64, Union{Float64, Nothing}],
    ),
)

const OPENAPI_FIELDS_TO_DB = Dict(
    "arc" => "arc_id",
    "bus" => "balancing_topology",
    "prime_mover_type" => "prime_mover",
    "from" => "from_id",
    "to" => "to_id",
)

const DB_TO_OPENAPI_FIELDS = Dict(t => s for (s, t) in OPENAPI_FIELDS_TO_DB)

const TYPE_TO_TABLE_LIST = [
    Area => "planning_regions",
    LoadZone => "balancing_topologies", # Assuming LoadZone maps to balancing topologies
    ACBus => "balancing_topologies", # Assuming ACBus maps to balancing topologies
    Arc => "arcs",
    AreaInterchange => "transmission_interchanges",
    Line => "transmission_lines",
    Transformer2W => "transmission_lines",
    MonitoredLine => "transmission_lines",
    PhaseShiftingTransformer => "transmission_lines",
    TapTransformer => "transmission_lines",
    TwoTerminalHVDCLine => "transmission_lines",
    PowerLoad => "loads",
    StandardLoad => "loads",
    FixedAdmittance => "loads",
    InterruptiblePowerLoad => "loads",
    ThermalStandard => "generation_units",
    RenewableDispatch => "generation_units",
    EnergyReservoirStorage => "storage_units", # Updated from generation_unit
    HydroDispatch => "generation_units",
    HydroPumpedStorage => "storage_units", # Updated from generation_unit
    ThermalMultiStart => "generation_units",
    RenewableNonDispatch => "generation_units",
    HydroEnergyReservoir => "generation_units", # Assuming this represents the generator part
]

const TYPE_TO_TABLE = Dict(TYPE_TO_TABLE_LIST)

const ALL_PSY_TYPES = [
    PSY.Area,
    PSY.LoadZone,
    PSY.ACBus,
    PSY.Arc,
    PSY.AreaInterchange,
    PSY.Line,
    PSY.Transformer2W,
    PSY.MonitoredLine,
    PSY.PhaseShiftingTransformer,
    PSY.TapTransformer,
    PSY.TwoTerminalHVDCLine,
    PSY.PowerLoad,
    PSY.StandardLoad,
    PSY.FixedAdmittance,
    PSY.InterruptiblePowerLoad,
    PSY.ThermalStandard,
    PSY.RenewableDispatch,
    PSY.EnergyReservoirStorage,
    PSY.HydroDispatch,
    PSY.HydroPumpedStorage,
    PSY.ThermalMultiStart,
    PSY.RenewableNonDispatch,
    PSY.HydroEnergyReservoir,
]

const ALL_TYPES = first.(TYPE_TO_TABLE_LIST)
const PSY_TO_OPENAPI_TYPE = Dict(k => v for (k, v) in zip(ALL_PSY_TYPES, ALL_TYPES))
const OPENAPI_TYPE_TO_PSY = Dict(v => k for (k, v) in zip(ALL_PSY_TYPES, ALL_TYPES))
const TYPE_NAMES = Dict(string(t) => t for t in ALL_TYPES)

const ALL_DESERIALIZABLE_TYPES = [
    Area,
    LoadZone,
    ACBus,
    Arc,
    AreaInterchange,
    Line,
    Transformer2W,
    MonitoredLine,
    PhaseShiftingTransformer,
    TapTransformer,
    TwoTerminalHVDCLine,
    PowerLoad,
    StandardLoad,
    FixedAdmittance,
    InterruptiblePowerLoad,
    ThermalStandard,
    RenewableDispatch,
    EnergyReservoirStorage,
    HydroDispatch,
    HydroPumpedStorage,
    ThermalMultiStart,
    RenewableNonDispatch,
    HydroEnergyReservoir,
]

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

function load_to_db!(db, data::Arc)
    stmt_str = "INSERT INTO arc (id, from_id, to_id)
        VALUES (?, ?, ?)"
    DBInterface.execute(db, stmt_str, [data.id, data.from, data.to])
end

function get_row_field(c::OpenAPI.APIModel, table_name::AbstractString, col_name::Symbol)
    k = if table_name == "transmission_lines" && col_name == :continuous_rating
        :rating
    elseif table_name == "storage_units" && col_name == :max_capacity
        :storage_capacity
    else
        Symbol(get(DB_TO_OPENAPI_FIELDS, string(col_name), col_name))
    end

    if !hasproperty(c, k)
        return nothing
    else
        return getproperty(c, k)
    end
end

function add_components_to_tables!(
    table_name::AbstractString,
    schema::Tables.Schema,
    table_statement::DBInterface.Statement,
    entity_statement::DBInterface.Statement,
    attribute_statement::DBInterface.Statement,
    components,
    ids::IDGenerator,
)
    for c in components
        c = psy2openapi(c, ids)
        row = tuple(
            (
                get_row_field(c, table_name, col_name) for
                (col_name, col_type) in zip(schema.names, schema.types)
            )...,
        )
        try
            DBInterface.execute(entity_statement, (c.id,))
            DBInterface.execute(table_statement, row)
        catch e
            if isa(e, SQLite.SQLiteException)
                error("Failed to insert into $(table_name): $(e.msg) with values $(row)")
            else
                rethrow(e)
            end
        end
        for (k, v) in JSON.parse(OpenAPI.to_json(c))
            col_name = get(OPENAPI_FIELDS_TO_DB, k, k)
            if !in(Symbol(col_name), schema.names)
                DBInterface.execute(
                    attribute_statement,
                    (c.id, "JULIA-MADE", col_name, JSON.json(v)),  # Not sure how to make this stable and right
                )
            end
        end
    end
end

function send_table_to_db!(::Type{T}, db, components, ids) where {T}
    table_name = TYPE_TO_TABLE[T]
    obj_type = last(split(string(T), "."))
    schema = TABLE_SCHEMAS[table_name]
    table_statement = DBInterface.prepare(
        db,
        """INSERT INTO $table_name ($(join(schema.names, ", ")))
          VALUES ($(join(repeat("?", length(schema.names)), ", ")))""",
    )
    attributes_statement = DBInterface.prepare(
        db,
        "INSERT INTO attributes (entity_id, type, name, value) VALUES (?, ?, ?, json(?))",
    )
    entity_statement = DBInterface.prepare(
        db,
        "INSERT INTO entities (id, entity_table, entity_type) VALUES (?, '$table_name', '$obj_type')",
    )
    return add_components_to_tables!(
        table_name,
        schema,
        table_statement,
        entity_statement,
        attributes_statement,
        components,
        ids,
    )
end

function sys2db!(db, sys::PSY.System, ids::IDGenerator)
    DBInterface.transaction(db) do
        for (T, OPENAPI_T) in zip(ALL_PSY_TYPES, ALL_TYPES)
            send_table_to_db!(OPENAPI_T, db, PSY.get_components(T, sys), ids)
        end
    end
end

# Database to System Translation

function get_entity_attributes(db)
    # First, get all attributes for this entity type and group them by entity_id
    attributes_query = """
    SELECT entity_id,
           json_group_object(name, json(value)) AS attribute_json
    FROM attributes
    GROUP BY entity_id
    """

    attributes_result = DBInterface.execute(db, attributes_query, strict=true)

    # Create a dictionary of entity_id => attributes
    attributes_dict = Dict{Int64, Dict{String, Any}}()
    for row in attributes_result
        attributes_dict[row.entity_id] = JSON.parse(row.attribute_json)
    end

    return attributes_dict
end

function db_to_openapi_field(table_name::AbstractString, key::String)::String
    if table_name == "transmission_lines" && key == "continuous_rating"
        return "rating"
    elseif table_name == "storage_units" && key == "max_capacity"
        return "storage_capacity"
    end
    get(DB_TO_OPENAPI_FIELDS, key, key)
end

function add_components_to_sys!(
    ::Type{OpenAPI_T},
    sys::PSY.System,
    table_name,
    rows,
    attributes::Dict{Int64, Dict{String, Any}},
    resolver::Resolver,
) where {OpenAPI_T}
    for row in rows
        extra_attributes = get(attributes, row.id, Dict{String, Any}())
        dict = merge(
            Dict(
                db_to_openapi_field(table_name, string(k)) => coalesce(v, nothing) for
                (k, v) in zip(propertynames(row), row)
            ),
            extra_attributes,
        )
        openapi_obj = OpenAPI.from_json(OpenAPI_T, dict)
        sienna_obj = openapi2psy(openapi_obj, resolver)
        PowerSystems.add_component!(sys, sienna_obj)
        resolver.id2uuid[row.id] = IS.get_uuid(sienna_obj)
    end
end

function db2sys!(sys::PSY.System, db, resolver::Resolver)
    attributes = get_entity_attributes(db)

    row_counts = Dict{String, Int64}()
    all_entities = 0
    # We need to parse ALL_TYPES in a specific order to resolver correctly
    for OPENAPI_T in ALL_DESERIALIZABLE_TYPES
        table_name = TYPE_TO_TABLE[OPENAPI_T]
        obj_type = last(split(string(OPENAPI_T), "."))
        # Query the specific table joining with entities to filter by type
        query = """
        SELECT t.*
        FROM $table_name t
        JOIN entities e ON t.id = e.id
        WHERE e.entity_type = ? AND e.entity_table = ?
        """
        rows = DBInterface.execute(db, query, (obj_type, table_name))
        add_components_to_sys!(OPENAPI_T, sys, table_name, rows, attributes, resolver)
        row_counts[table_name] =
            get(row_counts, table_name, 0) + (length(resolver.id2uuid) - all_entities)
        all_entities = length(resolver.id2uuid)
    end
    for (table_name, _) in TABLE_SCHEMAS
        if table_name == "attributes" ||
           table_name == "entities" ||
           table_name == "prime_mover_types" ||
           table_name == "fuels" ||
           table_name == "entity_types"
            continue
        end
        result = DBInterface.execute(db, "SELECT count(*) from $table_name")
        db_count = first(first(result))::Int64
        local_count = get(row_counts, table_name, 0)
        if db_count != local_count
            @warn "Table $table_name contains $db_count ids but $local_count were processed"
        end
    end
end

function make_system_from_db(db)
    sys = PSY.System(100)
    resolver = Resolver(sys, Dict{Int64, UUID}())
    db2sys!(sys, db, resolver)
    return sys
end
