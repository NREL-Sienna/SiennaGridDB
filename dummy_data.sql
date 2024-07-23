INSERT INTO prime_mover_types (prime_mover, fuel_type) VALUES
('CT', 'Oil'),
('STEAM', 'Coal'),
('CT', 'NG'),
('HYDRO', 'Hydro'),
('WIND', 'Wind'),
('STORAGE', 'Storage'),
('PV', 'Solar');


INSERT INTO areas (name, description) VALUES
('North', 'Northern region'),
('South', 'Southern region');

INSERT INTO balancing_topologies (name, area, description, participation_factor) VALUES
('Load Area 1', 'North', 'Urban area with high power demand', 0.5),
('Load Area 2', 'South', 'Rural area with moderate power demand', 0.7),
('Load Area 3', 'North', 'Industrial area with heavy power consumption', 0.5),
('Load Area 4', 'South', 'Commercial area with varying power requirements', 0.3);

INSERT INTO generation_units (
    unit_id, name, prime_mover, fuel_type, balancing_topology, rating, base_power
) VALUES
(1, 'Unit 1', 'CT', 'NG', 'Topo 1', 200, 200),
(2, 'Unit 2', 'HYDRO', 'Hydro', 'Topo 2', 300, 300),
(3, 'Unit 3', 'PV', 'Solar', 'Topo 3', 150, 200),
(4, 'Unit 4', 'WIND', 'Wind', 'Topo 4', 180, 200);

INSERT INTO storage_units (
    storage_unit_id, name, prime_mover, fuel_type, max_capacity, round_trip_efficiency, balancing_topology, rating, base_power
) VALUES
(1, 'Storage Unit 2', 'HYDRO', 'Hydro', 600.0, 1.0, 'Topo 2', 300, 300),
(2, 'Storage Unit 3', 'STORAGE', 'Storage' 900.0, 0.95 'Topo 3', 150, 300),
(3, 'Storage Unit 4', 'HYDRO', 'Hydro', 1200.0, 1.0,'Topo 4', 180, 300);

INSERT INTO transmission_lines (
    area_from, area_to, rating_up, rating_down
) VALUES
('Load Area 1', 'Load Area 2', 175.0, 193.0, 200.0, 22.0),
('Load Area 2', 'Load Area 3', 400.0, 510.0, 600.0, 55.0),
('Load Area 3', 'Load Area 4', 175.0, 208.0, 220.0, 22.0);

INSERT INTO attributes (entity_id, entity_type, name, value, data_type) VALUES
(1, 'generation_units', 'cost_vom', NULL, 'time_series'),
(1, 'generation_units', 'year', 2023, 'integer'),
(2, 'generation_units', 'cost_vom', 2023.2, 'real'),
(2, 'generation_units', 'year', 2022, 'integer'),
(3, 'generation_units', 'cost_vom', 'DEF Corp', 'text'),
(3, 'generation_units', 'year', 2021, 'integer'),
(4, 'demand_requirements', 'Load Area 1', 'time_series'),
(5, 'demand_requirements', 'Load Area 2', 'time_series');

INSERT INTO demand_requirements (entity_attribute_id, peak_load, area) VALUES
(4, 1000, 'North'),
(5, 2000, 'South');

