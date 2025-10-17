# HydroTurbine

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
**base_power** | **Float64** |  | [default to nothing]
**operation_cost** | [***HydroGenerationCost**](HydroGenerationCost.md) |  | [optional] [default to nothing]
**powerhouse_elevation** | **Float64** |  | [default to nothing]
**ramp_limits** | [***UpDown**](UpDown.md) |  | [optional] [default to nothing]
**time_limits** | [***UpDown**](UpDown.md) |  | [optional] [default to nothing]
**outflow_limits** | [***MinMax**](MinMax.md) |  | [optional] [default to nothing]
**efficiency** | **Float64** |  | [optional] [default to 1.0]
**turbine_type** | **String** |  | [optional] [default to "UNKNOWN"]
**conversion_factor** | **Float64** |  | [optional] [default to 1.0]
**reservoirs** | **Vector{Int64}** |  | [optional] [default to nothing]
**dynamic_injector** | **Any** |  | [optional] [default to nothing]

[[Back to Model list]](../README.md#models) [[Back to API list]](../README.md#api-endpoints) [[Back to README]](../README.md)
