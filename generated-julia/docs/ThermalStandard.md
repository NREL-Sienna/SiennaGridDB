# ThermalStandard


## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **Int64** |  | [default to nothing]
**name** | **String** |  | [default to nothing]
**prime_mover** | **String** |  | [optional] [default to "OT"]
**fuel_type** | **String** | Thermal fuels that reflect options in the EIA annual energy review. | [optional] [default to "OTHER"]
**rating** | **Float64** |  | [optional] [default to 0.0]
**base_power** | **Float64** |  | [optional] [default to 0.0]
**available** | **Bool** |  | [optional] [default to true]
**status** | **Bool** |  | [optional] [default to true]
**active_power** | **Float64** |  | [optional] [default to 0.0]
**reactive_power** | **Float64** |  | [optional] [default to 0.0]
**active_power_limits** | [***MinMax**](MinMax.md) |  | [optional] [default to nothing]
**reactive_power_limits** | [***MinMax**](MinMax.md) |  | [optional] [default to nothing]
**ramp_limits** | [***UpDown**](UpDown.md) |  | [optional] [default to nothing]
**operation_cost** | [***ThermalStandardOperationCost**](ThermalStandardOperationCost.md) |  | [default to nothing]
**time_limits** | [***UpDown**](UpDown.md) |  | [optional] [default to nothing]
**must_run** | **Bool** |  | [optional] [default to false]
**bus_id** | **Int64** |  | [default to nothing]


[[Back to Model list]](../README.md#models) [[Back to API list]](../README.md#api-endpoints) [[Back to README]](../README.md)


