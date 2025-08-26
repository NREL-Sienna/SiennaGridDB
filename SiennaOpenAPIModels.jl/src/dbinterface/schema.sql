-- DISCLAIMER
-- The current version of this schema only works for SQLITE >=3.45
-- When adding new functionality, think about the following:
--      1. Simplicity and ease of use over complexity,
--      2. Clear, consice and strict fields but allow for extensability,
--      3. User friendly over peformance, but consider performance always,
-- WARNING: This script should only be used while testing the schema and should not
-- be applied to existing dataset since it drops all the information it has.
DROP TABLE IF EXISTS generation_units;

DROP TABLE IF EXISTS storage_units;

DROP TABLE IF EXISTS prime_mover_types;

DROP TABLE IF EXISTS balancing_topologies;

DROP TABLE IF EXISTS supply_technologies;

DROP TABLE IF EXISTS storage_technologies;

DROP TABLE IF EXISTS transmission_lines;

DROP TABLE IF EXISTS planning_regions;

DROP TABLE IF EXISTS transmission_interchanges;

DROP TABLE IF EXISTS entities;

DROP TABLE IF EXISTS time_series_associations;

DROP TABLE IF EXISTS operational_data;

DROP TABLE IF EXISTS attributes;

DROP TABLE IF EXISTS supplemental_attributes;

DROP TABLE IF EXISTS attributes_associations;

DROP TABLE IF EXISTS arcs;

DROP TABLE IF EXISTS hydro_reservoir;

DROP TABLE IF EXISTS hydro_reservoir_connections;

DROP TABLE IF EXISTS fuels;

DROP TABLE IF EXISTS supplemental_attributes_association;

DROP TABLE IF EXISTS transport_technologies;

-- NOTE: This table should not be interacted directly since it gets populated
-- automatically.
-- Table of certain entities of griddb schema.
CREATE TABLE entities (
    id integer PRIMARY KEY,
    entity_table text NOT NULL,
    entity_type text NOT NULL,
    FOREIGN KEY (entity_type) REFERENCES entity_types (name)
);

-- Table of possible entity types
CREATE TABLE entity_types (name text PRIMARY KEY);

-- NOTE: Sienna-griddb follows the convention of the EIA prime mover where we
-- have a `prime_mover` and `fuel` to classify generators/storage units.
-- However, users could use any combination of `prime_mover` and `fuel` for
-- their own application. The only constraint is that the uniqueness is enforced
-- by the combination of (prime_mover, fuel)
-- Categories to classify generating units and supply technologies
CREATE TABLE prime_mover_types (
    id integer PRIMARY KEY,
    name text NOT NULL,
    description text NULL,
    UNIQUE(name)
);

CREATE TABLE fuels(
    id integer PRIMARY KEY,
    name text NOT NULL,
    description text NULL,
    UNIQUE (name)
);

-- Investment regions
CREATE TABLE planning_regions (
    id integer PRIMARY KEY REFERENCES entities (id),
    name text NOT NULL UNIQUE,
    description text NULL
);

-- Balancing topologies for the system. Could be either buses, or larger
-- aggregated regions.
CREATE TABLE balancing_topologies (
    id integer PRIMARY KEY REFERENCES entities (id),
    name text NOT NULL UNIQUE,
    area integer NULL REFERENCES planning_regions (id),
    description text NULL
);

-- NOTE: The purpose of this table is to provide links different entities that
-- naturally have a relantionship not model dependent (e.g., transmission lines,
-- transmission interchanges, etc.).
-- Physical connection between entities.
CREATE TABLE arcs (
    id integer PRIMARY KEY REFERENCES entities (id),
    from_id integer,
    to_id integer,
    FOREIGN KEY (from_id) REFERENCES entities (id),
    FOREIGN KEY (to_id) REFERENCES entities (id)
);

-- Existing transmission lines
CREATE TABLE transmission_lines (
    id integer PRIMARY KEY REFERENCES entities (id),
    name text NOT NULL UNIQUE,
    arc_id integer,
    continuous_rating real NULL CHECK (continuous_rating >= 0),
    ste_rating real NULL CHECK (ste_rating >= 0),
    lte_rating real NULL CHECK (lte_rating >= 0),
    line_length real NULL CHECK (line_length >= 0),
    FOREIGN KEY (arc_id) REFERENCES arcs (id)
) strict;

-- NOTE: The purpose of this table is to provide physical limits to flows
-- between areas or balancing topologies. In contrast with the transmission
-- lines, this entities are used to enforce given physical limits of certain
-- markets.
-- Transmission interchanges between two balancing topologies or areas
CREATE TABLE transmission_interchanges (
    id integer PRIMARY KEY REFERENCES entities (id),
    name text NOT NULL UNIQUE,
    arc_id int REFERENCES arcs(id),
    max_flow_from real NOT NULL,
    max_flow_to real NOT NULL
) strict;

-- NOTE: The purpose of this table is to capture data of **existing units only**.
-- Table of generation units
CREATE TABLE generation_units (
    id integer PRIMARY KEY REFERENCES entities (id),
    name text NOT NULL,
    prime_mover text NOT NULL REFERENCES prime_mover_types(name),
    fuel text NULL REFERENCES fuels(name),
    balancing_topology integer NOT NULL REFERENCES balancing_topologies (id),
    rating real NOT NULL CHECK (rating >= 0),
    base_power real NOT NULL CHECK (base_power > 0),
    --CHECK (base_power >= rating),
    UNIQUE (name)
) strict;

