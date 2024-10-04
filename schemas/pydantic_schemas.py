from enum import StrEnum
from pydantic import BaseModel
from typing import ClassVar, Annotated
from sqlalchemy import Table, Column, Integer, Text
from .sqlalchemy_schemas import (
    generation_unit,
    supply_technology,
    balancing_topology,
    area,
)


class ACBusType(StrEnum):
    PQ = "PQ"
    PV = "PV"
    REF = "REF"
    ISOLATED = "ISOLATED"
    SLACK = "SLACK"


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


class GenerationUnit(ObjModel):
    _table_name: ClassVar[Table] = generation_unit


class SupplyTechnology(ObjModel):
    _table_name: ClassVar[Table] = supply_technology


class BalancingTopology(ObjModel):
    _table_name: ClassVar[Table] = balancing_topology


class Area(ObjModel):
    _table_name: ClassVar[Table] = area


class AreaInterchange(ObjModel):
    pass


# How do you declare optional fields in pydantic
class ACBus(BalancingTopology):
    number: int = 0
    bustype: str = ACBusType.PQ
    angle: float | None = None
    magnitude: float | None = None
    base_voltage: float | None = None
    voltage_limits: MinMax | None = None


class DCBus(ObjModel):
    pass


class LoadZone(ObjModel):
    pass


class Line(ObjModel):
    available: bool = True
    active_power_flow: float = 0.0
    reactive_power_flow: float = 0.0
    from_id: int
    to_id: int
    r: float = 0.0
    x: float = 0.0
    g: FromTo = FromTo(from_value=0.0, to_value=0.0)
    b: FromTo = FromTo(from_value=0.0, to_value=0.0)
    rating: float = 0.0
    angle_limits: MinMax = MinMax(min=-1.571, max=1.571)

    _from_table: ClassVar[list[str]] = ["from_id", "to_id", "rating"]


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


class PrimeMover(StrEnum):
    GAS = "GAS"
    STEAM = "STEAM"
    HYDRO = "HYDRO"
    NUCLEAR = "NUCLEAR"
    SOLAR = "SOLAR"
    WIND = "WIND"
    GEOTHERMAL = "GEOTHERMAL"
    BIOMASS = "BIOMASS"
    COAL = "COAL"
    OIL = "OIL"
    DIESEL = "DIESEL"
    GAS_TURBINE = "GAS_TURBINE"
    COMBINED_CYCLE = "COMBINED_CYCLE"
    INTERNAL_COMBUSTION = "INTERNAL_COMBUSTION"
    FUEL_CELL = "FUEL_CELL"
    STORAGE = "STORAGE"
    OTHER = "OTHER"
    UNKNOWN = "UNKNOWN"


class Fuels(StrEnum):
    GAS = "GAS"
    COAL = "COAL"
    OIL = "OIL"
    DIESEL = "DIESEL"
    OTHER = "OTHER"
    UNKNOWN = "UNKNOWN"


class ThermalGenerationCost(BaseModel):
    fixed: float
    variable: float
    curve: list[float]  # TODO: Figure out Sienna's real cost mechanism


class ThermalStandard(ObjModel):
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
    prime_mover: PrimeMover = PrimeMover.UNKNOWN
    fuel_type: Fuels = Fuels.UNKNOWN
    bus_id: int

    _external_attributes: ClassVar[list[str]] = [
        "prime_mover",
        "fuel_type",
        "bus_id",
        "rating",
        "base_power",
    ]


class ThermalMultiStart(ObjModel):
    pass


class EnergyReservoirStorage(ObjModel):
    pass
