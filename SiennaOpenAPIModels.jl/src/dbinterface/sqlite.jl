import SQLite
import DBInterface
import JSON
import UUIDs
using Tables

include("db_definition.jl")
include("translation_constants.jl")

function get_row_field(c::OpenAPI.APIModel, table_name::AbstractString, col_name::Symbol)
    col_str = string(col_name)
    k = Symbol(get(DB_TO_OPENAPI_FIELDS, (table_name, col_str), col_name))

    if !hasproperty(c, k)
        return nothing
    end

    val = getproperty(c, k)

    # Serialize JSON columns
    if col_str in JSON_COLUMNS && val !== nothing
        return JSON.json(val)
    end

    return val
end

function _ignoreattribute(
    ::Type{T},
    table_name::AbstractString,
    schema::Tables.Schema,
    k::AbstractString,
) where {T <: OpenAPI.APIModel}
    col_name = get(OPENAPI_FIELDS_TO_DB, (table_name, k), k)
    return in(Symbol(col_name), schema.names)
end

function insert_attributes!(
    ::Type{T},
    table_name::AbstractString,
    schema::Tables.Schema,
    attribute_statement,
    c::OpenAPI.APIModel,
) where {T <: OpenAPI.APIModel}
    for (k, v) in JSON.parse(OpenAPI.to_json(c))
        if !_ignoreattribute(T, table_name, schema, k)
            DBInterface.execute(attribute_statement, (c.id, "FromSienna", k, JSON.json(v)))
        end
    end
end

function get_row(
    table_name::AbstractString,
    schema::Tables.Schema,
    c::OpenAPI.APIModel,
    ::PSY.Component,
)
    return tuple(
        (
            get_row_field(c, table_name, col_name) for
            (col_name, col_type) in zip(schema.names, schema.types)
        )...,
    )
end

# Custom get_row for ThermalStandard: fuel_type field maps to fuel column
# (ThermalMultiStart uses "fuel" directly, but ThermalStandard uses "fuel_type")
function get_row(
    table_name::AbstractString,
    schema::Tables.Schema,
    c::ThermalStandard,
    ::PSY.ThermalStandard,
)
    return tuple(
        (
            col_name == :fuel ? c.fuel_type : get_row_field(c, table_name, col_name) for
            (col_name, col_type) in zip(schema.names, schema.types)
        )...,
    )
end

function _ignoreattribute(
    ::Type{HydroReservoir},
    table_name::AbstractString,
    schema::Tables.Schema,
    k::AbstractString,
)
    # These fields are stored in hydro_reservoir_connections table, not as attributes
    if k in ("upstream_turbines", "downstream_turbines", "upstream_reservoirs")
        return true
    end
    col_name = get(OPENAPI_FIELDS_TO_DB, (table_name, k), k)
    return in(Symbol(col_name), schema.names)
end

function insert_uuid!(attribute_statement, table_name, id, uuid)
    DBInterface.execute(
        attribute_statement,
        (id, table_name, "uuid", JSON.json(string(uuid))),
    )
end

function add_components_to_tables!(
    ::Type{T},
    table_name::AbstractString,
    schema::Tables.Schema,
    table_statement::DBInterface.Statement,
    entity_statement::DBInterface.Statement,
    attribute_statement::DBInterface.Statement,
    components,
    ids::IDGenerator,
) where {T <: OpenAPI.APIModel}
    for component in components
        uuid = IS.get_uuid(component)
        openapi_component = psy2openapi(component, ids)
        row = get_row(table_name, schema, openapi_component, component)
        try
            DBInterface.execute(entity_statement, (openapi_component.id,))
            DBInterface.execute(table_statement, row)
        catch e
            if isa(e, SQLite.SQLiteException)
                error("Failed to insert into $(table_name): $(e.msg) with values $(row)")
            else
                rethrow(e)
            end
        end
        insert_attributes!(T, table_name, schema, attribute_statement, openapi_component)
        insert_uuid!(attribute_statement, table_name, openapi_component.id, uuid)
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
        uuid = IS.get_uuid(c)
        c = psy2openapi(c, ids)
        new_id = getid!(ids, UUIDs.uuid4())
        DBInterface.execute(arc_entity_statement, (new_id,))
        DBInterface.execute(arc_statement, (new_id, c.from_area, c.to_area))
        row = (c.id, c.name, new_id, c.flow_limits.to_from, c.flow_limits.from_to)
        DBInterface.execute(entity_statement, (c.id,))
        DBInterface.execute(table_statement, row)
        insert_attributes!(AreaInterchange, table_name, schema, attribute_statement, c)
        insert_uuid!(attribute_statement, table_name, c.id, uuid)
    end
end

