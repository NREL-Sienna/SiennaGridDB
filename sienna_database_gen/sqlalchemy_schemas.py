import sqlalchemy as sa
from sqlalchemy import Table, Column, Integer, Text, JSON, MetaData
from .pydantic_schemas import (
    create_table,
    GenerationUnit,
    SupplyTechnology,
    BalancingTopology,
    Area,
    Transmission,
    Arc,
    Load,
)

metadata_obj = MetaData()
arc = create_table(Arc, metadata_obj)
balancing_topology = create_table(BalancingTopology, metadata_obj)
generation_unit = create_table(GenerationUnit, metadata_obj)
supply_technology = create_table(SupplyTechnology, metadata_obj)
area = create_table(Area, metadata_obj)
transmission_line = create_table(Transmission, metadata_obj)
load = create_table(Load, metadata_obj)
attributes = Table(
    "attributes",
    metadata_obj,
    Column("id", Integer, primary_key=True, autoincrement=True),
    Column("entity_id", Integer, nullable=False),
    Column("entity_type", Text, nullable=False),
    Column("key", Text, nullable=False),
    Column("value", JSON, nullable=False),
)
