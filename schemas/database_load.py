from sqlalchemy import Connection, create_engine, insert, select
from sqlalchemy_schemas import metadata_obj, balancing_topology, attributes
from pydantic_schemas import ACBus

engine = create_engine("sqlite:///:memory:")
metadata_obj.create_all(engine)


acbus = ACBus(id=0, name="Bus 1", number=1)


def load_to_db(conn: Connection, data: ACBus):
    json_data = data.model_dump(mode="JSON")
    row = {}
    for key in ACBus._from_table + ["id", "name"]:
        row[key] = json_data[key]
        del json_data[key]
    row["obj_type"] = "ACBus"

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


with engine.begin() as conn:
    load_to_db(conn, acbus)

with engine.begin() as conn:
    print(conn.execute(select(balancing_topology)).fetchall())
    print(conn.execute(select(attributes)).fetchall())
