param([string]$Modo = "daemon")

$pastaScripts = $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($pastaScripts)) {
    $pastaScripts = Get-Location
}

$limpaScript = Join-Path $pastaScripts "limpa_tarefas_completas.ps1"
$resumoScript = Join-Path $pastaScripts "resumo-tarefas.ps1"
$enviarScript = Join-Path $pastaScripts "enviar-resumo.ps1"
$configScript = Join-Path $pastaScripts "config-email.ps1"

Write-Host "================================================"
Write-Host "Automacao de Tarefas e Resumos Diarios"
Write-Host "================================================"
Write-Host ""

if (-not (Test-Path $configScript)) {
    Write-Host "ERRO: Arquivo config-email.ps1 nao encontrado" -ForegroundColor Red
    exit 1
}

Write-Host "Carregando configuracao..." -ForegroundColor Cyan
. $configScript

Write-Host "Email: $EmailUsuario" -ForegroundColor Green
Write-Host "Destinatario: $EmailDestinatario" -ForegroundColor Green
Write-Host "Hora: $HoraExecucao" -ForegroundColor Green
Write-Host ""

if ($Modo -eq "daemon") {
    Write-Host "Modo DAEMON - Pressione Ctrl+C para parar" -ForegroundColor Yellow
    Write-Host ""
    
    while ($true) {
        $agora = Get-Date
        $hoje = $agora.ToString('HH:mm')
        
        if ($hoje -eq $HoraExecucao) {
            $data = (Get-Date).ToString('yyyy-MM-dd')
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Iniciando ciclo..." -ForegroundColor Green
            
            & $limpaScript
            & $resumoScript -Date $data
            & $enviarScript -EmailUsuario $EmailUsuario -SenhaUsuario $SenhaUsuario -EmailDestinatario $EmailDestinatario -EmailCC $EmailCC -ServidorSMTP $ServidorSMTP -PortaSMTP $PortaSMTP -Data $data
            
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Ciclo concluido!" -ForegroundColor Green
            Write-Host ""
            Start-Sleep -Seconds 61
        }
        
        Start-Sleep -Seconds 30
    }
} else {
    Write-Host "Modo MANUAL - Comandos disponiveis:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. Limpar tarefas:"
    Write-Host "   & '$limpaScript'"
    Write-Host ""
    Write-Host "2. Gerar resumo:"
    Write-Host "   & '$resumoScript' -Date '2026-06-02'"
    Write-Host ""
    Write-Host "3. Enviar email:"
    Write-Host "   `$config = @{}; . '$configScript'; & '$enviarScript' @`$config -Data '2026-06-02'"
}
