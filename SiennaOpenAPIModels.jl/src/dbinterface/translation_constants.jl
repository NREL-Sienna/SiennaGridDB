const OPENAPI_FIELDS_TO_DB = Dict(
    ("transmission_lines", "arc") => "arc_id",
    ("generation_units", "bus") => "balancing_topology",
    ("storage_units", "bus") => "balancing_topology",
    ("supply_technologies", "bus") => "balancing_topology",
    ("loads", "bus") => "balancing_topology",
    ("generation_units", "prime_mover_type") => "prime_mover",
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
    ThermalStandard => "generation_units",
    RenewableDispatch => "generation_units",
    EnergyReservoirStorage => "storage_units", # Updated from generation_unit
    HydroDispatch => "generation_units",
    HydroTurbine => "generation_units",
    HydroPumpTurbine => "storage_units", # Updated from generation_unit
    ThermalMultiStart => "generation_units",
    RenewableNonDispatch => "generation_units",
    HydroReservoir => "hydro_reservoir",
    Zone => "planning_regions",
    Node => "balancing_topologies", #What should we do if we want to use the same nodes for both system and portfolio?
    NodalACTransportTechnology => "transport_technologies",
    NodalHVDCTransportTechnology => "transport_technologies",
    AggregateTransportTechnology => "transport_technologies",
    StorageTechnology => "supply_technologies",
    SupplyTechnology => "supply_technologies",
    #DemandRequirement => "loads", #Should go to a separate table?
    #DemandSideTechnology => "balancing_topologies" # Should go to a separate table?
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
    PSY.RenewableDispatch,
    PSY.EnergyReservoirStorage,
    PSY.HydroDispatch,
    PSY.HydroTurbine,
    PSY.HydroPumpTurbine,
    PSY.ThermalMultiStart,
    PSY.RenewableNonDispatch,
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
    RenewableDispatch,
    EnergyReservoirStorage,
    HydroDispatch,
    HydroTurbine,
    HydroPumpTurbine,
    ThermalMultiStart,
    RenewableNonDispatch,
    HydroReservoir,
]

##################
### PSIP Stuff ###
##################

const PSIP_OPENAPI_FIELDS_TO_DB = Dict(
    ("transport_technologies", "from_node") => "from_node_id",
    ("transport_technologies", "to_node") => "to_node_id",
    ("supply_technologies", "region") => "balancing_topology",
    ("storage_technologies", "region") => "balancing_topology",
    ("loads", "region") => "balancing_topology",
    ("supply_technologies", "prime_mover_type") => "prime_mover",
    ("storage_technologies", "prime_mover_type") => "prime_mover",
)

const DB_TO_PSIP_OPENAPI_FIELDS =
    Dict((s[1], t) => s[2] for (s, t) in PSIP_OPENAPI_FIELDS_TO_DB)

const PSIP_TYPE_TO_TABLE_LIST = [
    Zone => "planning_regions",
    Node => "balancing_topologies", #What should we do if we want to use the same nodes for both system and portfolio?
    NodalACTransportTechnology => "transport_technologies",
    NodalHVDCTransportTechnology => "transport_technologies",
    AggregateTransportTechnology => "transport_technologies",
    StorageTechnology => "storage_technologies",
    SupplyTechnology => "supply_technologies",
    #DemandRequirement => "loads", #Should go to a separate table?
    #DemandSideTechnology => "balancing_topologies" # Should go to a separate table?
]

const PSIP_TYPE_TO_TABLE = Dict(PSIP_TYPE_TO_TABLE_LIST)

const ALL_PSIP_TYPES = [
    PSIP.Zone,
    PSIP.Node,
    PSIP.NodalACTransportTechnology,
    PSIP.NodalHVDCTransportTechnology,
    PSIP.AggregateTransportTechnology,
    PSIP.StorageTechnology,
    PSIP.SupplyTechnology,
    #PSIP.DemandRequirement,
    #PSIP.DemandSideTechnology
]

const PSIP_TYPES = first.(PSIP_TYPE_TO_TABLE_LIST)
const PSIP_TO_OPENAPI_TYPE = Dict(k => v for (k, v) in zip(ALL_PSIP_TYPES, PSIP_TYPES))
const OPENAPI_TYPE_TO_PSIP = Dict(v => k for (k, v) in zip(ALL_PSIP_TYPES, PSIP_TYPES))
const PSIP_TYPE_NAMES = Dict(string(t) => t for t in PSIP_TYPES)

const PSIP_DESERIALIZABLE_TYPES = [
    Zone,
    Node,
    NodalACTransportTechnology,
    NodalHVDCTransportTechnology,
    AggregateTransportTechnology,
    StorageTechnology,
    SupplyTechnology,
    #DemandRequirement,
    #DemandSideTechnology
]
