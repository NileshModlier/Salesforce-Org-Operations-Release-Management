# Validates M4 reports, dashboards, synthetic data, and metric checks.
$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

$failures = New-Object System.Collections.Generic.List[string]
$passes = New-Object System.Collections.Generic.List[string]

function Add-Pass {
    param([string]$Message)
    $script:passes.Add($Message)
}

function Add-Fail {
    param([string]$Message)
    $script:failures.Add($Message)
}

function Read-RepoText {
    param([string]$RelativePath)
    $full = Join-Path $root $RelativePath
    if (-not (Test-Path -LiteralPath $full)) {
        Add-Fail "Missing file: $RelativePath"
        return $null
    }
    return Get-Content -LiteralPath $full -Raw -Encoding UTF8
}

$salesReports = @(
    'Lead_Conversion_By_Source',
    'Pipeline_By_Stage',
    'Opportunities_Closing_This_Month',
    'Open_Opportunity_Value',
    'Conversion_Rate'
)
$supportReports = @(
    'Open_Cases_By_Priority',
    'Cases_By_Status',
    'First_Response_Performance',
    'Escalations_By_Priority',
    'Cases_Closed_By_Agent'
)

foreach ($name in $salesReports) {
    $text = Read-RepoText "force-app/main/default/reports/Sales_Leadership/$name.report-meta.xml"
    if ($null -eq $text) {
        continue
    }
    if ($text -match '<name>') {
        Add-Pass "Sales report $name has a name"
    }
    if ($text -match '<groupingsDown>' -or $text -match '<groupingsAcross>') {
        Add-Pass "Sales report $name has a grouping"
    }
    else {
        Add-Fail "Sales report $name has no grouping"
    }
}

foreach ($name in $supportReports) {
    $text = Read-RepoText "force-app/main/default/reports/Support_Leadership/$name.report-meta.xml"
    if ($null -eq $text) {
        continue
    }
    if ($text -match '<groupingsDown>' -or $text -match '<groupingsAcross>') {
        Add-Pass "Support report $name has a grouping"
    }
    else {
        Add-Fail "Support report $name has no grouping"
    }
}

$matrix = Read-RepoText 'force-app/main/default/reports/Support_Leadership/Cases_By_Status.report-meta.xml'
if ($null -ne $matrix -and $matrix -match '<format>Matrix</format>' -and $matrix -match '<groupingsAcross>') {
    Add-Pass 'Cases By Status is a matrix'
}
elseif ($null -ne $matrix) {
    Add-Fail 'Cases By Status is not a matrix'
}

$pipeline = Read-RepoText 'force-app/main/default/reports/Sales_Leadership/Pipeline_By_Stage.report-meta.xml'
if ($null -ne $pipeline -and $pipeline -match '<scope>user</scope>' -and $pipeline -match 'AMOUNT' -and $pipeline -match 'CLOSE_DATE' -and $pipeline -match 'STAGE_NAME') {
    Add-Pass 'Pipeline By Stage is the running-user stage report'
}
elseif ($null -ne $pipeline) {
    Add-Fail 'Pipeline By Stage is missing scope, stage, amount, or close date'
}

$formula = Read-RepoText 'force-app/main/default/reports/Sales_Leadership/Conversion_Rate.report-meta.xml'
if ($null -ne $formula -and $formula -match '<calculatedFormula>CONVERTED:SUM/RowCount</calculatedFormula>') {
    Add-Pass 'Conversion Rate has the conversion formula'
}
elseif ($null -ne $formula) {
    Add-Fail 'Conversion Rate is missing the conversion formula'
}

$response = Read-RepoText 'force-app/main/default/reports/Support_Leadership/First_Response_Performance.report-meta.xml'
if ($null -ne $response -and $response -match 'First_Response_At__c' -and $response -match '<aggregateTypes>Average</aggregateTypes>') {
    Add-Pass 'First Response Performance averages the hours formula'
}
elseif ($null -ne $response) {
    Add-Fail 'First Response Performance is missing the hours formula'
}

$summaryCount = @(Get-ChildItem -LiteralPath (Join-Path $root 'force-app/main/default/reports') -Recurse -Filter '*.report-meta.xml' |
        Where-Object { (Get-Content -LiteralPath $_.FullName -Raw -Encoding UTF8) -match '<format>Summary</format>' })
if ($summaryCount.Count -ge 1) {
    Add-Pass "Summary report count: $($summaryCount.Count)"
}
else {
    Add-Fail 'No summary report was found'
}

