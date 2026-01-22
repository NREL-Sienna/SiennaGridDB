db-name := "griddb-example.sqlite"
query-file := "queries.sql"
data := "dummy_data.sql"
sqlite-options := "--table"
tmpdir := `mktemp -d`
SQLITE_REQUIRED_VERSION := "3.35.0"
sqlite-command := "sqlite3"

assert-sqlite-version:
    @{{sqlite-command}} --version

create-schema db=db-name: assert-sqlite-version
    @echo "Creating schema"
    @touch {{db}} && rm {{db}}
    @{{sqlite-command}} {{db}} < schema.sql

create-triggers db=db-name: create-schema
    @echo "Adding triggers to schema"
    @{{sqlite-command}} {{db}} < triggers.sql

create-views db=db-name: create-schema
    @echo "Adding views to schema"
    @{{sqlite-command}} {{db}} < views.sql

load-dummy-data db=db-name: create-schema create-triggers create-views
    @echo "Loading dummy data"
    @{{sqlite-command}} {{db}} < {{data}}

new-db db=db-name: load-dummy-data
    @{{sqlite-command}} {{sqlite-options}} {{db}}

query db=db-name:
    @echo "Running query file to {{db}}"
    @{{sqlite-command}} {{sqlite-options}} {{db}} < {{query-file}}

test db=db-name:
    @echo "Running test sequence on {{db}}..."
    @just load-dummy-data {{db}}
    @just query {{db}}

# Validate schema integrity and foreign key constraints
validate-schema db=db-name: load-dummy-data
    @echo "Validating schema integrity for {{db}}..."
    @{{sqlite-command}} {{db}} "PRAGMA foreign_key_check;"
    @{{sqlite-command}} {{db}} "PRAGMA integrity_check;"
    @echo "Schema validation complete"

# Check entity type consistency
validate-entity-types db=db-name: load-dummy-data
    @echo "Validating entity type consistency..."
    @{{sqlite-command}} {{sqlite-options}} {{db}} "SELECT entity_type, COUNT(*) as count FROM entities GROUP BY entity_type ORDER BY entity_type;"
    @echo "Checking for orphaned entities..."
    @{{sqlite-command}} {{sqlite-options}} {{db}} "SELECT e.id, e.entity_type, e.source_table FROM entities e LEFT JOIN entity_types et ON e.entity_type = et.name WHERE et.name IS NULL;"

# Validate time series data integrity
validate-time-series db=db-name: load-dummy-data
    @echo "Validating time series data..."
    @{{sqlite-command}} {{sqlite-options}} {{db}} "SELECT ts.time_series_type, COUNT(*) as associations FROM time_series_associations ts GROUP BY ts.time_series_type;"
    @{{sqlite-command}} {{sqlite-options}} {{db}} "SELECT COUNT(*) as static_data_points FROM static_time_series_data;"
    @{{sqlite-command}} {{sqlite-options}} {{db}} "SELECT COUNT(*) as forecast_data_points FROM deterministic_forecast_data;"

# Run comprehensive validation (all checks)
validate-all db=db-name: validate-schema validate-entity-types validate-time-series
    @echo "All validation checks completed successfully!"

# Generate a summary report of the database contents
report db=db-name: load-dummy-data
    @echo "Database Summary Report for {{db}}..."
    @echo "======================================="
    @{{sqlite-command}} {{sqlite-options}} {{db}} "SELECT 'Total Entities:' as metric, COUNT(*) as value FROM entities UNION ALL SELECT 'Entity Types:' as metric, COUNT(*) as value FROM entity_types UNION ALL SELECT 'Generation Units:' as metric, COUNT(*) as value FROM generation_units UNION ALL SELECT 'Storage Units:' as metric, COUNT(*) as value FROM storage_units UNION ALL SELECT 'Transmission Lines:' as metric, COUNT(*) as value FROM transmission_lines UNION ALL SELECT 'Time Series:' as metric, COUNT(*) as value FROM time_series_associations;"

format sql-schema:
    #!/usr/bin/env bash
    set -euxo pipefail
    echo "Formatting code {{sql-schema}}"
    if command -v sleek &> /dev/null; then
        sleek {{sql-schema}}
    else
        echo "SQL formatter does not exist. Installed it using `cargo install sleek`"
        exit 1
    fi
