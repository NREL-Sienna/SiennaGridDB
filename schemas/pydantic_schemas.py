"""Plan:

1. Create a class for each table in the database
2. Create a class for each table in the schema
3. Annotate all columns with SQLAlchemy Column information and table name
4. Create tables with SQLAlchemy Table
5. Use obj_type when parsing to determine how to parse or separate into attributes
"""

from enum import StrEnum
from pydantic import BaseModel, Field, PositiveInt, model_validator, validator
from typing import Any, ClassVar, Annotated, get_type_hints
from sqlalchemy import Double, ForeignKey, Table, Column, Integer, Text

from R2X_schemas.enums import ACBusTypes, PrimeMoversType, ThermalFuels
from R2X_schemas.units import ApparentPower, Voltage


class MinMax(BaseModel):
    min: float
    max: float


class FromTo(BaseModel):
    from_value: float
    to_value: float


class UpDown(BaseModel):
    up: float
    down: float


class ObjModel(BaseModel):
    id: Annotated[int, Column(Integer, primary_key=True)]
    name: Annotated[str, Column(Text, nullable=False, unique=True)]
    obj_type: Annotated[str, Column(Text, nullable=False)] = "ObjModel"

    @classmethod
    def get_columns(cls):
        cols = [
            get_column_from_annotation(value, key)
            for key, value in get_type_hints(cls, include_extras=True).items()
        ]
        return list(filter(lambda x: x is not None, cols))

    @model_validator(mode="after")
    def set_obj_type(self):
        if self.obj_type == "ObjModel":
            self.obj_type = self.__class__.__name__
        else:
            assert self.obj_type == self.__class__.__name__, "obj_type must match class"
        return self


class GenerationUnit(ObjModel):
    prime_mover: Annotated[PrimeMoversType | None, Column(Text, nullable=True)]
    fuel_type: Annotated[ThermalFuels | None, Column(Text, nullable=True)]
    rating: Annotated[ApparentPower, Column(Double, nullable=False)]
    base_power: Annotated[ApparentPower, Column(Double, nullable=False)]
    _table_name: ClassVar[str] = "generation_unit"


class SupplyTechnology(ObjModel):
    prime_mover: Annotated[PrimeMoversType | None, Column(Text, nullable=True)]
    fuel_type: Annotated[ThermalFuels | None, Column(Text, nullable=True)]
    area_id: Annotated[
        int | None, Column(Integer, ForeignKey("area.id"), nullable=True)
    ]
    balancing_id: Annotated[
        int | None, Column(Integer, ForeignKey("balancing_topology.id"), nullable=True)
    ]
    _table_name: ClassVar[Table] = "supply_technology"


class BalancingTopology(ObjModel):
    area_id: Annotated[
        int | None, Column(Integer, ForeignKey("area.id"), nullable=True)
    ] = None
    _table_name: ClassVar[Table] = "balancing_topology"


class Area(ObjModel):
    _table_name: ClassVar[Table] = "area"


class TransmissionLine(ObjModel):
    from_id: Annotated[
        int | None, Column(Integer, ForeignKey("balancing_topology.id"), nullable=False)
    ]
    to_id: Annotated[
        int | None, Column(Integer, ForeignKey("balancing_topology.id"), nullable=False)
    ]
    rating: Annotated[float, Column(Double, nullable=False)]
    _table_name: ClassVar[Table] = "transmission_line"


def get_column_from_annotation(type_hint, name: str):
    if not hasattr(type_hint, "__metadata__"):
        return None
    for annotation in type_hint.__metadata__:
        if isinstance(annotation, Column):
            annotation = annotation.copy()
            if annotation.name is None:
                annotation.name = name
            return annotation
    return None


def create_table(cls, metadata_obj):
    return Table(cls._table_name, metadata_obj, *cls.get_columns())


class AreaInterchange(ObjModel):
    pass


# How do you declare optional fields in pydantic
class ACBus(BalancingTopology):
    number: PositiveInt = 0
    bustype: ACBusTypes = ACBusTypes.PQ
    angle: Annotated[float | None, Field(gt=-1.572, lt=1.572)] = None
    magnitude: Annotated[Voltage | None, Field(gt=0)] = None
    base_voltage: Annotated[Voltage | None, Field(gt=0)] = None
    voltage_limits: MinMax | None = None


