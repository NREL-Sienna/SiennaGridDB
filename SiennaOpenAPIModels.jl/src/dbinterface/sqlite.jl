import SQLite
import DBInterface
import JSON
import Tables

const SQLITE_CREATE_STR = [
    """
    PRAGMA foreign_keys = ON;
    """,
    """
    CREATE TABLE area (
        id INTEGER NOT NULL,
        name TEXT NOT NULL,
        obj_type TEXT NOT NULL,
        PRIMARY KEY (id),
        UNIQUE (name)
    )
    """,
    """
    CREATE TABLE loadzone (
    	id INTEGER NOT NULL,
    	name TEXT NOT NULL,
    	obj_type TEXT NOT NULL,
    	PRIMARY KEY (id),
    	UNIQUE (name)
    )
    """,
    """
    CREATE TABLE attributes (
    	id INTEGER NOT NULL,
    	entity_id INTEGER NOT NULL,
    	entity_type TEXT NOT NULL,
    	"key" TEXT NOT NULL,
    	value JSON NOT NULL,
    	PRIMARY KEY (id)
    )
    """,
    """
    CREATE TABLE bus (
    	id INTEGER NOT NULL,
    	name TEXT NOT NULL,
    	obj_type TEXT NOT NULL,
    	area_id INTEGER,
    	loadzone_id INTEGER,
    	PRIMARY KEY (id),
    	UNIQUE (name),
    	FOREIGN KEY(area_id) REFERENCES area (id),
    	FOREIGN KEY(loadzone_id) REFERENCES loadzone (id)
    )
    """,
    """
    CREATE TABLE arc (
    	id INTEGER NOT NULL,
        obj_type TEXT NOT NULL,
    	from_id INTEGER NOT NULL,
    	to_id INTEGER NOT NULL,
    	PRIMARY KEY (id),
    	FOREIGN KEY(from_id) REFERENCES bus (id),
    	FOREIGN KEY(to_id) REFERENCES bus (id)
    )
    """,
    """
    CREATE TABLE generation_unit (
    	id INTEGER NOT NULL,
    	name TEXT NOT NULL,
    	obj_type TEXT NOT NULL,
    	prime_mover_type TEXT,
    	fuel_type TEXT,
    	rating DOUBLE NOT NULL,
    	base_power DOUBLE NOT NULL,
    	bus_id INTEGER NOT NULL,
    	PRIMARY KEY (id),
    	UNIQUE (name),
    	FOREIGN KEY(bus_id) REFERENCES bus (id)
    )
    """,
    """
    CREATE TABLE supply_technology (
    	id INTEGER NOT NULL,
    	name TEXT NOT NULL,
    	obj_type TEXT NOT NULL,
    	prime_mover_type TEXT,
    	fuel_type TEXT,
    	area_id INTEGER,
    	bus_id INTEGER,
    	PRIMARY KEY (id),
    	UNIQUE (name),
    	FOREIGN KEY(area_id) REFERENCES area (id),
    	FOREIGN KEY(bus_id) REFERENCES bus (id)
    )
    """,
    """
    CREATE TABLE load (
    	id INTEGER NOT NULL,
    	name TEXT NOT NULL,
    	obj_type TEXT NOT NULL,
    	bus_id INTEGER NOT NULL,
        base_power DOUBLE,
    	PRIMARY KEY (id),
    	UNIQUE (name),
    	FOREIGN KEY(bus_id) REFERENCES bus (id)
    )
    """,
    """
    CREATE TABLE transmission (
    	id INTEGER NOT NULL,
    	name TEXT NOT NULL,
    	obj_type TEXT NOT NULL,
    	arc_id INTEGER NOT NULL,
    	rating DOUBLE,
    	PRIMARY KEY (id),
    	UNIQUE (name),
    	FOREIGN KEY(arc_id) REFERENCES arc (id)
    )
    """,
    """
    CREATE TABLE area_transmission (
        id INTEGER NOT NULL,
        name TEXT NOT NULL,
        obj_type TEXT NOT NULL,
        from_area INTEGER NOT NULL,
        to_area INTEGER NOT NULL,
        rating DOUBLE NOT NULL,
        PRIMARY KEY (id),
        UNIQUE (name),
        FOREIGN KEY(from_area) REFERENCES area (id),
        FOREIGN KEY(to_area) REFERENCES area (id)
    )
    """,
]

const TABLE_SCHEMAS = Dict(
    "generation_unit" => Tables.Schema(
        [
            "id",
            "name",
            "obj_type",
            "bus_id",
            "prime_mover_type",
            "fuel_type",
            "rating",
            "base_power",
        ],
        [
            Int64,
            String,
            String,
            Int64,
            Union{String, Nothing},
            Union{String, Nothing},
            Float64,
            Float64,
        ],
    ),
    "area" => Tables.Schema(["id", "name", "obj_type"], [Int64, String, String]),
    "loadzone" => Tables.Schema(["id", "name", "obj_type"], [Int64, String, String]),
    "attributes" => Tables.Schema(
        ["id", "entity_id", "entity_type", "key", "value"],
        [Int64, Int64, String, String, String],
    ),
    "bus" => Tables.Schema(
        ["id", "name", "obj_type", "area_id", "loadzone_id"],
        [Int64, String, String, Union{Int64, Nothing}, Union{Int64, Nothing}],
    ),
    "supply_technology" => Tables.Schema(
        [
            "id",
            "name",
            "obj_type",
            "prime_mover_type",
            "fuel_type",
            "area_id",
            "balancing_id",
        ],
        [
            Int64,
            String,
            String,
            Union{String, Nothing},
            Union{String, Nothing},
            Union{Int64, Nothing},
            Union{Int64, Nothing},
        ],
    ),
    "transmission" => Tables.Schema(
        ["id", "name", "obj_type", "arc_id", "rating"],
        [Int64, String, String, Int64, Union{Nothing, Float64}],
    ),
    "arc" => Tables.Schema(
        ["id", "obj_type", "from_id", "to_id"],
        [Int64, String, Int64, Int64],
    ),
    "load" => Tables.Schema(
        ["id", "name", "obj_type", "bus_id", "base_power"],
        [Int64, String, String, Int64, Union{Nothing, Float64}],
    ),
    "area_transmission" => Tables.Schema(
        ["id", "name", "obj_type", "from_area", "to_area", "rating"],
        [Int64, String, String, Int64, Int64, Float64],
    ),
)

