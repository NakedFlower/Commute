# 🏢 Slack 출퇴근 관리 시스템

Slack 슬래시 커맨드를 사용하여 출퇴근 시간을 자동으로 Excel 파일에 기록하는 시스템입니다.

## 📋 주요 기능

- **슬래시 커맨드**: `/출근`, `/외근`, `/퇴근`
- **자동 기록**: Excel 파일(attendance.xlsx)에 시간 자동 저장
- **한국 시간**: KST(Asia/Seoul) 시간대 기준
- **중복 방지**: 같은 날짜 + 같은 사용자는 행 업데이트 (새 행 생성 안 함)
- **동시성 제어**: 파일 Lock으로 동시 요청 안전 처리
- **보안**: Slack Signing Secret 검증

## 🚀 빠른 시작

### 1️⃣ 사전 요구사항

- Python 3.8 이상
- Slack 워크스페이스 관리자 권한

### 2️⃣ 설치

```powershell
# 가상환경 생성 (선택사항이지만 권장)
python -m venv venv
.\venv\Scripts\Activate.ps1

# 의존성 설치
pip install -r requirements.txt
```

### 3️⃣ 환경변수 설정

`.env.example`을 복사하여 `.env` 파일 생성:

```powershell
Copy-Item .env.example .env
```

`.env` 파일을 열어 실제 값으로 수정:

```env
SLACK_SIGNING_SECRET=your_actual_signing_secret
SLACK_BOT_TOKEN=xoxb-your-actual-bot-token
```

### 4️⃣ 로컬 실행

```powershell
python app.py
```

서버가 `http://localhost:8000`에서 실행됩니다.

### 5️⃣ 외부 접근 가능하게 만들기 (ngrok 사용)

Slack이 로컬 서버에 접근하려면 ngrok 등을 사용:

```powershell
# ngrok 설치 후
ngrok http 8000
```

ngrok이 제공하는 HTTPS URL을 Slack App 설정에 사용합니다.

---

## 🔧 Slack App 설정 가이드

### Step 1: Slack App 생성

1. https://api.slack.com/apps 접속
2. **"Create New App"** 클릭
3. **"From scratch"** 선택
4. App 이름 입력 (예: "출퇴근 관리")
5. 워크스페이스 선택
6. **"Create App"** 클릭

### Step 2: Bot Token Scopes 설정

1. 좌측 메뉴에서 **"OAuth & Permissions"** 클릭
2. **"Scopes"** > **"Bot Token Scopes"** 섹션으로 이동
3. 다음 권한 추가:
   - `commands` (슬래시 커맨드 사용)
   - `users:read` (사용자 정보 조회)

### Step 3: 슬래시 커맨드 생성

1. 좌측 메뉴에서 **"Slash Commands"** 클릭
2. **"Create New Command"** 클릭
3. 각 커맨드 생성:

#### `/출근` 커맨드
- **Command**: `/출근`
- **Request URL**: `https://your-ngrok-url.ngrok.io/slack/commands`
- **Short Description**: `출근 시간 기록`
- **Usage Hint**: (비워둠)
- **"Save"** 클릭

#### `/외근` 커맨드
- **Command**: `/외근`
- **Request URL**: `https://your-ngrok-url.ngrok.io/slack/commands`
- **Short Description**: `외근 시간 기록`
- **"Save"** 클릭

#### `/퇴근` 커맨드
- **Command**: `/퇴근`
- **Request URL**: `https://your-ngrok-url.ngrok.io/slack/commands`
- **Short Description**: `퇴근 시간 기록`
- **"Save"** 클릭

### Step 4: App 설치

1. 좌측 메뉴에서 **"Install App"** 클릭
2. **"Install to Workspace"** 클릭
3. 권한 승인
4. **"Bot User OAuth Token"** 복사 (xoxb-로 시작)
   - 이 토큰을 `.env` 파일의 `SLACK_BOT_TOKEN`에 입력

### Step 5: Signing Secret 확인

1. 좌측 메뉴에서 **"Basic Information"** 클릭
2. **"App Credentials"** 섹션에서 **"Signing Secret"** 찾기
3. **"Show"** 클릭 후 복사
4. 이 값을 `.env` 파일의 `SLACK_SIGNING_SECRET`에 입력

### Step 6: 환경변수 로드 후 서버 재시작

PowerShell에서 환경변수 로드:

```powershell
# .env 파일 수동 로드
Get-Content .env | ForEach-Object {
    if ($_ -match '^([^=]+)=(.*)$') {
        [Environment]::SetEnvironmentVariable($matches[1], $matches[2], "Process")
    }
}

# 서버 실행
python app.py
```

또는 `python-dotenv` 사용 (권장):

```powershell
pip install python-dotenv
```

`app.py` 최상단에 추가:
```python
from dotenv import load_dotenv
load_dotenv()
```

---

## 📊 Excel 파일 구조

