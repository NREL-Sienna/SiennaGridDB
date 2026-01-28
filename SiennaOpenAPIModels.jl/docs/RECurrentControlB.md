# RECurrentControlB


## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **Int64** |  | [default to nothing]
**Q_Flag** | **Int64** | Q Flag used for I_qinj, is this meant to also be 0 or 1? | [default to nothing]
**PQ_Flag** | **Int64** | PQ Flag used for the Current Limit Logic, is this meant to also be 0 or 1? | [default to nothing]
**Vdip_lim** | [***MinMax**](MinMax.md) |  | [default to nothing]
**T_rv** | **Float64** |  | [default to nothing]
**dbd_pnts** | **Int64** |  | [default to nothing]
**K_qv** | **Float64** |  | [default to nothing]
**Iqinj_lim** | [***MinMax**](MinMax.md) |  | [default to nothing]
**V_ref0** | **Float64** |  | [default to nothing]
**K_vp** | **Float64** |  | [default to nothing]
**K_vi** | **Float64** |  | [default to nothing]
**T_iq** | **Float64** |  | [default to nothing]
**I_max** | **Float64** |  | [default to nothing]
**states** | **Vector{String}** | States of the RECurrentControlB model (dependent on the Flags) | [default to nothing]
**n_states** | **Int64** | Number of states (dependent on the Flags) | [default to nothing]


[[Back to Model list]](../README.md#models) [[Back to API list]](../README.md#api-endpoints) [[Back to README]](../README.md)


