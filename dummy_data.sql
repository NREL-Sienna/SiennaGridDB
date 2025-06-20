PRAGMA foreign_keys = ON;

BEGIN TRANSACTION;

-- Insert entities and prime mover types with PowerSystems types
INSERT INTO entities (id, entity_type, source_table, name, description, user_data) VALUES 
    (1, 'PrimeMovers', 'prime_mover_types', 'CT', 'Combustion Turbine', json('{"eia_code": "CT", "description": "Combustion Turbine"}')),
    (2, 'PrimeMovers', 'prime_mover_types', 'HY', 'Hydroelectric', json('{"eia_code": "HY", "description": "Hydroelectric"}')),
    (3, 'PrimeMovers', 'prime_mover_types', 'WT', 'Wind Turbine', json('{"eia_code": "WT", "description": "Wind Turbine"}')),
    (4, 'PrimeMovers', 'prime_mover_types', 'BA', 'Battery Storage', json('{"eia_code": "BA", "description": "Battery Storage"}')),
    (5, 'PrimeMovers', 'prime_mover_types', 'PS', 'Pump Storage', json('{"eia_code": "PS", "description": "Pump Storage"}')),
    (6, 'PrimeMovers', 'prime_mover_types', 'PV', 'Photovoltaic', json('{"eia_code": "PV", "description": "Photovoltaic"}'));

INSERT INTO prime_mover_types (id, description) VALUES 
    (1, '[C]ombustion [T]urbine'),
    (2, '[HY]droelectric'),
    (3, '[W]ind [T]urbine'),
    (4, 'Energy Storage, [BA]ttery'),
    (5, '[P]ump [S]torage'),
    (6, '[P]hoto[V]oltaic');

-- Insert entities and fuels
INSERT INTO entities (id, entity_type, source_table, name, description, user_data) VALUES 
    (7, 'ThermalFuels', 'fuels', 'NG', 'Natural Gas', json('{"heat_rate": 7500, "carbon_content": 53.06, "eia_code": "NG"}')),
    (8, 'ThermalFuels', 'fuels', 'Oil', 'Oil', json('{"heat_rate": 9500, "carbon_content": 73.16, "eia_code": "DFO"}'));

INSERT INTO fuels (id, description) VALUES 
    (7, '[N]atural [G]as'),
    (8, 'Oil');

-- Insert entities and planning regions
INSERT INTO entities (id, entity_type, source_table, name, description, user_data) VALUES 
    (9, 'Area', 'planning_regions', 'North', 'Northern region', json('{"load_growth": 0.02, "renewable_target": 0.5, "region_type": "planning"}')),
    (10, 'Area', 'planning_regions', 'South', 'Southern region', json('{"load_growth": 0.015, "renewable_target": 0.4, "region_type": "planning"}'));

INSERT INTO planning_regions (id, description) VALUES 
    (9, 'Northern region'),
    (10, 'Southern region');

-- Insert entities and balancing topologies
INSERT INTO entities (id, entity_type, source_table, name, description, user_data) VALUES 
    (11, 'LoadZone', 'balancing_topologies', 'load_area_01', 'Urban area with high power demand', json('{"voltage_level": "transmission", "zone_type": "load"}')),
    (12, 'LoadZone', 'balancing_topologies', 'load_area_02', 'Rural area with moderate power demand', json('{"voltage_level": "transmission", "zone_type": "load"}')),
    (13, 'LoadZone', 'balancing_topologies', 'load_area_03', 'Industrial area with heavy power consumption', json('{"voltage_level": "transmission", "zone_type": "load"}')),
    (14, 'LoadZone', 'balancing_topologies', 'load_area_04', 'Commercial area with varying power requirements', json('{"voltage_level": "transmission", "zone_type": "load"}')),
    (15, 'ACBus', 'balancing_topologies', 'region_01', 'Urban area with generation from Natural Gas', json('{"voltage_level": "transmission", "bus_type": "generation"}')),
    (16, 'ACBus', 'balancing_topologies', 'region_02', 'Rural area with generation from hydro', json('{"voltage_level": "transmission", "bus_type": "generation"}')),
    (17, 'ACBus', 'balancing_topologies', 'region_03', 'Industrial area with generation from solar and storage', json('{"voltage_level": "transmission", "bus_type": "generation"}')),
    (18, 'ACBus', 'balancing_topologies', 'region_04', 'Commercial area with generation from wind and storage', json('{"voltage_level": "transmission", "bus_type": "generation"}'));

