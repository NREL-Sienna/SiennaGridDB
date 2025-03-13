function openapi2psy(bus::ACBus, resolver::Resolver)
    PSY.ACBus(;
        number=bus.number,
        name=bus.name,
        bustype=get_bustype_enum(bus.bustype),
        angle=bus.angle,
        magnitude=bus.magnitude,
        voltage_limits=get_nt_from_min_max(bus.voltage_limits),
        base_voltage=bus.base_voltage,
        area=resolver(bus.area),
        load_zone=resolver(bus.load_zone),
    )
end
