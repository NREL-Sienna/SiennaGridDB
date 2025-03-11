SELECT * from entities;

SELECT * from prime_movers;

SELECT * from balancing_topologies;

SELECT * from areas;

SELECT * from generation_units;

SELECT * from storage_units;

SELECT * from supply_technologies;

SELECT * from transmission_lines;

SELECT * from arcs;

SELECT id, type, json_extract(value, "$.lat") as latitude, json_extract(value, "$.lon") as longitude from supplemental_attributes;

SELECT * from time_series;

SELECT id, time_series_id, datetime(timestamp, 'unixepoch'), value from static_time_series;

SELECT * from deterministic_time_series_view;
