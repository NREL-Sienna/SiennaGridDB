# coding: utf-8

"""
    PowerSystemModels

    No description provided (generated by Openapi Generator https://github.com/openapitools/openapi-generator)

    The version of the OpenAPI document: 1.0.0
    Generated by OpenAPI Generator (https://openapi-generator.tech)

    Do not edit the class manually.
"""  # noqa: E501


from __future__ import annotations
import json
from enum import Enum
from typing_extensions import Self


class ThermalFuels(str, Enum):
    """
    Thermal fuels that reflect options in the EIA annual energy review.
    """

    """
    allowed enum values
    """
    COAL = 'COAL'
    WASTE_COAL = 'WASTE_COAL'
    DISTILLATE_FUEL_OIL = 'DISTILLATE_FUEL_OIL'
    WASTE_OIL = 'WASTE_OIL'
    PETROLEUM_COKE = 'PETROLEUM_COKE'
    RESIDUAL_FUEL_OIL = 'RESIDUAL_FUEL_OIL'
    NATURAL_GAS = 'NATURAL_GAS'
    OTHER_GAS = 'OTHER_GAS'
    NUCLEAR = 'NUCLEAR'
    AG_BIPRODUCT = 'AG_BIPRODUCT'
    MUNICIPAL_WASTE = 'MUNICIPAL_WASTE'
    WOOD_WASTE = 'WOOD_WASTE'
    GEOTHERMAL = 'GEOTHERMAL'
    OTHER = 'OTHER'

    @classmethod
    def from_json(cls, json_str: str) -> Self:
        """Create an instance of ThermalFuels from a JSON string"""
        return cls(json.loads(json_str))
