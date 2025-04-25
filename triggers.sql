CREATE TRIGGER IF NOT EXISTS check_planning_regions_entity_exists BEFORE
INSERT ON planning_regions BEGIN
SELECT RAISE(
        ABORT,
        printf(
            'Entity ID %d with type planning_regions must exist in entities table before insertion',
            NEW.id
        )
    )
WHERE NOT EXISTS (
        SELECT 1
        FROM entities
        WHERE id = NEW.id
            AND entity_type = 'planning_regions'
    );

END;

CREATE TRIGGER IF NOT EXISTS check_balancing_topologies_entity_exists BEFORE
INSERT ON balancing_topologies BEGIN
SELECT RAISE(
        ABORT,
        printf(
            'Entity ID %d with type balancing_topologies must exist in entities table before insertion',
            NEW.id
        )
    )
WHERE NOT EXISTS (
        SELECT 1
        FROM entities
        WHERE id = NEW.id
            AND entity_type = 'balancing_topologies'
    );

END;

CREATE TRIGGER IF NOT EXISTS check_arcs_entity_exists BEFORE
INSERT ON arcs BEGIN
SELECT RAISE(
        ABORT,
        printf(
            'Entity ID %d with type arcs must exist in entities table before insertion',
            NEW.id
        )
    )
WHERE NOT EXISTS (
        SELECT 1
        FROM entities
        WHERE id = NEW.id
            AND entity_type = 'arcs'
    );

END;

CREATE TRIGGER IF NOT EXISTS check_transmission_lines_entity_exists BEFORE
INSERT ON transmission_lines BEGIN
SELECT RAISE(
        ABORT,
        printf(
            'Entity ID %d with type transmission_lines must exist in entities table before insertion',
            NEW.id
        )
    )
WHERE NOT EXISTS (
        SELECT 1
        FROM entities
        WHERE id = NEW.id
            AND entity_type = 'transmission_lines'
    );

END;

CREATE TRIGGER IF NOT EXISTS check_transmission_interchanges_entity_exists BEFORE
INSERT ON transmission_interchanges BEGIN
SELECT RAISE(
        ABORT,
        printf(
            'Entity ID %d with type transmission_interchanges must exist in entities table before insertion',
            NEW.id
        )
    )
WHERE NOT EXISTS (
        SELECT 1
        FROM entities
        WHERE id = NEW.id
            AND entity_type = 'transmission_interchanges'
    );

END;

CREATE TRIGGER IF NOT EXISTS check_generation_units_entity_exists BEFORE
INSERT ON generation_units BEGIN
SELECT RAISE(
        ABORT,
        printf(
            'Entity ID %d with type generation_units must exist in entities table before insertion',
            NEW.id
        )
    )
WHERE NOT EXISTS (
        SELECT 1
        FROM entities
        WHERE id = NEW.id
            AND entity_type = 'generation_units'
    );

END;

CREATE TRIGGER IF NOT EXISTS check_storage_units_entity_exists BEFORE
INSERT ON storage_units BEGIN
SELECT RAISE(
        ABORT,
        printf(
            'Entity ID %d with type storage_units must exist in entities table before insertion',
            NEW.id
        )
    )
WHERE NOT EXISTS (
        SELECT 1
        FROM entities
        WHERE id = NEW.id
            AND entity_type = 'storage_units'
    );

END;

CREATE TRIGGER IF NOT EXISTS check_hydro_reservoir_entity_exists BEFORE
INSERT ON hydro_reservoir BEGIN
SELECT RAISE(
        ABORT,
        printf(
            'Entity ID %d with type hydro_reservoir must exist in entities table before insertion',
            NEW.id
        )
    )
WHERE NOT EXISTS (
        SELECT 1
        FROM entities
        WHERE id = NEW.id
            AND entity_type = 'hydro_reservoir'
    );

END;

CREATE TRIGGER IF NOT EXISTS check_supply_technologies_entity_exists BEFORE
INSERT ON supply_technologies BEGIN
SELECT RAISE(
        ABORT,
        printf(
            'Entity ID %d with type supply_technologies must exist in entities table before insertion',
            NEW.id
        )
    )
WHERE NOT EXISTS (
        SELECT 1
        FROM entities
        WHERE id = NEW.id
            AND entity_type = 'supply_technologies'
    );

END;

CREATE TRIGGER IF NOT EXISTS check_transport_technologies_entity_exists BEFORE
INSERT ON transport_technologies BEGIN
SELECT RAISE(
        ABORT,
        printf(
            'Entity ID %d with type transport_technologies must exist in entities table before insertion',
            NEW.id
        )
    )
WHERE NOT EXISTS (
        SELECT 1
        FROM entities
        WHERE id = NEW.id
            AND entity_type = 'transport_technologies'
    );

END;

CREATE TRIGGER IF NOT EXISTS check_supplemental_attributes_entity_exists BEFORE
INSERT ON supplemental_attributes BEGIN
SELECT RAISE(
        ABORT,
        printf(
            'Entity ID %d with type supplemental_attributes must exist in entities table before insertion',
            NEW.id
        )
    )
WHERE NOT EXISTS (
        SELECT 1
        FROM entities
        WHERE id = NEW.id
            AND entity_type = 'supplemental_attributes'
    );

END;

CREATE TRIGGER IF NOT EXISTS check_loads_entity_exists BEFORE
INSERT ON loads BEGIN
SELECT RAISE(
        ABORT,
        printf(
            'Entity ID %d with type loads must exist in entities table before insertion',
            NEW.id
        )
    )
WHERE NOT EXISTS (
        SELECT 1
        FROM entities
        WHERE id = NEW.id
            AND entity_type = 'loads'
    );

END;

CREATE TRIGGER IF NOT EXISTS enforce_arc_entity_types_insert
AFTER
INSERT ON arcs BEGIN -- Fetch entity types for from_id and to_id and perform checks
SELECT CASE
        -- Check if from_id entity type is valid
        WHEN (
            SELECT entity_type
            FROM entities
            WHERE id = NEW.from_id
        ) NOT IN ('balancing_topologies', 'planning_regions') THEN RAISE(
            ABORT,
            'Invalid from_id entity type: must be balancing_topologies or planning_regions'
        ) -- Check if to_id entity type is valid
        WHEN (
            SELECT entity_type
            FROM entities
            WHERE id = NEW.to_id
        ) NOT IN ('balancing_topologies', 'planning_regions') THEN RAISE(
            ABORT,
            'Invalid to_id entity type: must be balancing_topologies or planning_regions'
        ) -- Check if from_id and to_id entity types match
        WHEN (
            SELECT entity_type
            FROM entities
            WHERE id = NEW.from_id
        ) != (
            SELECT entity_type
            FROM entities
            WHERE id = NEW.to_id
        ) THEN RAISE(
            ABORT,
            'Entity types for from_id and to_id must match'
        )
    END;

END;
