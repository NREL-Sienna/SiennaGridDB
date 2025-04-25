/*
 CREATE TRIGGER IF NOT EXISTS autofill_planning_regions
 AFTER
 INSERT ON planning_regions BEGIN
 INSERT INTO entities(entity_type, entity_id)
 VALUES ("planning_regions", new.id);

 END;

 CREATE TRIGGER IF NOT EXISTS autofill_balancing_topologies
 AFTER
 INSERT ON balancing_topologies BEGIN
 INSERT INTO entities(entity_type, entity_id)
 VALUES ("balancing_topologies", new.id);

 END;

 CREATE TRIGGER IF NOT EXISTS autofill_generation_units
 AFTER
 INSERT ON generation_units BEGIN
 INSERT INTO entities(entity_type, entity_id)
 VALUES ("generation_units", new.id);

 END;

 CREATE TRIGGER IF NOT EXISTS autofill_storage_units
 AFTER
 INSERT ON storage_units BEGIN
 INSERT INTO entities(entity_type, entity_id)
 VALUES ("storage_units", new.id);

 END;

 CREATE TRIGGER IF NOT EXISTS autofill_arcs
 AFTER
 INSERT ON arcs BEGIN
 INSERT INTO entities(entity_type, entity_id)
 VALUES ("arcs", new.id);

 END;

 CREATE TRIGGER IF NOT EXISTS autofill_transmission_lines
 AFTER
 INSERT ON transmission_lines BEGIN
 INSERT INTO entities(entity_type, entity_id)
 VALUES ("transmission_lines", new.id);

 END;

 CREATE TRIGGER IF NOT EXISTS autofill_transmission_interchanges
 AFTER
 INSERT ON transmission_interchanges BEGIN
 INSERT INTO entities(entity_type, entity_id)
 VALUES ("transmission_interchanges", new.id);

 END;

 CREATE TRIGGER IF NOT EXISTS autofill_hydro_reservoir
 AFTER
 INSERT ON hydro_reservoir BEGIN
 INSERT INTO entities(entity_type, entity_id)
 VALUES ("hydro_reservoir", new.id);

 END;

 CREATE TRIGGER IF NOT EXISTS autofill_supply_technologies
 AFTER
 INSERT ON supply_technologies BEGIN
 INSERT INTO entities(entity_type, entity_id)
 VALUES ("supply_technologies", new.id);

 END;

 CREATE TRIGGER IF NOT EXISTS autofill_transport_technologies
 AFTER
 INSERT ON transport_technologies BEGIN
 INSERT INTO entities(entity_type, entity_id)
 VALUES ("transport_technologies", new.id);

 END;

 CREATE TRIGGER IF NOT EXISTS autofill_supplemental_attributes
 AFTER
 INSERT ON supplemental_attributes BEGIN
 INSERT INTO entities(entity_type, entity_id)
 VALUES ("supplemental_attributes", new.id);

 END;

 CREATE TRIGGER IF NOT EXISTS autofill_loads
 AFTER
 INSERT ON supplemental_attributes BEGIN
 INSERT INTO entities(entity_type, entity_id)
 VALUES ("loads", new.id);

 END;

 */
CREATE TRIGGER IF NOT EXISTS enforce_arc_entity_types_insert
AFTER
INSERT
    ON arcs
BEGIN
-- Fetch entity types for from_id and to_id and perform checks
SELECT
    CASE
        -- Check if from_id entity type is valid
        WHEN (
            SELECT
                entity_table
            FROM
                entities
            WHERE
                id = NEW.from_id
        ) NOT IN ('balancing_topologies', 'planning_regions') THEN RAISE(
            ABORT,
            'Invalid from_id entity type: must be balancing_topologies or planning_regions'
        ) -- Check if to_id entity type is valid
        WHEN (
            SELECT
                entity_table
            FROM
                entities
            WHERE
                id = NEW.to_id
        ) NOT IN ('balancing_topologies', 'planning_regions') THEN RAISE(
            ABORT,
            'Invalid to_id entity type: must be balancing_topologies or planning_regions'
        ) -- Check if from_id and to_id entity types match
        WHEN (
            SELECT
                entity_table
            FROM
                entities
            WHERE
                id = NEW.from_id
        ) != (
            SELECT
                entity_table
            FROM
                entities
            WHERE
                id = NEW.to_id
        ) THEN RAISE(
            ABORT,
            'Entity types for from_id and to_id must match'
        )
    END;

END;
