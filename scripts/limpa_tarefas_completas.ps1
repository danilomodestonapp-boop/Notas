param(
    [string]$FilePath = "${PSScriptRoot}\..\# Tarefas.md"
)

$filePath = Resolve-Path -LiteralPath $FilePath
$archivePath = Join-Path (Split-Path -Parent $filePath) "tarefas-concluidas.md"

$content = Get-Content -LiteralPath $filePath
$completed = @()
$remaining = @()

foreach ($line in $content) {
    if ($line -match '^\s*-\s*\[(x|X)\]\s+') {
        $completed += $line
    } else {
        $remaining += $line
    }
}

if ($completed.Count -gt 0) {
    if (-not (Test-Path -LiteralPath $archivePath)) {
        "# Tarefas Concluídas" | Set-Content -LiteralPath $archivePath
    }

    $dateHeader = "### Concluídas em $(Get-Date -Format 'yyyy-MM-dd')"
    $archiveContent = Get-Content -LiteralPath $archivePath

    if ($archiveContent -contains $dateHeader) {
        Add-Content -LiteralPath $archivePath -Value $completed
    } else {
        Add-Content -LiteralPath $archivePath -Value "`n$dateHeader"
        Add-Content -LiteralPath $archivePath -Value $completed
    }

    $remaining | Set-Content -LiteralPath $filePath
    Write-Host "Arquivadas $($completed.Count) tarefas concluídas em '$archivePath' no grupo '$dateHeader'."
} else {
    Write-Host "Nenhuma tarefa concluída para arquivar."
}
