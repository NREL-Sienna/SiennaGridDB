.print +----------+
.print | entities |
.print +----------+

SELECT * from entities;

.print +--------------+
.print | prime movers |
.print +--------------+

SELECT * from prime_mover_types;

.print +----------------------+
.print | balancing topologies |
.print +----------------------+

SELECT * from balancing_topologies;

.print +------------------+
.print | planning regions |
.print +------------------+

SELECT * from planning_regions;

.print +------------------+
.print | generation units |
.print +------------------+

SELECT * from generation_units;

.print +---------------+
.print | storage units |
.print +---------------+
SELECT * from storage_units;

.print +---------------------+
.print | supply technologies |
.print +---------------------+
SELECT * from supply_technologies;

.print +--------------------+
.print | transmission lines |
.print +--------------------+
SELECT * from transmission_lines;

.print +------+
.print | arcs |
.print +------+
SELECT * from arcs;

.print +-------------------------+
.print | Supplemental Attributes |
.print +-------------------------+
SELECT
  id,
  type,
  json_extract(value, "$.lat") as latitude,
  json_extract(value, "$.lon") as longitude
FROM
  supplemental_attributes
WHERE
  type == 'geolocation';


.print +-------------+
.print | Time Series |
.print +-------------+

SELECT
  time_series_type,
  name,
  initial_timestamp,
  resolution,
  horizon,
  interval,
  length
FROM
  time_series_associations;
