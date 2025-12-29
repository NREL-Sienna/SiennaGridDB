db-name := "griddb-example.sqlite"
sqlite-options := "--table"
sqlite-command := "sqlite3"

assert-sqlite-version:
    @{{sqlite-command}} --version

create-schema db=db-name: assert-sqlite-version
    @echo "Creating schema"
    @touch {{db}} && rm {{db}}
    @{{sqlite-command}} {{db}} < schema/schema.sql

create-triggers db=db-name: create-schema
    @echo "Adding triggers to schema"
    @{{sqlite-command}} {{db}} < schema/triggers.sql

create-views db=db-name: create-schema
    @echo "Adding views to schema"
    @{{sqlite-command}} {{db}} < schema/views.sql

new-db db=db-name: create-schema create-triggers create-views
    @{{sqlite-command}} {{sqlite-options}} {{db}}

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
