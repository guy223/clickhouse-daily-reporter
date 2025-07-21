# ClickHouse Daily Reporter

매일 오전 9:30에 ClickHouse 쿼리를 실행하여 결과를 Excel 파일로 저장하는 자동화 도구입니다.

## 🚀 빠른 시작

### 0. uv 설치 (Python 패키지 관리자)

```bash
# uv 설치
curl -LsSf https://astral.sh/uv/install.sh | sh

# 설치 확인
uv --version
```

### 1. 프로젝트 다운로드

#### GitHub.com에서 다운로드
```bash
git clone https://github.com/jhk2025-kim/clickhouse_reporter.git
cd clickhouse_reporter
```

#### Samsung GitHub Enterprise에서 다운로드
```bash
git clone git@github.ecodesamsung.com:jhk2025-kim/clickhouse_reporter.git
cd clickhouse_reporter
```

### 2. 설치

```bash
# 의존성 설치 및 환경 설정
bash setup.sh
```

### 3. 설정

`config.yaml` 파일을 수정하여 ClickHouse 연결 정보를 입력하세요:

```yaml
clickhouse:
  connection_type: 'kubectl'
  username: 'jhkim'
  password: 'your_password'  # 실제 비밀번호로 변경
  database: 'default'
  
  kubectl:
    enabled: true
    pod_name: 'chi-signoz-clickhouse-cluster-0-0-0'
    namespace: 'clickhouse'
    internal_port: 8123
    port_forward_local_port: 8123
```

### 4. 쿼리 설정

`config.yaml`에서 실행할 쿼리를 설정하세요:

```yaml
queries:
  daily_metrics:
    name: '일일 메트릭'
    query: |
      SELECT 
        toDate(event_time) as date,
        metric,
        value
      FROM system.metrics 
      WHERE event_time >= today() - 1
      ORDER BY event_time DESC
      LIMIT 100
```

### 5. 테스트 실행

```bash
uv run python main.py
```

### 6. 자동화 설정

```bash
bash setup_cron.sh
```

## 📁 파일 구조

```
clickhouse_reporter/
├── main.py              # 메인 실행 스크립트
├── config.yaml          # 설정 파일 (git-ignored)
├── config.example.yaml  # 설정 파일 템플릿
├── pyproject.toml       # uv 패키지 관리 파일
├── requirements.txt     # Python 패키지 목록 (호환성용)
├── setup.sh            # 설치 스크립트
├── setup_cron.sh       # cron 설정 스크립트
├── logs/               # 실행 로그 (git-ignored)
│   ├── reporter_20250721.log
│   └── cron_20250721.log
├── output/             # Excel 파일 저장 (git-ignored)
│   └── daily_report_20250721.xlsx
└── .venv/             # uv 가상환경 (git-ignored)
```

## ⚙️ 주요 기능

- **다중 쿼리 지원**: 여러 쿼리를 한 번에 실행
- **Excel 형식 출력**: 각 쿼리 결과를 별도 시트로 저장
- **날짜별 파일명**: `daily_report_YYYYMMDD.xlsx` 형식
- **자동 스타일링**: 헤더 스타일 및 열 너비 자동 조정
- **완전한 로깅**: 실행 이력 및 에러 로그 관리
- **cron 자동화**: 매일 오전 9:30 자동 실행
- **Kubernetes 지원**: kubectl port-forwarding을 통한 안전한 접근
- **타입 안전성**: Pylance 호환 및 방어적 프로그래밍
- **uv 패키지 관리**: 빠르고 안정적인 Python 의존성 관리

## 🔧 설정 상세

### ClickHouse 연결 설정

```yaml
clickhouse:
  host: 'localhost'        # ClickHouse 호스트
  port: 8123              # HTTP 포트
  username: 'default'     # 사용자명
  password: ''            # 비밀번호
  database: 'default'     # 데이터베이스
```

### 출력 설정

```yaml
output:
  directory: './output'           # 출력 디렉토리
  filename_prefix: 'daily_report' # 파일명 접두사
```

### 쿼리 설정

```yaml
queries:
  query_key:                    # 쿼리 식별자
    name: '시트 이름'           # Excel 시트명
    query: |                    # 실행할 쿼리
      SELECT * FROM table
      WHERE condition
```

## 🕘 실행 일정

- **실행 시간**: 매일 오전 9:30
- **로그 파일**: `logs/cron_YYYYMMDD.log`
- **출력 파일**: `output/daily_report_YYYYMMDD.xlsx`

## 📊 로그 확인

```bash
# 오늘 실행 로그 확인
cat logs/reporter_$(date +%Y%m%d).log

# cron 실행 로그 확인
cat logs/cron_$(date +%Y%m%d).log

# 수동 실행 (디버깅용)
uv run python main.py

# 의존성 설치/업데이트
uv sync

# 시스템 cron 로그 확인
grep CRON /var/log/syslog | tail -10
```

## 🔍 문제 해결

### cron이 실행되지 않는 경우

```bash
# cron 서비스 상태 확인
sudo service cron status

# cron 서비스 시작
sudo service cron start

# cron 작업 확인
crontab -l
```

### 연결 오류 발생 시

1. `config.yaml`의 연결 정보 확인
2. ClickHouse 서버 상태 확인
3. 네트워크 연결 확인
4. 로그 파일에서 상세 오류 확인

### 권한 오류 발생 시

```bash
# 실행 권한 부여
chmod +x main.py

# 디렉토리 권한 확인
ls -la ~/clickhouse_reporter/
```

## 📝 사용 팁

1. **쿼리 테스트**: 새 쿼리 추가 시 먼저 수동 실행으로 테스트
2. **로그 모니터링**: 정기적으로 로그 파일 확인
3. **백업**: 중요한 쿼리는 별도 백업 보관
4. **성능 고려**: 대용량 데이터 쿼리 시 LIMIT 사용 권장

## 🔧 개발 환경

### 패키지 관리
- **uv**: 빠른 Python 패키지 관리자 사용
- **가상환경**: `.venv/` 디렉토리에 자동 생성
- **의존성**: `pyproject.toml`에서 관리

### 코드 품질
- **타입 안전성**: Pylance 경고 모두 해결
- **방어적 프로그래밍**: null/undefined 체크 포함
- **에러 처리**: 모든 중요 경로에서 예외 처리

## 🚨 주의사항

- WSL2 환경에서만 테스트되었습니다
- ClickHouse 24.1.2.5 버전에서 테스트되었습니다
- 파일 경로에 한글이 포함될 경우 인코딩 문제가 발생할 수 있습니다
- 대용량 결과 세트는 메모리 사용량을 고려하여 LIMIT을 설정하세요
- kubectl 연결 시 Kubernetes context가 올바르게 설정되어 있어야 합니다