function send_table_to_db!(::Type{HydroReservoir}, db, components, ids)
    table_name = "hydro_reservoir"
    obj_type = "HydroReservoir"
    schema = TABLE_SCHEMAS[table_name]
    table_statement = prepare_schema_insert(db, table_name, schema)
    entity_statement = prepare_entity_insert(db, table_name, obj_type)
    attribute_statement = prepare_attributes_insert(db)
    connection_statement = DBInterface.prepare(
        db,
        "INSERT INTO hydro_reservoir_connections (source_id, sink_id) VALUES (?, ?)",
    )

    for component in components
        uuid = IS.get_uuid(component)
        openapi_component = psy2openapi(component, ids)
        row = (openapi_component.id, openapi_component.name)
        DBInterface.execute(entity_statement, (openapi_component.id,))
        DBInterface.execute(table_statement, row)
        insert_attributes!(
            HydroReservoir,
            table_name,
            schema,
            attribute_statement,
            openapi_component,
        )
        insert_uuid!(attribute_statement, table_name, openapi_component.id, uuid)

        # Insert connections: downstream_turbines (water flows from reservoir to turbine)
        if !isnothing(openapi_component.downstream_turbines)
            for turbine_id in openapi_component.downstream_turbines
                DBInterface.execute(
                    connection_statement,
                    (openapi_component.id, turbine_id),
                )
            end
        end

        # Insert connections: upstream_turbines (water flows from turbine to reservoir, pumping)
        if !isnothing(openapi_component.upstream_turbines)
            for turbine_id in openapi_component.upstream_turbines
                DBInterface.execute(
                    connection_statement,
                    (turbine_id, openapi_component.id),
                )
            end
        end

        # Insert connections: upstream_reservoirs (water flows from upstream reservoir to this one)
        if !isnothing(openapi_component.upstream_reservoirs)
            for upstream_reservoir_id in openapi_component.upstream_reservoirs
                DBInterface.execute(
                    connection_statement,
                    (upstream_reservoir_id, openapi_component.id),
                )
            end
        end
    end
end

function send_table_to_db!(::Type{T}, db, components, ids) where {T}
    table_name = TYPE_TO_TABLE[T]
    obj_type = last(split(string(T), "."))
    schema = TABLE_SCHEMAS[table_name]
    return add_components_to_tables!(
        T,
        table_name,
        schema,
        prepare_schema_insert(db, table_name, schema),
        prepare_entity_insert(db, table_name, obj_type),
        prepare_attributes_insert(db),
        components,
        ids,
    )
end

function sys2db!(db, sys::PSY.System, ids::IDGenerator; time_series=false)
    DBInterface.transaction(db) do
        for (T, OPENAPI_T) in zip(ALL_PSY_TYPES, ALL_TYPES)
            send_table_to_db!(OPENAPI_T, db, PSY.get_components(T, sys), ids)
        end
    end
    if time_series
        serialize_timeseries!(db, sys, ids)
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

# JSON columns that should be parsed when reading from DB
const JSON_COLUMNS = Set([
    "operation_cost",
    "active_power_limits",
    "reactive_power_limits",
    "ramp_limits",
    "time_limits",
    "outflow_limits",
    "storage_level_limits",
    "input_active_power_limits",
    "output_active_power_limits",
    "efficiency",
])

# Default values for fields that might be NULL in DB but required for certain types
const DEFAULT_OPERATION_COST = Dict{String, Any}()

function _build_openapi_dict(table_name::AbstractString, row)
    dict = Dict{String, Any}()
    for (k, v) in zip(propertynames(row), row)
        key = get(DB_TO_OPENAPI_FIELDS, (table_name, string(k)), string(k))
        val = coalesce(v, nothing)
        # Parse JSON columns from string
        if key in JSON_COLUMNS && val isa String
            val = JSON.parse(val)
        end
        dict[key] = val
    end
    return dict
end

function make_openapi_dict(
    ::Type{T},
    table_name::AbstractString,
    row,
    extra_attributes::Dict{String, Any},
) where {T <: OpenAPI.APIModel}
    dict = _build_openapi_dict(table_name, row)
    return merge(dict, extra_attributes)
end

function make_openapi_dict(
    ::Type{RenewableDispatch},
    table_name::AbstractString,
    row,
    extra_attributes::Dict{String, Any},
)
    dict = _build_openapi_dict(table_name, row)
    # Provide default operation_cost if NULL
    if get(dict, "operation_cost", nothing) === nothing
        dict["operation_cost"] = DEFAULT_OPERATION_COST
    end
    return merge(dict, extra_attributes)
end

function make_openapi_dict(
    ::Type{EnergyReservoirStorage},
    table_name::AbstractString,
    row,
    extra_attributes::Dict{String, Any},
)
    dict = _build_openapi_dict(table_name, row)
    return merge(dict, extra_attributes)
end

