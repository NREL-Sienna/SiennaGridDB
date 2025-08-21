const INFRASYS_TS_SCHEMA = Tables.Schema(
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
        "owner_uuid",
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
        String,
        Union{Missing, String},
        Union{Missing, String},
        Union{Missing, Int64},
        Union{Missing, Int64},
        String,
        String,
        String,
        String,
        String,
        Union{Missing, String},
        Base.UUID,
        Union{Missing, String},
    ],
)

function get_uuid_mapping(sys::PowerSystems.System)
    metadata_store = sys.data.time_series_manager.metadata_store

    time_series_uuids = IS.sql(
        metadata_store,
        """
        SELECT DISTINCT metadata_uuid, time_series_uuid, time_series_type, initial_timestamp, resolution, horizon, interval, window_count, length
        FROM time_series_associations
        """,
    )

    # Create a mapping from original time_series_uuid to new unique UUIDs for duplicates
    uuid_count = Dict{String, Int64}()
    uuid_mapping = Dict{String, Base.UUID}()

    for row in Tables.rows(time_series_uuids)
        uuid = row.time_series_uuid

        if haskey(uuid_count, uuid)
            # Duplicate found, assign a new UUID
            new_uuid = UUIDs.uuid4()
            uuid_count[uuid] += 1
            uuid_mapping[row.metadata_uuid] = new_uuid
        else
            uuid_count[uuid] = 1
            uuid_mapping[row.metadata_uuid] = Base.UUID(uuid)
        end
    end

    return uuid_mapping
end

function get_example_metadata_uuids(sys::PowerSystems.System)
    metadata_store = sys.data.time_series_manager.metadata_store

    return IS.sql(
        metadata_store,
        """
        SELECT time_series_uuid, metadata_uuid
        FROM time_series_associations GROUP BY time_series_uuid;
        """,
    )
end

function get_time_series_from_metadata_uuid(sys::PowerSystems.System, metadata_uuid)
    ts_metadata = sys.data.time_series_manager.metadata_store.metadata_uuids[metadata_uuid]

    start_time = IS._check_start_time(nothing, ts_metadata)
    rows = IS._get_rows(start_time, nothing, ts_metadata)
    columns = IS._get_columns(start_time, nothing, ts_metadata)
    storage = sys.data.time_series_manager.data_store

    return InfrastructureSystems.deserialize_time_series(
        InfrastructureSystems.time_series_metadata_to_data(ts_metadata),
        storage,
        ts_metadata,
        rows,
        columns,
    )
end

"""
Writes time series as rows (time_series_uuid, timestamp, value)
"""
function serialize_timeseries_data!(
    db,
    ts::PowerSystems.SingleTimeSeries,
    time_series_uuid::Base.UUID,
)
    stmt = DBInterface.prepare(
        db,
        """
        INSERT INTO static_time_series (uuid, idx, value)
        VALUES (?, ?, ?)
        """,
    )
    for (i, timestamp_value) in enumerate(ts)
        _, value = timestamp_value
        DBInterface.execute(stmt, (string(time_series_uuid), i, value))
    end
end

"""
Writes time series as rows (time_series_uuid, timestamp, value)
"""
function serialize_timeseries_data!(
    db,
    ts::PowerSystems.DeterministicSingleTimeSeries,
    time_series_uuid::Base.UUID,
)
    serialize_time_series_data(db, ts.single_time_series, time_series_uuid)
end

"""
Iterate through all metadata objects and serialize timeseries
"""
function serialize_all_timeseries_data!(db, sys::PowerSystems.System)
    time_series_uuid_to_metadata_uuids = get_example_metadata_uuids(sys)

    for (time_series_uuid, metadata_uuid) in eachrow(time_series_uuid_to_metadata_uuids)
        ts = get_time_series_from_metadata_uuid(sys, Base.UUID(metadata_uuid))
        serialize_timeseries_data!(db, ts, Base.UUID(time_series_uuid))
    end
end

function transform_associations!(sys::PowerSystems.System, associations, ids::IDGenerator)
    associations = PowerSystems.DataFrames.coalesce.(associations, nothing)
    type_strings =
        SiennaOpenAPIModels.ALL_DESERIALIZABLE_TYPES .|> (x -> last(split(string(x), ".")))
    deserializable_string(x) = in(x, type_strings)

    associations = associations[deserializable_string.(associations[!, "owner_type"]), :]
    associations[!, "owner_id"] =
        map(owner_uuid -> getid!(ids, Base.UUID(owner_uuid)), associations[!, "owner_uuid"])
    PowerSystems.DataFrames.select!(
        associations,
        Symbol.(collect(TABLE_SCHEMAS["time_series_associations"].names)),
    )
    return associations
end

function serialize_timeseries_associations!(db, sys::PowerSystems.System, ids::IDGenerator)
    associations = IS.sql(
        sys.data.time_series_manager.metadata_store,
        """SELECT $(join(INFRASYS_TS_SCHEMA.names, ", "))
FROM time_series_associations;""",
    )
    associations = transform_associations!(sys, associations, ids)

    statement = DBInterface.prepare(
        db,
        """INSERT INTO time_series_associations ($(join(TABLE_SCHEMAS["time_series_associations"].names, ", ")))
VALUES ($(join(repeat("?", length(TABLE_SCHEMAS["time_series_associations"].names)), ", ")))""",
    )

    for row in Tables.rowtable(associations)
        DBInterface.execute(statement, tuple(row...))
    end
end

function serialize_timeseries!(db, sys::PowerSystems.System, ids::IDGenerator)
    DBInterface.transaction(db) do
        serialize_all_timeseries_data!(db, sys)
        serialize_timeseries_associations!(db, sys, ids)
    end
