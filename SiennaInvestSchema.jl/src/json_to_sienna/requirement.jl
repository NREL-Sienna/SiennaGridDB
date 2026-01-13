function openapi2psip(requirement::CapacityReserveMargin, resolver::Resolver)
    PSIP.CapacityReserveMargin(
        name=requirement.name,
        id=requirement.id,
        available=requirement.available,
        capacity_reserve_fraction=requirement.capacity_reserve_fraction,
        target_year=requirement.target_year,
        eligible_technologies = [get_property(PowerSystemsInvestmentsPortfolios, t) for t in requirement.eligible_technologies]
    )
end

function openapi2psip(requirement::CarbonCaps, resolver::Resolver)
    PSIP.CarbonCaps(
        name=requirement.name,
        id=requirement.id,
        available=requirement.available,
        max_mtons=requirement.max_mtons,
        max_tons_mwh=requirement.max_tons_mwh,
        target_year=requirement.target_year,
        eligible_regions = [resolver(r) for r in requirement.eligible_regions]
    )
end

function openapi2psip(requirement::CarbonTax, resolver::Resolver)
    PSIP.CarbonTax(
        name=requirement.name,
        id=requirement.id,
        available=requirement.available,
        tax_dollars_per_ton=requirement.tax_dollars_per_ton,
        target_year=requirement.target_year,
        eligible_regions = [resolver(r) for r in requirement.eligible_regions]
    )
end

function openapi2psip(requirement::EnergyShareRequirements, resolver::Resolver)
    PSIP.EnergyShareRequirements(
        name=requirement.name,
        id=requirement.id,
        available=requirement.available,
        generation_fraction_requirement=requirement.generation_fraction_requirement,
        target_year=requirement.target_year,
        eligible_resources = [get_property(PowerSystemsInvestmentsPortfolios, t) for t in requirement.eligible_resources],
        eligible_regions = [resolver(r) for r in requirement.eligible_regions]
    )
end

function openapi2psip(requirement::HourlyMatching, resolver::Resolver)
    PSIP.HourlyMatching(
        name=requirement.name,
        id=requirement.id,
        available=requirement.available,
        target_year=requirement.target_year,
        eligible_demand = [get_property(PowerSystemsInvestmentsPortfolios, t) for t in requirement.eligible_demand],
        eligible_resources = [get_property(PowerSystemsInvestmentsPortfolios, t) for t in requirement.eligible_resources],
    )
end

function openapi2psip(requirement::MaximumCapacityRequirements, resolver::Resolver)
    PSIP.MaximumCapacityRequirements(
        name=requirement.name,
        id=requirement.id,
        available=requirement.available,
        max_capacity_mw=requirement.max_capacity_mw,
        target_year=requirement.target_year,
        eligible_resources = [get_property(PowerSystemsInvestmentsPortfolios, t) for t in requirement.eligible_resources],
    )
end

function openapi2psip(requirement::MinimumCapacityRequirements, resolver::Resolver)
    PSIP.MinimumCapacityRequirements(
        name=requirement.name,
        id=requirement.id,
        available=requirement.available,
        min_capacity_mw=requirement.max_capacity_mw,
        target_year=requirement.target_year,
        eligible_resources = [get_property(PowerSystemsInvestmentsPortfolios, t) for t in requirement.eligible_resources],
    )
end