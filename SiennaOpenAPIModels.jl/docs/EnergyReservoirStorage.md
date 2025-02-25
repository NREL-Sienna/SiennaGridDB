# EnergyReservoirStorage

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
**prime_mover_type** | **String** |  | [default to "OT"]
**storage_technology_type** | **String** | defines the storage technology used in an energy Storage system, based on the options in EIA form 923. | [default to nothing]
**storage_capacity** | **Float64** |  | [default to nothing]
**storage_level_limits** | [***MinMax**](MinMax.md) |  | [default to nothing]
**initial_storage_capacity_level** | **Float64** |  | [default to nothing]
**input_active_power_limits** | [***MinMax**](MinMax.md) |  | [default to nothing]
**output_active_power_limits** | [***MinMax**](MinMax.md) |  | [default to nothing]
**efficiency** | [***EnergyReservoirStorageEfficiency**](EnergyReservoirStorageEfficiency.md) |  | [default to nothing]
**reactive_power_limits** | [***MinMax**](MinMax.md) |  | [optional] [default to nothing]
**operation_cost** | [***StorageCost**](StorageCost.md) |  | [optional] [default to nothing]
**conversion_factor** | **Float64** |  | [optional] [default to 1.0]
**storage_target** | **Float64** |  | [optional] [default to 0.0]
**cycle_limits** | **Int64** |  | [optional] [default to 10000]
**base_power** | **Float64** |  | [default to nothing]
**dynamic_injector** | **Any** |  | [optional] [default to nothing]

[[Back to Model list]](../README.md#models) [[Back to API list]](../README.md#api-endpoints) [[Back to README]](../README.md)
