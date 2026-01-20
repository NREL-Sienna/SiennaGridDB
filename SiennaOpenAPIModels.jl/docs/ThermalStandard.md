# ThermalStandard

## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **Int64** |  | [default to nothing]
**name** | **String** |  | [default to nothing]
**available** | **Bool** |  | [default to nothing]
**status** | **Bool** |  | [default to nothing]
**bus** | **Int64** |  | [default to nothing]
**active_power** | **Float64** |  | [default to nothing]
**reactive_power** | **Float64** |  | [default to nothing]
**rating** | **Float64** |  | [default to nothing]
**active_power_limits** | [***MinMax**](MinMax.md) |  | [default to nothing]
**reactive_power_limits** | [***MinMax**](MinMax.md) |  | [optional] [default to nothing]
**ramp_limits** | [***UpDown**](UpDown.md) |  | [optional] [default to nothing]
**operation_cost** | [***ThermalGenerationCost**](ThermalGenerationCost.md) |  | [default to nothing]
**base_power** | **Float64** |  | [default to 0.0]
**time_limits** | [***UpDown**](UpDown.md) |  | [optional] [default to nothing]
**must_run** | **Bool** |  | [optional] [default to false]
**prime_mover_type** | **String** |  | [optional] [default to "OT"]
**fuel_type** | **String** | Thermal fuels that reflect options in the EIA annual energy review. | [optional] [default to "OTHER"]
**time_at_status** | **Float64** |  | [optional] [default to 10000.0]
**dynamic_injector** | **Any** |  | [optional] [default to nothing]

[[Back to Model list]](../README.md#models) [[Back to API list]](../README.md#api-endpoints) [[Back to README]](../README.md)
