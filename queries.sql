SELECT * from entities;

SELECT * from prime_movers;

SELECT * from balancing_topologies;

SELECT * from planning_regions;

SELECT * from generation_units;

SELECT id, name, max_capacity, round_trip_efficiency from storage_units;

SELECT * from supply_technologies;

SELECT * from transmission_lines;

SELECT * from arcs;

SELECT
  id,
  type,
  json_extract(value, "$.lat") as latitude,
  json_extract(value, "$.lon") as longitude
FROM
  supplemental_attributes
WHERE
  type == 'geolocation';

SELECT
  time_series_type,
  name,
  initial_timestamp,
  resolution_ms,
  horizon,
  interval,
  length
FROM
  time_series;

SELECT
  id,
  time_series_id,
  datetime (timestamp, 'unixepoch'),
  value
FROM
  static_time_series;

SELECT * from deterministic_time_series_view;
