function openapi2psip(attribute::RetirementPotential, resolver::Resolver)
    PSIP.RetirementPotential(;
        planned_retirement_year=attribute.planned_retirement_year,
        eligible_generators=attribute.eligible_generators,
        build_year=attribute.build_year,
    )
end

function openapi2psip(attribute::RetrofitPotential, resolver::Resolver)
    PSIP.RetrofitPotential(;
        eligible_generators=attribute.eligible_generators,
    )
end

function openapi2psip(attribute::AggregateRetirementPotential, resolver::Resolver)
    PSIP.AggregateRetirementPotential(;
        retirement_potential=attribute.retirement_potential,
    )
end

function openapi2psip(attribute::AggregateRetrofitPotential, resolver::Resolver)
    PSIP.AggregateRetrofitPotential(;
        retrofit_id=attribute.retrofit_id,
        retrofit_fraction=attribute.retrofit_fraction,
        retrofit_potential=attribute.retrofit_potential,
    )
end

function openapi2psip(attribute::TopologyMapping, resolver::Resolver)
    PSIP.TopologyMapping(;
        buses=attribute.buses,
    )
end

function openapi2psip(attribute::ExistingCapacity, resolver::Resolver)
    PSIP.ExistingCapacity(;
        existing_technologies=attribute.existing_technologies,
    )
end