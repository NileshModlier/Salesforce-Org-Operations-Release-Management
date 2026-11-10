# Validates M6 guides, runbooks, and the procedure assistant.
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

foreach ($relative in @(
        'docs/user-guides/sales-rep.md',
        'docs/user-guides/support-agent.md',
        'docs/runbook/L1.md',
        'docs/runbook/L2.md',
        'docs/support_model.md',
        'docs/ai_helper.md',
        'docs/ai_helper_evaluation.md',
        'helper/ingest.py',
        'helper/ask.py',
        'helper/eval/questions.json',
        'helper/eval/run_eval.py',
        'project_completion.md',
        'release_notes_v1.0.md',
        'future_roadmap.md',
        'portfolio_summary.md'
    )) {
    if (Test-Path -LiteralPath (Join-Path $root $relative)) {
        Add-Pass "Present: $relative"
    }
    else {
        Add-Fail "Missing file: $relative"
    }
}

$l1 = Read-RepoText 'docs/runbook/L1.md'
if ($null -ne $l1) {
    foreach ($topic in @('Login Problems', 'MFA Problems', 'Record Visibility', 'Missing Data', 'Report Access', 'Dashboard Access', 'Case Reassignment')) {
        if ($l1.Contains("## L1:$topic")) {
            Add-Pass "L1 covers $topic"
        }
        else {
            Add-Fail "L1 is missing $topic"
        }
    }
}

$l2 = Read-RepoText 'docs/runbook/L2.md'
if ($null -ne $l2) {
    foreach ($topic in @('Flow Faults', 'Validation Rule Issues', 'Permission Set Problems', 'Release Failures', 'Data Corrections', 'Reporting Discrepancies')) {
        if ($l2.Contains("## L2:$topic")) {
            Add-Pass "L2 covers $topic"
        }
        else {
            Add-Fail "L2 is missing $topic"
        }
    }
}

$sales = Read-RepoText 'docs/user-guides/sales-rep.md'
if ($null -ne $sales) {
    foreach ($token in @('## SalesRep:Lead Qualification', '### Steps', '### Expected outcome', '### Troubleshooting', '## SalesRep:Quick Reference')) {
        if ($sales.Contains($token)) {
            Add-Pass "Sales guide contains $token"
        }
        else {
            Add-Fail "Sales guide is missing $token"
        }
    }
}

$agent = Read-RepoText 'docs/user-guides/support-agent.md'
if ($null -ne $agent) {
    foreach ($token in @('## SupportAgent:Create a Case', '### Steps', '### Expected outcome', '### Troubleshooting', '## SupportAgent:Quick Reference')) {
        if ($agent.Contains($token)) {
            Add-Pass "Support guide contains $token"
        }
        else {
            Add-Fail "Support guide is missing $token"
        }
    }
}

$readme = Read-RepoText 'README.md'
if ($null -ne $readme) {
    foreach ($heading in @('## User Support Model', '## AI Assistant Architecture', '## Knowledge Management Strategy', '## M6 Status')) {
        if ($readme.Contains($heading)) {
            Add-Pass "README contains $heading"
        }
        else {
            Add-Fail "README is missing $heading"
        }
    }
}

if (Get-Command py -ErrorAction SilentlyContinue) {
    & py -3 -m unittest helper.tests.test_helper -v
}
elseif (Get-Command python -ErrorAction SilentlyContinue) {
    & python -m unittest helper.tests.test_helper -v
}
else {
    Add-Fail 'Python is not available to run helper tests'
    $global:LASTEXITCODE = 1
}
if ($LASTEXITCODE -eq 0) {
    Add-Pass 'helper.tests.test_helper passed'
}
elseif ($failures -notcontains 'Python is not available to run helper tests') {
    Add-Fail "helper.tests.test_helper exited $LASTEXITCODE"
}

Write-Output 'M6 user support validation'
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
