function openapi2psip(node::Node, resolver::Resolver)
    PSIP.Node(name=node.name, id=node.id, bustype=get_bustype_enum(node.bustype))
end

function openapi2psip(zone::Zone, resolver::Resolver)
    PSIP.Zone(name=zone.name, id=zone.id)
end
