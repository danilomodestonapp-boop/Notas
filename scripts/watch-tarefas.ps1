$filePath = Resolve-Path -LiteralPath "${PSScriptRoot}\..\# Tarefas.md"
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = Split-Path -Parent $filePath
$watcher.Filter = Split-Path -Leaf $filePath
$watcher.NotifyFilter = [System.IO.NotifyFilters]::LastWrite -bor [System.IO.NotifyFilters]::FileName -bor [System.IO.NotifyFilters]::DirectoryName
$watcher.IncludeSubdirectories = $false

$debounce = $false
$action = {
    if ($debounce) { return }
    $debounce = $true
    Start-Sleep -Milliseconds 250
    if (Test-Path -LiteralPath $filePath) {
        & "${PSScriptRoot}\limpa_tarefas_completas.ps1" -FilePath $filePath | Out-Null
    }
    $debounce = $false
}

Register-ObjectEvent $watcher Changed -Action $action | Out-Null
Register-ObjectEvent $watcher Created -Action $action | Out-Null
Register-ObjectEvent $watcher Renamed -Action $action | Out-Null
$watcher.EnableRaisingEvents = $true
Write-Host "Observando $filePath. Marque tarefas com '- [x]' e elas serão removidas automaticamente."
Write-Host "Pressione Enter para encerrar."
Read-Host | Out-Null
