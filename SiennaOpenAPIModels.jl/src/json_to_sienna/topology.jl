function openapi2psy(bus::ACBus, resolver::Resolver)
    PSY.ACBus(;
        number=bus.number,
        name=bus.name,
        bustype=get_bustype_enum(bus.bustype),
        angle=bus.angle,
        magnitude=bus.magnitude,
        voltage_limits=get_tuple_min_max(bus.voltage_limits),
        base_voltage=bus.base_voltage,
        area=resolver(bus.area),
        available=bus.available,
        load_zone=resolver(bus.load_zone),
    )
end

function openapi2psy(arc::Arc, resolver::Resolver)
    PSY.Arc(from=resolver(arc.from), to=resolver(arc.to))
end

function openapi2psy(area::Area, resolver::Resolver)
    if PSY.get_base_power(resolver.sys) == 0.0
        error("base power is 0.0")
    end
    PSY.Area(
        name=area.name,
        peak_active_power=(area.peak_active_power / PSY.get_base_power(resolver.sys)),
        peak_reactive_power=(area.peak_reactive_power / PSY.get_base_power(resolver.sys)),
        load_response=area.load_response,
    )
end

function openapi2psy(dcbus::DCBus, resolver::Resolver)
    PSY.DCBus(
        number=dcbus.number,
        name=dcbus.name,
        available=dcbus.available,
        magnitude=dcbus.magnitude,
        voltage_limits=get_tuple_min_max(dcbus.voltage_limits),
        base_voltage=dcbus.base_voltage,
        area=resolver(dcbus.area),
        load_zone=resolver(dcbus.load_zone),
    )
end
function openapi2psy(load_zone::LoadZone, resolver::Resolver)
    if PSY.get_base_power(resolver.sys) == 0.0
        error("base power is 0.0")
    end
    PSY.LoadZone(
        name=load_zone.name,
        peak_active_power=(load_zone.peak_active_power / PSY.get_base_power(resolver.sys)),
        peak_reactive_power=(
            load_zone.peak_reactive_power / PSY.get_base_power(resolver.sys)
        ),
    )
end
