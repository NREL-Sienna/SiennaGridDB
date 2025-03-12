PRAGMA foreign_keys = ON;
INSERT INTO prime_movers (prime_mover, fuel, description) VALUES
('CT', 'Oil', "[C]ombustion [T]urbine wiht Oil"),
('CT', 'NG', "[C]ombustion [T]urbine with [N]atural [G]as"),
('HY', NULL, "[HY]droelectric"),
('WT', NULL, "[W]ind [T]urbine"),
('BA', NULL, "Energy Storage, [BA]ttery"),
('PV', NULL, "[P]hoto[V]oltaic");
--
-- -- Areas are the higher level aggregation of balancing topologies
INSERT INTO planning_regions (name, description) VALUES
('North', 'Northern region'),
('South', 'Southern region');
--
-- -- Balancing topologies are the lower level aggregation of generation units
INSERT INTO balancing_topologies (name, area, participation_factor, description) VALUES
('load_area_01', 'North', 0.25, 'Urban area with high power demand'),
('load_area_02', 'South', 0.35, 'Rural area with moderate power demand'),
('load_area_03', 'North', 0.25, 'Industrial area with heavy power consumption'),
('load_area_04', 'South', 0.25,  'Commercial area with varying power requirements'),
('region_01', 'North',  0.25,'Urban area with generation from Natural Gas'),
('region_02', 'South', 0.35, 'Rural area with generation from hydro'),
('region_03', 'North', 0.25, 'Industrial area with generation from solar and storage'),
('region_04', 'South', 0.25, 'Commercial area with generation from wind and storage');
-- --
-- -- -- Inserting data for generation units
INSERT INTO generation_units (
    name, prime_mover, fuel, balancing_topology, rating, base_power, start_year
) VALUES
('Unit 1', 'CT', 'NG', 'region_01', 200, 200, 2020),
('Unit 2', 'HY', NULL, 'region_02', 300, 300, 2020),
('Unit 3', 'PV', NULL, 'region_03', 150, 200, 2020),
('Unit 4', 'WT', NULL, 'region_04', 180, 200, 2020);
--
-- Inserting data for storage units
INSERT INTO storage_units (
    id, name, prime_mover, max_capacity, discharge_efficiency, balancing_topology, rating, base_power, start_year
) VALUES
(1, 'Storage Unit 2',"PS",  600.0, 1.0, 'region_04', 300, 300, 2020),
(2, 'Storage Unit 3',"PS",  900.0, 0.95, 'region_03', 150, 300, 2020),
(3, 'Storage Unit 4',"PS", 1200.0, 1.0, 'region_02', 180, 300, 2020);

-- Insert some arcs
INSERT INTO arcs (from_to, to_from) VALUES (1, 2);
INSERT INTO arcs (from_to, to_from) VALUES (3, 4);
INSERT INTO arcs (from_to, to_from) VALUES (5, 6);

-- Inserting data for transmission lines
INSERT INTO transmission_lines (
    arc_id, continuous_rating, ste_rating, lte_rating, line_length
) VALUES
(2, 175.0, 193.0, 200.0, 22.0),
(3, 175.0, 193.0, 200.0, 22.0);

-- Inserting data for investment technologies
INSERT INTO supply_technologies (prime_mover, fuel, vom_cost, fom_cost, balancing_topology, scenario)
VALUES
("WT", NULL, 0.0, 0.0, "region_01", NULL),
("WT", NULL, 10.0, 0.0, "region_01", "Expensive"),
("PV", NULL,0.0, 0.0, "region_02", NULL);

-- Supplemental attributes
INSERT INTO supplemental_attributes (type, value) VALUES
    ('geolocation', jsonb("{'lat': 30.5, 'lon': -99.5}"));

-- Add supplemental attribute to some entities
INSERT INTO supplemental_attributes_association (attribute_id, entity_id) values (1, 3);

-- Add time series examples
INSERT INTO time_series (time_series_type, name, initial_timestamp, resolution_ms, horizon, interval, length, metadata)
VALUES
-- Hourly time series for a day (24 points)
('SingleTimeSeries', 'active_power', '2025-01-01 00:00:00', 3600000, 1, 1, 12, '{"unit": "MW"}'),
('DeterministicTimeSeries', 'active_power', '2025-01-01 00:00:00', 43200000, 4, 1, 24, '{"unit": "MW"}'),
('SingleTimeSeries', 'montly_budget', '2025-01-01 00:00:00', 2592000000, 1, 1, 12, '{"unit": "MWh"}'),
('SingleTimeSeries', 'investment', '2025-01-01 00:00:00', 2592000000, 1, 1, 1, '{"unit": "MWh"}');

-- Associate time series with entities
INSERT INTO time_series_associations (time_series_id, owner_id)
VALUES
(1, 11),
(2, 11),
(3, 12),
(4, 3);

-- Hourly time series
INSERT INTO static_time_series (time_series_id, timestamp, value)
VALUES
(1, strftime('%s', 'now', 'start of day'), random() * 100),
(1, strftime('%s', 'now', 'start of day', '+1 hour'), random() * 100),
(1, strftime('%s', 'now', 'start of day', '+2 hour'), random() * 100),
(1, strftime('%s', 'now', 'start of day', '+3 hour'), random() * 100),
(1, strftime('%s', 'now', 'start of day', '+4 hour'), random() * 100),
(1, strftime('%s', 'now', 'start of day', '+5 hour'), random() * 100),
(1, strftime('%s', 'now', 'start of day', '+6 hour'), random() * 100),
(1, strftime('%s', 'now', 'start of day', '+7 hour'), random() * 100),
(1, strftime('%s', 'now', 'start of day', '+8 hour'), random() * 100),
(1, strftime('%s', 'now', 'start of day', '+9 hour'), random() * 100),
(1, strftime('%s', 'now', 'start of day', '+10 hour'), random() * 100),
(1, strftime('%s', 'now', 'start of day', '+11 hour'), random() * 100);

-- Monthly time series
INSERT INTO static_time_series (time_series_id, timestamp, value)
VALUES
(3, strftime('%s', 'now', 'start of day'), random()),
(3, strftime('%s', 'now', 'start of day', '+30 days'), random()),
(3, strftime('%s', 'now', 'start of day', '+60 days'), random());

-- Year time series
INSERT INTO static_time_series (time_series_id, timestamp, value)
VALUES
(4, strftime('%s', 'now', 'start of year'), random());

-- Generate 30-minute active_power time series
WITH RECURSIVE time_points(n, timestamp) AS (
    SELECT 0, datetime('now', 'start of day')
    UNION ALL
    SELECT n+1, datetime(timestamp, '+30 minutes')
    FROM time_points
    WHERE n < 23
)
INSERT INTO deterministic_time_series (time_series_id, timestamp, value)
SELECT
    2 AS time_series_id,
    timestamp,
    jsonb_array(random(), random(), random(), random()) AS value -- 4 horizons
FROM time_points;
