# ActiveRenewableControllerAB


## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **Int64** |  | [default to nothing]
**bus_control** | **Int64** |  | [default to nothing]
**from_branch_control** | **Int64** |  | [default to nothing]
**to_branch_control** | **Int64** |  | [default to nothing]
**branch_id_control** | **String** |  | [default to nothing]
**Freq_Flag** | **Bool** |  | [default to nothing]
**K_pg** | **Float64** |  | [default to nothing]
**K_ig** | **Float64** |  | [default to nothing]
**T_p** | **Float64** |  | [default to nothing]
**fdbd_pnts** | [***FdbdPnts**](FdbdPnts.md) |  | [default to nothing]
**fe_lim** | [***MinMax**](MinMax.md) |  | [default to nothing]
**P_lim** | [***MinMax**](MinMax.md) |  | [default to nothing]
**T_g** | **Float64** |  | [default to nothing]
**D_dn** | **Float64** |  | [default to nothing]
**D_up** | **Float64** |  | [default to nothing]
**dP_lim** | [***MinMax**](MinMax.md) |  | [default to nothing]
**P_lim_inner** | [***MinMax**](MinMax.md) |  | [default to nothing]
**T_pord** | **Float64** |  | [optional] [default to nothing]
**P_ref** | **Float64** |  | [optional] [default to 1.0]
**states** | **Vector{String}** | States of the ActiveRenewableControllerAB model (dependent on the Flag) | [default to nothing]
**n_states** | **Int64** | Number of states (dependent on the Flag) | [default to nothing]


[[Back to Model list]](../README.md#models) [[Back to API list]](../README.md#api-endpoints) [[Back to README]](../README.md)


