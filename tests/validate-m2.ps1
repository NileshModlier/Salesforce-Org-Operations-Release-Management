# Validates M2 configuration metadata and the documents that describe it.
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

function Get-Section {
    param(
        [string]$Text,
        [string]$Heading
    )
    $pattern = "(?m)^## " + [regex]::Escape($Heading) + "\s*$"
    $found = [regex]::Match($Text, $pattern)
    if (-not $found.Success) {
        return $null
    }
    $rest = $Text.Substring($found.Index + $found.Length)
    $next = [regex]::Match($rest, '(?m)^## ')
    if ($next.Success) {
        return $rest.Substring(0, $next.Index)
    }
    return $rest
}

function Get-NormalizedFormula {
    param([string]$Formula)
    $decoded = [System.Net.WebUtility]::HtmlDecode($Formula)
    return ($decoded -replace '\s+', '')
}

$dataModel = Read-RepoText 'docs/data_model.md'
$ruleDoc = Read-RepoText 'docs/validation_rules.md'
$testCases = Read-RepoText 'docs/test-cases.md'
$traceability = Read-RepoText 'docs/requirement_traceability.md'
$layoutDoc = Read-RepoText 'docs/layout_strategy.md'
$readme = Read-RepoText 'README.md'

$fieldFiles = @(Get-ChildItem -LiteralPath (Join-Path $root 'force-app/main/default/objects') -Recurse -Filter '*.field-meta.xml')
if ($fieldFiles.Count -eq 0) {
    Add-Fail 'No custom fields found.'
}
foreach ($file in $fieldFiles) {
    $objectName = $file.Directory.Parent.Name
    $apiName = $file.BaseName -replace '\.field-meta$', ''
    $qualified = "$objectName.$apiName"
    if ($null -eq $dataModel) {
        continue
    }
    $section = Get-Section $dataModel $qualified
    if ($null -eq $section) {
        Add-Fail "data_model.md is missing $qualified"
        continue
    }
    $missingLabels = @('Purpose', 'Type', 'Used By', 'Requirement') | Where-Object { $section -notmatch [regex]::Escape($_) }
    if ($missingLabels.Count -eq 0) {
        Add-Pass "Field documented: $qualified"
    }
    else {
        Add-Fail "$qualified is missing documentation labels: $($missingLabels -join ', ')"
    }
    if ($null -ne $traceability -and $traceability.Contains($apiName)) {
        Add-Pass "Traceability names field $apiName"
    }
    elseif ($null -ne $traceability) {
        Add-Fail "Traceability does not name field $apiName"
    }
}

$ruleFiles = @(Get-ChildItem -LiteralPath (Join-Path $root 'force-app/main/default/objects') -Recurse -Filter '*.validationRule-meta.xml')
if ($ruleFiles.Count -ge 4 -and $ruleFiles.Count -le 6) {
    Add-Pass "Validation rule count: $($ruleFiles.Count)"
}
else {
    Add-Fail "Validation rule count: $($ruleFiles.Count). Expected 4 to 6."
}