foreach ($dashboard in @(
        'force-app/main/default/dashboards/Sales_Leadership/Sales_Dashboard.dashboard-meta.xml',
        'force-app/main/default/dashboards/Support_Leadership/Support_Dashboard.dashboard-meta.xml'
    )) {
    $text = Read-RepoText $dashboard
    if ($null -eq $text) {
        continue
    }
    foreach ($token in @('<componentType>Metric</componentType>', '<componentType>Table</componentType>', '<dashboardFilters>', '<dashboardType>LoggedInUser</dashboardType>')) {
        if ($text.Contains($token)) {
            Add-Pass "$dashboard contains $token"
        }
        else {
            Add-Fail "$dashboard is missing $token"
        }
    }
    if ($text -match '<componentType>Bar</componentType>' -or $text -match '<componentType>Donut</componentType>' -or $text -match '<componentType>Column</componentType>') {
        Add-Pass "$dashboard contains a chart"
    }
    else {
        Add-Fail "$dashboard has no chart"
    }
}

$reportDoc = Read-RepoText 'docs/reports.md'
if ($null -ne $reportDoc) {
    foreach ($token in @('## Filters', '## Groupings', '## Calculated Fields', '## Synthetic data strategy', 'Lead Conversion By Source', 'Cases By Status', '24', '18', '20')) {
        if ($reportDoc.Contains($token)) {
            Add-Pass "reports.md contains $token"
        }
        else {
            Add-Fail "reports.md is missing $token"
        }
    }
}

$dashboardDoc = Read-RepoText 'docs/dashboards.md'
if ($null -ne $dashboardDoc) {
    foreach ($token in @('## Sales Dashboard', '## Support Dashboard', 'KPI', 'Table', 'Filter', 'Bar chart', 'Donut chart', 'Column chart')) {
        if ($dashboardDoc.Contains($token)) {
            Add-Pass "dashboards.md contains $token"
        }
        else {
            Add-Fail "dashboards.md is missing $token"
        }
    }
}

$metricDoc = Read-RepoText 'docs/metric_validation.md'
if ($null -ne $metricDoc) {
    foreach ($token in @('## Sales Dashboard', '## Support Dashboard', 'Expected Value', 'Dashboard Value', 'Verification Method', '221000', '41.67%', 'Not observed')) {
        if ($metricDoc.Contains($token)) {
            Add-Pass "metric_validation.md contains $token"
        }
        else {
            Add-Fail "metric_validation.md is missing $token"
        }
    }
    $openChecks = ([regex]::Matches($metricDoc, '\| Open Cases \| 15 \|')).Count
    $escChecks = ([regex]::Matches($metricDoc, '\| Escalations \| 4 \|')).Count
    if ($openChecks -ge 1 -and $escChecks -ge 1) {
        Add-Pass 'Support metric rows record 15 open cases and 4 escalations'
    }
    else {
        Add-Fail 'Support metric rows are missing the hand-counted values'
    }
}

$trace = Read-RepoText 'docs/requirement_traceability.md'
if ($null -ne $trace -and $trace.Contains('## Reporting chain')) {
    foreach ($token in @('REQ-009', 'REQ-010', 'Pipeline_By_Stage', 'Cases_By_Status', 'Sales_Dashboard', 'Support_Dashboard', 'First_Response_Tracking', 'Escalation', 'Lead_Assignment', 'Case_Assignment')) {
        if ($trace.Contains($token)) {
            Add-Pass "Traceability contains $token"
        }
        else {
            Add-Fail "Traceability is missing $token"
        }
    }
}
elseif ($null -ne $trace) {
    Add-Fail 'Traceability is missing the reporting chain'
}

$opps = Import-Csv (Join-Path $root 'data/synthetic/opportunities.csv')
$openAmount = ($opps | Where-Object { $_.StageName -notin @('Closed Won', 'Closed Lost') } | Measure-Object Amount -Sum).Sum
if ($opps.Count -eq 18 -and $openAmount -eq 221000) {
    Add-Pass 'Opportunity file has 18 rows and 221000 open amount'
}
else {
    Add-Fail "Opportunity file counts drifted: rows=$($opps.Count) open=$openAmount"
}

