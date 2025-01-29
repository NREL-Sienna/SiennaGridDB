from sqlalchemy import create_mock_engine
from .sqlalchemy_schemas import metadata_obj
from sqlalchemy.dialects.sqlite.pysqlite import SQLiteDialect_pysqlite
from .pydantic_schemas import (
    GenerateJSONSchemaWithSQLInfo,
    GenerationUnit,
    SupplyTechnology,
    BalancingTopology,
    Area,
    Transmission,
    Arc,
    Load,
)

sqlite_dialect = SQLiteDialect_pysqlite()


def metadata_dump(sql, *multiparams, **params):
    # print or write to log or file etc
    print(str(sql.compile(dialect=sqlite_dialect)) + ";")


def print_sqlite():
    engine = create_mock_engine("sqlite://", metadata_dump)
    metadata_obj.create_all(engine, checkfirst=False)


def print_schemas():
    for schemas in [
        GenerationUnit,
        SupplyTechnology,
        BalancingTopology,
        Area,
        Transmission,
        Arc,
        Load,
    ]:
        print(schemas.model_json_schema(schema_generator=GenerateJSONSchemaWithSQLInfo))
