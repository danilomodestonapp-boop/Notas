param(
    [string]$ArchivePath = "${PSScriptRoot}\..\tarefas-concluidas.md",
    [string]$OutputPath = $null,
    [string]$Date = (Get-Date).ToString('yyyy-MM-dd')
)

$archivePath = Resolve-Path -LiteralPath $ArchivePath
if (-not $OutputPath) {
    $OutputPath = Join-Path (Split-Path -Parent $archivePath) "resumo-tarefas-$Date.txt"
}
$outputPath = [System.IO.Path]::GetFullPath($OutputPath)
$content = Get-Content -LiteralPath $archivePath -ErrorAction Stop
$header = "### Concluídas em $Date"

$found = $false
$summary = @()
foreach ($line in $content) {
    if ($line -eq $header) {
        $found = $true
        continue
    }
    if ($found) {
        if ($line -like '### Concluídas em *') {
            break
        }
        if (-not [string]::IsNullOrWhiteSpace($line)) {
            $summary += $line
        }
    }
}

if (-not $found) {
    Write-Host "Não encontrei seção para '$Date' em '$archivePath'." -ForegroundColor Yellow
    exit 1
}

if ($summary.Count -eq 0) {
    Write-Host "Nenhuma tarefa concluída encontrada para '$Date'." -ForegroundColor Yellow
    exit 0
}

$summary = $summary | Select-Object -Unique
$report = @(
    "Resumo de tarefas concluídas em $Date",
    "===================================",
    ""
) + $summary

$report | Set-Content -LiteralPath $outputPath -Encoding utf8
Write-Host "Resumo gerado em: $outputPath" -ForegroundColor Green
Write-Host ""
$report | ForEach-Object { Write-Host $_ }
