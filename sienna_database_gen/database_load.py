from sqlalchemy import Connection, create_engine, insert, select
from .sqlalchemy_schemas import metadata_obj, balancing_topology, attributes
from .pydantic_schemas import (
    OBJ_SUBCLASSES,
    GenerateJSONSchemaWithSQLInfo,
    GenerationUnit,
    ObjModel,
    ACBus,
)

engine = create_engine("sqlite:///:memory:")
metadata_obj.create_all(engine)


acbus = ACBus(id=0, name="Bus 1", number=1)


def load_to_db(conn: Connection, data: ObjModel):
    json_data = data.model_dump(mode="JSON")
    row = {}
    for col in data.get_columns():
        row[col.name] = json_data[col.name]
        del json_data[col.name]

    conn.execute(insert(balancing_topology).values(row))
    conn.execute(
        insert(attributes).values(
            [
                {
                    "entity_id": data.id,
                    "entity_type": "balancing_topology",
                    "key": key,
                    "value": value,
                }
                for key, value in json_data.items()
            ]
        )
    )
    return data.id


def load_from_db(conn: Connection, table, id):
    entity_result = conn.execute(select(table).where(table.c.id == id))
    row = entity_result.fetchone()
    if row is None:
        return None

    entity_attributes = conn.execute(
        select(attributes.c.key, attributes.c.value).where(
            attributes.c.entity_id == id, attributes.c.entity_type == table.name
        )
    ).fetchall()
    full_json = {
        **{key: value for key, value in zip(entity_result.keys(), row)},
        **{key: value for key, value in entity_attributes},
    }

    data = OBJ_SUBCLASSES[full_json["obj_type"]].parse_obj(full_json)
    return data


with engine.begin() as conn:
    load_to_db(conn, acbus)

with engine.begin() as conn:
    print(conn.execute(select(balancing_topology)).fetchall())
    print(conn.execute(select(attributes)).fetchall())

with engine.begin() as conn:
    acbus2 = load_from_db(conn, balancing_topology, 0)

    assert acbus == acbus2

print(GenerationUnit.model_json_schema(schema_generator=GenerateJSONSchemaWithSQLInfo))
