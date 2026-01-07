# TwoTerminalVSCLine

## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **Int64** |  | [default to nothing]
**name** | **String** |  | [default to nothing]
**available** | **Bool** |  | [default to nothing]
**arc** | **Int64** |  | [default to nothing]
**active_power_flow** | **Float64** |  | [default to nothing]
**rating** | **Float64** |  | [default to nothing]
**active_power_limits_from** | [***MinMax**](MinMax.md) |  | [default to nothing]
**active_power_limits_to** | [***MinMax**](MinMax.md) |  | [default to nothing]
**g** | **Float64** |  | [optional] [default to 0.0]
**dc_current** | **Float64** |  | [optional] [default to 0.0]
**reactive_power_from** | **Float64** |  | [optional] [default to 0.0]
**dc_voltage_control_from** | **Bool** |  | [optional] [default to true]
**ac_voltage_control_from** | **Bool** |  | [optional] [default to true]
**dc_setpoint_from** | **Float64** |  | [optional] [default to 0.0]
**ac_setpoint_from** | **Float64** |  | [optional] [default to 1.0]
**converter_loss_from** | [***InputOutputCurve**](InputOutputCurve.md) |  | [optional] [default to nothing]
**max_dc_current_from** | **Float64** |  | [optional] [default to 100000000]
**rating_from** | **Float64** |  | [optional] [default to 100000000]
**reactive_power_limits_from** | [***MinMax**](MinMax.md) |  | [optional] [default to nothing]
**power_factor_weighting_fraction_from** | **Float64** |  | [optional] [default to 1.0]
**voltage_limits_from** | [***MinMax**](MinMax.md) |  | [optional] [default to nothing]
**reactive_power_to** | **Float64** |  | [optional] [default to 0.0]
**dc_voltage_control_to** | **Bool** |  | [optional] [default to true]
**ac_voltage_control_to** | **Bool** |  | [optional] [default to true]
**dc_setpoint_to** | **Float64** |  | [optional] [default to 0.0]
**ac_setpoint_to** | **Float64** |  | [optional] [default to 1.0]
**converter_loss_to** | [***InputOutputCurve**](InputOutputCurve.md) |  | [optional] [default to nothing]
**max_dc_current_to** | **Float64** |  | [optional] [default to 100000000]
**rating_to** | **Float64** |  | [optional] [default to 100000000]
**reactive_power_limits_to** | [***MinMax**](MinMax.md) |  | [optional] [default to nothing]
**power_factor_weighting_fraction_to** | **Float64** |  | [optional] [default to 1.0]
**voltage_limits_to** | [***MinMax**](MinMax.md) |  | [optional] [default to nothing]

[[Back to Model list]](../README.md#models) [[Back to API list]](../README.md#api-endpoints) [[Back to README]](../README.md)
