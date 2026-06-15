param(
    [string]$ArchivePath = "${PSScriptRoot}\..\tarefas-concluidas.md",
    [string]$OutputPath = $null,
    [string]$Date = (Get-Date).ToString('yyyy-MM-dd'),
    [string]$PeriodStart = $null,
    [string]$PeriodEnd = $null
)

function Get-PortugueseMonthName {
    param([int]$Month)
    $months = @(
        'janeiro','fevereiro','março','abril','maio','junho',
        'julho','agosto','setembro','outubro','novembro','dezembro'
    )
    return $months[$Month - 1]
}

function Format-PortugueseDate {
    param([string]$IsoDate)
    $dt = [datetime]::ParseExact($IsoDate, 'yyyy-MM-dd', $null)
    return "{0:dd} de {1} de {0:yyyy}" -f $dt, (Get-PortugueseMonthName -Month $dt.Month)
}

function Clean-Task {
    param([string]$task)
    $clean = $task -replace '^[ \t]*-\s*\[[xX]\]\s*', ''
    $clean = $clean -replace '\*\*', '' -replace '~~', ''
    return $clean.Trim()
}

function Split-TitleAndDetail {
    param([string]$task)
    if ($task -match '^(?<title>.+?)\s*-\s*(?<detail>.+)$') {
        return @($matches['title'].Trim(), $matches['detail'].Trim())
    }
    if ($task -match '^(?<title>.+?):\s*(?<detail>.+)$') {
        return @($matches['title'].Trim(), $matches['detail'].Trim())
    }
    return @($task, $task)
}

function Classify-Task {
    param([string]$task)
    $text = $task.ToUpperInvariant()
    switch -regex ($text) {
        'PARAMETRIZAÇ|PARAMETRIZAÇAO|PARAMETRIZA.*' { return 'Parametrizações de sistema' }
        'TESTE|VALIDAÇ|VALIDAÇAO|VALIDA.*' { return 'Testes e validações técnicas' }
        'IMPLEMENTAÇ|IMPLEMENTA.*|RIC' { return 'Implementações técnicas' }
        'ACESSO' { return 'Acessos e configurações de sistemas' }
        'TREINAMENTO|TREINO' { return 'Preparação de treinamento' }
        'SUPORTE' { return 'Suporte técnico externo' }
        'COMUNICAÇ|COMUNICAC|E-MAIL|EMAIL' { return 'Comunicação interna' }
        'ATUALIZAÇ|ATUALIZAC|EXE' { return 'Atualização de software' }
        default { return 'Outros' }
    }
}

$archivePath = Resolve-Path -LiteralPath $ArchivePath
if (-not $OutputPath) {
    $OutputPath = Join-Path (Split-Path -Parent $archivePath) "resumo-tarefas-$Date.md"
}
$outputPath = [System.IO.Path]::GetFullPath($OutputPath)
$content = Get-Content -LiteralPath $archivePath -ErrorAction Stop
$header = "### Concluídas em $Date"

$found = $false
$tasks = @()
foreach ($line in $content) {
    if ($line -eq $header) {
        $found = $true
        continue
    }
    if ($found) {
        if ($line -like '### Concluídas em *') {
            break
        }
        if (-not [string]::IsNullOrWhiteSpace($line)) {
            $tasks += Clean-Task $line
        }
    }
}

if (-not $found) {
    Write-Host "Não encontrei seção para '$Date' em '$archivePath'." -ForegroundColor Yellow
    exit 1
}

if ($tasks.Count -eq 0) {
    Write-Host "Nenhuma tarefa concluída encontrada para '$Date'." -ForegroundColor Yellow
    exit 0
}

$tasks = $tasks | Select-Object -Unique

if (-not $PeriodStart) { $PeriodStart = $Date }
if (-not $PeriodEnd) { $PeriodEnd = $Date }

$reportDate = Format-PortugueseDate -IsoDate $Date
$startDt = [datetime]::ParseExact($PeriodStart, 'yyyy-MM-dd', $null)
$endDt = [datetime]::ParseExact($PeriodEnd, 'yyyy-MM-dd', $null)
$periodFormatted = "{0:dd} a {1:dd} de {2} de {0:yyyy}" -f $startDt, $endDt, (Get-PortugueseMonthName -Month $startDt.Month)

$report = @(
    '================================================================================',
    "RESUMO DE TAREFAS REALIZADAS - $reportDate",
    '================================================================================',
    '',
    "PERÍODO: $periodFormatted",
    "TOTAL DE TAREFAS: $($tasks.Count) concluídas",
    '',
    '================================================================================',
    'DETALHAMENTO DAS TAREFAS',
    '================================================================================',
    ''
)

$detailLines = @()
$categoryCounts = @{}
$index = 1
foreach ($task in $tasks) {
    $pair = Split-TitleAndDetail -task $task
    $title = $pair[0]
    $detail = $pair[1]
    $category = Classify-Task -task $title
    if (-not $categoryCounts.ContainsKey($category)) {
        $categoryCounts[$category] = 0
    }
    $categoryCounts[$category]++

    $detailLines += "$index. $title"
    $detailLines += "   $detail"
    $detailLines += ''
    $index++
}

$report += $detailLines
$report += @(
    '================================================================================',
    'RESUMO EXECUTIVO',
    '================================================================================',
    '',
    "Foram realizadas $($tasks.Count) tarefas neste período, compreendendo:"
)

foreach ($category in $categoryCounts.Keys) {
    $count = $categoryCounts[$category]
    $report += "• $count $category"
}

$report += @(
    '',
    'Todas as tarefas foram concluídas conforme planejado.',
    '',
    '================================================================================',
    "Data do Relatório: $reportDate",
    '================================================================================'
)

$report | Set-Content -LiteralPath $outputPath -Encoding utf8BOM
Write-Host "Resumo gerado em: $outputPath" -ForegroundColor Green
Write-Host ''
$report | ForEach-Object { Write-Host $_ }
