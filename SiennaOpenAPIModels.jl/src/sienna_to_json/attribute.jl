function psip2openapi(attribute::PSIP.RetirementPotential, ids::IDGenerator)
    RetirementPotential(;
        planned_retirement_year=attribute.planned_retirement_year,
        eligible_generators=attribute.eligible_generators,
        build_year=attribute.build_year,
    )
end

function psip2openapi(attribute::PSIP.RetrofitPotential, ids::IDGenerator)
    RetrofitPotential(;
        eligible_generators=attribute.eligible_generators,
    )
end

function psip2openapi(attribute::PSIP.AggregateRetirementPotential, ids::IDGenerator)
    AggregateRetirementPotential(;
        retirement_potential=attribute.retirement_potential,
    )
end

function psip2openapi(attribute::PSIP.AggregateRetrofitPotential, ids::IDGenerator)
    AggregateRetrofitPotential(;
        retrofit_id=attribute.retrofit_id,
        retrofit_fraction=attribute.retrofit_fraction,
        retrofit_potential=attribute.retrofit_potential,
    )
end

function psip2openapi(attribute::PSIP.TopologyMapping, ids::IDGenerator)
    TopologyMapping(;
        buses=attribute.buses,
    )
end

function psip2openapi(attribute::PSIP.ExistingCapacity, ids::IDGenerator)
    ExistingCapacity(;
        existing_technologies=attribute.existing_technologies,
    )
end