-- DISCLAIMER
-- The current version of this schema only works for SQLITE >=3.45
-- When adding new functionality, think about the following:
--      1. Simplicity and ease of use over complexity,
--      2. Clear, consice and strict fields but allow for extensability,
--      3. User friendly over peformance, but consider performance always,


-- WARNING: This script should only be used while testing the schema and should not
-- be applied to existing dataset since it drops all the information it has.
drop table if exists generation_units;
drop table if exists storage_units;
drop table if exists prime_movers;
drop table if exists balancing_topologies;
drop table if exists supply_technologies;
drop table if exists storage_technologies;
drop table if exists transmission_lines;
drop table if exists demand_requirements;
drop table if exists planning_regions;
drop table if exists attributes;
drop table if exists data_types;
drop table if exists time_series;
drop table if exists transmission_interchange;
drop table if exists entities;
drop table if exists time_series_associations;
drop table if exists time_series_metadata;
drop table if exists single_time_series;
drop table if exists deterministic_time_series;
drop table if exists probabilistic_time_series;
drop table if exists operational_data;
drop table if exists attributes;
drop table if exists supplemental_attributes;
drop table if exists attributes_associations;

-- NOTE: This table should not be interacted directly since it gets populated
-- automatically.
-- Table of certain entities of griddb schema.
create table entities (
  id integer primary key
  ,entity_type text not null
  ,entity_id integer not null
  ,unique (id, entity_id, entity_type)
);

-- NOTE: Sienna-griddb follows the convention of the EIA prime mover where we
-- have a `prime_mover` and `fuel` to classify generators/storage units.
-- However, users could use any combination of `prime_mover` and `fuel` for
-- their own application. The only constraint is that the uniqueness is enforced
-- by the combination of (prime_mover, fuel)
-- Categories to classify generating units and supply technologies
create table  prime_movers (
        id integer primary key
        ,prime_mover text not null
        ,fuel text null
        ,description text null
        ,unique (prime_mover, fuel)
);

-- Investment regions
create table planning_regions (
  id integer primary key
  ,name text not null unique
  ,description text null
);

-- Balancing topologies for the system. Could be either buses, or larger
-- aggregated regions.
create table balancing_topologies (
  id integer primary key
  ,name text not null unique
  ,area text null references planning_regions (name)
  ,participation_factor real default 1.0 not null check (
    participation_factor >= 0
    and participation_factor <= 1
  )
  ,description text null
);

-- NOTE: The purpose of this table is to provide links different entities that
-- naturally have a relantionship not model dependent (e.g., transmission lines,
-- transmission interchanges, etc.).
-- Physical connection between entities.
create table arcs (
  id integer primary key
  ,from_to int
  ,to_from int
  ,foreign key (from_to) references entities (id)
  ,foreign key (to_from) references entities (id)
);

-- Existing transmission lines
create table transmission_lines (
  id integer primary key
  ,arc_id int
  ,continuous_rating real not null check (continuous_rating >= 0)
  ,ste_rating real not null check (ste_rating >= 0)
  ,lte_rating real not null check (lte_rating >= 0)
  ,line_length real not null check (line_length >= 0)
  ,foreign key (arc_id) references arcs (id)
) strict;

-- NOTE: The purpose of this table is to provide physical limits to flows
-- between areas or balancing topologies. In contrast with the transmission
-- lines, this entities are used to enforce given physical limits of certain
-- markets.
-- Transmission interchanges between two balancing topologies or areas
create table transmission_interchange (
        arc_id int references arcs(id)
        ,max_flow_from real not null
	,max_flow_to real not null
) strict;

-- NOTE: The purpose of this table is to capture data of **existing units only**.
-- Table of generation units
create table generation_units (
   id integer primary key
  ,name text not null
  ,prime_mover text not null
  ,fuel text null
  ,balancing_topology text not null references balancing_topologies (name)
  ,start_year integer not null check (start_year >= 0)
  ,rating real check (rating > 0) default 1.0
  ,base_power real not null check (base_power > 0)
  ,foreign key (prime_mover, fuel) references prime_movers (prime_mover, fuel)
  ,check (base_power >= rating)
  ,unique (id, name)
) strict;

