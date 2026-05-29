param(
    [string]$FilePath = "${PSScriptRoot}\..\# Tarefas.md"
)

$filePath = Resolve-Path -LiteralPath $FilePath
$content = Get-Content -LiteralPath $filePath
$filtered = $content | Where-Object { -not ($_ -match '^\s*-\s*\[(x|X)\]\s+') }

if ($filtered.Count -ne $content.Count) {
    $filtered | Set-Content -LiteralPath $filePath
    Write-Host "Removidas $($content.Count - $filtered.Count) tarefas concluídas."
} else {
    Write-Host "Nenhuma tarefa concluída para remover."
}
