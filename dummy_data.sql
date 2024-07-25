INSERT INTO prime_mover_types (prime_mover, fuel_type) VALUES
('CT', 'Oil'),
('STEAM', 'Coal'),
('CT', 'NG'),
('HYDRO', 'Hydro'),
('WIND', 'Wind'),
('STORAGE', 'Storage'),
('PV', 'Solar');

-- Areas are the higher level aggregation of balancing topologies
INSERT INTO areas (name, description) VALUES
('North', 'Northern region'),
('South', 'Southern region');

-- Balancing topologies are the lower level aggregation of generation units
INSERT INTO balancing_topologies (name, area, description, participation_factor) VALUES
('Load Area 1', 'North', 'Urban area with high power demand', 0.25),
('Load Area 2', 'South', 'Rural area with moderate power demand', 0.35),
('Load Area 3', 'North', 'Industrial area with heavy power consumption', 0.25),
('Load Area 4', 'South', 'Commercial area with varying power requirements', 0.15),
('Topo 1', 'North', 'Urban area with generation from Natural Gas', 0.25),
('Topo 2', 'South', 'Rural area with generation from hydro', 0.35),
('Topo 3', 'North', 'Industrial area with generation from solar and storage', 0.25),
('Topo 4', 'South', 'Commercial area with generation from wind and storage', 0.15);

-- Inserting data for generation units
INSERT INTO generation_units (
    unit_id, name, prime_mover, fuel_type, balancing_topology, rating, base_power
) VALUES
(1, 'Unit 1', 'CT', 'NG', 'Topo 1', 200, 200),
(2, 'Unit 2', 'HYDRO', 'Hydro', 'Topo 2', 300, 300),
(3, 'Unit 3', 'PV', 'Solar', 'Topo 3', 150, 200),
(4, 'Unit 4', 'WIND', 'Wind', 'Topo 4', 180, 200);

-- Inserting data for storage units
INSERT INTO storage_units (
    storage_unit_id, name, prime_mover, fuel_type, max_capacity, round_trip_efficiency, balancing_topology, rating, base_power
) VALUES
(1, 'Storage Unit 2', 'HYDRO', 'Hydro', 600.0, 1.0, 'Topo 2', 300, 300),
(2, 'Storage Unit 3', 'STORAGE', 'Storage', 900.0, 0.95, 'Topo 3', 150, 300),
(3, 'Storage Unit 4', 'HYDRO', 'Hydro', 1200.0, 1.0,'Topo 4', 180, 300);

-- Inserting data for transmission lines
INSERT INTO transmission_lines (
    area_from, area_to, continuous_rating, ste_rating, lte_rating, line_length
) VALUES
('Load Area 1', 'Load Area 2', 175.0, 193.0, 200.0, 22.0),
('Load Area 1', 'Topo 1', 200.0, 220.0, 250.0, 25.0),
('Load Area 2', 'Topo 1', 300.0, 330.0, 400.0, 40.0),
('Topo 3', 'Load Area 3', 150.0, 165.0, 180.0, 18.0),
('Topo 3', 'Topo 4', 180.0, 198.0, 220.0, 22.0),
('Load Area 2', 'Load Area 3', 400.0, 510.0, 600.0, 55.0),
('Load Area 3', 'Load Area 4', 175.0, 208.0, 220.0, 22.0);

-- If there are time series or piecewise linear additions, an attribute must be created for data relation maintenance
INSERT INTO attributes (entity_id, entity_type, name, data_type) VALUES
(1, 'generation_units', 'wind_generation_curve', 'time_series'),
(2, 'generation_units', 'solar_generation_curve', 'time_series'),
(3, 'generation_units', 'hydro_generation_curve', 'time_series'),
(4, 'demand_requirements', 'Load Area 1', 'time_series'),
(5, 'demand_requirements', 'Load Area 2', 'time_series');

INSERT INTO demand_requirements (entity_attribute_id, peak_load, area) VALUES
(4, 1000, 'North'),
(5, 2000, 'South');


