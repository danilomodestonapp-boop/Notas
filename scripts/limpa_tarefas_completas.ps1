param(
    [string]$FilePath = "${PSScriptRoot}\..\# Tarefas.md"
)

$filePath = Resolve-Path -LiteralPath $FilePath
$archivePath = Join-Path (Split-Path -Parent $filePath) "tarefas-concluidas.md"

$content = Get-Content -LiteralPath $filePath
$completed = @()
$remaining = @()

foreach ($line in $content) {
    if ($line -match '^\s*-\s*\[(?:x|X)\]\s*') {
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
        $startIndex = [Array]::IndexOf($archiveContent, $dateHeader)
        $existing = @()
        for ($i = $startIndex + 1; $i -lt $archiveContent.Count; $i++) {
            if ($archiveContent[$i] -like '### Concluídas em *') {
                break
            }
            if (-not [string]::IsNullOrWhiteSpace($archiveContent[$i])) {
                $existing += $archiveContent[$i]
            }
        }
        $toAdd = $completed | Where-Object { -not ($existing -contains $_) }
        if ($toAdd.Count -gt 0) {
            Add-Content -LiteralPath $archivePath -Value $toAdd
            Write-Host "Arquivadas $($toAdd.Count) tarefas concluídas em '$archivePath' no grupo '$dateHeader'."
        } else {
            Write-Host "Nenhuma tarefa nova para arquivar em '$dateHeader'." -ForegroundColor Yellow
        }
    } else {
        Add-Content -LiteralPath $archivePath -Value "`n$dateHeader"
        Add-Content -LiteralPath $archivePath -Value $completed
        Write-Host "Arquivadas $($completed.Count) tarefas concluídas em '$archivePath' no grupo '$dateHeader'."
    }

    $remaining | Set-Content -LiteralPath $filePath
    Write-Host "Arquivadas $($completed.Count) tarefas concluídas em '$archivePath' no grupo '$dateHeader'."
} else {
    Write-Host "Nenhuma tarefa concluída para arquivar."
}
