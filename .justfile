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

load-dummy-data db=db-name: create-schema
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
