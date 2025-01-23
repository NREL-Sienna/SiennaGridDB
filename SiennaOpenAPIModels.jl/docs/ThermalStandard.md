# ThermalStandard


## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**active_power** | **Float64** |  | [optional] [default to 0.0]
**active_power_limits** | [***MinMax**](MinMax.md) |  | [optional] [default to nothing]
**available** | **Bool** |  | [optional] [default to true]
**base_power** | **Float64** |  | [optional] [default to 0.0]
**bus_id** | **Int64** |  | [default to nothing]
**fuel_type** | **String** | Thermal fuels that reflect options in the EIA annual energy review. | [optional] [default to "OTHER"]
**id** | **Int64** |  | [default to nothing]
**must_run** | **Bool** |  | [optional] [default to false]
**name** | **String** |  | [default to nothing]
**operation_cost** | [***ThermalStandardOperationCost**](ThermalStandardOperationCost.md) |  | [default to nothing]
**prime_mover** | **String** |  | [optional] [default to "OT"]
**ramp_limits** | [***UpDown**](UpDown.md) |  | [optional] [default to nothing]
**rating** | **Float64** |  | [optional] [default to 0.0]
**reactive_power** | **Float64** |  | [optional] [default to 0.0]
**reactive_power_limits** | [***MinMax**](MinMax.md) |  | [optional] [default to nothing]
**status** | **Bool** |  | [optional] [default to true]
**time_limits** | [***UpDown**](UpDown.md) |  | [optional] [default to nothing]


[[Back to Model list]](../README.md#models) [[Back to API list]](../README.md#api-endpoints) [[Back to README]](../README.md)


