const OPENAPI_FIELDS_TO_DB = Dict(
    ("transmission_lines", "arc") => "arc_id",
    ("thermal_generators", "bus") => "balancing_topology",
    ("renewable_generators", "bus") => "balancing_topology",
    ("hydro_generators", "bus") => "balancing_topology",
    ("storage_units", "bus") => "balancing_topology",
    ("supply_technologies", "bus") => "balancing_topology",
    ("loads", "bus") => "balancing_topology",
    ("thermal_generators", "prime_mover_type") => "prime_mover",
    ("renewable_generators", "prime_mover_type") => "prime_mover",
    ("hydro_generators", "prime_mover_type") => "prime_mover",
    ("storage_units", "prime_mover_type") => "prime_mover",
    ("arcs", "from") => "from_id",
    ("arcs", "to") => "to_id",
    ("transmission_lines", "rating") => "continuous_rating",
)

const DB_TO_OPENAPI_FIELDS = Dict((s[1], t) => s[2] for (s, t) in OPENAPI_FIELDS_TO_DB)

const TYPE_TO_TABLE_LIST = [
    Area => "planning_regions",
    LoadZone => "balancing_topologies", # Assuming LoadZone maps to balancing topologies
    ACBus => "balancing_topologies", # Assuming ACBus maps to balancing topologies
    Arc => "arcs",
    AreaInterchange => "transmission_interchanges",
    Line => "transmission_lines",
    Transformer2W => "transmission_lines",
    MonitoredLine => "transmission_lines",
    PhaseShiftingTransformer => "transmission_lines",
    TapTransformer => "transmission_lines",
    TwoTerminalGenericHVDCLine => "transmission_lines",
    PowerLoad => "loads",
    StandardLoad => "loads",
    FixedAdmittance => "loads",
    InterruptiblePowerLoad => "loads",
    ThermalStandard => "thermal_generators",
    ThermalMultiStart => "thermal_generators",
    RenewableDispatch => "renewable_generators",
    RenewableNonDispatch => "renewable_generators",
    HydroDispatch => "hydro_generators",
    HydroTurbine => "hydro_generators",
    HydroPumpTurbine => "hydro_generators",
    EnergyReservoirStorage => "storage_units",
    HydroReservoir => "hydro_reservoir",
]

const TYPE_TO_TABLE = Dict(TYPE_TO_TABLE_LIST)

const ALL_PSY_TYPES = [
    PSY.Area,
    PSY.LoadZone,
    PSY.ACBus,
    PSY.Arc,
    PSY.AreaInterchange,
    PSY.Line,
    PSY.Transformer2W,
    PSY.MonitoredLine,
    PSY.PhaseShiftingTransformer,
    PSY.TapTransformer,
    PSY.TwoTerminalGenericHVDCLine,
    PSY.PowerLoad,
    PSY.StandardLoad,
    PSY.FixedAdmittance,
    PSY.InterruptiblePowerLoad,
    PSY.ThermalStandard,
    PSY.ThermalMultiStart,
    PSY.RenewableDispatch,
    PSY.RenewableNonDispatch,
    PSY.HydroDispatch,
    PSY.HydroTurbine,
    PSY.HydroPumpTurbine,
    PSY.EnergyReservoirStorage,
    PSY.HydroReservoir,
]

const ALL_TYPES = first.(TYPE_TO_TABLE_LIST)
const PSY_TO_OPENAPI_TYPE = Dict(k => v for (k, v) in zip(ALL_PSY_TYPES, ALL_TYPES))
const OPENAPI_TYPE_TO_PSY = Dict(v => k for (k, v) in zip(ALL_PSY_TYPES, ALL_TYPES))
const TYPE_NAMES = Dict(string(t) => t for t in ALL_TYPES)

const ALL_DESERIALIZABLE_TYPES = [
    Area,
    LoadZone,
    ACBus,
    Arc,
    AreaInterchange,
    Line,
    Transformer2W,
    MonitoredLine,
    PhaseShiftingTransformer,
    TapTransformer,
    TwoTerminalGenericHVDCLine,
    PowerLoad,
    StandardLoad,
    FixedAdmittance,
    InterruptiblePowerLoad,
    ThermalStandard,
    ThermalMultiStart,
    RenewableDispatch,
    RenewableNonDispatch,
    HydroDispatch,
    HydroTurbine,
    HydroPumpTurbine,
    EnergyReservoirStorage,
    HydroReservoir,
]
