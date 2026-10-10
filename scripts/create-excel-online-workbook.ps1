param(
    [Parameter(Mandatory = $true)][string]$DataFile,
    [Parameter(Mandatory = $true)][string]$OutputPath
)

$ErrorActionPreference = 'Stop'
$raw = Get-Content -Raw -Encoding UTF8 $DataFile
$json = $raw -replace '^window\.scheduleSource\s*=\s*', '' -replace ';\s*$', ''
$source = $json | ConvertFrom-Json
$headers = @('ID','Regiao','Clinica','Medico','ESP','Agendado','Telefone','Segunda','Terca','Quarta','Quinta','Sexta','AtualizadoEm')

function Get-StableId([string]$text) {
    $sha = [Security.Cryptography.SHA256]::Create()
    try {
        $bytes = [Text.Encoding]::UTF8.GetBytes($text.ToLowerInvariant())
        return ([BitConverter]::ToString($sha.ComputeHash($bytes))).Replace('-', '').Substring(0, 16)
    } finally { $sha.Dispose() }
}

$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$excel.DisplayAlerts = $false
try {
    $book = $excel.Workbooks.Add()
    $sheet = $book.Worksheets.Item(1)
    $sheet.Name = 'AgendaMedicos'
    for ($column = 1; $column -le $headers.Count; $column++) { $sheet.Cells.Item(1, $column).Value2 = $headers[$column - 1] }

    $row = 2
    foreach ($record in $source.records) {
        $identity = "$($record.region)|$($record.clinic)|$($record.doctor)"
        $values = @(
            (Get-StableId $identity), $record.region, $record.clinic, $record.doctor,
            $record.specialty, $record.scheduled, $record.phone,
            $record.days.segunda, $record.days.terca, $record.days.quarta,
            $record.days.quinta, $record.days.sexta, ''
        )
        for ($column = 1; $column -le $values.Count; $column++) { $sheet.Cells.Item($row, $column).Value2 = [string]$values[$column - 1] }
        $row++
    }

    $range = $sheet.Range($sheet.Cells.Item(1,1), $sheet.Cells.Item($row - 1, $headers.Count))
    $table = $sheet.ListObjects.Add(1, $range, $null, 1)
    $table.Name = 'AgendaMedicos'
    $table.TableStyle = 'TableStyleMedium2'
    $sheet.Application.ActiveWindow.SplitRow = 1
    $sheet.Application.ActiveWindow.FreezePanes = $true
    $sheet.Columns.AutoFit() | Out-Null
    $sheet.Columns.Item(1).ColumnWidth = 19
    $sheet.Columns.Item(3).ColumnWidth = 32
    $sheet.Columns.Item(4).ColumnWidth = 38
    for ($column = 8; $column -le 12; $column++) { $sheet.Columns.Item($column).ColumnWidth = 18 }

    $fullOutput = [IO.Path]::GetFullPath((Join-Path (Get-Location) $OutputPath))
    $book.SaveAs($fullOutput, 51)
    $book.Close($true)
    Write-Output "Arquivo criado: $fullOutput"
    Write-Output "Tabela: AgendaMedicos | Registros: $($source.records.Count)"
}
finally {
    $excel.Quit()
    [Runtime.InteropServices.Marshal]::ReleaseComObject($excel) | Out-Null
}
