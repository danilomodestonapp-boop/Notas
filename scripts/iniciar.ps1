param(
    [string]$ConfigFile = $null,
    [string]$Modo = "daemon"
)

if (-not $ConfigFile) {
    $ConfigFile = Split-Path -Parent $MyInvocation.ScriptName
    if ([string]::IsNullOrWhiteSpace($ConfigFile)) {
        $ConfigFile = Get-Location
    }
    $ConfigFile = Join-Path $ConfigFile "config-email.ps1"
}

$scriptPath = Split-Path -Parent $ConfigFile
$limpaScript = Join-Path $scriptPath "limpa_tarefas_completas.ps1"
$resumoScript = Join-Path $scriptPath "resumo-tarefas.ps1"
$enviarScript = Join-Path $scriptPath "enviar-resumo.ps1"

Write-Host "================================================"
Write-Host "Automacao de Tarefas e Resumos Diarios"
Write-Host "================================================"
Write-Host ""

if (-not (Test-Path -LiteralPath $ConfigFile)) {
    Write-Host "ERRO: Arquivo de configuracao nao encontrado" -ForegroundColor Red
    Write-Host "Edite o arquivo: config-email.ps1" -ForegroundColor Yellow
    exit 1
}

Write-Host "Carregando configuracao..." -ForegroundColor Cyan
. $ConfigFile

Write-Host "Email: $EmailUsuario" -ForegroundColor Green
Write-Host "Destinatario: $EmailDestinatario" -ForegroundColor Green
Write-Host "Hora de execucao: $HoraExecucao" -ForegroundColor Green
Write-Host ""

if ($Modo -eq "daemon") {
    Write-Host "Modo DAEMON iniciado" -ForegroundColor Cyan
    Write-Host "Pressione Ctrl+C para parar" -ForegroundColor Yellow
    Write-Host ""
    
    while ($true) {
        $agora = Get-Date
        $hoje = $agora.ToString('HH:mm')
        
        if ($hoje -eq $HoraExecucao) {
            $data = (Get-Date).ToString('yyyy-MM-dd')
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Iniciando ciclo..." -ForegroundColor Green
            
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Limpando tarefas..." -ForegroundColor Cyan
            & $limpaScript
            
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Gerando resumo..." -ForegroundColor Cyan
            & $resumoScript -Date $data
            
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Enviando email..." -ForegroundColor Cyan
            & $enviarScript -EmailUsuario $EmailUsuario -SenhaUsuario $SenhaUsuario -EmailDestinatario $EmailDestinatario -EmailCC $EmailCC -ServidorSMTP $ServidorSMTP -PortaSMTP $PortaSMTP -Data $data
            
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Ciclo concluido!" -ForegroundColor Green
            Write-Host ""
            
            Start-Sleep -Seconds 61
        }
        
        Start-Sleep -Seconds 30
    }
}
else {
    Write-Host "Modo MANUAL" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Comandos disponiveis:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Limpar tarefas concluidas:"
    Write-Host "   powershell -NoProfile -File scripts\limpa_tarefas_completas.ps1"
    Write-Host ""
    Write-Host "2. Gerar resumo do dia:"
    Write-Host "   powershell -NoProfile -File scripts\resumo-tarefas.ps1 -Date (Get-Date).ToString('yyyy-MM-dd')"
    Write-Host ""
    Write-Host "3. Enviar resumo por email:"
    Write-Host "   powershell -NoProfile -File scripts\enviar-resumo.ps1 -EmailUsuario <email> -SenhaUsuario <senha> -EmailDestinatario <email> -Data (Get-Date).ToString('yyyy-MM-dd')"
}