$leads = Import-Csv (Join-Path $root 'data/synthetic/leads.csv')
$converted = @($leads | Where-Object { $_.ConvertedTarget -eq 'Yes' }).Count
if ($leads.Count -eq 24 -and $converted -eq 10) {
    Add-Pass 'Lead file has 24 rows and 10 conversion targets'
}
else {
    Add-Fail "Lead file counts drifted: rows=$($leads.Count) converted=$converted"
}

$cases = Import-Csv (Join-Path $root 'data/synthetic/cases.csv')
$openCases = @($cases | Where-Object { $_.Status -ne 'Closed' }).Count
$escalated = @($cases | Where-Object { $_.Status -eq 'Escalated' }).Count
if ($cases.Count -eq 20 -and $openCases -eq 15 -and $escalated -eq 4) {
    Add-Pass 'Case file has 20 rows, 15 open, and 4 escalated'
}
else {
    Add-Fail "Case file counts drifted: rows=$($cases.Count) open=$openCases escalated=$escalated"
}

$salesGroup = Read-RepoText 'force-app/main/default/permissionsetgroups/Sales_Rep.permissionsetgroup-meta.xml'
$l2Group = Read-RepoText 'force-app/main/default/permissionsetgroups/Support_Lead_L2.permissionsetgroup-meta.xml'
$l1Group = Read-RepoText 'force-app/main/default/permissionsetgroups/Support_Agent_L1.permissionsetgroup-meta.xml'
$opsGroup = Read-RepoText 'force-app/main/default/permissionsetgroups/Ops_Admin.permissionsetgroup-meta.xml'
if ($null -ne $salesGroup -and $salesGroup.Contains('<permissionSets>Reporting_Sales</permissionSets>')) {
    Add-Pass 'Sales Rep group includes Reporting_Sales'
}
elseif ($null -ne $salesGroup) {
    Add-Fail 'Sales Rep group is missing Reporting_Sales'
}
if ($null -ne $l2Group -and $l2Group.Contains('<permissionSets>Reporting_Support</permissionSets>')) {
    Add-Pass 'L2 group includes Reporting_Support'
}
elseif ($null -ne $l2Group) {
    Add-Fail 'L2 group is missing Reporting_Support'
}
if ($null -ne $opsGroup -and $opsGroup.Contains('<permissionSets>Reporting_Admin</permissionSets>')) {
    Add-Pass 'Ops Admin group includes Reporting_Admin'
}
elseif ($null -ne $opsGroup) {
    Add-Fail 'Ops Admin group is missing Reporting_Admin'
}
if ($null -ne $l1Group -and $l1Group -notmatch 'Reporting_') {
    Add-Pass 'L1 group has no reporting permission set'
}
elseif ($null -ne $l1Group) {
    Add-Fail 'L1 group includes a reporting permission set'
}

$manifest = Read-RepoText 'manifest/package.xml'
if ($null -ne $manifest) {
    foreach ($typeName in @('Report', 'Dashboard')) {
        if ($manifest -match "<name>$typeName</name>") {
            Add-Pass "Manifest includes $typeName"
        }
        else {
            Add-Fail "Manifest is missing $typeName"
        }
    }
    if ($manifest -match '<name>ApexClass</name>') {
        Add-Fail 'Manifest includes ApexClass'
    }
    else {
        Add-Pass 'Manifest includes no Apex'
    }
}

$readme = Read-RepoText 'README.md'
if ($null -ne $readme) {
    foreach ($heading in @('## Reporting Architecture', '## Business Insights', '## Dashboard Strategy')) {
        if ($readme.Contains($heading)) {
            Add-Pass "README contains $heading"
        }
        else {
            Add-Fail "README is missing $heading"
        }
    }
}

$apex = @(Get-ChildItem -LiteralPath (Join-Path $root 'force-app') -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Extension -in @('.cls', '.trigger') })
if ($apex.Count -eq 0) {
    Add-Pass 'No Apex was added'
}
else {
    Add-Fail "Apex found: $($apex.Name -join ', ')"
}

Write-Output 'M4 reporting validation'
Write-Output "Root: $root"
Write-Output ''
Write-Output "Passed: $($passes.Count)"
foreach ($pass in $passes) {
    Write-Output "  PASS  $pass"
}
Write-Output ''
Write-Output "Failed: $($failures.Count)"
foreach ($failure in $failures) {
    Write-Output "  FAIL  $failure"
}
Write-Output ''

if ($failures.Count -gt 0) {
    Write-Output 'RESULT: FAIL'
    exit 1
}

Write-Output 'RESULT: PASS'
exit 0
