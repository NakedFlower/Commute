# Slack 출퇴근 관리 시스템 - 파이썬 이용한 업무 자동화 스크립트

Slack 슬래시 커맨드를 사용하여 출퇴근 시간을 자동으로 Excel 파일에 기록하는 시스템입니다.

## 주요 기능

- **슬래시 커맨드**: `/출근`, `/외근`, `/퇴근`
- **자동 기록**: Excel 파일(attendance.xlsx)에 시간 자동 저장
- **한국 시간**: KST(Asia/Seoul) 시간대 기준
- **중복 방지**: 같은 날짜 + 같은 사용자는 행 업데이트 (새 행 생성 안 함)
- **동시성 제어**: 파일 Lock으로 동시 요청 안전 처리
- **보안**: Slack Signing Secret 검증

## 빠른 시작

### 사전 요구사항

- Python 3.8 이상
- Slack 워크스페이스 관리자 권한

### 2️⃣ 설치

```powershell
python -m venv venv
.\venv\Scripts\Activate.ps1

pip install -r requirements.txt
```

### 3️⃣ 환경변수 설정

`.env` 파일 생성:

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

ngrok이 제공하는 HTTPS URL을 Slack App 설정에 사용

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

### Step 6: 서버 시작

PowerShell에서 환경변수 로드:

```powershell
python app.py
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

## 🛠️ 트러블슈팅

### 1. ngrok 설치 이후 인증

**원인**: ngrok 계정은 만들었지만 내 PC에 인증 토큰을 아직 등록 안 함

**해결**:
- PowerShell에서 Authtoken 등록

### 2. "POST / HTTP/1.1" 405 Method Not

**원인**:
- Slack이 보낸 요청 경로: /
- 코드가 기대하는 경로: /slack/commands

**해결**:
- https://abcd-1234.ngrok.io/slack/commands 이렇게 수정

### 3. RuntimeError: Stream consumed

**원인**: FastAPI가 이미 request body를 한 번 읽어서 Form 파싱을 끝냈는데 같은 body를 또 읽으려고 해서 터진 거야

**해결**:
command: str = Form(...)
text: str = Form(...)
user_id: str = Form(...)
user_name: str = Form(...)

부분 삭제 

- (딱 한 번) body = await request.body()
