# Azure Sentinel

Set the variables:

```sh
cp config/template.tfvars .auto.tfvars
```

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

For this example:

1. Install the `Windows Security Events` connector in Sentinel.
2. Setup the connector will be done using the AMA option.
3. Add a data collection rule (DCR) set it under Basics.
4. Add the VM to the rule.
5. Select `All security events`.

It is also possible to collect [Sysmon][2] events via the `Security Events` connector.

There is also the legacy agent, not covered here.

## Data Analysis

This view will show the rules templates associated with the enabled connectors.

The Azure Activity data connector should be enabled and with Policy Assignment to it, and the primary log analytics workspace is selected.

Make sure you also tick the remediation task checkbox. If using managed identity, confirm the location.

## Analytical Rules

There are many [types][3] of rules.

Fusion is enabled by default and cannot be customized.

> ⚠️ Fusion requires multiple data connectors and additional setup. Check the documentation.

Microsoft Sentinel Analytics includes built-in machine learning behavior analytics rules. You can't edit these built-in rules or review the rule settings.

## Microsoft Security

You can [configure][3] the following security solutions to pass their alerts to Microsoft Sentinel:

- Microsoft Defender for Cloud Apps
- Microsoft Defender for Server
- Microsoft Defender for IoT
- Microsoft Defender for Identity
- Microsoft Defender for Office 365
- Microsoft Entra ID Protection
- Microsoft Defender for Endpoint

## Scheduled Rule

Create a sample scheduled rule:

```sql
AzureActivity
| where OperationName == "MICROSOFT.COMPUTE/VIRTUALMACHINES/WRITE"
| where ActivityStatus == "Succeeded"
| make-series dcount(ResourceId)  default=0 on EventSubmissionTimestamp in range(ago(7d), now(), 1d) by Caller
```

## Delete VM exercise - Trigger an incident

The Terraform configuration will create a specific scheduled rule to detect VM deletion following [this][4] exercise.

## Architecture

Workspace architecture options and log analytics workspace dependency.

https://learn.microsoft.com/en-us/training/modules/create-manage-azure-sentinel-workspaces/2-plan-for-azure-sentinel-workspace

- Lighthouse
- Workspace manager

## General exercises

Walkthrough [exercises][5] link.

For example, it can detect privileged escalation:

```ps1
net user theusernametoadd /add
net user theusernametoadd ThePassword1!
net localgroup administrators theusernametoadd /add
```

## CEF/SysLog

One could use a [log forwarder][6] for CEF/Syslog data.

## Custom queries

From the [documentation][7]:

> The query length should be between 1 and 10,000 characters and cannot contain `"search *"` or `"union *"`. You can use [user-defined functions][8] to overcome the query length limitation.

## Playbooks

You can implement [Playbooks][9] with Sentinel:

1. Create an automation rule
2. Create a playbook
3. Add actions to a playbook
4. Attach a playbook to an automation rule or an analytics rule to automate threat response

## Terminology

### General

General information dashboard, logs, and search.

### Threat management

- Incidents: Registered incidents
- Workbooks: Documentation in markdown with integrated queries and metrics
- Hunting: Workflow centered around hypothesis to seek out undetected threats and malicious behavior
- Notebooks: Jupyter notebooks integrated with Azure Machine Learning.
- Entity behavior: Tool to search for accounts, hosts, IP addresses, IoT devices or Azure resources. Works best with UEBA.
- Threat intelligence: Register indicators (domains, IPs, files, URLs). Data connectors and feeds can be used to import indicators. These indicators can be used in queries and rules.
- MITRE ATT&ACK (Preview): Integrated dashboard showing associated with rules and anomalies.

### Content management

- Content hub: Solutions setup
- Repositories: Bring your own solutions from GH, ADO, etc.
- Community: General community integrated page

### Configuration

- Workspace manager (Preview): Enables users to centrally manage multiple Microsoft Sentinel workspaces within one or more Azure tenants
- Data connectors: Same as content hub?
- Analytics: Create and manage rules (Scheduled, NRT, Microsoft) that query data, creates alerts and register incidents, and associated automation rules.
- Watchlist: Investigate threats and respond to incidents quickly with fast import of IP addresses, file hashes, etc. from csv files.
- Automation: Automation rules are actions to take when an alert, incident or entity trigger happens.
    - General (Actions): Change information of the trigger
    - Playbooks (Action): Logic Apps
- Settings: General settings of the Sentinel account.

## Sample queries

Failed login attempts (4625) to Windows machines:

```sql
let timeframe = 3d;
SecurityEvent
| where TimeGenerated > ago(1d)
| where AccountType == 'User' and EventID == 4625
| summarize failed_login_attempts=count(), latest_failed_login=arg_max(TimeGenerated, Account) by Account
| where failed_login_attempts > 5
| project-away Account1
```


[1]: https://learn.microsoft.com/en-us/training/modules/connect-microsoft-services-to-azure-sentinel/
[2]: https://learn.microsoft.com/en-us/training/modules/connect-windows-hosts-to-azure-sentinel/3-collect-sysmon-event-logs
[3]: https://learn.microsoft.com/en-us/training/modules/analyze-data-in-sentinel/4-analytics-rules
[4]: https://learn.microsoft.com/en-us/training/modules/analyze-data-in-sentinel/8-exercise-detect-threats
[5]: https://learn.microsoft.com/en-us/training/modules/configure-siem-security-operations-using-microsoft-sentinel/1-introduction
[6]: https://learn.microsoft.com/en-us/azure/sentinel/connect-cef-ama
[7]: https://learn.microsoft.com/en-us/azure/sentinel/detect-threats-custom
[8]: https://learn.microsoft.com/en-us/azure/data-explorer/kusto/query/functions/user-defined-functions
[9]: https://learn.microsoft.com/en-us/azure/sentinel/tutorial-respond-threats-playbook?tabs=LAC%2Cincidents
