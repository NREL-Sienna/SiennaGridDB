CREATE TRIGGER IF NOT EXISTS check_planning_regions_entity_exists BEFORE
INSERT ON planning_regions
    WHEN NOT EXISTS (
        SELECT 1
        FROM entities
        WHERE id = NEW.id
            AND entity_table = 'planning_regions'
    ) BEGIN
SELECT RAISE(
        ABORT,
        'Entity ID must exist in entities table with type planning_regions before insertion'
    );
END;

CREATE TRIGGER IF NOT EXISTS check_balancing_topologies_entity_exists BEFORE
INSERT ON balancing_topologies
    WHEN NOT EXISTS (
        SELECT 1
        FROM entities
        WHERE id = NEW.id
            AND entity_table = 'balancing_topologies'
    ) BEGIN
SELECT RAISE(
        ABORT,
        'Entity ID must exist in entities table with type balancing_topologies before insertion'
    );
END;

CREATE TRIGGER IF NOT EXISTS check_arcs_entity_exists BEFORE
INSERT ON arcs
    WHEN NOT EXISTS (
        SELECT 1
        FROM entities
        WHERE id = NEW.id
            AND entity_table = 'arcs'
    ) BEGIN
SELECT RAISE(
        ABORT,
        'Entity ID must exist in entities table with type arcs before insertion'
    );
END;

CREATE TRIGGER IF NOT EXISTS check_transmission_lines_entity_exists BEFORE
INSERT ON transmission_lines
    WHEN NOT EXISTS (
        SELECT 1
        FROM entities
        WHERE id = NEW.id
            AND entity_table = 'transmission_lines'
    ) BEGIN
SELECT RAISE(
        ABORT,
        'Entity ID must exist in entities table with type transmission_lines before insertion'
    );
END;

CREATE TRIGGER IF NOT EXISTS check_transmission_interchanges_entity_exists BEFORE
INSERT ON transmission_interchanges
    WHEN NOT EXISTS (
        SELECT 1
        FROM entities
        WHERE id = NEW.id
            AND entity_table = 'transmission_interchanges'
    ) BEGIN
SELECT RAISE(
        ABORT,
        'Entity ID must exist in entities table with type transmission_interchanges before insertion'
    );
END;

CREATE TRIGGER IF NOT EXISTS check_generation_units_entity_exists BEFORE
INSERT ON generation_units
    WHEN NOT EXISTS (
        SELECT 1
        FROM entities
        WHERE id = NEW.id
            AND entity_table = 'generation_units'
    ) BEGIN
SELECT RAISE(
        ABORT,
        'Entity ID must exist in entities table with type generation_units before insertion'
    );
END;

CREATE TRIGGER IF NOT EXISTS check_storage_units_entity_exists BEFORE
INSERT ON storage_units
    WHEN NOT EXISTS (
        SELECT 1
        FROM entities
        WHERE id = NEW.id
            AND entity_table = 'storage_units'
    ) BEGIN
SELECT RAISE(
        ABORT,
        'Entity ID must exist in entities table with type storage_units before insertion'
    );
END;

CREATE TRIGGER IF NOT EXISTS check_hydro_reservoir_entity_exists BEFORE
INSERT ON hydro_reservoir
    WHEN NOT EXISTS (
        SELECT 1
        FROM entities
        WHERE id = NEW.id
            AND entity_table = 'hydro_reservoir'
    ) BEGIN
SELECT RAISE(
        ABORT,
        'Entity ID must exist in entities table with type hydro_reservoir before insertion'
    );
END;

CREATE TRIGGER IF NOT EXISTS check_supply_technologies_entity_exists BEFORE
INSERT ON supply_technologies
    WHEN NOT EXISTS (
        SELECT 1
        FROM entities
        WHERE id = NEW.id
            AND entity_table = 'supply_technologies'
    ) BEGIN
SELECT RAISE(
        ABORT,
        'Entity ID must exist in entities table with type supply_technologies before insertion'
    );
END;

CREATE TRIGGER IF NOT EXISTS check_transport_technologies_entity_exists BEFORE
INSERT ON transport_technologies
    WHEN NOT EXISTS (
        SELECT 1
        FROM entities
        WHERE id = NEW.id
            AND entity_table = 'transport_technologies'
    ) BEGIN
SELECT RAISE(
        ABORT,
        'Entity ID must exist in entities table with type transport_technologies before insertion'
    );
END;

CREATE TRIGGER IF NOT EXISTS check_supplemental_attributes_entity_exists BEFORE
INSERT ON supplemental_attributes
    WHEN NOT EXISTS (
        SELECT 1
        FROM entities
        WHERE id = NEW.id
            AND entity_table = 'supplemental_attributes'
    ) BEGIN
SELECT RAISE(
        ABORT,
        'Entity ID must exist in entities table with type supplemental_attributes before insertion'
    );
END;

CREATE TRIGGER IF NOT EXISTS check_loads_entity_exists BEFORE
INSERT ON loads
    WHEN NOT EXISTS (
        SELECT 1
        FROM entities
        WHERE id = NEW.id
            AND entity_table = 'loads'
    ) BEGIN
SELECT RAISE(
        ABORT,
        'Entity ID must exist in entities table with type loads before insertion'
    );
END;

CREATE TRIGGER IF NOT EXISTS enforce_arc_entity_types_insert
AFTER
INSERT ON arcs BEGIN -- Fetch entity types for from_id and to_id and perform checks
SELECT CASE
        -- Check if from_id entity type is valid
        WHEN (
            SELECT entity_table
            FROM entities
            WHERE id = NEW.from_id
        ) NOT IN ('balancing_topologies', 'planning_regions') THEN RAISE(
            ABORT,
            'Invalid from_id entity type: must be balancing_topologies or planning_regions'
        ) -- Check if to_id entity type is valid
        WHEN (
            SELECT entity_table
            FROM entities
            WHERE id = NEW.to_id
        ) NOT IN ('balancing_topologies', 'planning_regions') THEN RAISE(
            ABORT,
            'Invalid to_id entity type: must be balancing_topologies or planning_regions'
        ) -- Check if from_id and to_id entity types match
        WHEN (
            SELECT entity_table
            FROM entities
            WHERE id = NEW.from_id
        ) != (
            SELECT entity_table
            FROM entities
            WHERE id = NEW.to_id
        ) THEN RAISE(
            ABORT,
            'Entity types for from_id and to_id must match'
        )
    END;

END;
