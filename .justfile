db-name := "example.db"
data := "dummy_data.sql"
sqlite-options := "--table"
tmpdir := `mktemp -d`
SQLITE_REQUIRED_VERSION := "3.35.0"
sqlite-command := "sqlite3"

assert-sqlite-version:
    @{{sqlite-command}} --version

create-schema: assert-sqlite-version
    @echo "Creating schema"
    @rm {{db-name}}
    @{{sqlite-command}} {{db-name}} < schema.sql

load-dummy-data: create-schema
    @echo "Loading dummy data"
    @{{sqlite-command}} {{db-name}} < {{data}}

new-db: load-dummy-data
    @{{sqlite-command}} {{sqlite-options}} {{db-name}}

test: load-dummy-data
    @echo "Running queries"
    @{{sqlite-command}} {{sqlite-options}} {{db-name}} < queries.sql
