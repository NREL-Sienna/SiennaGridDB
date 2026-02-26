CREATE VIEW IF NOT EXISTS deterministic_time_series_view AS WITH json_data AS (
    SELECT deterministic_forecast_time_series.time_series_id,
        deterministic_forecast_time_series.id,
        deterministic_forecast_time_series.timestamp,
        json_each.value,
        ROW_NUMBER() OVER (
            PARTITION BY deterministic_forecast_time_series.id
            ORDER BY json_each.value
        ) AS horizon
    FROM deterministic_forecast_time_series,
        json_each(deterministic_forecast_time_series.value)
)
SELECT time_series_id,
    id,
    timestamp,
    horizon,
    value
FROM json_data;

CREATE VIEW IF NOT EXISTS operational_data AS
SELECT e.id AS entity_id,
    e.entity_table,
    e.entity_type,
    json_extract(apl.value, '$.min') AS active_power_limit_min,
    json_extract(mr.value, '$') AS must_run,
    json_extract(tl.value, '$.up') AS uptime,
    json_extract(tl.value, '$.down') AS downtime,
    json_extract(rl.value, '$.up') AS ramp_up,
    json_extract(rl.value, '$.down') AS ramp_down,
    oc.value AS operational_cost,
    json_type(oc.value) AS operational_cost_type
FROM entities e
    LEFT JOIN attributes apl ON e.id = apl.entity_id
    AND apl.name = 'active_power_limits'
    LEFT JOIN attributes mr ON e.id = mr.entity_id
    AND mr.name = 'must_run'
    LEFT JOIN attributes tl ON e.id = tl.entity_id
    AND tl.name = 'time_limits'
    LEFT JOIN attributes rl ON e.id = rl.entity_id
    AND rl.name = 'ramp_limits'
    LEFT JOIN attributes oc ON e.id = oc.entity_id
    AND oc.name = 'operation_cost'
WHERE -- Only include entities that have at least one operational attribute
    (
        apl.entity_id IS NOT NULL
        OR mr.entity_id IS NOT NULL
        OR tl.entity_id IS NOT NULL
        OR rl.entity_id IS NOT NULL
        OR oc.entity_id IS NOT NULL
    )
    AND e.entity_type IN ('ThermalStandard', 'ThermalMultiStart');
