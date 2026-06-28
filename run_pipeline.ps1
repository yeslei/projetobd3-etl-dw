$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ProjectRoot

$Notebooks = @(
    "notebooks/etl_olist.ipynb",
    "notebooks/load_dw.ipynb",
    "notebooks/create_views_dw.ipynb"
)

Write-Host "Iniciando pipeline de notebooks..." -ForegroundColor Cyan

if (-not (Get-Command jupyter -ErrorAction SilentlyContinue)) {
    Write-Error "Jupyter nao foi encontrado. Instale com: pip install jupyter"
}

foreach ($Notebook in $Notebooks) {
    if (-not (Test-Path $Notebook)) {
        Write-Error "Notebook nao encontrado: $Notebook"
    }

    Write-Host ""
    Write-Host "Executando $Notebook" -ForegroundColor Yellow

    jupyter nbconvert `
        --to notebook `
        --execute $Notebook `
        --inplace

    if ($LASTEXITCODE -ne 0) {
        Write-Error "Falha ao executar: $Notebook"
    }
}

Write-Host ""
Write-Host "Pipeline concluido com sucesso." -ForegroundColor Green
