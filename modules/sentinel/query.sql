AzureActivity
| where OperationName == "MICROSOFT.COMPUTE/VIRTUALMACHINES/DELETE"
| where ActivityStatus == "Success"