foreach ($file in $ruleFiles) {
    $ruleName = $file.BaseName -replace '\.validationRule-meta$', ''
    $xml = Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8
    $formulaMatch = [regex]::Match($xml, '(?s)<errorConditionFormula>(.*?)</errorConditionFormula>')
    $messageMatch = [regex]::Match($xml, '(?s)<errorMessage>(.*?)</errorMessage>')
    $activeMatch = [regex]::Match($xml, '(?s)<active>(.*?)</active>')
    if ($activeMatch.Success -and $activeMatch.Groups[1].Value.Trim() -eq 'true') {
        Add-Pass "$ruleName is active"
    }
    else {
        Add-Fail "$ruleName is not active"
    }
    if (-not $formulaMatch.Success -or -not $messageMatch.Success) {
        Add-Fail "$ruleName metadata is missing a formula or error message"
        continue
    }
    $section = if ($null -ne $ruleDoc) { Get-Section $ruleDoc $ruleName } else { $null }
    if ($null -eq $section) {
        Add-Fail "validation_rules.md is missing $ruleName"
    }
    else {
        foreach ($label in @('Rule Formula', 'Error Message', 'Requirement')) {
            if ($section -match [regex]::Escape($label)) {
                Add-Pass "$ruleName documents $label"
            }
            else {
                Add-Fail "$ruleName is missing $label"
            }
        }
        $docFormula = [regex]::Match($section, '(?s)```\s*(.*?)\s*```')
        if ($docFormula.Success -and (Get-NormalizedFormula $docFormula.Groups[1].Value) -eq (Get-NormalizedFormula $formulaMatch.Groups[1].Value)) {
            Add-Pass "$ruleName formula matches the metadata"
        }
        else {
            Add-Fail "$ruleName formula in the doc does not match the metadata"
        }
        $message = $messageMatch.Groups[1].Value.Trim()
        if ($section.Contains($message)) {
            Add-Pass "$ruleName error message matches the metadata"
        }
        else {
            Add-Fail "$ruleName error message in the doc does not match the metadata"
        }
    }
    $caseSection = if ($null -ne $testCases) { Get-Section $testCases $ruleName } else { $null }
    if ($null -eq $caseSection) {
        Add-Fail "test-cases.md is missing $ruleName"
    }
    else {
        foreach ($example in @('PASS 1', 'PASS 2', 'PASS 3', 'FAIL 1', 'FAIL 2', 'FAIL 3')) {
            if ($caseSection.Contains($example)) {
                Add-Pass "$ruleName has $example"
            }
            else {
                Add-Fail "$ruleName is missing $example"
            }
        }
    }
    if ($null -ne $traceability -and $traceability.Contains($ruleName)) {
        Add-Pass "Traceability names rule $ruleName"
    }
    elseif ($null -ne $traceability) {
        Add-Fail "Traceability does not name rule $ruleName"
    }
}

if ($null -ne $traceability) {
    foreach ($id in 1..12) {
        $req = 'REQ-{0:D3}' -f $id
        if ($traceability.Contains($req)) {
            Add-Pass "Traceability covers $req"
        }
        else {
            Add-Fail "Traceability is missing $req"
        }
    }
}

if ($null -ne $layoutDoc) {
    foreach ($token in @(
            'Sales Rep',
            'Support Agent L1',
            'Support Lead L2',
            'Ops Admin',
            'Lead_Record_Page',
            'Opportunity_Record_Page',
            'Case_Record_Page',
            '## Dynamic visibility',
            '## Page activation'
        )) {
        if ($layoutDoc.Contains($token)) {
            Add-Pass "Layout strategy contains $token"
        }
        else {
            Add-Fail "Layout strategy is missing $token"
        }
    }
}

$layoutExpectations = @(
    @{ Path = 'force-app/main/default/layouts/Lead-Sales Rep.layout-meta.xml'; Pattern = '<field>Product_Interest__c</field>' },
    @{ Path = 'force-app/main/default/layouts/Opportunity-Sales Rep.layout-meta.xml'; Pattern = '<field>Next_Step__c</field>' },
    @{ Path = 'force-app/main/default/layouts/Opportunity-Support Lead L2.layout-meta.xml'; Pattern = '<behavior>Readonly</behavior>\s*<field>Next_Step__c</field>' },
    @{ Path = 'force-app/main/default/layouts/Case-Support Agent L1.layout-meta.xml'; Pattern = '<behavior>Readonly</behavior>\s*<field>Resolution_Notes__c</field>' },
    @{ Path = 'force-app/main/default/layouts/Case-Support Lead L2.layout-meta.xml'; Pattern = '<behavior>Edit</behavior>\s*<field>Resolution_Notes__c</field>' },
    @{ Path = 'force-app/main/default/layouts/Case-Ops Admin.layout-meta.xml'; Pattern = '<field>Escalation_Reason__c</field>' },
    @{ Path = 'force-app/main/default/layouts/Lead-Ops Admin.layout-meta.xml'; Pattern = '<field>Product_Interest__c</field>' },
    @{ Path = 'force-app/main/default/layouts/Opportunity-Ops Admin.layout-meta.xml'; Pattern = '<field>Next_Step__c</field>' },
    @{ Path = 'force-app/main/default/layouts/User-Ops Admin.layout-meta.xml'; Pattern = '<field>Persona__c</field>' }
)
foreach ($expected in $layoutExpectations) {
    $text = Read-RepoText $expected.Path
    if ($null -eq $text) {
        continue
    }
    if ($text -match $expected.Pattern) {
        Add-Pass "Layout check passed: $($expected.Path)"
    }
    else {
        Add-Fail "Layout check failed: $($expected.Path)"
    }
}

