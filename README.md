# ClickHouse Daily Reporter

ClickHouse 쿼리를 자동 실행하여 Excel 리포트를 생성하는 Python 도구입니다. Kubernetes 환경에서 kubectl port-forwarding을 지원하며, cron을 통한 자동화 스케줄링이 가능합니다.

## ✨ 주요 특징

- **다중 쿼리 지원**: 여러 쿼리를 한 번에 실행하여 각각 별도 Excel 시트로 저장
- **Kubernetes 지원**: kubectl port-forwarding을 통한 안전한 Pod 접근
- **자동 스케줄링**: cron을 통한 일일/주기적 실행
- **Excel 자동 포맷팅**: 헤더 스타일링 및 열 너비 자동 조정
- **완전한 로깅**: 실행 이력 및 에러 로그 추적
- **타입 안전성**: Pylance 호환 및 방어적 프로그래밍
- **uv 패키지 관리**: 빠르고 안정적인 의존성 관리

## 🚀 빠른 시작

### 1. uv 설치 (Python 패키지 관리자)

```bash
# uv 설치
curl -LsSf https://astral.sh/uv/install.sh | sh

# 설치 확인
uv --version
```

### 2. 프로젝트 다운로드

```bash
# GitHub에서 클론
git clone https://github.com/jhk2025-kim/clickhouse_reporter.git
cd clickhouse_reporter

# 또는 Samsung GitHub Enterprise에서
git clone git@github.ecodesamsung.com:jhk2025-kim/clickhouse_reporter.git
cd clickhouse_reporter
```

### 3. 환경 설정

```bash
# 의존성 설치 및 환경 설정
bash setup.sh
```

### 4. 설정 파일 작성

`config.yaml` 파일을 생성하고 연결 정보를 입력하세요:

```yaml
# ClickHouse 연결 설정
clickhouse:
  connection_type: 'kubectl'  # 'direct' 또는 'kubectl'
  username: 'your_username'
  password: 'your_password'
  database: 'default'
  
  # kubectl을 사용한 Pod 접근 설정
  kubectl:
    enabled: true
    pod_name: 'chi-signoz-clickhouse-cluster-0-0-0'
    namespace: 'clickhouse'
    internal_port: 8123
    port_forward_local_port: 8123
    context: 'your-k8s-context'  # 선택사항

# 출력 설정
output:
  directory: './output'
  filename_prefix: 'daily_report'

# 실행할 쿼리들
queries:
  system_metrics:
    name: '시스템 메트릭'
    query: |
      SELECT 
        metric,
        value,
        description
      FROM system.metrics 
      ORDER BY metric
      LIMIT 50
      
  table_sizes:
    name: '테이블 크기'
    query: |
      SELECT 
        database,
        table,
        formatReadableSize(total_bytes) as size
      FROM system.tables 
      WHERE total_bytes > 0
      ORDER BY total_bytes DESC
      LIMIT 20
```

### 5. 테스트 실행

```bash
# 수동 실행으로 테스트
uv run python main.py

# 로그 확인
cat logs/reporter_$(date +%Y%m%d).log
```

### 6. 자동화 설정

```bash
# cron 작업 설정 (매일 오전 9:30 실행)
bash setup_cron.sh
```

## 📁 프로젝트 구조

```
clickhouse_reporter/
├── main.py              # 메인 애플리케이션 (ClickHouseReporter 클래스)
├── config.yaml          # 런타임 설정 파일 (git-ignored)
├── config.example.yaml  # 설정 파일 템플릿
├── pyproject.toml       # uv 패키지 관리 파일
├── requirements.txt     # 호환성을 위한 pip requirements
├── setup.sh            # 설치 및 설정 스크립트
├── setup_cron.sh       # cron 설정 스크립트
├── git_setup.sh        # Git 초기화 및 GitHub 설정
├── logs/               # 애플리케이션 로그 (git-ignored)
│   ├── reporter_YYYYMMDD.log
│   └── cron_YYYYMMDD.log
├── output/             # 생성된 Excel 파일 (git-ignored)
│   └── daily_report_YYYYMMDD.xlsx
└── .venv/             # uv 가상환경 (git-ignored)
```

## ⚙️ 설정 가이드

### 연결 타입

#### 1. 직접 연결 (Direct Connection)
```yaml
clickhouse:
  connection_type: 'direct'
  host: 'localhost'
  port: 8123
  username: 'default'
  password: 'your_password'
  database: 'default'
```

#### 2. kubectl 포트 포워딩 (Kubernetes)
```yaml
clickhouse:
  connection_type: 'kubectl'
  username: 'default'
  password: 'your_password'
  database: 'default'
  
  kubectl:
    enabled: true
    pod_name: 'chi-signoz-clickhouse-cluster-0-0-0'
    namespace: 'clickhouse'
    internal_port: 8123
    port_forward_local_port: 8123
    context: 'production-cluster'  # 선택사항
```

### 쿼리 정의

각 쿼리는 고유한 키와 함께 다음 속성을 가집니다:

```yaml
queries:
  backup_status:
    name: '백업 상태'
    query: |
      SELECT 
        command,
        status,
        start_time,
        end_time,
        files_new,
        bytes_new
      FROM system.backup_actions 
      WHERE start_time >= today() - 7
      ORDER BY start_time DESC
      
  cluster_info:
    name: '클러스터 정보'
    query: |
      SELECT 
        host_name,
        host_address,
        port,
        is_local,
        user,
        default_database
      FROM system.clusters 
      WHERE cluster = 'default'
```

## 🚀 운영 가이드

### 실행 및 스케줄링

```bash
# 수동 실행
uv run python main.py

# cron 작업 확인
crontab -l

# cron 로그 확인
cat logs/cron_$(date +%Y%m%d).log

# 애플리케이션 로그 확인  
cat logs/reporter_$(date +%Y%m%d).log
```

### 로그 모니터링

생성되는 로그 파일들:
- `logs/reporter_YYYYMMDD.log`: 애플리케이션 실행 로그
- `logs/cron_YYYYMMDD.log`: cron 작업 로그  
- `output/daily_report_YYYYMMDD.xlsx`: 생성된 Excel 리포트

### 유지보수 명령어

```bash
# 의존성 업데이트
uv sync

# 설정 파일 편집
vi config.yaml

# 출력 디렉토리 정리 (30일 이상 파일 삭제)
find output/ -name "*.xlsx" -mtime +30 -delete

# 로그 파일 정리 (30일 이상 파일 삭제)
find logs/ -name "*.log" -mtime +30 -delete
```

## 🔍 문제 해결

### 1. 연결 실패

**kubectl 포트 포워딩 실패**:
```bash
# 현재 context 확인
kubectl config current-context

# Pod 상태 확인
kubectl get pods -n clickhouse

# 수동 포트 포워딩 테스트
kubectl port-forward -n clickhouse chi-signoz-clickhouse-cluster-0-0-0 8123:8123
```

**직접 연결 실패**:
- 호스트/포트 정보 확인
- 방화벽 설정 확인
- ClickHouse 서비스 상태 확인

### 2. cron 작업 문제

```bash
# cron 서비스 상태
sudo systemctl status cron

# cron 작업 다시 설정
bash setup_cron.sh

# 시스템 cron 로그 확인
sudo journalctl -u cron -f
```

### 3. 권한 문제

```bash
# 스크립트 실행 권한
chmod +x main.py setup.sh setup_cron.sh

# 디렉토리 권한 확인
ls -la logs/ output/
```

## 💡 고급 사용법

### 1. 환경별 설정 분리

```bash
# 개발환경 설정
cp config.yaml config.dev.yaml

# 운영환경에서 다른 설정 사용
CONFIG_FILE=config.prod.yaml uv run python main.py
```

### 2. 커스텀 쿼리 템플릿

유용한 ClickHouse 시스템 쿼리 예제:

```yaml
queries:
  # 백업 모니터링
  backup_monitoring:
    name: '백업 현황'
    query: |
      SELECT 
        command,
        status,
        formatDateTime(start_time, '%Y-%m-%d %H:%M:%S') as start_time,
        formatDateTime(end_time, '%Y-%m-%d %H:%M:%S') as end_time,
        formatReadableSize(bytes_new) as backup_size,
        files_new
      FROM system.backup_actions 
      WHERE start_time >= today() - 30
      ORDER BY start_time DESC
      
  # 클러스터 상태
  cluster_health:
    name: '클러스터 상태'  
    query: |
      SELECT 
        host_name,
        host_address,
        port,
        is_local,
        errors_count,
        estimated_recovery_time
      FROM system.clusters 
      WHERE cluster = 'default'
      
  # 디스크 사용량
  disk_usage:
    name: '디스크 사용량'
    query: |
      SELECT 
        name,
        path,
        formatReadableSize(total_space) as total_space,
        formatReadableSize(free_space) as free_space,
        round((total_space - free_space) * 100 / total_space, 2) as usage_percent
      FROM system.disks
```

### 3. Kubernetes 환경 최적화

```yaml
# 다중 Pod 환경에서의 설정
clickhouse:
  connection_type: 'kubectl'
  kubectl:
    # 로드밸런싱을 위한 다중 Pod 설정
    pod_name: 'chi-signoz-clickhouse-cluster-0-0-0'  # Primary
    fallback_pods:
      - 'chi-signoz-clickhouse-cluster-0-1-0'       # Replica
      - 'chi-signoz-clickhouse-cluster-1-0-0'       # Another shard
```

## 🛡️ 보안 고려사항

- `config.yaml` 파일은 `.gitignore`에 포함되어 credential 노출 방지
- 로그에는 쿼리 텍스트가 포함되지만 credential은 마스킹됨
- kubectl 포트 포워딩은 로컬 포트만 사용하여 외부 노출 없음
- 정기적인 로그 파일 정리로 디스크 사용량 관리

## 📈 성능 최적화

- 대용량 쿼리 시 `LIMIT` 절 사용 권장
- 복잡한 조인이나 집계 쿼리는 별도 스케줄로 분리
- Excel 파일 크기 제한 고려 (100만 행 이상 시 CSV 고려)
- 메모리 사용량 모니터링 (`htop`, `free -m`)

## 🔄 버전 관리

현재 버전: 1.0.0
- Python 3.8+ 지원
- ClickHouse 24.1.2.5 테스트 완료
- WSL2 Ubuntu 환경 검증