class DCBus(ObjModel):
    pass


class LoadZone(ObjModel):
    pass


class Line(TransmissionLine):
    available: bool = True
    active_power_flow: float = 0.0
    reactive_power_flow: float = 0.0
    r: float = 0.0
    x: float = 0.0
    g: FromTo = FromTo(from_value=0.0, to_value=0.0)
    b: FromTo = FromTo(from_value=0.0, to_value=0.0)
    angle_limits: MinMax = MinMax(min=-1.571, max=1.571)


class MonitoredLine(ObjModel):
    pass


class PhaseShiftingTransformer(ObjModel):
    pass


class TapTransformer(ObjModel):
    pass


class Transformer2W(ObjModel):
    pass


class TwoTerminalDCLine(ObjModel):
    pass


class TwoTerminalVSCDLine(ObjModel):
    pass


class TModelHVDCLine(ObjModel):
    pass


class InterruptiblePowerLoad(ObjModel):
    pass


class FixedAdmittance(ObjModel):
    pass


class SwitchedAdmittance(ObjModel):
    pass


class PowerLoad(ObjModel):
    pass


class StandardLoad(ObjModel):
    pass


class ExponentialLoad(ObjModel):
    pass


class InteronnectingConverter(ObjModel):
    pass


class HydroEnergyReservoir(ObjModel):
    pass


class HydroDispatch(ObjModel):
    pass


class HydroPumedStorage(ObjModel):
    pass


class RenewableDispatch(ObjModel):
    pass


class RenewableNonDispatch(ObjModel):
    pass


class ThermalGenerationCost(BaseModel):
    fixed: float
    variable: float
    curve: list[float]  # TODO: Figure out Sienna's real cost mechanism


class ThermalStandard(GenerationUnit):
    available: bool = True
    status: bool = True
    active_power: float = 0.0
    reactive_power: float = 0.0
    rating: float = 0.0
    active_power_limits: MinMax = MinMax(min=0.0, max=0.0)
    reactive_power_limits: MinMax | None = None
    ramp_limits: MinMax | None = MinMax(min=0.0, max=0.0)
    operation_cost: ThermalGenerationCost
    base_power: float = 0.0
    time_limits: UpDown | None = None
    must_run: bool = False
    prime_mover: PrimeMoversType = PrimeMoversType.OT
    fuel_type: ThermalFuels = ThermalFuels.OTHER
    bus_id: int


class ThermalMultiStart(ObjModel):
    pass


class EnergyReservoirStorage(ObjModel):
    pass


# cls.__subclasses__() is not transitive, so either we list them all manually
# or we use a recursive function to get all subclasses
OBJ_SUBCLASSES = {
    "GenerationUnit": GenerationUnit,
    "SupplyTechnology": SupplyTechnology,
    "BalancingTopology": BalancingTopology,
    "Area": Area,
    "TransmissionLine": TransmissionLine,
    "AreaInterchange": AreaInterchange,
    "ACBus": ACBus,
    "DCBus": DCBus,
    "LoadZone": LoadZone,
    "Line": Line,
    "MonitoredLine": MonitoredLine,
    "PhaseShiftingTransformer": PhaseShiftingTransformer,
    "TapTransformer": TapTransformer,
    "Transformer2W": Transformer2W,
    "TwoTerminalDCLine": TwoTerminalDCLine,
    "TwoTerminalVSCDLine": TwoTerminalVSCDLine,
    "TModelHVDCLine": TModelHVDCLine,
    "InterruptiblePowerLoad": InterruptiblePowerLoad,
    "FixedAdmittance": FixedAdmittance,
    "SwitchedAdmittance": SwitchedAdmittance,
    "PowerLoad": PowerLoad,
    "StandardLoad": StandardLoad,
    "ExponentialLoad": ExponentialLoad,
    "InteronnectingConverter": InteronnectingConverter,
    "HydroEnergyReservoir": HydroEnergyReservoir,
    "HydroDispatch": HydroDispatch,
    "HydroPumedStorage": HydroPumedStorage,
    "RenewableDispatch": RenewableDispatch,
    "RenewableNonDispatch": RenewableNonDispatch,
    "ThermalStandard": ThermalStandard,
    "ThermalMultiStart": ThermalMultiStart,
    "EnergyReservoirStorage": EnergyReservoirStorage,
}
