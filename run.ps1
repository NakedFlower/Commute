# Slack 출퇴근 관리 시스템 실행 스크립트 (PowerShell)

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Slack 출퇴근 관리 시스템 시작" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# 1. .env 파일 확인
if (Test-Path ".env") {
    Write-Host "✅ .env 파일 발견. 환경변수 로드 중..." -ForegroundColor Green
    
    # .env 파일에서 환경변수 로드
    Get-Content .env | ForEach-Object {
        if ($_ -match '^([^=]+)=(.*)$') {
            $name = $matches[1]
            $value = $matches[2]
            [Environment]::SetEnvironmentVariable($name, $value, "Process")
            Write-Host "  - $name 설정 완료" -ForegroundColor Gray
        }
    }
    Write-Host ""
} else {
    Write-Host "⚠️  .env 파일이 없습니다." -ForegroundColor Yellow
    Write-Host "   .env.example을 복사하여 .env 파일을 생성하세요:" -ForegroundColor Yellow
    Write-Host "   Copy-Item .env.example .env" -ForegroundColor White
    Write-Host ""
}

# 2. 가상환경 활성화 확인
if ($env:VIRTUAL_ENV) {
    Write-Host "✅ 가상환경 활성화됨: $env:VIRTUAL_ENV" -ForegroundColor Green
} else {
    Write-Host "ℹ️  가상환경이 활성화되지 않았습니다." -ForegroundColor Yellow
    Write-Host "   권장: .\venv\Scripts\Activate.ps1" -ForegroundColor White
}
Write-Host ""

# 3. 의존성 확인
Write-Host "📦 의존성 확인 중..." -ForegroundColor Cyan
$installed = pip list --format=freeze
$required = Get-Content requirements.txt

$missing = @()
foreach ($req in $required) {
    if ($req -match '^([^=]+)') {
        $package = $matches[1]
        if (-not ($installed -match "^$package")) {
            $missing += $package
        }
    }
}

if ($missing.Count -gt 0) {
    Write-Host "⚠️  누락된 패키지 발견:" -ForegroundColor Yellow
    foreach ($pkg in $missing) {
        Write-Host "   - $pkg" -ForegroundColor Red
    }
    Write-Host ""
    Write-Host "설치 명령: pip install -r requirements.txt" -ForegroundColor White
    Write-Host ""
    
    $response = Read-Host "지금 설치하시겠습니까? (y/N)"
    if ($response -eq "y" -or $response -eq "Y") {
        pip install -r requirements.txt
        Write-Host ""
    } else {
        Write-Host "❌ 의존성 설치가 필요합니다. 종료합니다." -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "✅ 모든 의존성이 설치되어 있습니다." -ForegroundColor Green
}
Write-Host ""

# 4. Python 서버 실행
Write-Host "🚀 서버 시작 중..." -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

python app.py
