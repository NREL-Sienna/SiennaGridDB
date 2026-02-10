# Test that TABLE_SCHEMAS in db_definition.jl matches schema.sql
# Uses SQLite introspection to parse the schema reliably

using SiennaOpenAPIModels:
    TABLE_SCHEMAS, SQLITE_CREATE_STR, OPENAPI_FIELDS_TO_DB, TYPE_TO_TABLE
import SQLite
import DBInterface

"""
    get_table_columns(db, table_name::AbstractString)

Use PRAGMA table_xinfo to get column names from an actual SQLite table.
Returns (regular_columns, generated_columns) as vectors of lowercase column names.
"""
function get_table_columns(db, table_name::AbstractString)
    # table_xinfo returns: cid, name, type, notnull, dflt_value, pk, hidden
    # hidden: 0 = normal, 1 = dynamic (VIRTUAL generated), 2 = stored (STORED generated), 3 = hidden
    result = DBInterface.execute(db, "PRAGMA table_xinfo($table_name)")
    regular_columns = String[]
    generated_columns = String[]
    for row in result
        col_name = lowercase(row.name)
        if row.hidden == 0
            push!(regular_columns, col_name)
        elseif row.hidden in (1, 2)  # VIRTUAL or STORED generated columns
            push!(generated_columns, col_name)
        end
    end
    return regular_columns, generated_columns
end

"""
    get_all_tables(db)

Get all user table names from the SQLite database.
"""
function get_all_tables(db)
    result = DBInterface.execute(
        db,
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
    )
    return [row.name for row in result]
end

@testset "TABLE_SCHEMAS matches schema.sql" begin
    # Create in-memory database and apply schema
    db = SQLite.DB()

    # Apply schema (same way the actual code does it)
    for statement in SQLITE_CREATE_STR
        DBInterface.execute(db, statement)
    end

    # Get actual tables from the database
    actual_tables = Set(get_all_tables(db))

    # Validate each table in TABLE_SCHEMAS
    for (table_name, schema) in TABLE_SCHEMAS
        @testset "Table: $table_name" begin
            # Check table exists in actual DB
            @test table_name in actual_tables

            if !(table_name in actual_tables)
                continue
            end

            # Get actual columns from SQLite (separates regular vs generated)
            regular_columns, generated_columns = get_table_columns(db, table_name)
            all_actual_columns = vcat(regular_columns, generated_columns)
            expected_columns = [lowercase(string(name)) for name in schema.names]

            # Check all expected columns exist in actual DB (regular or generated)
            for col in expected_columns
                @test col in all_actual_columns
                if !(col in all_actual_columns)
                    @error "Column '$col' in TABLE_SCHEMAS[$table_name] not found in schema.sql" regular_columns generated_columns
                end
            end

            # Generated columns must not be in TABLE_SCHEMAS (can't INSERT into them)
            generated_in_schema = filter(c -> c in generated_columns, expected_columns)
            isempty(generated_in_schema) ||
                @error "Remove generated columns from TABLE_SCHEMAS (can't INSERT into them)" table_name generated_in_schema
            @test isempty(generated_in_schema)

            # Check for extra regular columns in DB that aren't in TABLE_SCHEMAS
            for col in regular_columns
                if !(col in expected_columns)
                    @warn "Column '$col' in schema.sql table '$table_name' not in TABLE_SCHEMAS"
                end
            end

            # Verify column order matches (only for regular columns in TABLE_SCHEMAS)
            expected_regular = filter(c -> c in regular_columns, expected_columns)
            actual_filtered = filter(c -> c in expected_regular, regular_columns)
            @test actual_filtered == expected_regular
            if actual_filtered != expected_regular
                @error "Column order mismatch for '$table_name'" expected = expected_regular actual =
                    actual_filtered
            end
        end
    end

    # Check for tables in schema.sql that aren't in TABLE_SCHEMAS
    @testset "Schema coverage" begin
        julia_tables = Set(keys(TABLE_SCHEMAS))
        # Tables that are OK to not have in TABLE_SCHEMAS
        utility_tables = Set(["entity_types"])

        for table_name in actual_tables
            if table_name in utility_tables
                continue
            end
            if !(table_name in julia_tables)
                @warn "Table '$table_name' in schema.sql but not in TABLE_SCHEMAS"
            end
        end
    end
end

@testset "OPENAPI_FIELDS_TO_DB mappings are valid" begin
    # Every field mapping should reference a table and column that exist in TABLE_SCHEMAS
    for ((table_name, openapi_field), db_column) in OPENAPI_FIELDS_TO_DB
        @testset "Mapping: ($table_name, $openapi_field) => $db_column" begin
            # Table must exist in TABLE_SCHEMAS
            haskey(TABLE_SCHEMAS, table_name) ||
                @error "Table not in TABLE_SCHEMAS" table_name
            @test haskey(TABLE_SCHEMAS, table_name)

            if haskey(TABLE_SCHEMAS, table_name)
                # Column must exist in that table's schema
                schema = TABLE_SCHEMAS[table_name]
                schema_columns = [lowercase(string(name)) for name in schema.names]
                lowercase(db_column) in schema_columns ||
                    @error "Column not in TABLE_SCHEMAS" table_name db_column schema_columns
                @test lowercase(db_column) in schema_columns
            end
        end
    end
end

@testset "TYPE_TO_TABLE references valid TABLE_SCHEMAS" begin
    # Every table referenced in TYPE_TO_TABLE must have a TABLE_SCHEMAS entry
    for (openapi_type, table_name) in TYPE_TO_TABLE
        @testset "Type: $openapi_type => $table_name" begin
            haskey(TABLE_SCHEMAS, table_name) ||
                @error "Table not in TABLE_SCHEMAS" openapi_type table_name
            @test haskey(TABLE_SCHEMAS, table_name)
        end
    end
end
