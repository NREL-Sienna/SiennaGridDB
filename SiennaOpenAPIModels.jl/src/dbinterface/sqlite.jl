import SQLite
import DBInterface
import JSON
import UUIDs
using Tables

include("db_definition.jl")
include("translation_constants.jl")

function load_to_db!(db, data::Arc)
    stmt_str = "INSERT INTO arc (id, from_id, to_id)
        VALUES (?, ?, ?)"
    DBInterface.execute(db, stmt_str, [data.id, data.from, data.to])
end

function get_row_field(c::OpenAPI.APIModel, table_name::AbstractString, col_name::Symbol)
    k = Symbol(get(DB_TO_OPENAPI_FIELDS, (table_name, string(col_name)), col_name))

    if !hasproperty(c, k)
        return nothing
    else
        return getproperty(c, k)
    end
end

function insert_attributes!(attribute_statement, schema::Tables.Schema, c::OpenAPI.APIModel)
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
        insert_attributes!(attribute_statement, schema, c)
    end
end

function prepare_schema_insert(db, table_name::AbstractString, schema::Tables.Schema)
    return DBInterface.prepare(
        db,
        """INSERT INTO $table_name ($(join(schema.names, ", ")))
          VALUES ($(join(repeat("?", length(schema.names)), ", ")))""",
    )
end

function prepare_entity_insert(db, table_name::AbstractString, obj_type::AbstractString)
    return DBInterface.prepare(
        db,
        "INSERT INTO entities (id, entity_table, entity_type) VALUES (?, '$table_name', '$obj_type')",
    )
end

function prepare_attributes_insert(db)
    return DBInterface.prepare(
        db,
        "INSERT INTO attributes (entity_id, type, name, value) VALUES (?, ?, ?, json(?))",
    )
end

function send_table_to_db!(::Type{AreaInterchange}, db, components, ids)
    table_name = "transmission_interchanges"
    obj_type = "AreaInterchange"
    schema = TABLE_SCHEMAS[table_name]
    table_statement = prepare_schema_insert(db, table_name, schema)
    arc_statement = prepare_schema_insert(db, "arcs", TABLE_SCHEMAS["arcs"])
    arc_entity_statement = prepare_entity_insert(db, "arcs", "Arc")
    attribute_statement = prepare_attributes_insert(db)
    entity_statement = prepare_entity_insert(db, table_name, obj_type)

    for c in components
        c = psy2openapi(c, ids)
        new_id = getid!(ids, UUIDs.uuid4())
        DBInterface.execute(arc_entity_statement, (new_id,))
        DBInterface.execute(arc_statement, (new_id, c.from_area, c.to_area))
        row = (c.id, c.name, new_id, c.flow_limits.to_from, c.flow_limits.from_to)
        DBInterface.execute(entity_statement, (c.id,))
        DBInterface.execute(table_statement, row)
        insert_attributes!(attribute_statement, schema, c)
    end
end

function send_table_to_db!(::Type{T}, db, components, ids) where {T}
    table_name = TYPE_TO_TABLE[T]
    obj_type = last(split(string(T), "."))
    schema = TABLE_SCHEMAS[table_name]
    return add_components_to_tables!(
        table_name,
        schema,
        prepare_schema_insert(db, table_name, schema),
        prepare_entity_insert(db, table_name, obj_type),
        prepare_attributes_insert(db),
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
                get(DB_TO_OPENAPI_FIELDS, (table_name, string(k)), string(k)) =>
                    coalesce(v, nothing) for (k, v) in zip(propertynames(row), row)
            ),
            extra_attributes,
        )
        openapi_obj = OpenAPI.from_json(OpenAPI_T, dict)
        sienna_obj = openapi2psy(openapi_obj, resolver)
        PowerSystems.add_component!(sys, sienna_obj)
        resolver.id2uuid[row.id] = IS.get_uuid(sienna_obj)
    end
end

function add_components_to_sys!(
    ::Type{AreaInterchange},
    sys::PSY.System,
    table_name,
    rows,
    attributes::Dict{Int64, Dict{String, Any}},
    resolver::Resolver,
)
    for row in rows
        extra_attributes = get(attributes, row.id, Dict{String, Any}())
        dict = merge(
            Dict(
                get(DB_TO_OPENAPI_FIELDS, (table_name, string(k)), string(k)) =>
                    coalesce(v, nothing) for (k, v) in zip(propertynames(row), row)
            ),
            Dict{String, Any}(  # if you don't put {String, Any}, it fails
                "flow_limits" => Dict{String, Any}(
                    "from_to" => row.max_flow_to,
                    "to_from" => row.max_flow_from,
                ),
            ),
            extra_attributes,
        )
        openapi_obj = OpenAPI.from_json(AreaInterchange, dict)
        sienna_obj = openapi2psy(openapi_obj, resolver)
        PowerSystems.add_component!(sys, sienna_obj)
        resolver.id2uuid[row.id] = IS.get_uuid(sienna_obj)
    end
end

const ARC_QUERY = """
SELECT a.* FROM arcs a
LEFT JOIN entities e ON a.id = e.id
LEFT JOIN entities e_from ON a.from_id = e_from.id
WHERE e_from.entity_type IN ('ACBus', 'DCBus') AND
    e.entity_type = ? AND
    e.entity_table = 'arcs'
"""

const TRANSMISSION_INTERCHANGE_QUERY = """
SELECT t.*, a.from_id as from_area, a.to_id as to_area FROM transmission_interchanges t
JOIN entities e ON t.id = e.id
JOIN arcs a ON t.arc_id = a.id
WHERE e.entity_type = ? AND e.entity_table = 'transmission_interchanges'
"""

function get_query_for_table_name(table_name)
    if table_name == "arcs"
        ARC_QUERY
    elseif table_name == "transmission_interchanges"
        TRANSMISSION_INTERCHANGE_QUERY
    else
        """SELECT t.*
        FROM $table_name t
        JOIN entities e ON t.id = e.id
        WHERE e.entity_type = ? AND e.entity_table = '$table_name'
        """
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
        query = get_query_for_table_name(table_name)
        rows = DBInterface.execute(db, query, (obj_type,))
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
