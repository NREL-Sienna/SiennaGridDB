CREATE TRIGGER IF NOT EXISTS check_arcs_entity_exists BEFORE
INSERT ON arcs
    WHEN NOT EXISTS (
        SELECT 1
        FROM entities
        WHERE id = NEW.id
            AND source_table = 'arcs'
    ) BEGIN
SELECT RAISE(
        ABORT,
        'Entity ID must exist in entities table with source_table arcs before insertion'
    );
END;

CREATE TRIGGER IF NOT EXISTS check_transmission_lines_entity_exists BEFORE
INSERT ON transmission_lines
    WHEN NOT EXISTS (
        SELECT 1
        FROM entities
        WHERE id = NEW.id
            AND source_table = 'transmission_lines'
    ) BEGIN
SELECT RAISE(
        ABORT,
        'Entity ID must exist in entities table with source_table transmission_lines before insertion'
    );
END;

CREATE TRIGGER IF NOT EXISTS check_transmission_interchanges_entity_exists BEFORE
INSERT ON transmission_interchanges
    WHEN NOT EXISTS (
        SELECT 1
        FROM entities
        WHERE id = NEW.id
            AND source_table = 'transmission_interchanges'
    ) BEGIN
SELECT RAISE(
        ABORT,
        'Entity ID must exist in entities table with source_table transmission_interchanges before insertion'
    );
END;

CREATE TRIGGER IF NOT EXISTS check_generation_units_entity_exists BEFORE
INSERT ON generation_units
    WHEN NOT EXISTS (
        SELECT 1
        FROM entities
        WHERE id = NEW.id
            AND source_table = 'generation_units'
    ) BEGIN
SELECT RAISE(
        ABORT,
        'Entity ID must exist in entities table with source_table generation_units before insertion'
    );
END;

CREATE TRIGGER IF NOT EXISTS check_storage_units_entity_exists BEFORE
INSERT ON storage_units
    WHEN NOT EXISTS (
        SELECT 1
        FROM entities
        WHERE id = NEW.id
            AND source_table = 'storage_units'
    ) BEGIN
SELECT RAISE(
        ABORT,
        'Entity ID must exist in entities table with source_table storage_units before insertion'
    );
END;

CREATE TRIGGER IF NOT EXISTS check_hydro_reservoir_entity_exists BEFORE
INSERT ON hydro_reservoir
    WHEN NOT EXISTS (
        SELECT 1
        FROM entities
        WHERE id = NEW.id
            AND source_table = 'hydro_reservoir'
    ) BEGIN
SELECT RAISE(
        ABORT,
        'Entity ID must exist in entities table with source_table hydro_reservoir before insertion'
    );
END;

CREATE TRIGGER IF NOT EXISTS check_supply_technologies_entity_exists BEFORE
INSERT ON supply_technologies
    WHEN NOT EXISTS (
        SELECT 1
        FROM entities
        WHERE id = NEW.id
            AND source_table = 'supply_technologies'
    ) BEGIN
SELECT RAISE(
        ABORT,
        'Entity ID must exist in entities table with source_table supply_technologies before insertion'
    );
END;

CREATE TRIGGER IF NOT EXISTS check_transport_technologies_entity_exists BEFORE
INSERT ON transport_technologies
    WHEN NOT EXISTS (
        SELECT 1
        FROM entities
        WHERE id = NEW.id
            AND source_table = 'transport_technologies'
    ) BEGIN
SELECT RAISE(
        ABORT,
        'Entity ID must exist in entities table with source_table transport_technologies before insertion'
    );
END;

CREATE TRIGGER IF NOT EXISTS check_supplemental_attributes_entity_exists BEFORE
INSERT ON supplemental_attributes
    WHEN NOT EXISTS (
        SELECT 1
        FROM entities
        WHERE id = NEW.id
            AND source_table = 'supplemental_attributes'
    ) BEGIN
SELECT RAISE(
        ABORT,
        'Entity ID must exist in entities table with source_table supplemental_attributes before insertion'
    );
END;

CREATE TRIGGER IF NOT EXISTS check_loads_entity_exists BEFORE
INSERT ON loads
    WHEN NOT EXISTS (
        SELECT 1
        FROM entities
        WHERE id = NEW.id
            AND source_table = 'loads'
    ) BEGIN
SELECT RAISE(
        ABORT,
        'Entity ID must exist in entities table with source_table loads before insertion'
    );
END;


-- Business Logic Validation Triggers
CREATE TRIGGER enforce_arc_entity_types_insert
AFTER INSERT ON arcs 
BEGIN 
    SELECT CASE
        WHEN NOT EXISTS (SELECT 1 FROM entities WHERE id = NEW.from_id) THEN 
            RAISE(ABORT, 'from_id entity does not exist')
        WHEN NOT EXISTS (SELECT 1 FROM entities WHERE id = NEW.to_id) THEN 
            RAISE(ABORT, 'to_id entity does not exist')
        WHEN (SELECT entity_type FROM entities WHERE id = NEW.from_id) 
             NOT IN ('balancing_topologies', 'planning_regions', 'LoadZone', 'ACBus', 'Area') THEN 
            RAISE(ABORT, 'Invalid from_id entity type: must be balancing topology or planning region')
        WHEN (SELECT entity_type FROM entities WHERE id = NEW.to_id) 
             NOT IN ('balancing_topologies', 'planning_regions', 'LoadZone', 'ACBus', 'Area') THEN 
            RAISE(ABORT, 'Invalid to_id entity type: must be balancing topology or planning region')
    END;
END;

-- Validate entity categories for consistency
CREATE TRIGGER validate_entity_category_consistency
BEFORE INSERT ON entities
BEGIN
    SELECT CASE
        WHEN NOT EXISTS (SELECT 1 FROM entity_types WHERE name = NEW.entity_type) THEN
            RAISE(ABORT, 'Invalid entity_type: ' || NEW.entity_type || ' not found in entity_types')
    END;
END;

-- Validate deterministic forecast data type and JSON array structure
CREATE TRIGGER validate_deterministic_forecast_data_type
BEFORE INSERT ON deterministic_forecast_data
BEGIN
    SELECT CASE
        WHEN (SELECT time_series_type FROM time_series_associations WHERE id = NEW.time_series_id) NOT LIKE '%deterministic%' AND
             (SELECT time_series_type FROM time_series_associations WHERE id = NEW.time_series_id) NOT LIKE '%forecast%' THEN
            RAISE(ABORT, 'Cannot insert deterministic forecast data into non-forecast time series type')
        WHEN json_type(NEW.forecast_values) != 'array' THEN
            RAISE(ABORT, 'forecast_values must be a JSON array')
        WHEN json_array_length(NEW.forecast_values) != (SELECT CAST(horizon AS INTEGER) FROM time_series_associations WHERE id = NEW.time_series_id) THEN
            RAISE(ABORT, 'forecast_values array length must match horizon from time_series_associations')
    END;
END;