-- Once the attribute is created, the time series data for the load can be inserted into the blob
-- Insert time series data as JSON blob
INSERT INTO time_series (entity_attribute_id, time_series_blob) VALUES
(4, json_object('timestamp', strftime('%s', 'now', 'start of day'), 'value', random() * 100)),
(4, json_object('timestamp', strftime('%s', 'now', 'start of day', '+1 hour'), 'value', random() * 100)),
(4, json_object('timestamp', strftime('%s', 'now', 'start of day', '+2 hours'), 'value', random() * 100)),
(4, json_object('timestamp', strftime('%s', 'now', 'start of day', '+3 hours'), 'value', random() * 100)),
(4, json_object('timestamp', strftime('%s', 'now', 'start of day', '+4 hours'), 'value', random() * 100)),
(4, json_object('timestamp', strftime('%s', 'now', 'start of day', '+5 hours'), 'value', random() * 100)),
(4, json_object('timestamp', strftime('%s', 'now', 'start of day', '+6 hours'), 'value', random() * 100)),
(4, json_object('timestamp', strftime('%s', 'now', 'start of day', '+7 hours'), 'value', random() * 100)),
(4, json_object('timestamp', strftime('%s', 'now', 'start of day', '+8 hours'), 'value', random() * 100)),
(4, json_object('timestamp', strftime('%s', 'now', 'start of day', '+9 hours'), 'value', random() * 100)),
(4, json_object('timestamp', strftime('%s', 'now', 'start of day', '+10 hours'), 'value', random() * 100)),
(4, json_object('timestamp', strftime('%s', 'now', 'start of day', '+11 hours'), 'value', random() * 100)),
(4, json_object('timestamp', strftime('%s', 'now', 'start of day', '+12 hours'), 'value', random() * 100)),
(4, json_object('timestamp', strftime('%s', 'now', 'start of day', '+13 hours'), 'value', random() * 100)),
(4, json_object('timestamp', strftime('%s', 'now', 'start of day', '+14 hours'), 'value', random() * 100)),
(4, json_object('timestamp', strftime('%s', 'now', 'start of day', '+15 hours'), 'value', random() * 100)),
(4, json_object('timestamp', strftime('%s', 'now', 'start of day', '+16 hours'), 'value', random() * 100)),
(4, json_object('timestamp', strftime('%s', 'now', 'start of day', '+17 hours'), 'value', random() * 100)),
(4, json_object('timestamp', strftime('%s', 'now', 'start of day', '+18 hours'), 'value', random() * 100)),
(4, json_object('timestamp', strftime('%s', 'now', 'start of day', '+19 hours'), 'value', random() * 100)),
(4, json_object('timestamp', strftime('%s', 'now', 'start of day', '+20 hours'), 'value', random() * 100)),
(4, json_object('timestamp', strftime('%s', 'now', 'start of day', '+21 hours'), 'value', random() * 100)),
(4, json_object('timestamp', strftime('%s', 'now', 'start of day', '+22 hours'), 'value', random() * 100)),
(4, json_object('timestamp', strftime('%s', 'now', 'start of day', '+23 hours'), 'value', random() * 100)),
(5, json_object('timestamp', strftime('%s', 'now', 'start of day'), 'value', random() * 100)),
(5, json_object('timestamp', strftime('%s', 'now', 'start of day', '+1 hour'), 'value', random() * 100)),
(5, json_object('timestamp', strftime('%s', 'now', 'start of day', '+2 hours'), 'value', random() * 100)),
(5, json_object('timestamp', strftime('%s', 'now', 'start of day', '+3 hours'), 'value', random() * 100)),
(5, json_object('timestamp', strftime('%s', 'now', 'start of day', '+4 hours'), 'value', random() * 100)),
(5, json_object('timestamp', strftime('%s', 'now', 'start of day', '+5 hours'), 'value', random() * 100)),
(5, json_object('timestamp', strftime('%s', 'now', 'start of day', '+6 hours'), 'value', random() * 100)),
(5, json_object('timestamp', strftime('%s', 'now', 'start of day', '+7 hours'), 'value', random() * 100)),
(5, json_object('timestamp', strftime('%s', 'now', 'start of day', '+8 hours'), 'value', random() * 100)),
(5, json_object('timestamp', strftime('%s', 'now', 'start of day', '+9 hours'), 'value', random() * 100)),
(5, json_object('timestamp', strftime('%s', 'now', 'start of day', '+10 hours'), 'value', random() * 100)),
(5, json_object('timestamp', strftime('%s', 'now', 'start of day', '+11 hours'), 'value', random() * 100)),
(5, json_object('timestamp', strftime('%s', 'now', 'start of day', '+12 hours'), 'value', random() * 100)),
(5, json_object('timestamp', strftime('%s', 'now', 'start of day', '+13 hours'), 'value', random() * 100)),
(5, json_object('timestamp', strftime('%s', 'now', 'start of day', '+14 hours'), 'value', random() * 100)),
(5, json_object('timestamp', strftime('%s', 'now', 'start of day', '+15 hours'), 'value', random() * 100)),
(5, json_object('timestamp', strftime('%s', 'now', 'start of day', '+16 hours'), 'value', random() * 100)),
(5, json_object('timestamp', strftime('%s', 'now', 'start of day', '+17 hours'), 'value', random() * 100)),
(5, json_object('timestamp', strftime('%s', 'now', 'start of day', '+18 hours'), 'value', random() * 100)),
(5, json_object('timestamp', strftime('%s', 'now', 'start of day', '+19 hours'), 'value', random() * 100)),
(5, json_object('timestamp', strftime('%s', 'now', 'start of day', '+20 hours'), 'value', random() * 100)),
(5, json_object('timestamp', strftime('%s', 'now', 'start of day', '+21 hours'), 'value', random() * 100)),
(5, json_object('timestamp', strftime('%s', 'now', 'start of day', '+22 hours'), 'value', random() * 100)),
(5, json_object('timestamp', strftime('%s', 'now', 'start of day', '+23 hours')));