-- NOTE: The purpose of this table is to capture data of **existing storage units only**.
-- Table of energy storage units (including PHES or other kinds),
create table storage_units (
  id integer primary key
  ,name text not null
  ,prime_mover text not null
  ,max_capacity real not null check (max_capacity > 0) -- Energy capacity
  ,balancing_topology text not null references balancing_topologies (name)
  ,charging_efficiency real check (
    charging_efficiency > 0
    and charging_efficiency <= 1.0
  ) default 1.0
  ,discharge_efficiency real check (
    discharge_efficiency > 0
    and discharge_efficiency <= 1.0
  ) default 1.0
  ,round_trip_efficiency  real generated always as (charging_efficiency * discharge_efficiency) virtual
  ,start_year integer not null check (start_year >= 0)
  ,rating real not null default 1 check (rating > 0)
  ,base_power real not null check (base_power > 0)
  ,check (base_power >= rating)
  ,unique(name)
) strict;

-- NOTE: The purpose of this table is to capture technologies available for
-- investment for expansion problems.
-- Investment technology options for expansion problems
create table supply_technologies (
  id integer primary key
  ,prime_mover text not null
  ,fuel text null
  ,area text null references planning_regions (name)
  ,balancing_topology text null references balancing_topologies (name)
  ,vom_cost real not null check (vom_cost >= 0)
  ,fom_cost real not null check (fom_cost >= 0)
  ,scenario text null
  ,foreign key (prime_mover, fuel) references prime_movers(prime_mover, fuel)
);

-- NOTE: The purpose of this table is to link operational parameters to multiple
-- entities like existing units (real paramters) or supply technologies
-- (expected parameters).
-- The same operational data could be attached to multiple entities.
create table operational_data (
  id integer primary key
  ,entity_id integer not null
  ,fom_cost real not null check (fom_cost >= 0)
  ,vom_cost real not null check (vom_cost >= 0)
  ,startup_cost real not null check (startup_cost >= 0)
  ,min_stable_level real not null check (min_stable_level >= 0)
  ,mttr integer not null check (mttr >= 0)
  ,startup_fuel_mmbtu_per_mw real not null check (startup_fuel_mmbtu_per_mw >= 0)
  ,uptime real not null check (uptime >= 0)
  ,downtime real not null check (downtime >= 0)

  -- Could overtake some of the fields here.
  ,operational_cost jsonb null

  -- Enforce unique constraint
  ,foreign key (entity_id) references entities(id)
);