INSERT INTO balancing_topologies (id, area, description) VALUES 
    (11, 9, 'Urban area with high power demand'),      -- load_area_01, North
    (12, 10, 'Rural area with moderate power demand'), -- load_area_02, South
    (13, 9, 'Industrial area with heavy power consumption'), -- load_area_03, North
    (14, 10, 'Commercial area with varying power requirements'), -- load_area_04, South
    (15, 9, 'Urban area with generation from Natural Gas'), -- region_01, North
    (16, 10, 'Rural area with generation from hydro'), -- region_02, South
    (17, 9, 'Industrial area with generation from solar and storage'), -- region_03, North
    (18, 10, 'Commercial area with generation from wind and storage'); -- region_04, South

-- Insert entities and generation units with PowerSystems types
INSERT INTO entities (id, entity_type, source_table, name, description, user_data) VALUES 
    (19, 'ThermalStandard', 'generation_units', 'Unit 1', 'Gas turbine unit', json('{"unit_commitment": true, "min_up_time": 4, "min_down_time": 2, "start_up_cost": 1000.0}')),
    (20, 'HydroDispatch', 'generation_units', 'Unit 2', 'Hydro unit', json('{"unit_commitment": false, "reservoir_capacity": 1000, "water_flow_rate": 50.0}')),
    (21, 'RenewableNonDispatch', 'generation_units', 'Unit 3', 'Solar PV unit', json('{"weather_dependent": true, "availability_factor": 0.25, "power_factor": 0.95}')),
    (22, 'RenewableNonDispatch', 'generation_units', 'Unit 4', 'Wind turbine unit', json('{"weather_dependent": true, "availability_factor": 0.35, "power_factor": 0.92}'));

INSERT INTO generation_units (id, prime_mover, fuel, balancing_topology, rating, base_power) VALUES 
    (19, 1, 7, 15, 1, 200),    -- CT with NG at region_01
    (20, 2, NULL, 16, 1, 300), -- HY at region_02
    (21, 6, NULL, 17, 1, 200), -- PV at region_03
    (22, 3, NULL, 18, 1, 200); -- WT at region_04

-- Insert entities and storage units with PowerSystems types
INSERT INTO entities (id, entity_type, source_table, name, description, user_data) VALUES 
    (23, 'HydroPumpedStorage', 'storage_units', 'Storage Unit 1', 'Pump storage unit 1', json('{"round_trip_efficiency": 0.8, "pump_efficiency": 0.9, "turbine_efficiency": 0.89}')),
    (24, 'HydroPumpedStorage', 'storage_units', 'Storage Unit 2', 'Pump storage unit 2', json('{"round_trip_efficiency": 0.75, "pump_efficiency": 0.85, "turbine_efficiency": 0.88}')),
    (25, 'HydroPumpedStorage', 'storage_units', 'Storage Unit 3', 'Pump storage unit 3', json('{"round_trip_efficiency": 0.8, "pump_efficiency": 0.9, "turbine_efficiency": 0.89}'));

INSERT INTO storage_units (id, prime_mover, max_capacity, efficiency_up, balancing_topology, rating, base_power) VALUES 
    (23, 5, 600.0, 1.0, 18, 1, 300),    -- PS at region_04
    (24, 5, 900.0, 0.95, 17, 1, 300),   -- PS at region_03
    (25, 5, 1200.0, 1.0, 16, 1, 300);   -- PS at region_02

-- Insert entities and arcs
INSERT INTO entities (id, entity_type, source_table, name, description, user_data) VALUES 
    (26, 'Arc', 'arcs', 'Arc 1', 'Connection between load areas', json('{"network_type": "transport", "arc_type": "load_interconnection"}')),
    (27, 'Arc', 'arcs', 'Arc 2', 'Connection between load areas', json('{"network_type": "transport", "arc_type": "load_interconnection"}')),
    (28, 'Arc', 'arcs', 'Arc 3', 'Connection between generation regions', json('{"network_type": "transport", "arc_type": "generation_interconnection"}'));

INSERT INTO arcs (id, from_id, to_id) VALUES 
    (26, 12, 13),  -- load_area_02 to load_area_03
    (27, 14, 13),  -- load_area_04 to load_area_03
    (28, 16, 17);  -- region_02 to region_03

-- Insert entities and transmission lines
INSERT INTO entities (id, entity_type, source_table, name, description, user_data) VALUES 
    (29, 'Line', 'transmission_lines', 'transmission_line1', 'First transmission line', json('{"voltage_level": 500, "line_type": "overhead", "conductor_type": "ACSR"}')),
    (30, 'Line', 'transmission_lines', 'transmission_line2', 'Second transmission line', json('{"voltage_level": 500, "line_type": "overhead", "conductor_type": "ACSR"}'));

INSERT INTO transmission_lines (id, arc_id, continuous_rating, ste_rating, lte_rating, line_length) VALUES 
    (29, 27, 175.0, 193.0, 200.0, 22.0), -- Using arc 27
    (30, 28, 175.0, 193.0, 200.0, 22.0); -- Using arc 28

