function psy2openapi(bus::PSY.ACBus, ids::IDGenerator)
    ACBus(
        id = getid!(ids, bus),
        number = bus.number,
        name = bus.name,
        bustype = string(bus.bustype),
        angle = bus.angle,
        magnitude = bus.magnitude,
        voltage_limits = get_min_max(bus.voltage_limits),
        base_voltage = bus.base_voltage,
        area = getid!(ids, bus.area),
        load_zone = getid!(ids, bus.load_zone),
    )
end

function psy2openapi(arc::PSY.Arc, ids::IDGenerator)
    Arc(id = getid!(ids, arc), from = getid!(ids, arc.from), to = getid!(ids, arc.to))
end