-- NOTE: Attributes are additional parameters that can be linked to entities.
-- The main purpose of this is when there is an important field that is not
-- capture on the entity table that should exist on the model. Example of this
-- fields are variable or fixed operation and maintenance cost or any other
-- field that its representation is hard to fit into a `integer`, `real` or
-- `texrt`. `It must not be used for operational details since most of the should
-- be included in the `operational_data` table.
-- Table with additional (not supplemental) atttributes
create table attributes (
  id integer primary key
  ,type text not null
  ,name text not null
  ,value jsonb not null
  ,json_type text generated always  as (json_type(value)) virtual
);

-- association table between attributes and entities
create table attributes_associations (
  attribute_id integer not null
  ,entity_id integer not null
  ,foreign key (entity_id) references entities (id)
  ,foreign key (attribute_id) references attributes (id)
  ,unique(attribute_id, entity_id)
) strict;

-- create supplemental atttributes
create table supplemental_attributes (
  id integer primary key
  ,type text not NULL
  ,value jsonb not null
  ,json_type text generated always as (json_type (value)) virtual
);

create table supplemental_attributes_association (
  attribute_id integer not null
  ,entity_id integer not null
  ,foreign key (entity_id) references entities (id)
  ,foreign key (attribute_id) references supplemental_attributes (id)
) strict;

create table time_series (
  id integer primary key
  ,uuid text null
  ,time_series_type text not null
  ,name text not null
  ,initial_timestamp datetime not NULL
  ,resolution_ms integer not NULL
  ,horizon integer not null
  ,interval integer not null
  ,length integer not null
  ,features jsonb null
  ,metadata jsonb null
);

-- associate time series with entities or attributes
create table time_series_associations (
  id integer primary key
  ,time_series_id integer not null
  ,owner_id integer not NULL
  ,foreign key (owner_id) references entities (id)
  ,foreign key (time_series_id) references time_series (id)
) strict;

-- From Sienna docs:
-- A static time series data is a single column of data where each time period has
-- a single value assigned to a component field, such as its maximum active power.
-- This data commonly is obtained from historical information or the realization
-- of a time-varying quantity.
create table static_time_series (
  id integer primary key
  ,time_series_id integer not null
  ,uuid text null
  ,timestamp integer not null
  ,value real not null
  ,foreign key (time_series_id) references time_series (id)
);

--  A deterministic time series represent forecast that data that usually comes
--  in the following format, where a column represents the time stamp
--  associated with the initial time of the forecast, and the remaining columns
--  represent the forecasted values at each step in the forecast horizon.
create table deterministic_time_series (
  id integer primary key
  ,time_series_id integer not null
  ,uuid text null
  ,timestamp datetime not null
  ,value jsonb not null
  ,foreign key (time_series_id) references time_series (id)
);

create table probabilistic_time_series (
  id integer primary key
  ,time_series_id integer not null
  ,uuid text null
  ,timestamp datetime not null
  ,value real not null
  ,foreign key (time_series_id) references time_series (id)
);

-- View sections
CREATE VIEW deterministic_time_series_view AS
WITH json_data AS (
  SELECT
    deterministic_time_series.time_series_id
    ,deterministic_time_series.id
    ,deterministic_time_series.timestamp
    ,json_each.value
    ,ROW_NUMBER() OVER (PARTITION BY deterministic_time_series.id ORDER BY json_each.value) AS horizon
  FROM deterministic_time_series, json_each(deterministic_time_series.value)
)
SELECT time_series_id, id, timestamp, horizon, value
FROM json_data;


-- Trigger section
CREATE TRIGGER IF not EXISTS autofill_supply
AFTER INSERT ON supply_technologies
BEGIN
    INSERT INTO entities(entity_type, entity_id) VALUES("supply_technologies", new.id);
END;

CREATE TRIGGER IF not EXISTS autofill_generation_units
AFTER INSERT ON generation_units
BEGIN
	INSERT INTO entities(entity_type, entity_id) VALUES("generation_units", new.id);
END;

CREATE TRIGGER IF not EXISTS autofill_storage_units
AFTER INSERT ON storage_units
BEGIN
	INSERT INTO entities(entity_type, entity_id) VALUES("storage_units", new.id);
END;

CREATE TRIGGER IF not EXISTS autofill_areas
AFTER INSERT ON planning_regions
BEGIN
	INSERT INTO entities(entity_type, entity_id) VALUES("planning_regions", new.id);
END;

CREATE TRIGGER IF not EXISTS autofill_topologies
AFTER INSERT ON balancing_topologies
BEGIN
	INSERT INTO entities(entity_type, entity_id) VALUES("balancing_topologies", new.id);
END;

CREATE TRIGGER IF not EXISTS autofill_attributes
AFTER INSERT ON supplemental_attributes
BEGIN
	INSERT INTO entities(entity_type, entity_id) VALUES("supplemental_attributes", new.id);
END;

CREATE TRIGGER IF not EXISTS autofill_attributes
AFTER INSERT ON attributes
BEGIN
	INSERT INTO entities(entity_type, entity_id) VALUES("attribute", new.id);
END;

-- Create a trigger that runs after inserting into the arcs table
CREATE TRIGGER enforce_arc_entity_types_insert
AFTER INSERT ON arcs
BEGIN
    -- Check if the from_to entity has a valid type
    SELECT CASE
        WHEN (SELECT entity_type FROM entities WHERE id = NEW.from_to)
             NOT IN ('balancing_topologies', 'planning_regions')
        THEN RAISE(ABORT, 'Invalid from_to entity type')
    END;

    -- Check if the to_from entity has a valid type
    SELECT CASE
        WHEN (SELECT entity_type FROM entities WHERE id = NEW.to_from)
             NOT IN ('balancing_topologies', 'planning_regions')
        THEN RAISE(ABORT, 'Invalid to_from entity type')
    END;
END;

-- Safety mechanism to force json arrays
-- CREATE TRIGGER enforce_json_array_value_on_deterministic_time_series
-- BEFORE INSERT ON deterministic_time_series
-- FOR EACH ROW
-- WHEN NOT (json_valid(NEW.value) AND json_type(NEW.value, '$') = 'array')
-- BEGIN
--     SELECT RAISE(ABORT, 'Value must be a valid JSON array');
-- END;
