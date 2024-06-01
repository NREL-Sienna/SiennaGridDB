INSERT INTO prime_mover_types (prime_mover, description) VALUES
('Diesel', 'Internal Combustion Engine'),
('Gas Turbine', 'Combustion Engine using gas as fuel'),
('Hydro', 'Hydropower Turbine'),
('Wind', 'Wind Turbine'),
('Solar', 'Solar Panels');


INSERT INTO areas (name, description) VALUES
('North', 'Northern region'),
('South', 'Southern region'),
('East', 'Eastern region'),
('West', 'Western region');

INSERT INTO balancing_topologies (name, area, description) VALUES
('Load Area 1', 'North', 'Urban area with high power demand'),
('Load Area 2', 'South', 'Rural area with moderate power demand'),
('Load Area 3', 'East', 'Industrial area with heavy power consumption'),
('Load Area 4', 'West', 'Commercial area with varying power requirements');

INSERT INTO generation_units (
    unit_id, name, prime_mover, balancing_topology, rating, base_power
) VALUES
(1, 'Unit 1', 'Gas Turbine', 'Topo 1', 200, 200),
(2, 'Unit 2', 'Hydro', 'Topo 2', 300, 300),
(3, 'Unit 3', 'Solar', 'Topo 3', 150, 200),
(4, 'Unit 4', 'Wind', 'Topo 4', 180, 200);

INSERT INTO storage_units (
    storage_unit_id, name, prime_mover, balancing_topology, rating, base_power
) VALUES
(1, 'Storage Unit 1', 'Gas Turbine', 'Topo 1', 200, 300),
(2, 'Storage Unit 2', 'Hydro', 'Topo 2', 300, 300),
(3, 'Storage Unit 3', 'Solar', 'Topo 3', 150, 300),
(4, 'Storage Unit 4', 'Wind', 'Topo 4', 180, 300);

INSERT INTO transmission_lines (
    area_from, area_to, rating_up, rating_down
) VALUES
('North', 'South', 500, 500),
('South', 'East', 400, 400),
('East', 'West', 300, 300),
('West', 'North', 450, 450);

INSERT INTO attributes (entity_id, entity_type, name, value, data_type) VALUES
(1, 'generation_units', 'cost_vom', NULL, 'time_series'),
(1, 'generation_units', 'year', 2023, 'integer'),
(2, 'generation_units', 'cost_vom', 2023.2, 'real'),
(2, 'generation_units', 'year', 2022, 'integer'),
(3, 'generation_units', 'cost_vom', 'DEF Corp', 'text'),
(3, 'generation_units', 'year', 2021, 'integer');

-- Insert dummy data for a 24-hour time series
INSERT INTO time_series (entity_attribute_id, timestamp, value)
VALUES
(1, strftime('%s', 'now', 'start of day'), random() * 100),
(1, strftime('%s', 'now', 'start of day', '+1 hour'), random() * 100),
(1, strftime('%s', 'now', 'start of day', '+2 hours'), random() * 100),
(1, strftime('%s', 'now', 'start of day', '+3 hours'), random() * 100),
(1, strftime('%s', 'now', 'start of day', '+4 hours'), random() * 100),
(1, strftime('%s', 'now', 'start of day', '+5 hours'), random() * 100),
(1, strftime('%s', 'now', 'start of day', '+6 hours'), random() * 100),
(1, strftime('%s', 'now', 'start of day', '+7 hours'), random() * 100),
(1, strftime('%s', 'now', 'start of day', '+8 hours'), random() * 100),
(1, strftime('%s', 'now', 'start of day', '+9 hours'), random() * 100),
(1, strftime('%s', 'now', 'start of day', '+10 hours'), random() * 100),
(1, strftime('%s', 'now', 'start of day', '+11 hours'), random() * 100),
(1, strftime('%s', 'now', 'start of day', '+12 hours'), random() * 100),
(1, strftime('%s', 'now', 'start of day', '+13 hours'), random() * 100),
(1, strftime('%s', 'now', 'start of day', '+14 hours'), random() * 100),
(1, strftime('%s', 'now', 'start of day', '+15 hours'), random() * 100),
(1, strftime('%s', 'now', 'start of day', '+16 hours'), random() * 100),
(1, strftime('%s', 'now', 'start of day', '+17 hours'), random() * 100),
(1, strftime('%s', 'now', 'start of day', '+18 hours'), random() * 100),
(1, strftime('%s', 'now', 'start of day', '+19 hours'), random() * 100),
(1, strftime('%s', 'now', 'start of day', '+20 hours'), random() * 100),
(1, strftime('%s', 'now', 'start of day', '+21 hours'), random() * 100),
(1, strftime('%s', 'now', 'start of day', '+22 hours'), random() * 100),
(1, strftime('%s', 'now', 'start of day', '+23 hours'), random() * 100);
--
--
-- .print ''
-- .print 'Testing queries'
-- .print ''
--
--
-- .print ''
-- .print 'Unit attribute table'
-- .print ''
-- select * from unit_attributes limit 5;;
--
-- .print ''
-- .print 'Time series table'
-- .print ''
-- select * from unit_time_series limit 10;
--
-- .print ''
-- .print 'Technologies for a given balancing_topology:'
-- .print ''
-- .print 'Denormalized from the view'
-- .print ''
-- select * from unit_attributes where balancing_topology = 'Topo 1' limit 10;
-- .print ''
-- .print 'Normalized view'
-- .print ''
-- select * from generation_units where balancing_topology = 'Topo 1' limit 10;

