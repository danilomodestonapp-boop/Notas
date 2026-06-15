param(
    [string]$FilePath = "${PSScriptRoot}\..\# Tarefas.md",
    [string]$ArchivePath = "${PSScriptRoot}\..\tarefas-concluidas.md",
    [string]$Date = (Get-Date).ToString('yyyy-MM-dd'),
    [string]$OutputPath = $null
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
    $clean = $task -replace '^[ \t]*[-*]\s*\[[ \t]*[xX][ \t]*\]\s*', ''
    $clean = $clean -replace '\*\*', '' -replace '~~', ''
    return $clean.Trim()
}

function Get-DisplayTask {
    param([string]$task)
    return $task.Trim()
}

function Split-TaskTitleAndDetail {
    param([string]$task)

    if ($task -match '^(?<title>.+?)\s*[-:]\s*(?<detail>.+)$') {
        return @($matches['title'].Trim(), $matches['detail'].Trim())
    }

    return @($task.Trim(), $null)
}

function Classify-Task {
    param([string]$task)

    $text = $task.ToUpperInvariant()
    switch -regex ($text) {
        'PARAMETRIZAÇ|PARAMETRIZAÇAO|PARAMETRIZA.*' { return 'Parametrização' }
        'TESTE|VALIDAÇ|VALIDAÇAO|VALIDA.*' { return 'Teste / Validação' }
        'IMPLEMENTAÇ|IMPLEMENTA.*|RIC' { return 'Implementação' }
        'ACESSO' { return 'Acesso / Configuração' }
        'TREINAMENTO|TREINO' { return 'Treinamento' }
        'SUPORTE' { return 'Suporte' }
        'COMUNICAÇ|COMUNICAC|E-MAIL|EMAIL' { return 'Comunicação' }
        'ATUALIZAÇ|ATUALIZAC|EXE' { return 'Atualização' }
        default { return 'Outros' }
    }
}

function Add-CompletedTasksToArchive {
    param(
        [string[]]$CompletedTasks,
        [string]$ArchivePath,
        [string]$Date
    )

    if (-not (Test-Path -LiteralPath $ArchivePath)) {
        "# Tarefas Concluídas" | Set-Content -LiteralPath $ArchivePath -Encoding utf8BOM
    }

    $archiveContent = Get-Content -LiteralPath $ArchivePath -Encoding utf8
    $dateHeader = "### Concluídas em $Date"
    $cleanCompleted = $CompletedTasks | ForEach-Object { Get-DisplayTask $_ }

    if ($archiveContent -contains $dateHeader) {
        $startIndex = [Array]::IndexOf($archiveContent, $dateHeader)
        $existing = @()
        for ($i = $startIndex + 1; $i -lt $archiveContent.Count; $i++) {
            if ($archiveContent[$i] -like '### Concluídas em *') { break }
            if (-not [string]::IsNullOrWhiteSpace($archiveContent[$i])) {
                $existing += $archiveContent[$i]
            }
        }
        $toAdd = $cleanCompleted | Where-Object { -not ($existing -contains $_) }
        if ($toAdd.Count -gt 0) {
            Add-Content -LiteralPath $ArchivePath -Value $toAdd -Encoding utf8BOM
        }
        return $toAdd.Count
    }

    Add-Content -LiteralPath $ArchivePath -Value "`n$dateHeader" -Encoding utf8BOM
    Add-Content -LiteralPath $ArchivePath -Value $cleanCompleted -Encoding utf8BOM
    return $cleanCompleted.Count
}