end

function deserialize_timedata(
    db,
    sts_meta::InfrastructureSystems.SingleTimeSeriesMetadata,
    time_series_uuid,
)
    stmt = DBInterface.prepare(
        db,
        """
        SELECT idx, value
        FROM static_time_series
        WHERE uuid = ?
        ORDER BY idx
        """,
    )
    rows = DBInterface.execute(stmt, (string(time_series_uuid),))
    column_table = Tables.columntable(rows)
    timestamps =
        range(sts_meta.initial_timestamp; length=sts_meta.length, step=sts_meta.resolution)
    return PowerSystems.TimeSeries.TimeArray(timestamps, column_table.value)
end

function deserialize_timedata(_, ts::InfrastructureSystems.DeterministicMetadata, _)
    error("Cannot deserialize deterministic timeseries $ts")
end

function deserialize_time_series_row!(sys, db, row)
    metadata = deserialize_metadata(row)
    if isa(metadata, InfrastructureSystems.DeterministicMetadata) &&
       metadata.time_series_type <: InfrastructureSystems.DeterministicSingleTimeSeries
        component = PowerSystems.get_component(sys, row.owner_uuid)
        InfrastructureSystems.add_metadata!(
            sys.data.time_series_manager.metadata_store,
            component,
            metadata,
        )
    else
        time_array = deserialize_timedata(db, metadata, row.time_series_uuid)
        ts = InfrastructureSystems.time_series_metadata_to_data(metadata)(
            metadata,
            time_array,
        )
        PowerSystems.add_time_series!(
            sys,
            PowerSystems.get_component(sys, row.owner_uuid),
            ts,
        )
    end
end

# TODO: STOLEN FROM InfrastructureSystems. This should be made an IS functions.
function deserialize_metadata(row)
    exclude_keys = Set((:metadata_uuid, :owner_uuid, :time_series_type))
    time_series_type =
        InfrastructureSystems.TIME_SERIES_STRING_TO_TYPE[row.time_series_type]
    metadata_type = InfrastructureSystems.time_series_data_to_metadata(time_series_type)
    fields = Set(fieldnames(metadata_type))
    data = Dict{Symbol, Any}(
        :internal => InfrastructureSystems.InfrastructureSystemsInternal(;
            uuid=Base.UUID(row.metadata_uuid),
        ),
    )
    if time_series_type <: InfrastructureSystems.Forecast
        # Special case because the table column does not match the field name.
        data[:count] = row.window_count
    end
    if time_series_type <: InfrastructureSystems.AbstractDeterministic
        data[:time_series_type] = time_series_type
    end
    for field in keys(row)
        if !in(field, fields) || field in exclude_keys
            continue
        end
        val = getproperty(row, field)
        if field == :initial_timestamp
            data[field] = Dates.DateTime(val)
        elseif field == :resolution
            data[field] = InfrastructureSystems.from_iso_8601(val)
        elseif field == :horizon || field == :interval
            if !ismissing(val)
                data[field] = InfrastructureSystems.from_iso_8601(val)
            end
        elseif field == :time_series_uuid
            data[field] = Base.UUID(val)
        elseif field == :features
            features_array = InfrastructureSystems.JSON3.read(val, Array)
            features_dict = Dict{String, Union{Bool, Int, String}}()
            for obj in features_array
                length(obj) != 1 && error("Invalid features: $obj")
                key = first(keys(obj))
                key in keys(features_dict) && error("Duplicate features: $key")
                features_dict[key] = obj[key]
            end
            data[field] = features_dict
        elseif field == :scaling_factor_multiplier
            if !ismissing(val)
                val2 = InfrastructureSystems.JSON3.read(val, Dict{String, Any})
                data[field] = InfrastructureSystems.deserialize(Function, val2)
            end
        else
            data[field] = val
        end
    end
    metadata = metadata_type(; data...)
    return metadata
end

function get_example_metadata(db)
    time_series_uuid_rows = DBInterface.execute(
        db,
        "SELECT * FROM time_series_associations WHERE time_series_type != 'DeterministicSingleTimeSeries' GROUP BY time_series_uuid",
    )
    return time_series_uuid_rows
end

function deserialize_time_series_from_metadata!(
    sys::PowerSystems.System,
    db,
    resolver::Resolver,
    metadata,
    row,
)
    time_array = deserialize_timedata(db, metadata, row.time_series_uuid)
    ts = InfrastructureSystems.time_series_metadata_to_data(metadata)(metadata, time_array)
    PowerSystems.add_time_series!(sys, resolver(row.owner_id), ts)
end

function deserialize_timeseries!(sys::PowerSystems.System, db, resolver::Resolver)
    DBInterface.transaction(db) do
        # For each time_series_uuid, we'll pick a "real" metadata_uuid (so no DeterministicSingleTimeSeries),
        # then we will deserialize and add them to the system. Finally, we'll go through and add_metadata!
        # for all others.
        serialized_metadata = Set{String}()
        for row in get_example_metadata(db)
            metadata = deserialize_metadata(row)
            deserialize_time_series_from_metadata!(sys, db, resolver, metadata, row)
            push!(serialized_metadata, row.metadata_uuid)
        end

        associations = DBInterface.execute(db, "SELECT * FROM time_series_associations")

        for row in associations
            metadata = deserialize_metadata(row)
            if in(row.metadata_uuid, serialized_metadata)
                continue
            end
            component = resolver(row.owner_id)
            InfrastructureSystems.add_metadata!(
                sys.data.time_series_manager.metadata_store,
                component,
                metadata,
            )
        end
    end
end
