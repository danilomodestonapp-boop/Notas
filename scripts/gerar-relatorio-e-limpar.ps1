param(
    [string]$FilePath = "${PSScriptRoot}\..\# Tarefas.md",
    [string]$ArchivePath = "${PSScriptRoot}\..\tarefas-concluidas.md",
    [string]$Date = (Get-Date).ToString('yyyy-MM-dd'),
    [string]$OutputPath = $null
)

$filePath = Resolve-Path -LiteralPath $FilePath
$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $PSCommandPath }
$workflowScript = Join-Path $scriptDir "salvar-gerar-relatorio-resumo.ps1"

Write-Host "Iniciando fluxo de salvar, gerar relatório e limpar tarefas concluídas..." -ForegroundColor Cyan
& $workflowScript -FilePath $filePath -ArchivePath $ArchivePath -Date $Date -OutputPath $OutputPath

Write-Host "Operação concluída." -ForegroundColor Green
