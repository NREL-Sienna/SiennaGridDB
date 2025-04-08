import SQLite
import DBInterface
import JSON
import Tables

const SQLITE_CREATE_STR = [
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
    	base_power DOUBLE NOT NULL,
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
    	rating DOUBLE NOT NULL,
    	PRIMARY KEY (id),
    	UNIQUE (name),
    	FOREIGN KEY(arc_id) REFERENCES arc (id)
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
        [Int64, String, String, Int64, Float64],
    ),
    "arc" => Tables.Schema(
        ["id", "obj_type", "from_id", "to_id"],
        [Int64, String, Int64, Int64],
    ),
    "load" => Tables.Schema(
        ["id", "name", "obj_type", "bus_id", "base_power"],
        [Int64, String, String, Int64, Float64],
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

const ALL_PSY_TYPES = [
    PSY.ACBus,
    PSY.Arc,
    PSY.ThermalStandard,
    PSY.RenewableDispatch,
    PSY.Line,
    PSY.Transformer2W,
    PSY.PowerLoad,
    PSY.StandardLoad,
]
const ALL_TYPES = [
    ACBus,
    Arc,
    ThermalStandard,
    RenewableDispatch,
    Line,
    Transformer2W,
    PowerLoad,
    StandardLoad,
]

const PSY_TO_OPENAPI_TYPE = Dict(k => v for (k, v) in zip(ALL_PSY_TYPES, ALL_TYPES))

const TYPE_NAMES = Dict(string(t) => t for t in ALL_TYPES)
const TYPE_TO_TABLE = Dict(
    ACBus => "bus",
    Arc => "arc",
    ThermalStandard => "generation_unit",
    RenewableDispatch => "generation_unit",
    Line => "transmission",
    Transformer2W => "transmission",
    PowerLoad => "load",
    StandardLoad => "load",
)

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

function add_components_to_tables!(
    table_name::AbstractString,
    obj_type::AbstractString,
    schema::Tables.Schema,
    table::S,
    attributes_table::T,
    components,
    ids::IDGenerator,
)::Tuple{S, T} where {S, T}
    for c in components
        c = psy2openapi(c, ids)
        push!(table.obj_type, obj_type)
        for (col_name, col_type) in zip(schema.names, schema.types)
            if col_name == :obj_type
                continue
            end
            k = if haskey(DB_TO_OPENAPI_FIELDS, string(col_name))
                Symbol(DB_TO_OPENAPI_FIELDS[string(col_name)])
            else
                col_name
            end

            if !hasproperty(c, k)
                @assert Nothing <: col_type "$obj_type does not have $col_name with type $col_type"
                push!(getproperty(table, col_name), nothing)
            else
                push!(getproperty(table, col_name), getproperty(c, k))
            end
        end
        for (k, v) in JSON.parse(OpenAPI.to_json(c))
            col_name = if haskey(OPENAPI_FIELDS_TO_DB, k)
                OPENAPI_FIELDS_TO_DB[k]
            else
                k
            end
            if !in(Symbol(col_name), schema.names)
                push!(
                    attributes_table,
                    (
                        entity_id=c.id,
                        entity_type=table_name,
                        key=col_name,
                        value=JSON.json(v),
                    ),
                )
            end
        end
    end
    return table, attributes_table
end

function get_table_from_components(::Type{T}, components, ids) where {T}
    table_name = TYPE_TO_TABLE[T]
    obj_type = last(split(string(T), "."))
    schema = TABLE_SCHEMAS[table_name]
    #table = NamedTuple{schema.names, Tuple{schema.types...}}[]
    #attributes = NamedTuple{
    #    TABLE_SCHEMA["attributes"].names,
    #    Tuple{TABLE_SCHEMAS["attributes"].types...},
    #}[]
    table = NamedTuple{schema.names, Tuple{(Vector{i} for i in schema.types)...}}((
        [] for t in schema.types
    ))
    #table = Dict(k => [] for (k, t) for zip(schema.names, schema.types))
    attributes_table = NamedTuple{
        TABLE_SCHEMAS["attributes"].names[2:end],
        Tuple{TABLE_SCHEMAS["attributes"].types[2:end]...},
    }[]
    return add_components_to_tables!(
        table_name,
        obj_type,
        schema,
        table,
        attributes_table,
        components,
        ids,
    )
end

function load_to_db!(db, data)
    # Parse data to JSON
    T = typeof(data)
    table_name = TYPE_TO_TABLE[T]
    data = JSON.parse(OpenAPI.to_json(data))
    # Pack into main row
    main_row = Any[last(split(string(T), "."))]
    column_names = ["obj_type"]
    attributes = Dict()
    for (k, v) in data
        if haskey(OPENAPI_FIELDS_TO_DB, k)
            col_name = OPENAPI_FIELDS_TO_DB[k]
        else
            col_name = k
        end
        if in(Symbol(col_name), TABLE_SCHEMAS[table_name].names)
            push!(column_names, col_name)
            push!(main_row, v)
        else
            attributes[k] = v
        end
    end
    stmt_str = "INSERT INTO $table_name ($(join(column_names, ", ")))
        VALUES ($(join(repeat("?", length(column_names)), ", ")))"
    DBInterface.execute(db, stmt_str, main_row)
    for (k, v) in attributes
        # Add a row for each attributes.
        # SQLite requires converting to JSON manually, since SQLite.jl
        # does not do JSON serialization.
        DBInterface.execute(
            db,
            "INSERT INTO attributes (entity_id, entity_type, key, value)
VALUES (?, ?, ?, json(?))",
            [data["id"], table_name, k, JSON.json(v)],
        )
    end
end

function sys2db!(db, sys::PSY.System, ids::IDGenerator)
    for (T, OPENAPI_T) in zip(ALL_PSY_TYPES, ALL_TYPES)
        table_name = TYPE_TO_TABLE[OPENAPI_T]
        table, attributes =
            get_table_from_components(OPENAPI_T, PSY.get_components(T, sys), ids)

        println(typeof(table))
        @assert length(unique((length(entries) for entries in table))) == 1 """
            $T, $table_name
            $([length(entries) for entries in table])
        """
        SQLite.load!(table, db, table_name)
        SQLite.load!(attributes, db, "attributes")
    end
end
