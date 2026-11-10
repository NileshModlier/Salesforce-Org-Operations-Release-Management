# Validates the M1 foundation. Exits 0 on success and 1 when any check fails.
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

function Read-RepoFile {
    param(
        [string]$RelativePath,
        [int]$MinimumLength = 40
    )
    $full = Join-Path $root $RelativePath
    if (-not (Test-Path -LiteralPath $full)) {
        Add-Fail "Missing file: $RelativePath"
        return $null
    }
    $item = Get-Item -LiteralPath $full
    if ($item.Length -lt $MinimumLength) {
        Add-Fail "File is too small to be a real document: $RelativePath ($($item.Length) bytes)"
    }
    return Get-Content -LiteralPath $full -Raw -Encoding UTF8
}

$requiredFiles = @(
    'README.md',
    'sfdx-project.json',
    'manifest/package.xml',
    '.gitignore',
    'config/project-scratch-def.json',
    'docs/personas.md',
    'docs/requirements.md',
    'docs/environment_strategy.md',
    'docs/flosum_access.md',
    'docs/lifecycle_center_notes.md'
)

$requiredDirs = @(
    'org-ops',
    'docs',
    'release',
    'helper',
    'force-app',
    'force-app/main/default',
    'tests',
    'manifest',
    'config'
)

foreach ($dir in $requiredDirs) {
    if (Test-Path -LiteralPath (Join-Path $root $dir) -PathType Container) {
        Add-Pass "Directory present: $dir"
    }
    else {
        Add-Fail "Missing directory: $dir"
    }
}

foreach ($file in $requiredFiles) {
    $minimum = if ($file -like '*.md') { 400 } else { 40 }
    $content = Read-RepoFile $file $minimum
    if ($null -ne $content) {
        Add-Pass "Document present: $file"
    }
}

$personaText = Read-RepoFile 'docs/personas.md' 400
$personaNames = @('Sales Rep', 'Support Agent L1', 'Support Lead L2', 'Ops Admin')
$personaSections = @(
    'Responsibilities',
    'Objects Used',
    'Reports Needed',
    'Permissions Needed',
    'Pain Points',
    'Success Criteria'
)

if ($null -ne $personaText) {
    $personaCount = 0
    foreach ($name in $personaNames) {
        $heading = "(?m)^## " + [regex]::Escape($name) + "\s*$"
        $found = [regex]::Matches($personaText, $heading)
        if ($found.Count -ne 1) {
            Add-Fail "Persona heading '$name' appears $($found.Count) times. Expected 1."
            continue
        }
        $personaCount++
        $start = $found[0].Index + $found[0].Length
        $rest = $personaText.Substring($start)
        $next = [regex]::Match($rest, '(?m)^## ')
        $body = if ($next.Success) { $rest.Substring(0, $next.Index) } else { $rest }
        foreach ($section in $personaSections) {
            $sectionPattern = "(?m)^### " + [regex]::Escape($section) + "\s*$"
            if ([regex]::IsMatch($body, $sectionPattern)) {
                Add-Pass "Persona '$name' has section $section"
            }
            else {
                Add-Fail "Persona '$name' is missing section $section"
            }
        }
    }
    if ($personaCount -eq 4) {
        Add-Pass "Persona count: 4"
    }
    else {
        Add-Fail "Persona count: $personaCount. Expected 4."
    }
}

$requirementText = Read-RepoFile 'docs/requirements.md' 400
$allowedPersonas = $personaNames
$allowedPriorities = @('High', 'Medium', 'Low')
$allowedThemes = @(
    'Sales Pipeline',
    'Lead Qualification',
    'Case Management',
    'Escalation',
    'Reporting',
    'Access Control'
)

