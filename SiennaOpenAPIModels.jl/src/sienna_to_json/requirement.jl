function psip2openapi(requirement::PSIP.CapacityReserveMargin, ids::IDGenerator)
    CapacityReserveMargin(
        name=requirement.name,
        id=requirement.id,
        available=requirement.available,
        capacity_reserve_fraction=requirement.capacity_reserve_fraction,
        target_year=requirement.target_year,
        eligible_technologies=[string(t) for t in requirement.eligible_technologies],
    )
end

function psip2openapi(requirement::PSIP.CarbonCaps, ids::IDGenerator)
    CarbonCaps(
        name=requirement.name,
        id=requirement.id,
        available=requirement.available,
        max_mtons=requirement.max_mtons,
        max_tons_mwh=requirement.max_tons_mwh,
        target_year=requirement.target_year,
        eligible_regions=[PSIP.get_id(r) for r in requirement.eligible_regions],
    )
end

function psip2openapi(requirement::PSIP.CarbonTax, ids::IDGenerator)
    CarbonTax(
        name=requirement.name,
        id=requirement.id,
        available=requirement.available,
        tax_dollars_per_ton=requirement.tax_dollars_per_ton,
        target_year=requirement.target_year,
        eligible_regions=[PSIP.get_id(r) for r in requirement.eligible_regions], #Probably replace the get_id with the ids thing in the DB
    )
end

function psip2openapi(requirement::PSIP.EnergyShareRequirements, ids::IDGenerator)
    EnergyShareRequirements(
        name=requirement.name,
        id=requirement.id,
        available=requirement.available,
        generation_fraction_requirement=requirement.generation_fraction_requirement,
        target_year=requirement.target_year,
        eligible_resources=[string(t) for t in requirement.eligible_resources],
        eligible_regions=[PSIP.get_id(r) for r in requirement.eligible_regions],
    )
end

function psip2openapi(requirement::HourlyMatching, ids::IDGenerator)
    PSIP.HourlyMatching(
        name=requirement.name,
        id=requirement.id,
        available=requirement.available,
        target_year=requirement.target_year,
        eligible_demand=[string(t) for t in requirement.eligible_demand],
        eligible_resources=[string(t) for t in requirement.eligible_resources],
    )
end

function psip2openapi(requirement::MaximumCapacityRequirements, ids::IDGenerator)
    PSIP.MaximumCapacityRequirements(
        name=requirement.name,
        id=requirement.id,
        available=requirement.available,
        max_capacity_mw=requirement.max_capacity_mw,
        target_year=requirement.target_year,
        eligible_resources=[string(t) for t in requirement.eligible_resources], #we have a proper function for getting this, I just forget it, go find it
    )
end

function psip2openapi(requirement::MinimumCapacityRequirements, ids::IDGenerator)
    PSIP.MinimumCapacityRequirements(
        name=requirement.name,
        id=requirement.id,
        available=requirement.available,
        min_capacity_mw=requirement.max_capacity_mw,
        target_year=requirement.target_year,
        eligible_resources=[string(t) for t in requirement.eligible_resources],
    )
end
