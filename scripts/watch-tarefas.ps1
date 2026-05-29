$filePath = Resolve-Path -LiteralPath "${PSScriptRoot}\..\# Tarefas.md"
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = Split-Path -Parent $filePath
$watcher.Filter = Split-Path -Leaf $filePath
$watcher.NotifyFilter = [System.IO.NotifyFilters]::LastWrite

$debounce = $false
$action = {
    if ($debounce) { return }
    $debounce = $true
    Start-Sleep -Milliseconds 250
    & "${PSScriptRoot}\limpa_tarefas_completas.ps1" -FilePath $filePath | Out-Null
    $debounce = $false
}

Register-ObjectEvent $watcher Changed -Action $action | Out-Null
$watcher.EnableRaisingEvents = $true
Write-Host "Observando $filePath. Marque tarefas com '- [x]' e elas serão removidas automaticamente."
Write-Host "Pressione Enter para encerrar."
Read-Host | Out-Null