function add_components_to_sys!(
    ::Type{OpenAPI_T},
    sys::PSY.System,
    db,
    table_name,
    rows,
    attributes::Dict{Int64, Dict{String, Any}},
    resolver::Resolver,
) where {OpenAPI_T}
    for row in rows
        extra_attributes = get(attributes, row.id, Dict{String, Any}())
        dict = make_openapi_dict(OpenAPI_T, table_name, row, extra_attributes)
        openapi_obj = OpenAPI.from_json(OpenAPI_T, dict)
        sienna_obj = openapi2psy(openapi_obj, resolver)
        if haskey(dict, "uuid")
            IS.set_uuid!(IS.get_internal(sienna_obj), Base.UUID(dict["uuid"]))
        end
        PSY.add_component!(sys, sienna_obj)
        resolver.id2uuid[row.id] = IS.get_uuid(sienna_obj)
    end
end

function add_components_to_sys!(
    ::Type{AreaInterchange},
    sys::PSY.System,
    db,
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
        if haskey(dict, "uuid")
            IS.set_uuid!(IS.get_internal(sienna_obj), Base.UUID(dict["uuid"]))
        end
        PSY.add_component!(sys, sienna_obj)
        resolver.id2uuid[row.id] = IS.get_uuid(sienna_obj)
    end
end

function add_components_to_sys!(
    ::Type{HydroReservoir},
    sys::PSY.System,
    db,
    table_name,
    rows,
    attributes::Dict{Int64, Dict{String, Any}},
    resolver::Resolver,
)
    # Prepared statements for connection queries
    downstream_turbines_stmt = DBInterface.prepare(
        db,
        """
        SELECT hrc.sink_id FROM hydro_reservoir_connections hrc
        JOIN entities e ON hrc.sink_id = e.id
        WHERE hrc.source_id = ? AND e.entity_table IN ('hydro_generators', 'storage_units')
        """,
    )
    upstream_turbines_stmt = DBInterface.prepare(
        db,
        """
        SELECT hrc.source_id FROM hydro_reservoir_connections hrc
        JOIN entities e ON hrc.source_id = e.id
        WHERE hrc.sink_id = ? AND e.entity_table IN ('hydro_generators', 'storage_units')
        """,
    )
    upstream_reservoirs_stmt = DBInterface.prepare(
        db,
        """
        SELECT hrc.source_id FROM hydro_reservoir_connections hrc
        JOIN entities e ON hrc.source_id = e.id
        WHERE hrc.sink_id = ? AND e.entity_table = 'hydro_reservoir'
        """,
    )

    for row in rows
        extra_attributes = get(attributes, row.id, Dict{String, Any}())

        # Get connections from the connections table using prepared statements
        downstream_turbines = Int64[
            r.sink_id for r in DBInterface.execute(downstream_turbines_stmt, (row.id,))
        ]
        upstream_turbines = Int64[
            r.source_id for r in DBInterface.execute(upstream_turbines_stmt, (row.id,))
        ]
        upstream_reservoirs = Int64[
            r.source_id for r in DBInterface.execute(upstream_reservoirs_stmt, (row.id,))
        ]

        dict = merge(
            Dict(
                get(DB_TO_OPENAPI_FIELDS, (table_name, string(k)), string(k)) =>
                    coalesce(v, nothing) for (k, v) in zip(propertynames(row), row)
            ),
            Dict{String, Any}(
                "downstream_turbines" => downstream_turbines,
                "upstream_turbines" => upstream_turbines,
                "upstream_reservoirs" => upstream_reservoirs,
            ),
            extra_attributes,
        )
        openapi_obj = OpenAPI.from_json(HydroReservoir, dict)
        sienna_obj = openapi2psy(openapi_obj, resolver)
        if haskey(dict, "uuid")
            IS.set_uuid!(IS.get_internal(sienna_obj), Base.UUID(dict["uuid"]))
        end
        PSY.add_component!(sys, sienna_obj)
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

function db2sys!(sys::PSY.System, db, resolver::Resolver; time_series=false)
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
        # HydroReservoir needs db to query connections table
        add_components_to_sys!(OPENAPI_T, sys, db, table_name, rows, attributes, resolver)
        row_counts[table_name] =
            get(row_counts, table_name, 0) + (length(resolver.id2uuid) - all_entities)
        all_entities = length(resolver.id2uuid)
    end
    for (table_name, _) in TABLE_SCHEMAS
        if table_name == "attributes" ||
           table_name == "entities" ||
           table_name == "prime_mover_types" ||
           table_name == "fuels" ||
           table_name == "entity_types" ||
           table_name == "time_series_associations" ||
           table_name == "static_time_series" ||
           table_name == "hydro_reservoir_connections"
            continue
        end
        result = DBInterface.execute(db, "SELECT count(*) from $table_name")
        db_count = first(first(result))::Int64
        local_count = get(row_counts, table_name, 0)
        if db_count != local_count
            @warn "Table $table_name contains $db_count ids but $local_count were processed"
        end
    end
    if time_series
        deserialize_timeseries!(sys, db, resolver)
    end
end

function db2sys(db; time_series=false)
    sys = PSY.System(100)
    resolver = Resolver(sys, Dict{Int64, UUID}())
    db2sys!(sys, db, resolver, time_series=time_series)
    return sys
end
