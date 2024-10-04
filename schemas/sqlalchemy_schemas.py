import sqlalchemy as sa
from sqlalchemy import (
    Table,
    Column,
    Integer,
    String,
    MetaData,
    ForeignKey,
    Text,
    JSON,
    Double,
)

metadata_obj = MetaData()

generation_unit = Table(
    "generation_unit",
    metadata_obj,
    Column("id", Integer, primary_key=True),
    Column("name", Text, nullable=False, unique=True),
    Column("obj_type", Text, nullable=False),
    Column("prime_mover", Text, nullable=False),
    Column("fuel_type", Text, nullable=False),
    Column("rating", Double, nullable=False),
    Column("base_power", Double, nullable=False),
)

supply_technology = Table(
    "supply_technology",
    metadata_obj,
    Column("id", Integer, primary_key=True),
    Column("name", Text, nullable=False, unique=True),
    Column("obj_type", Text, nullable=False),
    Column("prime_mover", Text, nullable=False),
    Column("fuel_type", Text, nullable=False),
    # Foreign Key for area
    Column("area_id", Integer, ForeignKey("area.id"), nullable=True),
    Column("balancing_id", Integer, ForeignKey("balancing_topology.id"), nullable=True),
)

balancing_topology = Table(
    "balancing_topology",
    metadata_obj,
    Column("id", Integer, primary_key=True),
    Column("name", Text, nullable=False, unique=True),
    Column("obj_type", Text, nullable=False),
    Column("area_id", Integer, ForeignKey("area.id"), nullable=True),
)

area = Table(
    "area",
    metadata_obj,
    Column("id", Integer, primary_key=True),
    Column("name", Text, nullable=False, unique=True),
)

transmission_line = Table(
    "transmission_line",
    metadata_obj,
    Column("id", Integer, primary_key=True),
    Column("name", Text, nullable=False, unique=True),
    Column("obj_type", Text, nullable=False),
    Column("from_id", Integer, ForeignKey("balancing_topology.id"), nullable=True),
    Column("to_id", Integer, ForeignKey("balancing_topology.id"), nullable=True),
    Column("rating", Double, nullable=False),
)

attributes = Table(
    "attributes",
    metadata_obj,
    Column("id", Integer, primary_key=True),
    Column("entity_id", Integer, nullable=False),
    Column("entity_type", Text, nullable=False),
    Column("key", Text, nullable=False),
    Column("value", JSON, nullable=False),
)
