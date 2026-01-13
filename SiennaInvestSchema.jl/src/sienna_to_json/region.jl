function psip2openapi(node::PSIP.Node, ids::IDGenerator)
    Node(
        name=node.name,
        id=node.id,
        bustype=string(node.bustype),
    )
end

function psip2openapi(zone::PSIP.Zone, ids::IDGenerator)
    Zone(
        name=zone.name,
        id=zone.id
    )
end
