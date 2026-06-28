$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ProjectRoot

$Notebooks = @(
    "notebooks/etl_olist.ipynb",
    "notebooks/load_dw.ipynb",
    "notebooks/create_views_dw.ipynb"
)

$ContainerDbUri = "postgresql+psycopg2://admin:senha_segura_123@postgres-dw:5432/dw_academico"

Write-Host "Iniciando pipeline de notebooks..." -ForegroundColor Cyan

function Test-Command {
    param(
        [string]$Exe,
        [string[]]$Args
    )

    if (-not (Get-Command $Exe -ErrorAction SilentlyContinue)) {
        return $false
    }

    try {
        & $Exe @Args --version *> $null
        return $LASTEXITCODE -eq 0
    } catch {
        return $false
    }
}

function Wait-Postgres {
    param(
        [string]$HostName = "localhost",
        [int]$Port = 5433,
        [int]$TimeoutSeconds = 60
    )

    $Deadline = (Get-Date).AddSeconds($TimeoutSeconds)

    while ((Get-Date) -lt $Deadline) {
        $Connection = Test-NetConnection -ComputerName $HostName -Port $Port -WarningAction SilentlyContinue

        if ($Connection.TcpTestSucceeded) {
            return
        }

        Start-Sleep -Seconds 2
    }

    Write-Error "PostgreSQL nao respondeu em ${HostName}:${Port}. Verifique se o Docker esta rodando e se a porta 5433 esta livre."
}

function Test-DockerReady {
    docker info *> $null
    return $LASTEXITCODE -eq 0
}

function Start-DockerDesktop {
    $DockerDesktopPaths = @(
        "$Env:ProgramFiles\Docker\Docker\Docker Desktop.exe",
        "$Env:LocalAppData\Docker\Docker Desktop.exe"
    )

    foreach ($DockerDesktopPath in $DockerDesktopPaths) {
        if (Test-Path $DockerDesktopPath) {
            Write-Host "Docker Desktop nao esta aberto. Iniciando Docker Desktop..." -ForegroundColor Cyan
            Start-Process -FilePath $DockerDesktopPath -WindowStyle Hidden
            return
        }
    }

    Write-Error "Docker Desktop nao esta aberto e o executavel nao foi encontrado. Abra o Docker Desktop manualmente e rode o script novamente."
}

function Wait-Docker {
    param(
        [int]$TimeoutSeconds = 120
    )

    $Deadline = (Get-Date).AddSeconds($TimeoutSeconds)

    while ((Get-Date) -lt $Deadline) {
        if (Test-DockerReady) {
            return
        }

        Start-Sleep -Seconds 3
    }

    Write-Error "Docker Desktop foi iniciado, mas o Docker nao ficou pronto dentro de ${TimeoutSeconds}s."
}

if (Test-Path "docker-compose.yml") {
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        Write-Error "Docker nao foi encontrado. Instale o Docker Desktop ou suba o PostgreSQL manualmente na porta 5433."
    }

    if (-not (Test-DockerReady)) {
        Start-DockerDesktop
        Write-Host "Aguardando Docker Desktop ficar pronto..." -ForegroundColor Cyan
        Wait-Docker
    }

    Write-Host "Subindo PostgreSQL via Docker Compose..." -ForegroundColor Cyan
    docker compose up -d postgres-dw

    if ($LASTEXITCODE -ne 0) {
        Write-Error "Falha ao subir o PostgreSQL com Docker Compose."
    }

    Write-Host "Aguardando PostgreSQL em localhost:5433..." -ForegroundColor Cyan
    Wait-Postgres
}

foreach ($Notebook in $Notebooks) {
    if (-not (Test-Path $Notebook)) {
        Write-Error "Notebook nao encontrado: $Notebook"
    }
}

$NotebookList = $Notebooks -join " "
$ContainerCommand = "cd /home/jovyan/work && for notebook in $NotebookList; do echo; echo Executando `$notebook; jupyter nbconvert --to notebook --execute `"`$notebook`" --inplace || exit 1; done"

Write-Host ""
Write-Host "Executando notebooks no container jupyter-etl..." -ForegroundColor Yellow

docker compose run --rm -T `
    -e "DB_URI=$ContainerDbUri" `
    jupyter-etl `
    bash -lc $ContainerCommand

if ($LASTEXITCODE -ne 0) {
    Write-Error "Falha ao executar os notebooks no container jupyter-etl."
}

Write-Host ""
Write-Host "Pipeline concluido com sucesso." -ForegroundColor Green
