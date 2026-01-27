function psip2openapi(node::PSIP.Node, ids::IDGenerator)
    Node(
        name=node.name,
        id=getid!(ids, node),
        bus_type=string(node.bus_type),
    )
end

function psip2openapi(zone::PSIP.Zone, ids::IDGenerator)
    Zone(
        name=zone.name,
        id=getid!(ids, zone)
    )
end