-- NOTE: The purpose of this table is to capture data of **existing storage units only**.
-- Table of energy storage units (including PHES or other kinds),
CREATE TABLE storage_units (
    id integer PRIMARY KEY REFERENCES entities (id),
    name text NOT NULL,
    prime_mover text NOT NULL REFERENCES prime_mover_types(name),
    -- Energy capacity
    max_capacity real NOT NULL,
    balancing_topology integer NOT NULL REFERENCES balancing_topologies (id),
    efficiency_up real CHECK (
        efficiency_up > 0
        AND efficiency_up <= 1.0
    ) DEFAULT 1.0,
    efficiency_down real CHECK (
        efficiency_down > 0
        AND efficiency_down <= 1.0
    ) DEFAULT 1.0,
    rating real NOT NULL DEFAULT 1 CHECK (rating > 0),
    base_power real NOT NULL CHECK (base_power > 0),
    --CHECK (base_power >= rating),
    UNIQUE(name)
) strict;

CREATE TABLE hydro_reservoir(
    id integer PRIMARY KEY REFERENCES entities (id),
    name text NOT NULL,
    UNIQUE(name)
);

CREATE TABLE hydro_reservoir_connections(
    turbine_id integer NOT NULL REFERENCES entities(id),
    reservoir_id integer NOT NULL REFERENCES hydro_reservoir(id)
);

-- NOTE: The purpose of this table is to capture technologies available for
-- investment for expansion problems.
-- Investment technology options for expansion problems
CREATE TABLE supply_technologies (
    id integer PRIMARY KEY REFERENCES entities (id),
    prime_mover text NOT NULL REFERENCES prime_mover_types(name),
    fuel text NULL REFERENCES fuels(name),
    area text NULL REFERENCES planning_regions (name),
    balancing_topology text NULL REFERENCES balancing_topologies (name),
    scenario text NULL,
    UNIQUE(prime_mover, fuel, scenario)
);

CREATE TABLE transport_technologies(
    id integer PRIMARY KEY REFERENCES entities (id),
    arc_id integer NULL REFERENCES arcs(id),
    scenario text NULL,
    UNIQUE(id, arc_id, scenario)
);

-- NOTE: The purpose of this table is to link operational parameters to multiple
-- entities like existing units (real paramters) or supply technologies
-- (expected parameters).
-- The same operational data could be attached to multiple entities.
CREATE TABLE operational_data (
    id integer PRIMARY KEY,
    entity_id integer NOT NULL,
    active_power_limit_min real NOT NULL CHECK (active_power_limit_min >= 0),
    must_run bool,
    uptime real NOT NULL CHECK (uptime >= 0),
    downtime real NOT NULL CHECK (downtime >= 0),
    ramp_up real NOT NULL,
    ramp_down real NOT NULL,
    operational_cost json NULL,
    -- We can add what type of operational cost it is or other parameters (e.g., variable)
    operational_cost_type text generated always AS (json_type(operational_cost)) virtual,
    FOREIGN KEY (entity_id) REFERENCES entities(id)
);


-- NOTE: Attributes are additional parameters that can be linked to entities.
-- The main purpose of this is when there is an important field that is not
-- capture on the entity table that should exist on the model. Example of this
-- fields are variable or fixed operation and maintenance cost or any other
-- field that its representation is hard to fit into a `integer`, `real` or
-- `text`. It must not be used for operational details since most of the should
-- be included in the `operational_data` table.
CREATE TABLE attributes (
    id integer PRIMARY KEY,
    entity_id integer NOT NULL,
    TYPE text NOT NULL,
    name text NOT NULL,
    value json NOT NULL,
    json_type text generated always AS (json_type(value)) virtual,
    FOREIGN KEY (entity_id) REFERENCES entities (id)
);

-- NOTE: Supplemental are optional parameters that can be linked to entities.
-- The main purpose of this is to provide a way to save relevant information
-- but that could or could not be used for modeling. not `text`. Examples of
-- this field are geolocation (e.g., lat, long), outages, etc.)
CREATE TABLE supplemental_attributes (
    id integer PRIMARY KEY REFERENCES entities (id),
    TYPE text NOT NULL,
    value json NOT NULL,
    json_type text generated always AS (json_type (value)) virtual
);

CREATE TABLE supplemental_attributes_association (
    attribute_id integer NOT NULL,
    entity_id integer NOT NULL,
    FOREIGN KEY (entity_id) REFERENCES entities (id),
    FOREIGN KEY (attribute_id) REFERENCES supplemental_attributes (id)
) strict;

CREATE TABLE time_series_associations(
    id INTEGER PRIMARY KEY,
    time_series_uuid TEXT NOT NULL,
    time_series_type TEXT NOT NULL,
    initial_timestamp TEXT NOT NULL,
    resolution TEXT NOT NULL,
    horizon TEXT,
    "interval" TEXT,
    window_count INTEGER,
    length INTEGER,
    name TEXT NOT NULL,
    owner_id INTEGER NOT NULL REFERENCES entities(id),
    owner_type TEXT NOT NULL,
    owner_category TEXT NOT NULL,
    features TEXT NOT NULL,
    scaling_factor_multiplier TEXT NULL,
    metadata_uuid TEXT NOT NULL,
    units TEXT NULL
);
CREATE UNIQUE INDEX "by_c_n_tst_features" ON "time_series_associations" (
    "owner_id",
    "time_series_type",
    "name",
    "resolution",
    "features"
);
CREATE INDEX "by_ts_uuid" ON "time_series_associations" ("time_series_uuid");


CREATE TABLE loads (
    id integer PRIMARY KEY REFERENCES entities (id),
    name TEXT NOT NULL UNIQUE,
    balancing_topology INTEGER NOT NULL,
    base_power DOUBLE,
    FOREIGN KEY(balancing_topology) REFERENCES balancing_topologies (id)
);

CREATE TABLE static_time_series (
    id integer PRIMARY KEY,
    uuid text NULL,
    idx integer NOT NULL,
    value real NOT NULL
);
