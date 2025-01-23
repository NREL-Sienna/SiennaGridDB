import sys
from python_models.ACBus import *
from python_models.ThermalStandard import *
from python_models.common import *


def test_acbus():
    acbus = ACBus(id=3, name="4", number=2, bustype="PQ")
    assert acbus.id == 3


def test_thermal_standard():
    cost = ThermalGenerationCost(
        variable=CostCurve(
            value_curve=InputOutputCurve(
                function_data=LinearFunctionData(proportional_term=1, constant_term=0)
            ),
            power_units="NATURAL_UNITS",
            vom_cost=InputOutputCurve(
                function_data=LinearFunctionData(proportional_term=1, constant_term=0)
            ),
        ),
        fixed=2,
        start_up=StartUpStages(hot=1, cold=2, warm=3),
        shut_down=3,
    )

    thermal_standard = ThermalStandard(
        id=3, name="test_thermal", bus_id=3, operation_cost=cost
    )
    assert cost == thermal_standard.operation_cost
