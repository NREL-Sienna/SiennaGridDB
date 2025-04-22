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
    @rm {{db}}
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
