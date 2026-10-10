param(
    [Parameter(Mandatory = $true)][string]$WorkbookPath,
    [Parameter(Mandatory = $true)][string]$OutputPath
)

$ErrorActionPreference = 'Stop'
$dayKeys = @('segunda', 'terca', 'quarta', 'quinta', 'sexta')
$regionNames = @{
    'JD Cuiaba ' = ('Jardim Cuiab' + [char]0x00E1)
    'Santa Rosa' = 'Santa Rosa'
    'Várzea Grande' = 'Várzea Grande'
    'Centro e quilombo' = 'Centro e Quilombo'
    'Araes' = ('Ara' + [char]0x00E9 + 's')
}

function Clean-Value([object]$value) {
    return ([string]$value).Trim() -replace '\s+', ' '
}

$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$excel.DisplayAlerts = $false
$records = [System.Collections.Generic.List[object]]::new()
$issues = [System.Collections.Generic.List[object]]::new()

try {
    $book = $excel.Workbooks.Open((Resolve-Path $WorkbookPath).Path, 0, $true)
    foreach ($sheet in $book.Worksheets) {
        $region = $regionNames[[string]$sheet.Name]
        if (-not $region) { $region = Clean-Value $sheet.Name }
        $used = $sheet.UsedRange
        $clinic = ''
        $inTable = $false

        for ($row = 1; $row -le $used.Rows.Count; $row++) {
            $cells = for ($col = 1; $col -le 9; $col++) { Clean-Value ($sheet.Cells.Item($row, $col).Text) }
            $first = $cells[0]
            $nextFirst = if ($row -lt $used.Rows.Count) { Clean-Value ($sheet.Cells.Item($row + 1, 1).Text) } else { '' }

            if ($first -and $nextFirst -match '(?i)^m.dico$') {
                $clinic = $first
                $inTable = $false
                continue
            }
            if ($first -match '(?i)^m.dico$') {
                $inTable = $true
                continue
            }
            if (-not $inTable -or -not $first -or -not $clinic) { continue }

            $days = [ordered]@{}
            for ($index = 0; $index -lt $dayKeys.Count; $index++) {
                $days[$dayKeys[$index]] = $cells[4 + $index]
            }
            $record = [ordered]@{
                clinic = $clinic
                region = $region
                doctor = $first
                specialty = $cells[1]
                scheduled = $cells[2]
                phone = $cells[3]
                days = $days
                source = [ordered]@{ sheet = [string]$sheet.Name; row = $row }
            }
            $records.Add([pscustomobject]$record)

            foreach ($day in $dayKeys) {
                $value = $days[$day]
                if ($value -and $value -notmatch '\d{1,2}:\d{2}' -and $value -notmatch '(?i)manh|tarde') {
                    $issues.Add([pscustomobject][ordered]@{
                        type = 'Horario nao padronizado'
                        clinic = $clinic
                        doctor = $first
                        day = $day
                        value = $value
                        source = "$($sheet.Name), linha $row"
                    })
                }
            }
        }
    }
    $book.Close($false)
}
finally {
    $excel.Quit()
    [Runtime.InteropServices.Marshal]::ReleaseComObject($excel) | Out-Null
}

$payload = [ordered]@{
    importedAt = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ssK')
    sourceFile = [IO.Path]::GetFileName($WorkbookPath)
    records = $records
    issues = $issues
}
$json = $payload | ConvertTo-Json -Depth 8
$javascript = "window.scheduleSource = $json;`n"
[IO.File]::WriteAllText((Join-Path (Resolve-Path (Split-Path $OutputPath -Parent)).Path (Split-Path $OutputPath -Leaf)), $javascript, [Text.UTF8Encoding]::new($false))
Write-Output "Registros importados: $($records.Count)"
Write-Output "Inconsistências sinalizadas: $($issues.Count)"
