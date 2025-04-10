/* Autopopulate entity table */
CREATE TRIGGER IF NOT EXISTS autofill_prime_mover_types
AFTER
INSERT
    ON prime_mover_types
BEGIN
INSERT INTO
    entities(entity_type, entity_id)
VALUES
    ("prime_mover_types", new.id);

END;

CREATE TRIGGER IF NOT EXISTS autofill_fuels
AFTER
INSERT
    ON fuels
BEGIN
INSERT INTO
    entities(entity_type, entity_id)
VALUES
    ("fuels", new.id);

END;

CREATE TRIGGER IF NOT EXISTS autofill_planning_regions
AFTER
INSERT
    ON planning_regions
BEGIN
INSERT INTO
    entities(entity_type, entity_id)
VALUES
    ("planning_regions", new.id);

END;

CREATE TRIGGER IF NOT EXISTS autofill_balancing_topologies
AFTER
INSERT
    ON balancing_topologies
BEGIN
INSERT INTO
    entities(entity_type, entity_id)
VALUES
    ("balancing_topologies", new.id);

END;

CREATE TRIGGER IF NOT EXISTS autofill_generation_units
AFTER
INSERT
    ON generation_units
BEGIN
INSERT INTO
    entities(entity_type, entity_id)
VALUES
    ("generation_units", new.id);

END;

CREATE TRIGGER IF NOT EXISTS autofill_storage_units
AFTER
INSERT
    ON storage_units
BEGIN
INSERT INTO
    entities(entity_type, entity_id)
VALUES
    ("storage_units", new.id);

END;

CREATE TRIGGER IF NOT EXISTS autofill_arcs
AFTER
INSERT
    ON arcs
BEGIN
INSERT INTO
    entities(entity_type, entity_id)
VALUES
    ("arcs", new.id);

END;

CREATE TRIGGER IF NOT EXISTS autofill_transmission_lines
AFTER
INSERT
    ON transmission_lines
BEGIN
INSERT INTO
    entities(entity_type, entity_id)
VALUES
    ("transmission_lines", new.id);

END;

CREATE TRIGGER IF NOT EXISTS autofill_transmission_interchanges
AFTER
INSERT
    ON transmission_interchanges
BEGIN
INSERT INTO
    entities(entity_type, entity_id)
VALUES
    ("transmission_interchanges", new.id);

END;

CREATE TRIGGER IF NOT EXISTS autofill_hydro_reservoir
AFTER
INSERT
    ON hydro_reservoir
BEGIN
INSERT INTO
    entities(entity_type, entity_id)
VALUES
    ("hydro_reservoir", new.id);

END;

CREATE TRIGGER IF NOT EXISTS autofill_supply_technologies
AFTER
INSERT
    ON supply_technologies
BEGIN
INSERT INTO
    entities(entity_type, entity_id)
VALUES
    ("supply_technologies", new.id);

END;

CREATE TRIGGER IF NOT EXISTS autofill_transport_technologies
AFTER
INSERT
    ON transport_technologies
BEGIN
INSERT INTO
    entities(entity_type, entity_id)
VALUES
    ("transport_technologies", new.id);

END;

CREATE TRIGGER IF NOT EXISTS autofill_attributes
AFTER
INSERT
ON attributes
BEGIN
  INSERT INTO
  entities(entity_type, entity_id)
  VALUES
  ("attributes", new.id);

END;

CREATE TRIGGER IF NOT EXISTS autofill_supplemental_attributes
AFTER
INSERT
    ON supplemental_attributes
BEGIN
INSERT INTO
    entities(entity_type, entity_id)
VALUES
    ("supplemental_attributes", new.id);

END;

-- Create a trigger that runs after inserting into the arcs table
CREATE TRIGGER IF NOT EXISTS enforce_arc_entity_types_insert
AFTER
INSERT
    ON arcs
BEGIN
-- Check if the from_to entity has a valid type
SELECT
    CASE
        WHEN (
            SELECT
                entity_type
            FROM
                entities
            WHERE
                id = NEW.from_to
        ) NOT IN ('balancing_topologies', 'planning_regions') THEN RAISE(ABORT, 'Invalid from_to entity type')
    END;

-- Check if the to_from entity has a valid type
SELECT
    CASE
        WHEN (
            SELECT
                entity_type
            FROM
                entities
            WHERE
                id = NEW.to_from
        ) NOT IN ('balancing_topologies', 'planning_regions') THEN RAISE(ABORT, 'Invalid to_from entity type')
    END;

END;
