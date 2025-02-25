-- drop tables if they exist
drop table if exists generation_units;
drop table if exists storage_units;
drop view if exists unit_attributes;
drop view if exists unit_time_series;
drop table if exists prime_mover_types;
drop table if exists balancing_topologies;
drop table if exists supply_technologies;
drop table if exists storage_technologies;
drop table if exists transmission_lines;
drop table if exists demand_requirements;
drop table if exists areas;
drop table if exists attributes;
drop table if exists data_types;
drop table if exists time_series;
drop table if exists piecewise_linear;
drop table if exists transmission_interchange;
drop table if exists entities;
drop table if exists linkages;
drop table if exists reserves;
drop table if exists operational_data;

-- only generation units
create table  generation_units (
	unit_id integer primary key,
	name text not null unique,
	prime_mover text not null,
	fuel_type text not null,
	balancing_topology text not null references balancing_topologies(name),
	start_year integer not null check (start_year >= 0),
	rating float not null check (rating > 0 ),
	base_power float not null check (base_power > 0),
	check (base_power >= rating),
	foreign key (prime_mover, fuel_type) references prime_mover_types(prime_mover, fuel_type)
);

-- only storge units
create table  storage_units (
	storage_unit_id integer primary key,
	name text not null unique,
	prime_mover text not null,
	fuel_type text not null,
	max_capacity float not null check (max_capacity > 0),
	round_trip_efficiency float check (round_trip_efficiency >= 0),
	balancing_topology text not null references balancing_topologies(name),
	charging_efficiency float not null check (charging_efficiency > 0),
	discharge_efficiency float not null check (discharge_efficiency > 0),
	start_year integer not null check (start_year >= 0),
	rating float not null default 1 check (rating > 0 ),
	base_power float not null check (base_power > 0),
	scenario text null,
	check (base_power >= rating),
	foreign key (prime_mover, fuel_type) references prime_mover_types(prime_mover, fuel_type)
);

-- create table for technologies, perhaps change the name to investment_technologies
create table supply_technologies (
    technology_id integer primary key,
    prime_mover text not null,
	  fuel_type text not null,
	  technology_class real null,
    vom_cost float not null check (vom_cost >= 0),
    fom_cost float not null check (fom_cost >= 0),
    scenario text null,
	  area text null references areas(name),
	  balancing_topology text null references balancing_topologies(name),
	  foreign key (prime_mover, fuel_type) references prime_mover_types(prime_mover, fuel_type)
);

create table storage_technologies (
	storage_unit_id integer primary key,
	name text not null unique,
	prime_mover text not null,
	fuel_type text not null,
	scenario text null,
	area text null references areas(name),
	balancing_topology text null references balancing_topologies(name),
	foreign key (prime_mover, fuel_type) references prime_mover_types(prime_mover, fuel_type)
);


create table operational_data (
	unit_id references generation_units(unit_id),
	fom_cost float not null check (fom_cost >= 0),
	vom_cost float not null check (vom_cost >=0),
	forced_outage float not null,
	startup_cost float not null check (startup_cost >= 0),
	min_stable_level float not null check (min_stable_level >= 0),
	mttr integer not null check (mttr >= 0),
	startup_fuel_mmbtu_per_mw float not null check (startup_fuel_mmbtu_per_mw >= 0),
	uptime float not null check (uptime >= 0),
	downtime float not null check (downtime >= 0)
);

-- create table for prime movers
create table  prime_mover_types (
	prime_mover text not null,
	fuel_type text not null,
	description text null,
	primary key (prime_mover, fuel_type)
);

-- create table for balancing topologies
create table balancing_topologies (
	name text not null primary key,
	area text null references areas(name),
	participation_factor float default 1.0 not null check (participation_factor >= 0 and participation_factor <= 1),
	description text null
);

-- change to planning regions
create table  areas (
	name text not null primary key,
	description text null
);

-- electrical information of the lines
create table  transmission_lines (
	balancing_topology_from text references balancing_topologies(name),
	balancing_topology_to text references balancing_topologies(name),
	area_from text references areas(name),
	area_to text references areas(name),
	continuous_rating float not null check(continuous_rating >= 0),
	ste_rating float not null check (ste_rating >=0),
	lte_rating float not null check (lte_rating >=0),
	line_length float not null check (line_length >= 0)
);


