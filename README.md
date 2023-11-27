# Azure Sentinel

Start the environment to work with Sentinel:

```sh
terraform init
terraform apply -auto-approve
```

The scripts will provision and onboard a Log Analytics Workspace into Azure Sentinel.


## Watchlist

Create the watchlist using the Portal for the file [HighValue.csv](HighValue.csv), or via CLI:

> This was bugged in Preview, so prefer the Portal

```sh
az sentinel watchlist create \
    --name HighValueHosts \
    --display-name HighValueHosts \
    --resource-group rg-healthcare \
    --workspace-name log-healthcare \
    --description "High value hosts." \
    --content-type "text/csv" \
    --provider "Microsoft" \
    --source "HighValue.csv" \
    --items-search-key Hostname 
```

To view the watchlist, simply select it and use the `View in logs` button:

```sql
_GetWatchlist('HighValueHosts')
```

## Threat Intelligence






Threat indicator / Threat intelligence (Blade)
-- domain-name (types) ...
-- enter the domain .. contoso.com
Threat type "malicious-activity"
-- name same as the domain

now go to logs... and KQL `ThreatIntelligenceIndicator | project DomainName`


Retention... SecurityEvent table on logs


Workspace architecture options and log analytics workspace dependency.

https://learn.microsoft.com/en-us/training/modules/create-manage-azure-sentinel-workspaces/2-plan-for-azure-sentinel-workspace
