# Azure Sentinel

Start the environment to work with Sentinel:

```sh
terraform init
terraform apply -auto-approve
```

The scripts will provision and onboard a Log Analytics Workspace into Azure Sentinel.

Data connectors need to be enabled and configured manually. Optionally follow [this][1] reference.


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

## Threat Indicator / Intelligence

A default `domain-name` threat indicator  with threat type `malicious-activity` will be created.

You may modify the indicator, such as confidence threshold and kills chains.

To query it using KQL:

```sql
`ThreatIntelligenceIndicator | project DomainName`
```

## Connectors

Microsoft services connectors:

- Microsoft 365 (formerly Office) 365 - Data is stored in the `OfficeActivity` table.
- Azure Active Directory (being renamed to Microsoft Entra ID) - Activate Audit and Sign-in in the configurations
- Microsoft Entra ID Protection - Table is `SecurityAlert`. Auto-creation o incidents is supported
- Azure Activity - Azure Resource Manager operational data, service health events, write operations taken on the resources in your subscription, and the status of activities performed in Azure.

Install each of these connectors and enable the features in each of them.

## Retention

Retention configuration can be managed in the `SecurityEvent` table within the Log Analytics workspace.

## Windows Host Security

In this example, install the `Windows Security Events` connector in Sentinel. Setup will be done using AMA.

Add a data collection rule (DCR) set it under Basics.

Add the VM to the rule. Select `All security events`.

## Architecture

Workspace architecture options and log analytics workspace dependency.

https://learn.microsoft.com/en-us/training/modules/create-manage-azure-sentinel-workspaces/2-plan-for-azure-sentinel-workspace

- Lighthouse
- Workspace manager

[1]: https://learn.microsoft.com/en-us/training/modules/connect-microsoft-services-to-azure-sentinel/
