function get_bustype_enum(bustype::String)
    if bustype == "PQ"
        return PSY.ACBusTypes.PQ
    elseif bustype == "PV"
        return PSY.ACBusTypes.PV
    elseif bustype == "REF"
        return PSY.ACBusTypes.REF
    elseif bustype == "ISOLATED"
        return PSY.ACBusTypes.ISOLATED
    elseif bustype == "SLACK"
        return PSY.ACBusTypes.SLACK
    else
        error("Unknown bus type: $bustype")
    end
end

function get_tuple_min_max(obj::MinMax)
    return (min=obj.min, max=obj.max)
end

mutable struct Resolver
    sys::PSY.System
    id2uuid::Dict{Int64, UUID}
end

function resolver_from_id_generator(idgen::IDGenerator, sys::PSY.System)
    inverted_dict = Dict()
    for (uuid, id) in idgen.uuid2int
        inverted_dict[id] = uuid
    end
    return Resolver(sys, inverted_dict)
end

function (resolve::Resolver)(id::Int64)
    PSY.get_component(resolve.sys, resolver.id2uuid(id))
end

function (resolve::Resolver)(id::Nothing)
    nothing
end
