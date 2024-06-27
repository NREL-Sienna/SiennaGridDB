-- drop tables if they exist
drop table if exists generation_units;
drop table if exists storage_units;
drop view if exists unit_attributes;
drop view if exists unit_time_series;
drop table if exists prime_mover_types;
drop table if exists balancing_topologies;
drop table if exists areas;
drop table if exists attributes;
drop table if exists data_types;
drop table if exists time_series;
drop table if exists transmission_interchange;

-- only generation units
create table  generation_units (
	unit_id integer primary key,
	name text not null unique,
	prime_mover text not null,
	fuel_type text not null,
	balancing_topology text not null references balancing_topologies(name),
	rating float not null check (rating > 0 ),
	base_power float not null check (base_power > 0),
	check (base_power >= rating),
	foreign key (prime_mover, fuel_type) references prime_mover_types(prime_mover, fuel_type)
);
-- ) strict;
-- create storage batteries table
-- only storge units
create table  storage_units (
	storage_unit_id integer primary key,
	name text not null unique,
	prime_mover text not null,
	fuel_type text not null,
	max_capacity float not null check (max_capacity > 0),
	round_trip_efficiency float check (round_trip_efficiency >= 0),
	balancing_topology text not null references balancing_topologies(name),
	rating float not null check (rating > 0 ),
	base_power float not null check (base_power > 0),
	check (base_power >= rating),
	foreign key (prime_mover, fuel_type) references prime_mover_types(prime_mover, fuel_type)
);

-- create table for technologies
create table supply_technologies (
    technology_id integer primary key,
    prime_mover text not null,
	fuel_type text not null,
    vom_cost float not null check (vom_cost >= 0),
    fom_cost float not null check (fom_cost >= 0),
    scenario text null,
	foreign key (prime_mover, fuel_type) references prime_mover_types(prime_mover, fuel_type)
);


create table  prime_mover_types (
	prime_mover text not null unique primary key,
	fuel_type text not null,
	primary key (prime_mover, fuel_type)
);

--
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
	balancing_topology_from text not null references balancing_topologies(name),
	balancing_topology_to text not null references balancing_topologies(name),
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
    -- primary key (entity_id, entity_type, attribute_name),
    check (name != 'entity_id')
);

create table data_types(
	name text not null primary key,
	validation_query text,
	description text null
);

-- Create function data table

insert into data_types (name, validation_query) values
('integer', 'cast(? as integer) is not null'),
('real', 'cast(? as real) is not null'),
('text', 'cast(? as text) is not null'),
('time_series', '? is null'),
('piecewise_lin', '? is null');
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
        when new.data_type = 'time_series' and typeof(new.value) != null then
            raise(fail, 'invalid data type for attribute value. expected real.')  -- noqa: PRS
        when new.data_type = 'text' and typeof(new.value) != 'text' then
            raise(fail, 'invalid data type for attribute value. expected text.')  -- noqa: PRS
		when new.data_type = 'piecewise_lin' and typeof(new.value) != null then
			raise(fail, 'invalid data type for attribute value. expected real.')  -- noqa: PRS
    -- add more conditions for other data types as needed
    end;
end;


create table time_series(
	entity_attribute_id integer references attributes(entity_attribute_id),
	timestamp int not null,
	value real not null
);

create table piecewise_lin(
	entity_attribute_id integer references attributes(entity_attribute_id),
	from_capacity real not null,
	to_capacity real not null,
	area text null references areas(name),
    balancing_topology text null references balancing_topologies(name),
	capacity_cost_per_mw real not null,
	distance_km real not null,
	reinforcement_cost_per_mw real not null,
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

-- .print ''
-- .print 'available tables:'
-- .print ''
-- .table
--
-- .print ''
-- .print 'available views:'
-- .print ''
-- select name
-- from sqlite_schema
-- where type = 'view';

