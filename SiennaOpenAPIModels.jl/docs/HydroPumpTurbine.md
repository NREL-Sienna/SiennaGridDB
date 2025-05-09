# HydroPumpTurbine

## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **Int64** |  | [default to nothing]
**name** | **String** |  | [default to nothing]
**available** | **Bool** |  | [default to nothing]
**bus** | **Int64** |  | [default to nothing]
**active_power** | **Float64** |  | [default to nothing]
**reactive_power** | **Float64** |  | [default to nothing]
**rating** | **Float64** |  | [default to nothing]
**active_power_limits** | [***MinMax**](MinMax.md) |  | [default to nothing]
**reactive_power_limits** | [***MinMax**](MinMax.md) |  | [optional] [default to nothing]
**active_power_limits_pump** | [***MinMax**](MinMax.md) |  | [default to nothing]
**outflow_limits** | [***MinMax**](MinMax.md) |  | [optional] [default to nothing]
**head_reservoir** | [***HydroReservoir**](HydroReservoir.md) |  | [default to nothing]
**tail_reservoir** | [***HydroReservoir**](HydroReservoir.md) |  | [default to nothing]
**powerhouse_elevation** | **Float64** |  | [default to nothing]
**ramp_limits** | [***UpDown**](UpDown.md) |  | [optional] [default to nothing]
**time_limits** | [***UpDown**](UpDown.md) |  | [optional] [default to nothing]
**base_power** | **Float64** |  | [default to nothing]
**operation_cost** | [***HydroStorageGenerationCost**](HydroStorageGenerationCost.md) |  | [optional] [default to nothing]
**active_power_pump** | **Float64** |  | [optional] [default to 0.0]
**efficiency** | [***TurbinePump**](TurbinePump.md) |  | [optional] [default to nothing]
**transition_time** | [***TurbinePump**](TurbinePump.md) |  | [optional] [default to nothing]
**minimum_time** | [***TurbinePump**](TurbinePump.md) |  | [optional] [default to nothing]
**conversion_factor** | **Float64** |  | [optional] [default to 1.0]
**must_run** | **Bool** |  | [optional] [default to false]
**prime_mover_type** | **String** |  | [optional] [default to "OT"]
**dynamic_injector** | **Any** |  | [optional] [default to nothing]

[[Back to Model list]](../README.md#models) [[Back to API list]](../README.md#api-endpoints) [[Back to README]](../README.md)
