# This file was generated by the Julia OpenAPI Code Generator
# Do not modify this file directly. Modify the OpenAPI specification instead.


@doc raw"""RenewableGenerationCost
Cost representation for renewable generation units

    RenewableGenerationCost(;
        cost_type="RENEWABLE",
        curtailment_cost=nothing,
        variable=nothing,
    )

    - cost_type::String
    - curtailment_cost::CostCurve
    - variable::CostCurve
"""
Base.@kwdef mutable struct RenewableGenerationCost <: OpenAPI.APIModel
    cost_type::Union{Nothing, String} = "RENEWABLE"
    curtailment_cost = nothing # spec type: Union{ Nothing, CostCurve }
    variable = nothing # spec type: Union{ Nothing, CostCurve }

    function RenewableGenerationCost(cost_type, curtailment_cost, variable, )
        OpenAPI.validate_property(RenewableGenerationCost, Symbol("cost_type"), cost_type)
        OpenAPI.validate_property(RenewableGenerationCost, Symbol("curtailment_cost"), curtailment_cost)
        OpenAPI.validate_property(RenewableGenerationCost, Symbol("variable"), variable)
        return new(cost_type, curtailment_cost, variable, )
    end
end # type RenewableGenerationCost

const _property_types_RenewableGenerationCost = Dict{Symbol,String}(Symbol("cost_type")=>"String", Symbol("curtailment_cost")=>"CostCurve", Symbol("variable")=>"CostCurve", )
OpenAPI.property_type(::Type{ RenewableGenerationCost }, name::Symbol) = Union{Nothing,eval(Base.Meta.parse(_property_types_RenewableGenerationCost[name]))}

function check_required(o::RenewableGenerationCost)
    o.variable === nothing && (return false)
    true
end

function OpenAPI.validate_property(::Type{ RenewableGenerationCost }, name::Symbol, val)

    if name === Symbol("cost_type")
        OpenAPI.validate_param(name, "RenewableGenerationCost", :enum, val, ["RENEWABLE"])
    end



end