const OPENAPI_FIELDS_TO_DB = Dict(
    "arc" => "arc_id",
    "area" => "area_id",
    "bus" => "bus_id",
    "prime_mover_type" => "prime_mover_type",
    "from" => "from_id",
    "to" => "to_id",
)

const DB_TO_OPENAPI_FIELDS = Dict(t => s for (s, t) in OPENAPI_FIELDS_TO_DB)

const TYPE_TO_TABLE_LIST = [
    Area => "area",
    LoadZone => "loadzone",
    ACBus => "bus",
    Arc => "arc",
    AreaInterchange => "area_transmission",
    Line => "transmission",
    Transformer2W => "transmission",
    MonitoredLine => "transmission",
    PhaseShiftingTransformer => "transmission",
    TapTransformer => "transmission",
    TwoTerminalHVDCLine => "transmission",
    PowerLoad => "load",
    StandardLoad => "load",
    FixedAdmittance => "load",
    InterruptiblePowerLoad => "load",
    ThermalStandard => "generation_unit",
    RenewableDispatch => "generation_unit",
    EnergyReservoirStorage => "generation_unit",
    HydroDispatch => "generation_unit",
    HydroPumpedStorage => "generation_unit",
    ThermalMultiStart => "generation_unit",
    RenewableNonDispatch => "generation_unit",
    HydroEnergyReservoir => "generation_unit",
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
    # TwoTerminalHVDCLine,
    PowerLoad,
    StandardLoad,
    FixedAdmittance,
    # InterruptiblePowerLoad,
    ThermalStandard,
    RenewableDispatch,
    EnergyReservoirStorage,
    HydroDispatch,
    HydroPumpedStorage,
    # ThermalMultiStart,
    RenewableNonDispatch,
    # HydroEnergyReservoir,
]

function make_sqlite!(db)
    for table in SQLITE_CREATE_STR
        DBInterface.execute(db, table)
    end
end

function load_to_db!(db, data::Arc)
    stmt_str = "INSERT INTO arc (id, from_id, to_id)
        VALUES (?, ?, ?)"
    DBInterface.execute(db, stmt_str, [data.id, data.from, data.to])
end

function get_row_field(c::OpenAPI.APIModel, obj_type::AbstractString, col_name::Symbol)
    if col_name == :obj_type
        return obj_type
    end
    k = Symbol(get(DB_TO_OPENAPI_FIELDS, string(col_name), col_name))

    if !hasproperty(c, k)
        return nothing
    else
        return getproperty(c, k)
    end
end

function add_components_to_tables!(
    table_name::AbstractString,
    obj_type::AbstractString,
    schema::Tables.Schema,
    table_statement::DBInterface.Statement,
    attribute_statement::DBInterface.Statement,
    components,
    ids::IDGenerator,
)
    for c in components
        c = psy2openapi(c, ids)
        row = tuple(
            (
                get_row_field(c, obj_type, col_name) for
                (col_name, col_type) in zip(schema.names, schema.types)
            )...,
        )
        try
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
                    (c.id, table_name, col_name, JSON.json(v)),
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
        "INSERT INTO attributes (entity_id, entity_type, key, value) VALUES (?, ?, ?, json(?))",
    )
    return add_components_to_tables!(
        table_name,
        obj_type,
        schema,
        table_statement,
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
           json_group_object(key, json(value)) AS attribute_json
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

function add_components_to_sys!(
    ::Type{OpenAPI_T},
    sys::PSY.System,
    rows,
    attributes::Dict{Int64, Dict{String, Any}},
    resolver::Resolver,
) where {OpenAPI_T}
    for row in rows
        extra_attributes = get(attributes, row.id, Dict{String, Any}())
        dict = merge(
            Dict(
                get(DB_TO_OPENAPI_FIELDS, string(k), string(k)) => coalesce(v, nothing)
                for (k, v) in zip(propertynames(row), row)
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

    # We need to parse ALL_TYPES in a specific order to resolver correctly
    for OPENAPI_T in ALL_DESERIALIZABLE_TYPES
        table_name = TYPE_TO_TABLE[OPENAPI_T]
        obj_type = last(split(string(OPENAPI_T), "."))
        rows = DBInterface.execute(
            db,
            "SELECT * FROM $table_name WHERE obj_type=?",
            (obj_type,),
        )
        add_components_to_sys!(OPENAPI_T, sys, rows, attributes, resolver)
    end
end

function make_system_from_db(db)
    sys = PSY.System(100)
    resolver = Resolver(sys, Dict{Int64, UUID}())
    db2sys!(sys, db, resolver)
    return sys
end
