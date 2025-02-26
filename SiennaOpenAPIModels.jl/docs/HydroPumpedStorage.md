# HydroPumpedStorage


## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**active_power** | **Float64** |  | [default to nothing]
**active_power_limits** | [***MinMax**](MinMax.md) |  | [default to nothing]
**active_power_limits_pump** | [***MinMax**](MinMax.md) |  | [default to nothing]
**available** | **Bool** |  | [default to nothing]
**base_power** | **Float64** |  | [default to nothing]
**bus** | **Int64** |  | [default to nothing]
**conversion_factor** | **Float64** |  | [optional] [default to 1.0]
**id** | **Int64** |  | [default to nothing]
**inflow** | **Float64** |  | [default to nothing]
**initial_storage** | [***UpDown**](UpDown.md) |  | [default to nothing]
**name** | **String** |  | [default to nothing]
**outflow** | **Float64** |  | [default to nothing]
**operation_cost** | [***HydroStorageGenerationCost**](HydroStorageGenerationCost.md) |  | [optional] [default to nothing]
**prime_mover_type** | **String** |  | [default to "OT"]
**pump_efficiency** | **Float64** |  | [optional] [default to 1.0]
**ramp_limits** | [***UpDown**](UpDown.md) |  | [optional] [default to nothing]
**ramp_limits_pump** | [***UpDown**](UpDown.md) |  | [optional] [default to nothing]
**rating** | **Float64** |  | [default to nothing]
**rating_pump** | **Float64** |  | [default to nothing]
**reactive_power** | **Float64** |  | [default to nothing]
**reactive_power_limits** | [***MinMax**](MinMax.md) |  | [optional] [default to nothing]
**reactive_power_limits_pump** | [***MinMax**](MinMax.md) |  | [optional] [default to nothing]
**status** | **String** |  | [optional] [default to "OFF"]
**storage_capacity** | [***UpDown**](UpDown.md) |  | [default to nothing]
**storage_target** | [***UpDown**](UpDown.md) |  | [optional] [default to nothing]
**time_at_status** | **Float64** |  | [optional] [default to 10000.0]
**time_limits** | [***UpDown**](UpDown.md) |  | [optional] [default to nothing]
**time_limits_pump** | [***UpDown**](UpDown.md) |  | [optional] [default to nothing]
**dynamic_injector** | **Any** |  | [optional] [default to nothing]


[[Back to Model list]](../README.md#models) [[Back to API list]](../README.md#api-endpoints) [[Back to README]](../README.md)