-- Insert dummy data for a 24-hour time series
INSERT INTO time_series (entity_attribute_id, timestamp, value)
VALUES
(4, strftime('%s', 'now', 'start of day'), random() * 100),
(4, strftime('%s', 'now', 'start of day', '+1 hour'), random() * 100),
(4, strftime('%s', 'now', 'start of day', '+2 hours'), random() * 100),
(4, strftime('%s', 'now', 'start of day', '+3 hours'), random() * 100),
(4, strftime('%s', 'now', 'start of day', '+4 hours'), random() * 100),
(4, strftime('%s', 'now', 'start of day', '+5 hours'), random() * 100),
(4, strftime('%s', 'now', 'start of day', '+6 hours'), random() * 100),
(4, strftime('%s', 'now', 'start of day', '+7 hours'), random() * 100),
(4, strftime('%s', 'now', 'start of day', '+8 hours'), random() * 100),
(4, strftime('%s', 'now', 'start of day', '+9 hours'), random() * 100),
(4, strftime('%s', 'now', 'start of day', '+10 hours'), random() * 100),
(4, strftime('%s', 'now', 'start of day', '+11 hours'), random() * 100),
(4, strftime('%s', 'now', 'start of day', '+12 hours'), random() * 100),
(4, strftime('%s', 'now', 'start of day', '+13 hours'), random() * 100),
(4, strftime('%s', 'now', 'start of day', '+14 hours'), random() * 100),
(4, strftime('%s', 'now', 'start of day', '+15 hours'), random() * 100),
(4, strftime('%s', 'now', 'start of day', '+16 hours'), random() * 100),
(4, strftime('%s', 'now', 'start of day', '+17 hours'), random() * 100),
(4, strftime('%s', 'now', 'start of day', '+18 hours'), random() * 100),
(4, strftime('%s', 'now', 'start of day', '+19 hours'), random() * 100),
(4, strftime('%s', 'now', 'start of day', '+20 hours'), random() * 100),
(4, strftime('%s', 'now', 'start of day', '+21 hours'), random() * 100),
(4, strftime('%s', 'now', 'start of day', '+22 hours'), random() * 100),
(4, strftime('%s', 'now', 'start of day', '+23 hours'), random() * 100);
(5, strftime('%s', 'now', 'start of day'), random() * 100),
(5, strftime('%s', 'now', 'start of day', '+1 hour'), random() * 100),
(5, strftime('%s', 'now', 'start of day', '+2 hours'), random() * 100),
(5, strftime('%s', 'now', 'start of day', '+3 hours'), random() * 100),
(5, strftime('%s', 'now', 'start of day', '+4 hours'), random() * 100),
(5, strftime('%s', 'now', 'start of day', '+5 hours'), random() * 100),
(5, strftime('%s', 'now', 'start of day', '+6 hours'), random() * 100),
(5, strftime('%s', 'now', 'start of day', '+7 hours'), random() * 100),
(5, strftime('%s', 'now', 'start of day', '+8 hours'), random() * 100),
(5, strftime('%s', 'now', 'start of day', '+9 hours'), random() * 100),
(5, strftime('%s', 'now', 'start of day', '+10 hours'), random() * 100),
(5, strftime('%s', 'now', 'start of day', '+11 hours'), random() * 100),
(5, strftime('%s', 'now', 'start of day', '+12 hours'), random() * 100),
(5, strftime('%s', 'now', 'start of day', '+13 hours'), random() * 100),
(5, strftime('%s', 'now', 'start of day', '+14 hours'), random() * 100),
(5, strftime('%s', 'now', 'start of day', '+15 hours'), random() * 100),
(5, strftime('%s', 'now', 'start of day', '+16 hours'), random() * 100),
(5, strftime('%s', 'now', 'start of day', '+17 hours'), random() * 100),
(5, strftime('%s', 'now', 'start of day', '+18 hours'), random() * 100),
(5, strftime('%s', 'now', 'start of day', '+19 hours'), random() * 100),
(5, strftime('%s', 'now', 'start of day', '+20 hours'), random() * 100),
(5, strftime('%s', 'now', 'start of day', '+21 hours'), random() * 100),
(5, strftime('%s', 'now', 'start of day', '+22 hours'), random() * 100),
(5, strftime('%s', 'now', 'start of day', '+23 hours'), random() * 100);


-- Insert dummy data for a piecewise linear function
INSERT INTO attributes (entity_attribute_id, entity_id, entity_type, name, data_type)
VALUES (1, 1, 'supply_technologies', 'Wind_class1', 'piecewise_linear');

INSERT INTO piecewise_linear (entity_attribute_id, piecewise_linear_blob)
VALUES
(1, '{"from_x": 0, "to_x": 10, "from_y": 0, "to_y": 100}'),
(1, '{"from_x": 10, "to_x": 20, "from_y": 100, "to_y": 200}'),
(1, '{"from_x": 20, "to_x": 30, "from_y": 200, "to_y": 300}');