생성되는 `attendance.xlsx` 파일 구조:

| 날짜       | Slack User ID | 이름   | 출근 시간 | 외근 시간 | 퇴근 시간 |
|------------|---------------|--------|-----------|-----------|-----------|
| 2026-01-30 | U12345        | 홍길동 | 09:00     | 14:30     | 18:00     |
| 2026-01-30 | U67890        | 김철수 | 09:15     |           | 18:10     |

- **날짜**: YYYY-MM-DD 형식
- **시간**: HH:MM 형식 (24시간제)
- 같은 날짜 + 같은 사용자는 자동으로 업데이트됨

---

## 🧪 테스트 방법

### 1. 로컬 서버 헬스체크

```powershell
curl http://localhost:8000
```

응답:
```json
{"status": "ok", "message": "Slack 출퇴근 관리 시스템이 정상 작동 중입니다."}
```

### 2. Slack에서 테스트

워크스페이스의 아무 채널에서:

```
/출근
```

응답:
```
🏢 출근 시간이 09:12로 기록되었습니다.
```

Excel 파일(`attendance.xlsx`)을 열어 기록 확인.

### 3. 수동 API 테스트 (curl)

```powershell
curl -X POST http://localhost:8000/slack/commands `
  -H "Content-Type: application/x-www-form-urlencoded" `
  -d "command=/출근&user_id=U12345&user_name=testuser&text="
```

**주의**: Slack Signing Secret 검증이 실패할 수 있으므로 실제 테스트는 Slack에서 하는 것을 권장합니다.

---

## 🔒 보안

### Signing Secret 검증

모든 요청은 Slack Signing Secret으로 검증되어 위조 요청을 차단합니다.

- 타임스탬프 5분 이상 차이 나는 요청 거부 (재생 공격 방지)
- HMAC-SHA256 서명 검증

### 개발 환경

환경변수가 설정되지 않은 경우 검증을 스킵하고 경고 메시지를 출력합니다.

**운영 환경에서는 반드시 환경변수를 설정하세요!**

---

## 🚢 배포 (운영 환경)

### 클라우드 배포 옵션

1. **AWS EC2 + Nginx + Gunicorn**
2. **Heroku** (가장 간단)
3. **Google Cloud Run**
4. **Azure App Service**

### Heroku 배포 예시

```powershell
# Heroku CLI 설치 후
heroku create your-app-name
heroku config:set SLACK_SIGNING_SECRET=your_secret
heroku config:set SLACK_BOT_TOKEN=xoxb-your-token
git push heroku main
```

`Procfile` 생성:
```
web: uvicorn app:app --host 0.0.0.0 --port $PORT
```

배포 후 Slack App 설정에서 Request URL을 업데이트:
```
https://your-app-name.herokuapp.com/slack/commands
```

---

## 🛠️ 트러블슈팅

### 1. "Invalid signature" 오류

**원인**: Slack Signing Secret이 잘못되었거나 타임스탬프 차이가 큽니다.

**해결**:
- `.env` 파일의 `SLACK_SIGNING_SECRET` 확인
- 서버 시간이 정확한지 확인

### 2. "사용자 정보 조회 실패"

**원인**: `SLACK_BOT_TOKEN`이 없거나 잘못되었습니다.

**해결**:
- `.env` 파일의 `SLACK_BOT_TOKEN` 확인
- Slack App에서 `users:read` 권한이 있는지 확인
- 토큰이 xoxb-로 시작하는지 확인

### 3. "Excel 파일 열 수 없음" 오류

**원인**: 파일이 다른 프로그램에서 열려있습니다.

**해결**:
- Excel에서 파일을 닫고 다시 시도

### 4. ngrok 연결 오류

**원인**: ngrok이 실행 중이 아니거나 URL이 만료되었습니다.

**해결**:
- ngrok 재시작: `ngrok http 8000`
- Slack App 설정에서 Request URL 업데이트

---

## 📁 프로젝트 구조

```
commute/
├── app.py                 # 메인 애플리케이션
├── requirements.txt       # Python 의존성
├── .env.example          # 환경변수 템플릿
├── .env                  # 실제 환경변수 (gitignore)
├── attendance.xlsx       # 생성되는 Excel 파일 (자동)
└── README.md             # 이 문서
```

---

## 📝 라이선스

이 프로젝트는 실무용으로 자유롭게 사용 가능합니다.

## 💡 추가 개선 아이디어

- [ ] 월별 통계 리포트 생성
- [ ] 주간 근무 시간 자동 계산
- [ ] 관리자 대시보드 추가
- [ ] Slack 멘션으로 개인 근태 현황 조회
- [ ] 데이터베이스 연동 (PostgreSQL, MySQL 등)
- [ ] 휴가/반차 기록 기능

---

## 🙋‍♂️ 문의

문제가 발생하면 이슈를 등록하거나 워크스페이스 관리자에게 문의하세요.
