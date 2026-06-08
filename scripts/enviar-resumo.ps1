param(
    [string]$ResumoPorEmail = $null,
    [string]$ServidorSMTP = "smtp.gmail.com",
    [int]$PortaSMTP = 587,
    [string]$EmailUsuario = $null,
    [string]$SenhaUsuario = $null,
    [string]$EmailDestinatario = $null,
    [string]$EmailCC = $null,
    [string]$Data = (Get-Date).ToString('yyyy-MM-dd')
)

$scriptPath = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
$pastaRaiz = Split-Path -Parent $scriptPath

if (-not $ResumoPorEmail) {
    $ResumoPorEmail = Join-Path $pastaRaiz "resumo-tarefas-$Data.txt"
}

if (-not (Test-Path -LiteralPath $ResumoPorEmail)) {
    Write-Host "Arquivo de resumo não encontrado: $ResumoPorEmail" -ForegroundColor Red
    Write-Host "Gere primeiro com: powershell -File resumo-tarefas.ps1 -Date '$Data'" -ForegroundColor Yellow
    exit 1
}

if (-not $EmailUsuario -or -not $SenhaUsuario -or -not $EmailDestinatario) {
    Write-Host "Configuração de e-mail incompleta. Use:" -ForegroundColor Yellow
    Write-Host "powershell -File enviar-resumo.ps1 ``" -ForegroundColor Yellow
    Write-Host "  -EmailUsuario seu_email@gmail.com ``" -ForegroundColor Yellow
    Write-Host "  -SenhaUsuario sua_senha ``" -ForegroundColor Yellow
    Write-Host "  -EmailDestinatario destinatario@empresa.com ``" -ForegroundColor Yellow
    Write-Host "  -Data '2026-06-02'" -ForegroundColor Yellow
    Write-Host "" -ForegroundColor Yellow
    Write-Host "Nota: Use App Password se estiver usando Gmail com 2FA" -ForegroundColor Cyan
    exit 1
}

try {
    $conteudo = Get-Content -LiteralPath $ResumoPorEmail -Raw
    
    $credencial = New-Object System.Management.Automation.PSCredential (
        $EmailUsuario,
        (ConvertTo-SecureString $SenhaUsuario -AsPlainText -Force)
    )
    
    $params = @{
        SmtpServer       = $ServidorSMTP
        Port             = $PortaSMTP
        UseSsl           = $true
        Credential       = $credencial
        From             = $EmailUsuario
        To               = $EmailDestinatario
        Subject          = "Resumo de tarefas concluídas - $Data"
        Body             = $conteudo
        BodyAsHtml       = $false
    }
    
    if ($EmailCC) {
        $params['Cc'] = $EmailCC
    }
    
    Send-MailMessage @params
    Write-Host "E-mail enviado com sucesso para: $EmailDestinatario" -ForegroundColor Green
    if ($EmailCC) {
        Write-Host "CC: $EmailCC" -ForegroundColor Green
    }
} catch {
    Write-Host "Erro ao enviar e-mail: $_" -ForegroundColor Red
    exit 1
}