-- Time series data can also be added for the wind and solar generation curves


-- Inserting data for investment technologies
INSERT INTO supply_technologies (technology_id, prime_mover, fuel_type, technology_class, vom_cost, fom_cost, balancing_topology)
VALUES
(1, "WIND", "Wind", 1, 0.0, 0.0, "Topo 1"),
(2, "SOLAR", "Solar", 1, 0.0, 0.0, "Topo 2");

-- Again, for piecewise linear data an attribute must be created to connect the function data to the investment technology
INSERT INTO attributes (entity_attribute_id, entity_id, entity_type, name, data_type)
VALUES 
(6, 1, 'supply_technologies', 'Wind_class1', 'piecewise_linear'),
(7, 2, 'supply_technologies', 'Solar_class1', 'piecewise_linear');

-- x values are in MW capacity built, y is $/MW as you insert into the piecewise_linear blob
INSERT INTO piecewise_linear (entity_attribute_id, piecewise_linear_blob)
VALUES
(6, '{"from_x": 0, "to_x": 100, "from_y": 0, "to_y": 100}'),
(6, '{"from_x": 100, "to_x": 200, "from_y": 100, "to_y": 250}'),
(6, '{"from_x": 200, "to_x": 300, "from_y": 250, "to_y": 390}'),
(7, '{"from_x": 0, "to_x": 100, "from_y": 0, "to_y": 100}'),
(7, '{"from_x": 100, "to_x": 200, "from_y": 100, "to_y": 250}'),
(7, '{"from_x": 200, "to_x": 300, "from_y": 250, "to_y": 390}');

-- Extraneous data such as policy information can be added to the attributes table
INSERT INTO attributes (entity_attribute_id, entity_id, entity_type, name, value, data_type)
VALUES 
(8, 1, 'policy_data', 'RPS_fraction_North', 0.2, 'float'),
(9, 1, 'policy_data', 'RPS_fraction_South', 0.7, 'float');