$pageExpectations = @(
    @{ Path = 'force-app/main/default/flexipages/Lead_Record_Page.flexipage-meta.xml'; Tokens = @('visibilityRule', '{!$User.Persona__c}', '{!Record.Status}', 'sobjectType>Lead') },
    @{ Path = 'force-app/main/default/flexipages/Opportunity_Record_Page.flexipage-meta.xml'; Tokens = @('visibilityRule', '{!$User.Persona__c}', '{!Record.StageName}', 'sobjectType>Opportunity') },
    @{ Path = 'force-app/main/default/flexipages/Case_Record_Page.flexipage-meta.xml'; Tokens = @('visibilityRule', '{!$User.Persona__c}', '{!Record.Status}', 'sobjectType>Case') }
)
foreach ($expected in $pageExpectations) {
    $text = Read-RepoText $expected.Path
    if ($null -eq $text) {
        continue
    }
    $missing = @($expected.Tokens | Where-Object { $text -notlike "*$_*" })
    if ($missing.Count -eq 0) {
        Add-Pass "Record page check passed: $($expected.Path)"
    }
    else {
        Add-Fail "Record page $($expected.Path) is missing: $($missing -join ', ')"
    }
}

$valueSets = @{
    'force-app/main/default/standardValueSets/LeadStatus.standardValueSet-meta.xml' = @('Open - Not Contacted', 'Working - Contacted', 'Qualified', 'Unqualified')
    'force-app/main/default/standardValueSets/OpportunityStage.standardValueSet-meta.xml' = @('Prospecting', 'Qualification', 'Proposal', 'Negotiation', 'Closed Won', 'Closed Lost')
    'force-app/main/default/standardValueSets/CaseStatus.standardValueSet-meta.xml' = @('New', 'Working', 'Waiting on Customer', 'Escalated', 'Closed')
}
foreach ($entry in $valueSets.GetEnumerator()) {
    $text = Read-RepoText $entry.Key
    if ($null -eq $text) {
        continue
    }
    $missing = @($entry.Value | Where-Object { $text -notlike "*$_*" })
    if ($missing.Count -eq 0) {
        Add-Pass "Value set contains the process contract: $($entry.Key)"
    }
    else {
        Add-Fail "$($entry.Key) is missing values: $($missing -join ', ')"
    }
}

$forbidden = @(Get-ChildItem -LiteralPath (Join-Path $root 'force-app') -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object {
            $_.Extension -in @('.cls', '.trigger')
        })
if ($forbidden.Count -eq 0) {
    Add-Pass 'No Apex was added'
}
else {
    Add-Fail "Out-of-scope metadata found: $($forbidden.Name -join ', ')"
}

$manifest = Read-RepoText 'manifest/package.xml'
if ($null -ne $manifest) {
    foreach ($typeName in @('CustomField', 'ValidationRule', 'Layout', 'FlexiPage', 'StandardValueSet')) {
        if ($manifest -match "<name>$typeName</name>") {
            Add-Pass "Manifest includes $typeName"
        }
        else {
            Add-Fail "Manifest is missing $typeName"
        }
    }
    foreach ($typeName in @('ApexClass')) {
        if ($manifest -match "<name>$typeName</name>") {
            Add-Fail "Manifest includes forbidden type $typeName"
        }
    }
}

if ($null -ne $readme) {
    foreach ($heading in @('## M2 Status', '## Configuration Summary', '## Metadata Categories')) {
        if ($readme.Contains($heading)) {
            Add-Pass "README contains $heading"
        }
        else {
            Add-Fail "README is missing $heading"
        }
    }
}

Write-Output 'M2 configuration validation'
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