function Generate-Summary {
    param(
        [string[]]$Tasks,
        [string]$OutputPath,
        [string]$Date
    )

    if (-not $OutputPath) {
        $OutputPath = Join-Path (Split-Path -Parent $FilePath) "resumo-tarefas-$Date.md"
    }

    $reportDate = Format-PortugueseDate -IsoDate $Date
    $taskCount = $Tasks.Count
    $report = @(
        '================================================================================',
        "RESUMO DE TAREFAS FINALIZADAS - $reportDate",
        '================================================================================',
        '',
        "TOTAL DE TAREFAS: $taskCount concluídas",
        '',
        '================================================================================',
        'DETALHAMENTO DAS TAREFAS',
        '================================================================================',
        ''
    )

    $index = 1
    $categoryCounts = @{}

    foreach ($task in $Tasks) {
        $clean = Clean-Task $task
        $pair = Split-TaskTitleAndDetail -task $clean
        $title = $pair[0]
        $detail = $pair[1]
        $category = Classify-Task -task $title

        if (-not $categoryCounts.ContainsKey($category)) {
            $categoryCounts[$category] = 0
        }
        $categoryCounts[$category]++

        $report += "$index. $title"
        $report += "   Categoria: $category"
        if ($detail) {
            $report += "   Descrição: $detail"
        }
        $report += ''
        $index++
    }

    $report += @(
        '================================================================================',
        'RESUMO EXECUTIVO',
        '================================================================================',
        '',
        "Foram concluídas $taskCount tarefas em $reportDate.",
        ''
    )

    foreach ($category in $categoryCounts.Keys) {
        $report += "• $($categoryCounts[$category]) x $category"
    }

    $report += @(
        '',
        '================================================================================',
        "Data do Relatório: $reportDate",
        '================================================================================'
    )

    $report | Set-Content -LiteralPath $OutputPath -Encoding utf8BOM
    return $OutputPath
}

$filePath = Resolve-Path -LiteralPath $FilePath
if (-not $ArchivePath -or [string]::IsNullOrWhiteSpace($ArchivePath)) {
    $ArchivePath = Join-Path (Split-Path -Parent $filePath) 'tarefas-concluidas.md'
}

try {
    $archivePath = Resolve-Path -LiteralPath $ArchivePath -ErrorAction Stop
} catch {
    $archivePath = [System.IO.Path]::GetFullPath($ArchivePath)
}

Write-Host "Arquivo de tarefas: $filePath" -ForegroundColor Cyan
Write-Host "Arquivo de arquivamento: $archivePath" -ForegroundColor Cyan

$content = Get-Content -LiteralPath $filePath -Encoding utf8
$completed = $content | Where-Object { $_ -match '^[ \t]*[-*]\s*\[[ \t]*[xX][ \t]*\]\s*' }
$remaining = $content | Where-Object { $_ -notmatch '^[ \t]*[-*]\s*\[[ \t]*[xX][ \t]*\]\s*' }
Write-Host "Tarefas encontradas: $($content.Count)" -ForegroundColor Cyan
Write-Host "Tarefas concluídas detectadas: $($completed.Count)" -ForegroundColor Cyan
Write-Host "Tarefas restantes após remoção: $($remaining.Count)" -ForegroundColor Cyan

if ($completed.Count -eq 0) {
    Write-Host 'Nenhuma tarefa concluída encontrada.' -ForegroundColor Yellow
    exit 0
}

$addedCount = Add-CompletedTasksToArchive -CompletedTasks $completed -ArchivePath $archivePath -Date $Date
$remaining | Set-Content -LiteralPath $filePath -Encoding utf8BOM

if (-not $OutputPath) {
    $OutputPath = Join-Path (Split-Path -Parent $filePath) "resumo-tarefas-$Date.md"
}
$outputPath = [System.IO.Path]::GetFullPath($OutputPath)
$summaryPath = Generate-Summary -Tasks $completed -OutputPath $outputPath -Date $Date

Write-Host "Concluídas $($completed.Count) tarefas e removidas de '$filePath'." -ForegroundColor Green
Write-Host "Tarefas salvas em: $archivePath" -ForegroundColor Green
Write-Host "Resumo gerado em: $summaryPath" -ForegroundColor Green