if ($null -ne $requirementText) {
    $headings = [regex]::Matches($requirementText, '(?m)^### (REQ-\d{3})\s*$')
    $ids = @($headings | ForEach-Object { $_.Groups[1].Value })
    $unique = @($ids | Select-Object -Unique)
    if ($ids.Count -ge 10 -and $ids.Count -le 15) {
        Add-Pass "Requirement count: $($ids.Count) (allowed range 10-15)"
    }
    else {
        Add-Fail "Requirement count: $($ids.Count). Expected between 10 and 15."
    }
    if ($unique.Count -ne $ids.Count) {
        Add-Fail "Requirement ids are not unique."
    }
    $expectedIds = @(1..$ids.Count | ForEach-Object { 'REQ-{0:D3}' -f $_ })
    $missingIds = @($expectedIds | Where-Object { $_ -notin $ids })
    $extraIds = @($ids | Where-Object { $_ -notin $expectedIds })
    if ($missingIds.Count -eq 0 -and $extraIds.Count -eq 0 -and $ids.Count -gt 0) {
        Add-Pass "Requirement ids are sequential from REQ-001"
    }
    else {
        Add-Fail "Requirement ids are not REQ-001 through the last story. Missing: $($missingIds -join ', '). Extra: $($extraIds -join ', ')."
    }

    $themesSeen = @{}
    $personasSeen = @{}
    foreach ($heading in $headings) {
        $id = $heading.Groups[1].Value
        $start = $heading.Index + $heading.Length
        $rest = $requirementText.Substring($start)
        $next = [regex]::Match($rest, '(?m)^#{2,3} ')
        $body = if ($next.Success) { $rest.Substring(0, $next.Index) } else { $rest }

        $idLine = [regex]::Match($body, '(?m)^- \*\*Requirement ID:\*\* (REQ-\d{3})\s*$')
        $themeLine = [regex]::Match($body, '(?m)^- \*\*Theme:\*\* (.+?)\s*$')
        $storyLine = [regex]::Match($body, '(?m)^- \*\*User Story:\*\* (.+)$')
        $priorityLine = [regex]::Match($body, '(?m)^- \*\*Priority:\*\* (High|Medium|Low)\s*$')
        $personaLine = [regex]::Match($body, '(?m)^- \*\*Persona:\*\* (.+?)\s*$')
        $criteria = [regex]::Matches($body, '(?m)^  - .+$')

        if (-not $idLine.Success -or $idLine.Groups[1].Value -ne $id) {
            Add-Fail "$id is missing a matching Requirement ID field."
        }
        if (-not $storyLine.Success -or $storyLine.Groups[1].Value -notmatch '^As an? ') {
            Add-Fail "$id user story must start with 'As a' or 'As an'."
        }
        if ($criteria.Count -lt 2) {
            Add-Fail "$id needs at least two acceptance criteria."
        }
        if (-not $priorityLine.Success -or $priorityLine.Groups[1].Value -notin $allowedPriorities) {
            Add-Fail "$id priority is missing or not High, Medium, or Low."
        }
        if (-not $personaLine.Success -or $personaLine.Groups[1].Value -notin $allowedPersonas) {
            Add-Fail "$id persona is missing or not one of the four personas."
        }
        elseif ($storyLine.Success -and $storyLine.Groups[1].Value -notmatch [regex]::Escape($personaLine.Groups[1].Value)) {
            Add-Fail "$id user story does not name persona $($personaLine.Groups[1].Value)."
        }
        else {
            $personasSeen[$personaLine.Groups[1].Value] = $true
        }
        if (-not $themeLine.Success -or $themeLine.Groups[1].Value -notin $allowedThemes) {
            Add-Fail "$id theme is missing or not one of the six required themes."
        }
        else {
            $themesSeen[$themeLine.Groups[1].Value] = $true
        }
    }

    foreach ($theme in $allowedThemes) {
        if ($themesSeen.ContainsKey($theme)) {
            Add-Pass "Theme covered: $theme"
        }
        else {
            Add-Fail "Theme not covered: $theme"
        }
    }
    foreach ($name in $allowedPersonas) {
        if ($personasSeen.ContainsKey($name)) {
            Add-Pass "Requirements include persona: $name"
        }
        else {
            Add-Fail "No requirement uses persona: $name"
        }
    }
}

$environmentText = Read-RepoFile 'docs/environment_strategy.md' 400
if ($null -ne $environmentText) {
    $diagrams = [regex]::Matches($environmentText, '(?m)^```mermaid\s*$')
    if ($diagrams.Count -ge 2) {
        Add-Pass "Environment diagram count: $($diagrams.Count)"
    }
    else {
        Add-Fail "Environment strategy has $($diagrams.Count) Mermaid diagrams. Expected at least 2."
    }
    foreach ($phrase in @(
            'Production stand-in',
            'UAT stand-in',
            'Dev Hub',
            'Lifecycle Center hub',
            '| Edition | Developer Edition |',
            '| Sandboxes | None |',
            '| Flosum | Not Executed |'
        )) {
        if ($environmentText.Contains($phrase)) {
            Add-Pass "Environment strategy contains: $phrase"
        }
        else {
            Add-Fail "Environment strategy is missing: $phrase"
        }
    }
}

