CREATE VIEW IF NOT EXISTS deterministic_time_series_view AS WITH json_data AS (
    SELECT
        deterministic_forecast_time_series.time_series_id,
        deterministic_forecast_time_series.id,
        deterministic_forecast_time_series.timestamp,
        json_each.value,
        ROW_NUMBER() OVER (
            PARTITION BY deterministic_forecast_time_series.id
            ORDER BY
                json_each.value
        ) AS horizon
    FROM
        deterministic_forecast_time_series,
        json_each(deterministic_forecast_time_series.value)
)
SELECT
    time_series_id,
    id,
    timestamp,
    horizon,
    value
FROM
    json_data;
