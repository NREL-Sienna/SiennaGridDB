# This file was generated by the Julia OpenAPI Code Generator
# Do not modify this file directly. Modify the OpenAPI specification instead.


@doc raw"""LinearFunctionData

    LinearFunctionData(;
        constant_term=nothing,
        function_type="LINEAR",
        proportional_term=nothing,
    )

    - constant_term::Float64
    - function_type::String
    - proportional_term::Float64
"""
Base.@kwdef mutable struct LinearFunctionData <: OpenAPI.APIModel
    constant_term::Union{Nothing, Float64} = nothing
    function_type::Union{Nothing, String} = "LINEAR"
    proportional_term::Union{Nothing, Float64} = nothing

    function LinearFunctionData(constant_term, function_type, proportional_term, )
        OpenAPI.validate_property(LinearFunctionData, Symbol("constant_term"), constant_term)
        OpenAPI.validate_property(LinearFunctionData, Symbol("function_type"), function_type)
        OpenAPI.validate_property(LinearFunctionData, Symbol("proportional_term"), proportional_term)
        return new(constant_term, function_type, proportional_term, )
    end
end # type LinearFunctionData

const _property_types_LinearFunctionData = Dict{Symbol,String}(Symbol("constant_term")=>"Float64", Symbol("function_type")=>"String", Symbol("proportional_term")=>"Float64", )
OpenAPI.property_type(::Type{ LinearFunctionData }, name::Symbol) = Union{Nothing,eval(Base.Meta.parse(_property_types_LinearFunctionData[name]))}

function check_required(o::LinearFunctionData)
    o.constant_term === nothing && (return false)
    o.function_type === nothing && (return false)
    o.proportional_term === nothing && (return false)
    true
end

function OpenAPI.validate_property(::Type{ LinearFunctionData }, name::Symbol, val)


    if name === Symbol("function_type")
        OpenAPI.validate_param(name, "LinearFunctionData", :enum, val, ["LINEAR"])
    end


end
