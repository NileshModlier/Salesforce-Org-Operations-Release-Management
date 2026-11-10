# Validates M5 release checklists, changelog, rollback drill, and traceability.
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

function Get-SectionBody {
    param(
        [string]$Text,
        [string]$Heading
    )
    $pattern = "(?ms)^$([regex]::Escape($Heading))\r?\n(.*?)(?=^## |\z)"
    $match = [regex]::Match($Text, $pattern)
    if (-not $match.Success) {
        return $null
    }
    return $match.Groups[1].Value
}

$checklist = Read-RepoText 'release/CHECKLIST.md'
if ($null -ne $checklist) {
    foreach ($heading in @('## Pre-Release', '## Deployment', '## Post-Release', '## Rollback', '## Operator')) {
        $body = Get-SectionBody -Text $checklist -Heading $heading
        if ($null -eq $body) {
            Add-Fail "Checklist is missing $heading"
            continue
        }
        $boxes = ([regex]::Matches($body, '(?m)^- \[ \] ')).Count
        if ($boxes -ge 5) {
            Add-Pass "$heading has $boxes checklist items"
        }
        else {
            Add-Fail "$heading has $boxes checklist items. Expected at least 5."
        }
    }
}

$plan = Read-RepoText 'release/release-plan.md'
if ($null -ne $plan) {
    foreach ($heading in @(
            '## Work Item',
            '## Branch',
            '## Review',
            '## UAT',
            '## Approval',
            '## Production Promotion',
            '## Post-Deployment Validation',
            '## Rollback Criteria'
        )) {
        if ($plan.Contains($heading)) {
            Add-Pass "Release plan contains $heading"
        }
        else {
            Add-Fail "Release plan is missing $heading"
        }
    }
    if ($plan.Contains('Path B') -and $plan.Contains('Not Executed')) {
        Add-Pass 'Release plan selects Path B because Flosum is Not Executed'
    }
    else {
        Add-Fail 'Release plan does not record the Path B decision'
    }
}

$changelog = Read-RepoText 'release/CHANGELOG.md'
if ($null -ne $changelog) {
    foreach ($heading in @('## Release 1', '## Release 2', '## Template')) {
        if ($changelog.Contains($heading)) {
            Add-Pass "Changelog contains $heading"
        }
        else {
            Add-Fail "Changelog is missing $heading"
        }
    }
    foreach ($releaseHeading in @('## Release 1', '## Release 2')) {
        $body = Get-SectionBody -Text $changelog -Heading $releaseHeading
        if ($null -eq $body) {
            Add-Fail "$releaseHeading has no body"
            continue
        }
        foreach ($field in @('Date', 'Components', 'Reason', 'Outcome', 'Rollback Status')) {
            if ($body -match "\| $field \|") {
                Add-Pass "$releaseHeading records $field"
            }
            else {
                Add-Fail "$releaseHeading is missing $field"
            }
        }
        if ($body -match 'Not executed') {
            Add-Pass "$releaseHeading outcome is not executed"
        }
        else {
            Add-Fail "$releaseHeading claims an execution that did not happen"
        }
    }
}

$drill = Read-RepoText 'release/rollback-drill.md'
if ($null -ne $drill) {
    foreach ($heading in @(
            '## Rollback Scenario',
            '## Rollback Trigger',
            '## Rollback Steps',
            '## Validation Steps',
            '## Observed Risks',
            '## Metadata Limitations'
        )) {
        if ($drill.Contains($heading)) {
            Add-Pass "Rollback drill contains $heading"
        }
        else {
            Add-Fail "Rollback drill is missing $heading"
        }
    }
    if ($drill.Contains('tabletop') -and $drill -match 'revert') {
        Add-Pass 'Rollback drill uses a revert and is a tabletop'
    }
    else {
        Add-Fail 'Rollback drill does not describe the revert tabletop'
    }
}

