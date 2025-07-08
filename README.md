# ClickHouse Daily Reporter

매일 오전 9:30에 ClickHouse 쿼리를 실행하여 결과를 Excel 파일로 저장하는 자동화 도구입니다.

## 🚀 빠른 시작

### 1. 설치

```bash
# 프로젝트 디렉토리 생성 및 이동
mkdir ~/clickhouse_reporter
cd ~/clickhouse_reporter

# 파일들을 이 디렉토리에 복사한 후
bash setup.sh
```

### 2. 설정

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

### 3. 쿼리 설정

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

### 4. 테스트 실행

```bash
python3 main.py
```

### 5. 자동화 설정

```bash
bash setup_cron.sh
```

## 📁 파일 구조

```
clickhouse_reporter/
├── main.py              # 메인 실행 스크립트
├── config.yaml          # 설정 파일
├── requirements.txt     # Python 패키지 목록
├── setup.sh            # 설치 스크립트
├── setup_cron.sh       # cron 설정 스크립트
├── logs/               # 실행 로그
│   ├── reporter_20241207.log
│   └── cron_20241207.log
└── output/             # Excel 파일 저장
    └── daily_report_20241207.xlsx
```

## ⚙️ 주요 기능

- **다중 쿼리 지원**: 여러 쿼리를 한 번에 실행
- **Excel 형식 출력**: 각 쿼리 결과를 별도 시트로 저장
- **날짜별 파일명**: `daily_report_YYYYMMDD.xlsx` 형식
- **자동 스타일링**: 헤더 스타일 및 열 너비 자동 조정
- **완전한 로깅**: 실행 이력 및 에러 로그 관리
- **cron 자동화**: 매일 오전 9:30 자동 실행

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

## 🚨 주의사항

- WSL2 환경에서만 테스트되었습니다
- ClickHouse 24.1.2.5 버전에서 테스트되었습니다
- 파일 경로에 한글이 포함될 경우 인코딩 문제가 발생할 수 있습니다
- 대용량 결과 세트는 메모리 사용량을 고려하여 LIMIT을 설정하세요