$flosumText = Read-RepoFile 'docs/flosum_access.md' 400
if ($null -ne $flosumText) {
    foreach ($row in @(
            '| Trial request | Not Executed |',
            '| Demo request | Not Executed |',
            '| Product access | Not Executed |',
            '**Access status: Not Executed**'
        )) {
        if ($flosumText.Contains($row)) {
            Add-Pass "Flosum assessment contains: $row"
        }
        else {
            Add-Fail "Flosum assessment is missing: $row"
        }
    }
    if ($flosumText -match '(?i)access granted|trial approved|tenant connected|we have flosum') {
        Add-Fail "Flosum assessment claims access that was not obtained."
    }
}

$lifecycleText = Read-RepoFile 'docs/lifecycle_center_notes.md' 400
if ($null -ne $lifecycleText) {
    foreach ($heading in @(
            '## Purpose',
            '## Architecture',
            '## Git Integration',
            '## Developer Edition Support',
            '## Expected Usage In M5'
        )) {
        if ($lifecycleText.Contains($heading)) {
            Add-Pass "Lifecycle Center notes contain: $heading"
        }
        else {
            Add-Fail "Lifecycle Center notes are missing heading: $heading"
        }
    }
}

$readmeText = Read-RepoFile 'README.md' 400
if ($null -ne $readmeText) {
    foreach ($heading in @(
            '## Project Purpose',
            '## Scope',
            '## Architecture',
            '## Current Status',
            '## Roadmap',
            '## Developer Edition Constraints'
        )) {
        if ($readmeText.Contains($heading)) {
            Add-Pass "README contains: $heading"
        }
        else {
            Add-Fail "README is missing heading: $heading"
        }
    }
}

$projectJsonPath = Join-Path $root 'sfdx-project.json'
if (Test-Path -LiteralPath $projectJsonPath) {
    try {
        $projectJson = Get-Content -LiteralPath $projectJsonPath -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($projectJson.sourceApiVersion -eq '68.0') {
            Add-Pass "sfdx-project.json sourceApiVersion is 68.0"
        }
        else {
            Add-Fail "sfdx-project.json sourceApiVersion is '$($projectJson.sourceApiVersion)'. Expected 68.0."
        }
        $defaultDir = @($projectJson.packageDirectories | Where-Object { $_.default -eq $true -or $_.path -eq 'force-app' })
        if ($defaultDir.Count -ge 1) {
            Add-Pass "sfdx-project.json package directory includes force-app"
        }
        else {
            Add-Fail "sfdx-project.json does not point at force-app."
        }
    }
    catch {
        Add-Fail "sfdx-project.json is not valid JSON: $($_.Exception.Message)"
    }
}

$scratchPath = Join-Path $root 'config/project-scratch-def.json'
if (Test-Path -LiteralPath $scratchPath) {
    try {
        $scratch = Get-Content -LiteralPath $scratchPath -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($scratch.edition -eq 'Developer') {
            Add-Pass "Scratch org definition edition is Developer"
        }
        else {
            Add-Fail "Scratch org definition edition is '$($scratch.edition)'. Expected Developer."
        }
    }
    catch {
        Add-Fail "project-scratch-def.json is not valid JSON: $($_.Exception.Message)"
    }
}

$manifestPath = Join-Path $root 'manifest/package.xml'
if (Test-Path -LiteralPath $manifestPath) {
    $manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8
    if ($manifest -match '<version>68\.0</version>') {
        Add-Pass "package.xml version is 68.0"
    }
    else {
        Add-Fail "package.xml is missing version 68.0."
    }
    foreach ($forbiddenType in @('ApexClass')) {
        if ($manifest -match "<name>$forbiddenType</name>") {
            Add-Fail "package.xml contains out-of-scope type $forbiddenType"
        }
    }
    Add-Pass "package.xml contains no Apex"
}

$outOfScope = @(Get-ChildItem -LiteralPath (Join-Path $root 'force-app') -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object {
            $_.Extension -in @('.cls', '.trigger')
        })
if ($outOfScope.Count -eq 0) {
    Add-Pass "force-app contains no Apex"
}
else {
    Add-Fail "force-app contains out-of-scope metadata: $($outOfScope.Name -join ', ')"
}

Write-Output "M1 foundation validation"
Write-Output "Root: $root"
Write-Output ""
Write-Output "Passed: $($passes.Count)"
foreach ($pass in $passes) {
    Write-Output "  PASS  $pass"
}
Write-Output ""
Write-Output "Failed: $($failures.Count)"
foreach ($failure in $failures) {
    Write-Output "  FAIL  $failure"
}
Write-Output ""

if ($failures.Count -gt 0) {
    Write-Output "RESULT: FAIL"
    exit 1
}

Write-Output "RESULT: PASS"
exit 0