$management = Read-RepoText 'docs/release_management.md'
if ($null -ne $management) {
    foreach ($token in @('## Project setup', '## Pipeline', '## Work items', '## Promotion flow', '## Rollback via git revert', 'Path B', 'Not Executed')) {
        if ($management.Contains($token)) {
            Add-Pass "Release management contains $token"
        }
        else {
            Add-Fail "Release management is missing $token"
        }
    }
}

$governance = Read-RepoText 'docs/release_governance.md'
if ($null -ne $governance) {
    foreach ($token in @('## Path', '## Roles', '## Gates', 'Ops Admin', 'Not Executed', 'no sandbox')) {
        if ($governance.Contains($token)) {
            Add-Pass "Release governance contains $token"
        }
        else {
            Add-Fail "Release governance is missing $token"
        }
    }
}

$trace = Read-RepoText 'docs/requirement_traceability.md'
if ($null -ne $trace -and $trace.Contains('## Release chain')) {
    foreach ($req in 1..12) {
        $id = 'REQ-{0:D3}' -f $req
        if ($trace -match "(?s)## Release chain.*$id") {
            Add-Pass "Release chain contains $id"
        }
        else {
            Add-Fail "Release chain is missing $id"
        }
    }
    foreach ($token in @('Release 1', 'Release 2', 'validate-m2.ps1', 'validate-m3.ps1', 'validate-m4.ps1')) {
        $chain = Get-SectionBody -Text $trace -Heading '## Release chain'
        if ($null -ne $chain -and $chain.Contains($token)) {
            Add-Pass "Release chain contains $token"
        }
        else {
            Add-Fail "Release chain is missing $token"
        }
    }
}
elseif ($null -ne $trace) {
    Add-Fail 'Traceability is missing the release chain'
}

$flosum = Read-RepoText 'docs/flosum_access.md'
if ($null -ne $flosum -and $flosum.Contains('**Access status: Not Executed**')) {
    Add-Pass 'Flosum access remains Not Executed'
}
elseif ($null -ne $flosum) {
    Add-Fail 'Flosum access status was changed'
}

$release1 = Read-RepoText 'release/manifests/release-1-package.xml'
if ($null -ne $release1) {
    if ($release1 -match '<name>Report</name>' -or $release1 -match '<name>Dashboard</name>') {
        Add-Fail 'Release 1 manifest includes reports or dashboards'
    }
    else {
        Add-Pass 'Release 1 manifest has no reports or dashboards'
    }
    if ($release1 -match '<name>Flow</name>' -and $release1 -match '<name>PermissionSetGroup</name>') {
        Add-Pass 'Release 1 manifest includes flows and permission set groups'
    }
    elseif ($null -ne $release1) {
        Add-Fail 'Release 1 manifest is missing flows or groups'
    }
}

$release2 = Read-RepoText 'release/manifests/release-2-package.xml'
if ($null -ne $release2 -and $release2 -match '<name>Report</name>' -and $release2 -match '<name>Dashboard</name>' -and $release2 -notmatch '<name>Flow</name>') {
    Add-Pass 'Release 2 manifest is reports and dashboards only'
}
elseif ($null -ne $release2) {
    Add-Fail 'Release 2 manifest is not limited to reports and dashboards'
}

$destructive = Read-RepoText 'release/rollback/destructiveChanges.xml'
if ($null -ne $destructive -and $destructive -match 'Sales_Leadership/Sales_Dashboard' -and $destructive -notmatch '<name>CustomField</name>') {
    Add-Pass 'Destructive rollback removes dashboards and does not remove fields'
}
elseif ($null -ne $destructive) {
    Add-Fail 'Destructive rollback package is not limited to Release 2'
}

$readme = Read-RepoText 'README.md'
if ($null -ne $readme -and $readme.Contains('## M5 Status')) {
    Add-Pass 'README contains M5 Status'
}
elseif ($null -ne $readme) {
    Add-Fail 'README is missing M5 Status'
}

Write-Output 'M5 release management validation'
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