-- Insert entities and supply technologies
INSERT INTO entities (id, entity_type, source_table, name, description, user_data) VALUES 
    (31, 'RenewableNonDispatch', 'supply_technologies', 'Supply Tech WT 1', 'Wind turbine investment option', json('{"investment_cost": 1200, "fixed_om_cost": 35, "variable_om_cost": 0}')),
    (32, 'RenewableNonDispatch', 'supply_technologies', 'Supply Tech WT 2', 'Wind turbine investment option (expensive)', json('{"investment_cost": 1500, "fixed_om_cost": 40, "variable_om_cost": 0}')),
    (33, 'ThermalStandard', 'supply_technologies', 'Supply Tech CT 1', 'Gas turbine investment option', json('{"investment_cost": 800, "fixed_om_cost": 45, "variable_om_cost": 35}')),
    (34, 'RenewableNonDispatch', 'supply_technologies', 'Supply Tech PV 1', 'Solar PV investment option', json('{"investment_cost": 1000, "fixed_om_cost": 20, "variable_om_cost": 0}'));

INSERT INTO supply_technologies (id, prime_mover, fuel, balancing_topology, scenario) VALUES 
    (31, 3, NULL, 15, NULL),        -- WT at region_01
    (32, 3, NULL, 15, 'Expensive'), -- WT at region_01, expensive
    (33, 1, 7, 15, 'Expensive'),    -- CT with NG at region_01, expensive
    (34, 6, NULL, 16, NULL);        -- PV at region_02

-- Insert entities and supplemental attributes
INSERT INTO entities (id, entity_type, source_table, name, description, user_data) VALUES 
    (35, 'SupplementalData', 'supplemental_attributes', 'Outage Data', 'Equipment outage information', json('{"data_type": "outage_schedule", "format": "array"}')),
    (36, 'SupplementalData', 'supplemental_attributes', 'Location Data', 'Geographic location data', json('{"data_type": "geolocation", "format": "coordinates"}'));

INSERT INTO supplemental_attributes (id, TYPE, value) VALUES 
    (35, 'outage', json('[0,1,2,3]')),
    (36, 'geolocation', json('{"lat": 30.5, "lon": -99.5}'));

-- Add supplemental attribute associations
INSERT INTO supplemental_attributes_association (attribute_id, entity_id) VALUES 
    (35, 12),  -- Outage data for load_area_02
    (36, 12);  -- Location data for load_area_02

-- Insert entities and loads
INSERT INTO entities (id, entity_type, source_table, name, description, user_data) VALUES 
    (37, 'PowerLoad', 'loads', 'Load 1', 'Load at urban area', json('{"load_type": "residential", "demand_response": false, "power_factor": 0.95}')),
    (38, 'PowerLoad', 'loads', 'Load 2', 'Load at rural area', json('{"load_type": "mixed", "demand_response": true, "power_factor": 0.92}')),
    (39, 'PowerLoad', 'loads', 'Load 3', 'Load at industrial area', json('{"load_type": "industrial", "demand_response": false, "power_factor": 0.88}')),
    (40, 'PowerLoad', 'loads', 'Load 4', 'Load at commercial area', json('{"load_type": "commercial", "demand_response": true, "power_factor": 0.93}'));

INSERT INTO loads (id, balancing_topology, base_power) VALUES 
    (37, 11, 1500.0), -- Load at load_area_01
    (38, 12, 1200.0), -- Load at load_area_02
    (39, 13, 2000.0), -- Load at load_area_03
    (40, 14, 800.0);  -- Load at load_area_04

-- Time series examples using the new time_series_associations table
INSERT INTO time_series_associations (
    time_series_uuid,
    time_series_type,
    name,
    initial_timestamp,
    resolution,
    horizon,
    interval,
    length,
    owner_uuid,
    owner_type,
    owner_category,
    features,
    scaling_factor_multiplier,
    units
) VALUES 
    -- Static time series for load
    (
        'ts-load-001',
        'static',
        'active_power_demand',
        '2025-01-01T00:00:00Z',
        'PT1H',
        NULL,
        'PT1H',
        24,
        '38',
        'PowerLoad',
        'asset',
        '{"weather_dependent": false}',
        '1.0',
        'MW'
    ),
    -- Deterministic forecast for generation
    (
        'ts-gen-forecast-001',
        'deterministic_forecast',
        'available_capacity',
        '2025-01-01T00:00:00Z',
        'PT1H',
        '24',
        'PT1H',
        24,
        '21',
        'RenewableNonDispatch',
        'asset',
        '{"weather_dependent": true}',
        '1.0',
        'MW'
    ),
    -- Monthly budget time series
    (
        'ts-budget-001',
        'static',
        'monthly_budget',
        '2025-01-01T00:00:00Z',
        'P1M',
        NULL,
        'P1M',
        12,
        '13',
        'LoadZone',
        'topology',
        '{"budget_type": "operational"}',
        '1.0',
        'USD'
    );