-- ) strict;
-- flow between two regions
create table  transmission_interchange (
	area_from text not null references areas(name),
	area_to text not null references areas(name),
	max_flow_from float not null,
	max_flow_to float not null
);

-- create load input table, at some point need to add the growth rate
create table  demand_requirements (
	entity_attribute_id integer primary key,
	peak_load float not null,
	area text references areas(name),
	balancing_topology text references balancing_topologies(name)
);

-- create entity-attribute table
create table attributes (
	entity_attribute_id integer primary key,
	entity_id integer not null,
	entity_type text not null,
	name text not null,
	value any null,
	data_type text not null references data_types(name),
	foreign key (entity_type) references table_names(name),
    check (name != 'entity_id')
);

create table data_types(
	name text not null primary key,
	validation_query text,
	description text null
);

create table reserves(
    id integer primary key,
    time_frame float not null,
    requirement float not null,
    direction text not null
);

-- Entities gets populated automatically once there is an insert on the core tables.
create table entities(
	id integer primary key,
	entity_type text not null references table_names(name),
	entity_id integer not null
);



CREATE TRIGGER IF NOT EXISTS autofill_supply
AFTER INSERT ON supply_technologies
BEGIN
    INSERT INTO entities(entity_type, entity_id) VALUES("supply_technologies", new.technology_id);
END;

CREATE TRIGGER IF NOT EXISTS autofill_generation_units
AFTER INSERT ON generation_units
BEGIN
	INSERT INTO entities(entity_type, entity_id) VALUES("generation_units", new.unit_id);
END;

CREATE TRIGGER IF NOT EXISTS autofill_storage_units
AFTER INSERT ON storage_units
BEGIN
	INSERT INTO entities(entity_type, entity_id) VALUES("storage_units", new.storage_unit_id);
END;

CREATE TRIGGER IF NOT EXISTS autofill_storage_technologies
AFTER INSERT ON storage_technologies
BEGIN
	INSERT INTO entities(entity_type, entity_id) VALUES("storage_technologies", new.storage_unit_id);
END;

CREATE TRIGGER IF NOT EXISTS autofill_reserves
AFTER INSERT ON reserves
BEGIN
    INSERT INTO entities(entity_type, entity_id) VALUES("reserves", new.id);
END;

-- Create function data table

insert into data_types (name, validation_query) values
('integer', 'cast(? as integer) is not null'),
('float', 'cast(? as float) is not null'),
('real', 'cast(? as real) is not null'),
('text', 'cast(? as text) is not null'),
('json', 'json_valid(?) is 1');
('time_series', '? is null'),
('piecewise_linear', '? is null');
-- Create a new data type for function data here

-- triggers
-- we might need a better way of doing this. but we can not get more information where
-- it failed.
create trigger validate_attribute_data_type
before insert on attributes
for each row  -- noqa: PRS
begin
    select case
        when new.data_type = 'integer' and typeof(new.value) != 'integer' then
            raise(fail, 'invalid data type for attribute value. expected integer.')  -- noqa: PRS
        when new.data_type = 'text' and typeof(new.value) != 'text' then
            raise(fail, 'invalid data type for attribute value. expected text.')  -- noqa: PRS
		when new.data_type = 'float' and typeof(new.value) != 'float' then
			raise(fail, 'invalid data type for attribute value. expected float.')  -- noqa: PRS
		when new.data_type = 'json' and json_valid(new.value) != 1 then
            raise(fail, 'invalid data type for attribute value. expected valid JSON.') -- noqa: PRS
    -- add more conditions for other data types as needed
    end;
end;


create table time_series(
	entity_id integer references entities(id),
	timestamp not null,
	value float not null
);

create view unit_attributes as
select u.unit_id,
       u.name,
       u.prime_mover,
       u.balancing_topology,
       u.rating,
       ea.name as attribute_name,
       ea.value as attribute_value,
       ea.data_type as attribute_type
from generation_units u
left join attributes ea on u.unit_id = ea.entity_id and ea.entity_type = 'generation_units';

create view unit_time_series as
select u.name as unit_name,
       a.name,
       ts.timestamp,
       ts.value
from generation_units u
join attributes a on u.unit_id = a.entity_id
join time_series ts on a.entity_attribute_id = ts.entity_attribute_id
where a.entity_type = 'generation_units' and a.data_type = "time_series";