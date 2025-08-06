function psy2openapi(bus::PSY.ACBus, ids::IDGenerator)
    ACBus(
        id=getid!(ids, bus),
        number=bus.number,
        name=bus.name,
        bustype=string(bus.bustype),
        angle=bus.angle,
        magnitude=bus.magnitude,
        voltage_limits=get_min_max(bus.voltage_limits),
        base_voltage=bus.base_voltage,
        area=getid!(ids, bus.area),
        available=bus.available,
        load_zone=getid!(ids, bus.load_zone),
    )
end

function psy2openapi(arc::PSY.Arc, ids::IDGenerator)
    Arc(id=getid!(ids, arc), from=getid!(ids, arc.from), to=getid!(ids, arc.to))
end

function psy2openapi(area::PSY.Area, ids::IDGenerator)
    if PSY.get_base_power(area) == 0.0
        error("base power is 0.0")
    end
    Area(
        id=getid!(ids, area),
        name=area.name,
        peak_active_power=area.peak_active_power * PSY.get_base_power(area),
        peak_reactive_power=area.peak_reactive_power * PSY.get_base_power(area),
        load_response=area.load_response,
    )
end

function psy2openapi(dcbus::PSY.DCBus, ids::IDGenerator)
    DCBus(
        id=getid!(ids, dcbus),
        number=dcbus.number,
        name=dcbus.name,
        magnitude=dcbus.magnitude,
        voltage_limits=get_min_max(dcbus.voltage_limits),
        base_voltage=dcbus.base_voltage,
        area=getid!(ids, dcbus.area),
        load_zone=getid!(ids, dcbus.load_zone),
    )
end

function psy2openapi(load_zone::PSY.LoadZone, ids::IDGenerator)
    if PSY.get_base_power(load_zone) == 0.0
        error("base power is 0.0")
    end
    LoadZone(
        id=getid!(ids, load_zone),
        name=load_zone.name,
        peak_active_power=load_zone.peak_active_power * PSY.get_base_power(load_zone),
        peak_reactive_power=load_zone.peak_reactive_power * PSY.get_base_power(load_zone),
    )
end
