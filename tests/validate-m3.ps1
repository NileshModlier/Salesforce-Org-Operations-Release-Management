# Validates M3 flows, permission sets, profiles, and the security matrix.
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

$flows = @('Lead_Assignment', 'Case_Assignment', 'First_Response_Tracking', 'Escalation')
foreach ($flow in $flows) {
    $text = Read-RepoText "force-app/main/default/flows/$flow.flow-meta.xml"
    if ($null -eq $text) {
        continue
    }
    if ($text -match '<faultConnector>' -and $text -match '<name>Capture_Fault</name>') {
        Add-Pass "$flow has a fault path"
    }
    else {
        Add-Fail "$flow is missing a Capture Fault path"
    }
    if ($text -match '<status>Draft</status>') {
        Add-Pass "$flow is Draft"
    }
    else {
        Add-Fail "$flow is not Draft"
    }
    $tests = @(Get-ChildItem -LiteralPath (Join-Path $root 'force-app/main/default/flowtests') -Filter '*.flowtest-meta.xml' |
            Where-Object { (Get-Content -LiteralPath $_.FullName -Raw -Encoding UTF8) -match "<flowApiName>$flow</flowApiName>" })
    if ($tests.Count -ge 1) {
        Add-Pass "$flow has $($tests.Count) flow test(s)"
    }
    else {
        Add-Fail "$flow has no flow test"
    }
}

$flowDoc = Read-RepoText 'docs/flows.md'
if ($null -ne $flowDoc) {
    foreach ($heading in @('## Lead Assignment', '## Case Assignment', '## First Response Tracking', '## Escalation')) {
        if ($flowDoc.Contains($heading)) {
            Add-Pass "Flow doc contains $heading"
        }
        else {
            Add-Fail "Flow doc is missing $heading"
        }
    }
    foreach ($label in @('Expected Inputs', 'Expected Outputs', 'Failure Behavior', 'Assignment rules', 'Routing matrix', 'Scheduled path')) {
        if ($flowDoc.Contains($label)) {
            Add-Pass "Flow doc contains $label"
        }
        else {
            Add-Fail "Flow doc is missing $label"
        }
    }
}

$profileDoc = Read-RepoText 'docs/profile_strategy.md'
if ($null -ne $profileDoc) {
    foreach ($token in @('minimum-access', 'Sales_Rep', 'Support_L1', 'Support_L2', 'Ops_Admin', 'permission set group')) {
        if ($profileDoc.Contains($token)) {
            Add-Pass "Profile strategy contains $token"
        }
        else {
            Add-Fail "Profile strategy is missing $token"
        }
    }
}

$personaDoc = Read-RepoText 'docs/persona_testing.md'
if ($null -ne $personaDoc) {
    foreach ($token in @('## Sales Rep', '## Support Agent L1', '## Support Lead L2', '## Ops Admin', '## Profile-only control')) {
        if ($personaDoc.Contains($token)) {
            Add-Pass "Persona testing contains $token"
        }
        else {
            Add-Fail "Persona testing is missing $token"
        }
    }
}

$permExpectations = @{
    'Sales_Rep' = @('Lead.Product_Interest__c', '<object>Lead</object>', '<object>Opportunity</object>')
    'Support_L1' = @('Case.Escalation_Reason__c', '<object>Case</object>', '<allowDelete>false</allowDelete>')
    'Support_L2' = @('<viewAllRecords>true</viewAllRecords>', 'TransferAnyCase', 'Case.Resolution_Notes__c')
    'Ops_Admin' = @('CustomizeApplication', 'ManageUsers', 'User.Persona__c')
}
foreach ($name in $permExpectations.Keys) {
    $text = Read-RepoText "force-app/main/default/permissionsets/$name.permissionset-meta.xml"
    if ($null -eq $text) {
        continue
    }
    if ($text -match 'ModifyAllData') {
        Add-Fail "$name grants Modify All Data"
    }
    else {
        Add-Pass "$name does not grant Modify All Data"
    }
    foreach ($token in $permExpectations[$name]) {
        if ($text.Contains($token)) {
            Add-Pass "$name contains $token"
        }
        else {
            Add-Fail "$name is missing $token"
        }
    }
}

$sales = Read-RepoText 'force-app/main/default/permissionsets/Sales_Rep.permissionset-meta.xml'
if ($null -ne $sales -and $sales -match '<object>Case</object>') {
    Add-Fail 'Sales Rep permission set grants Case access'
}
elseif ($null -ne $sales) {
    Add-Pass 'Sales Rep permission set has no Case object access'
}

