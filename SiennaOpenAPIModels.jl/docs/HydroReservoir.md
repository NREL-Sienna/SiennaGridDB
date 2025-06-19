# HydroReservoir

## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **Int64** |  | [default to nothing]
**name** | **String** |  | [default to nothing]
**available** | **Bool** |  | [default to nothing]
**storage_level_limits** | [***MinMax**](MinMax.md) |  | [default to nothing]
**initial_level** | **Float64** |  | [default to nothing]
**spillage_limits** | [***MinMax**](MinMax.md) |  | [optional] [default to nothing]
**inflow** | **Float64** |  | [default to nothing]
**outflow** | **Float64** |  | [default to nothing]
**level_targets** | **Float64** |  | [optional] [default to nothing]
**travel_time** | **Float64** |  | [optional] [default to nothing]
**intake_elevation** | **Float64** |  | [default to nothing]
**head_to_volume_factor** | [***ValueCurve**](ValueCurve.md) |  | [default to nothing]
**operation_cost** | [***HydroReservoirCost**](HydroReservoirCost.md) |  | [default to nothing]
**level_data_type** | **String** |  | [optional] [default to "USABLE_VOLUME"]

[[Back to Model list]](../README.md#models) [[Back to API list]](../README.md#api-endpoints) [[Back to README]](../README.md)