-- Insert static time series data
INSERT INTO static_time_series_data (time_series_id, timestamp, value) VALUES 
    -- Hourly load data for 24 hours (time_series_id = 1)
    (1, '2025-01-01T00:00:00Z', 1200.0), (1, '2025-01-01T01:00:00Z', 1150.0),
    (1, '2025-01-01T02:00:00Z', 1100.0), (1, '2025-01-01T03:00:00Z', 1050.0),
    (1, '2025-01-01T04:00:00Z', 1000.0), (1, '2025-01-01T05:00:00Z', 1050.0),
    (1, '2025-01-01T06:00:00Z', 1200.0), (1, '2025-01-01T07:00:00Z', 1400.0),
    (1, '2025-01-01T08:00:00Z', 1600.0), (1, '2025-01-01T09:00:00Z', 1650.0),
    (1, '2025-01-01T10:00:00Z', 1700.0), (1, '2025-01-01T11:00:00Z', 1750.0),
    (1, '2025-01-01T12:00:00Z', 1800.0), (1, '2025-01-01T13:00:00Z', 1750.0),
    (1, '2025-01-01T14:00:00Z', 1700.0), (1, '2025-01-01T15:00:00Z', 1650.0),
    (1, '2025-01-01T16:00:00Z', 1600.0), (1, '2025-01-01T17:00:00Z', 1700.0),
    (1, '2025-01-01T18:00:00Z', 1800.0), (1, '2025-01-01T19:00:00Z', 1750.0),
    (1, '2025-01-01T20:00:00Z', 1600.0), (1, '2025-01-01T21:00:00Z', 1500.0),
    (1, '2025-01-01T22:00:00Z', 1400.0), (1, '2025-01-01T23:00:00Z', 1300.0);

-- Insert deterministic forecast data (24-hour forecast as JSON array)
INSERT INTO deterministic_forecast_data (time_series_id, timestamp, forecast_values) VALUES (
    2, 
    '2025-01-01T00:00:00Z', 
    '[180.0, 185.0, 190.0, 195.0, 200.0, 195.0, 190.0, 180.0, 170.0, 160.0, 150.0, 140.0, 130.0, 135.0, 140.0, 145.0, 150.0, 155.0, 160.0, 165.0, 170.0, 175.0, 180.0, 185.0]'
);

-- Insert monthly budget data (time_series_id = 3)
INSERT INTO static_time_series_data (time_series_id, timestamp, value) VALUES 
    (3, '2025-01-01T00:00:00Z', 1000000.0), (3, '2025-02-01T00:00:00Z', 950000.0),
    (3, '2025-03-01T00:00:00Z', 1100000.0), (3, '2025-04-01T00:00:00Z', 1050000.0),
    (3, '2025-05-01T00:00:00Z', 1200000.0), (3, '2025-06-01T00:00:00Z', 1300000.0),
    (3, '2025-07-01T00:00:00Z', 1400000.0), (3, '2025-08-01T00:00:00Z', 1350000.0),
    (3, '2025-09-01T00:00:00Z', 1250000.0), (3, '2025-10-01T00:00:00Z', 1150000.0),
    (3, '2025-11-01T00:00:00Z', 1000000.0), (3, '2025-12-01T00:00:00Z', 900000.0);

-- Add some operational data examples
INSERT INTO operational_data (
    entity_id, active_power_limit_min, must_run, uptime, downtime, 
    ramp_up, ramp_down, operational_cost
) VALUES 
    (19, 50.0, 0, 4.0, 2.0, 10.0, 15.0, json('{"variable_cost": 35.5, "startup_cost": 1000.0}')),
    (20, 100.0, 1, 0.5, 0.25, 50.0, 50.0, json('{"variable_cost": 5.0, "startup_cost": 100.0}')),
    (21, 0.0, 0, 0.0, 0.0, 200.0, 200.0, json('{"variable_cost": 0.0, "startup_cost": 0.0}')),
    (22, 0.0, 0, 0.0, 0.0, 100.0, 100.0, json('{"variable_cost": 0.0, "startup_cost": 0.0}'));

-- Add some attributes examples
INSERT INTO attributes (entity_id, TYPE, name, value) VALUES 
    (19, 'cost', 'variable_om_cost', json('25.5')),
    (20, 'cost', 'variable_om_cost', json('15.0')),
    (21, 'cost', 'variable_om_cost', json('5.0')),
    (22, 'cost', 'variable_om_cost', json('8.0')),
    (19, 'cost', 'fixed_om_cost', json('50000.0')),
    (20, 'cost', 'fixed_om_cost', json('75000.0')),
    (21, 'cost', 'fixed_om_cost', json('25000.0')),
    (22, 'cost', 'fixed_om_cost', json('30000.0'));

COMMIT;