$l1 = Read-RepoText 'force-app/main/default/permissionsets/Support_L1.permissionset-meta.xml'
if ($null -ne $l1 -and $l1 -match '(?s)<editable>false</editable>\s*<field>Case.Resolution_Notes__c</field>\s*<readable>true</readable>') {
    Add-Pass 'L1 resolution notes are read-only'
}
elseif ($null -ne $l1) {
    Add-Fail 'L1 resolution notes are not read-only'
}

$groups = @{
    'Sales_Rep' = 'Sales_Rep'
    'Support_Agent_L1' = 'Support_L1'
    'Support_Lead_L2' = 'Support_L2'
    'Ops_Admin' = 'Ops_Admin'
}
foreach ($group in $groups.Keys) {
    $text = Read-RepoText "force-app/main/default/permissionsetgroups/$group.permissionsetgroup-meta.xml"
    if ($null -eq $text) {
        continue
    }
    if ($text.Contains("<permissionSets>$($groups[$group])</permissionSets>")) {
        Add-Pass "$group group includes $($groups[$group])"
    }
    else {
        Add-Fail "$group group does not include $($groups[$group])"
    }
}

$profiles = @{
    'Sales_Rep' = 'Lead-Sales Rep'
    'Support_Agent_L1' = 'Case-Support Agent L1'
    'Support_Lead_L2' = 'Case-Support Lead L2'
    'Ops_Admin' = 'User-Ops Admin'
}
foreach ($profile in $profiles.Keys) {
    $text = Read-RepoText "force-app/main/default/profiles/$profile.profile-meta.xml"
    if ($null -eq $text) {
        continue
    }
    if ($text -match '<objectPermissions>') {
        Add-Fail "$profile profile contains object permissions"
    }
    else {
        Add-Pass "$profile profile has no object permissions"
    }
    if ($text.Contains($profiles[$profile]) -and $text -match '<applicationVisibilities>') {
        Add-Pass "$profile profile has its layout and an app"
    }
    else {
        Add-Fail "$profile profile is missing its layout or app"
    }
}

foreach ($queue in @('L1_Support', 'L2_Escalation')) {
    $text = Read-RepoText "force-app/main/default/queues/$queue.queue-meta.xml"
    if ($null -ne $text -and $text -match '<sobjectType>Case</sobjectType>') {
        Add-Pass "$queue is a Case queue"
    }
    elseif ($null -ne $text) {
        Add-Fail "$queue is not a Case queue"
    }
}

$matrixPath = Join-Path $root 'docs/security-matrix.xlsx'
if (-not (Test-Path -LiteralPath $matrixPath)) {
    Add-Fail 'Missing file: docs/security-matrix.xlsx'
}
else {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = [System.IO.Compression.ZipFile]::OpenRead($matrixPath)
    try {
        $sheet = $zip.Entries | Where-Object { $_.FullName -eq 'xl/worksheets/sheet1.xml' } | Select-Object -First 1
        if ($null -eq $sheet) {
            Add-Fail 'security-matrix.xlsx has no sheet1'
        }
        else {
            $reader = New-Object System.IO.StreamReader($sheet.Open())
            $xml = $reader.ReadToEnd()
            $reader.Close()
            foreach ($token in @('Object', 'Create', 'Read', 'Edit', 'Delete', 'Field Exceptions', 'Persona Mapping', 'Sales Rep', 'Support Agent L1', 'Support Lead L2', 'Ops Admin')) {
                if ($xml.Contains($token)) {
                    Add-Pass "Security matrix contains $token"
                }
                else {
                    Add-Fail "Security matrix is missing $token"
                }
            }
        }
    }
    finally {
        $zip.Dispose()
    }
}

$manifest = Read-RepoText 'manifest/package.xml'
if ($null -ne $manifest) {
    foreach ($typeName in @('Flow', 'FlowTest', 'PermissionSet', 'PermissionSetGroup', 'Profile', 'Queue')) {
        if ($manifest -match "<name>$typeName</name>") {
            Add-Pass "Manifest includes $typeName"
        }
        else {
            Add-Fail "Manifest is missing $typeName"
        }
    }
}

$readme = Read-RepoText 'README.md'
if ($null -ne $readme -and $readme.Contains('## M3 Status')) {
    Add-Pass 'README contains M3 Status'
}
elseif ($null -ne $readme) {
    Add-Fail 'README is missing M3 Status'
}

Write-Output 'M3 automation and security validation'
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
