PRAGMA foreign_keys = ON;

INSERT INTO prime_mover_types (name, description)
VALUES ('CT', "[C]ombustion [T]urbine"),
    ('HY', "[HY]droelectric"),
    ('WT', "[W]ind [T]urbine"),
    ('BA', "Energy Storage, [BA]ttery"),
    ('PS', "[P]ump [S]torage"),
    ('PV', "[P]hoto[V]oltaic");

INSERT INTO fuels(name, description)
VALUES ("NG", "[N]atural [G]as"),
    ("Oil", "Oil");

INSERT INTO entities (id, entity_type)
VALUES (0, 'planning_regions'),
    (1, 'planning_regions');

-- Areas are the higher level aggregation of balancing topologies
INSERT INTO planning_regions (id, name, description)
VALUES (0, 'North', 'Northern region'),
    (1, 'South', 'Southern region');

INSERT INTO entities (id, entity_type)
VALUES (2, 'balancing_topologies'),
    (3, 'balancing_topologies'),
    (4, 'balancing_topologies'),
    (5, 'balancing_topologies'),
    (6, 'balancing_topologies'),
    (7, 'balancing_topologies'),
    (8, 'balancing_topologies'),
    (9, 'balancing_topologies');

-- Balancing topologies are the lower level aggregation of generation units
INSERT INTO balancing_topologies (id, name, area, description)
VALUES (
        2,
        'load_area_01',
        0,
        'Urban area with high power demand'
    ),
    (
        3,
        'load_area_02',
        1,
        'Rural area with moderate power demand'
    ),
    (
        4,
        'load_area_03',
        0,
        'Industrial area with heavy power consumption'
    ),
    (
        5,
        'load_area_04',
        1,
        'Commercial area with varying power requirements'
    ),
    (
        6,
        'region_01',
        0,
        'Urban area with generation from Natural Gas'
    ),
    (
        7,
        'region_02',
        1,
        'Rural area with generation from hydro'
    ),
    (
        8,
        'region_03',
        0,
        'Industrial area with generation from solar and storage'
    ),
    (
        9,
        'region_04',
        1,
        'Commercial area with generation from wind and storage'
    );

INSERT INTO entities (id, entity_type)
VALUES (10, 'generation_units'),
    (11, 'generation_units'),
    (12, 'generation_units'),
    (13, 'generation_units');

-- Inserting data for generation units
INSERT INTO generation_units (
        id,
        name,
        prime_mover,
        fuel,
        balancing_topology,
        rating,
        base_power
    )
VALUES (10, 'Unit 1', 'CT', 'NG', 6, 1, 200),
    (11, 'Unit 2', 'HY', NULL, 7, 1, 300),
    (12, 'Unit 3', 'PV', NULL, 8, 1, 200),
    (13, 'Unit 4', 'WT', NULL, 9, 1, 200);

INSERT INTO entities (id, entity_type)
VALUES (14, 'storage_units'),
    (15, 'storage_units'),
    (16, 'storage_units');

-- Inserting data for storage units
INSERT INTO storage_units (
        id,
        name,
        prime_mover,
        max_capacity,
        efficiency_up,
        balancing_topology,
        rating,
        base_power
    )
VALUES (
        14,
        'Storage Unit 2',
        "PS",
        600.0,
        1.0,
        9,
        1,
        300
    ),
    (
        15,
        'Storage Unit 3',
        "PS",
        900.0,
        0.95,
        8,
        1,
        300
    ),
    (
        16,
        'Storage Unit 4',
        "PS",
        1200.0,
        1.0,
        7,
        1,
        300
    );

INSERT INTO entities (id, entity_type)
VALUES (17, 'arcs'),
    (18, 'arcs'),
    (19, 'arcs');

-- Insert some arcs
INSERT INTO arcs (id, from_id, to_id)
VALUES (17, 3, 4);

INSERT INTO arcs (id, from_id, to_id)
VALUES (18, 5, 4);

INSERT INTO arcs (id, from_id, to_id)
VALUES (19, 7, 8);

INSERT INTO entities (id, entity_type)
VALUES (20, 'transmission_lines'),
    (21, 'transmission_lines');

-- Inserting data for transmission lines
INSERT INTO transmission_lines (
        id,
        name,
        arc_id,
        continuous_rating,
        ste_rating,
        lte_rating,
        line_length
    )
VALUES (
        20,
        "transmission_line1",
        18,
        175.0,
        193.0,
        200.0,
        22.0
    ),
    (
        21,
        "transmission_line2",
        19,
        175.0,
        193.0,
        200.0,
        22.0
    );

INSERT INTO entities (id, entity_type)
VALUES (22, 'supply_technologies'),
    (23, 'supply_technologies'),
    (24, 'supply_technologies'),
    (25, 'supply_technologies');

-- Inserting data for investment technologies
INSERT INTO supply_technologies (
        id,
        prime_mover,
        fuel,
        balancing_topology,
        scenario
    )
VALUES (22, "WT", NULL, "region_01", NULL),
    (23, "WT", NULL, "region_01", "Expensive"),
    (24, "CT", "NG", "region_01", "Expensive"),
    (25, "PV", NULL, "region_02", NULL);

INSERT INTO entities (id, entity_type)
VALUES (26, 'supplemental_attributes'),
    (27, 'supplemental_attributes');

-- Supplemental attributes
INSERT INTO supplemental_attributes (id, TYPE, value)
VALUES (26, 'outage', json("[0,1,2,3]"));

INSERT INTO supplemental_attributes (id, TYPE, value)
VALUES (
        27,
        'geolocation',
        json("{'lat': 30.5, 'lon': -99.5}")
    );

-- Add supplemental attribute to some entities
INSERT INTO supplemental_attributes_association (attribute_id, entity_id)
VALUES (26, 3);

-- Add time series examples
INSERT INTO time_series (
        time_series_uuid,
        time_series_type,
        name,
        initial_timestamp,
        resolution,
        horizon,
        INTERVAL,
        length,
        owner_id
    )
VALUES -- Hourly time series for a day (24 points)
    (
        '0',
        'SingleTimeSeries',
        'active_power',
        '2025-01-01 00:00:00',
        3600,
        1,
        1,
        12,
        3
    ),
    (
        '1',
        'DeterministicTimeSeries',
        'active_power',
        '2025-01-01 00:00:00',
        43200000,
        4,
        1,
        24,
        3
    ),
    (
        '2',
        'SingleTimeSeries',
        'montly_budget',
        '2025-01-01 00:00:00',
        2592000000,
        1,
        1,
        12,
        4
    ),
    (
        '3',
        'SingleTimeSeries',
        'investment',
        '2025-01-01 00:00:00',
        2592000000,
        1,
        1,
        1,
        10
    );
