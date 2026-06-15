param(
    [string]$HoraExecucao = "17:00",
    [int]$IntervalMinutos = 60
)

$scriptPath = Split-Path -Parent $MyInvocation.MyFullPath
$limpaScript = Join-Path $scriptPath "limpa_tarefas_completas.ps1"
$resumoScript = Join-Path $scriptPath "resumo-tarefas.ps1"

Write-Host "Agendador iniciado. Gerando resumo diariamente às $HoraExecucao" -ForegroundColor Cyan
Write-Host "Pressione Ctrl+C para encerrar" -ForegroundColor Yellow
Write-Host ""

while ($true) {
    $agora = Get-Date
    $hoje = $agora.ToString('HH:mm')
    
    if ($hoje -eq $HoraExecucao) {
        $data = (Get-Date).ToString('yyyy-MM-dd')
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Limpando tarefas..." -ForegroundColor Green
        & $limpaScript
        
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Gerando resumo para $data..." -ForegroundColor Green
        & $resumoScript -Date $data
        
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Resumo salvo em: resumo-tarefas-$data.md" -ForegroundColor Green
        Write-Host ""
        
        Start-Sleep -Seconds 61
    }
    
    Start-Sleep -Seconds $IntervalMinutos
}
