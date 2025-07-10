#!/bin/bash

# ClickHouse Daily Reporter cron 설정 스크립트
# 매일 오전 10:00에 실행되도록 설정 (venv 환경 포함)

echo "⏰ cron 설정 시작"

# 현재 사용자와 경로 정보
USER=$(whoami)
SCRIPT_DIR="$HOME/clickhouse_reporter"
PYTHON_PATH=$(which python3)

# 가상환경 확인 및 생성
VENV_DIR="$SCRIPT_DIR/venv"
if [ ! -d "$VENV_DIR" ]; then
    echo "📦 가상환경 생성 중..."
    cd "$SCRIPT_DIR"
    python3 -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt
    echo "✅ 가상환경 생성 완료"
else
    echo "✅ 가상환경이 이미 존재합니다: $VENV_DIR"
fi

# 가상환경의 Python 경로
VENV_PYTHON="$VENV_DIR/bin/python"

# cron 작업 내용 (가상환경 Python 사용)
CRON_JOB="00 10 * * * cd $SCRIPT_DIR && $VENV_PYTHON main.py >> logs/cron_\$(date +\\%Y\\%m\\%d).log 2>&1"

echo "👤 사용자: $USER"
echo "📁 스크립트 경로: $SCRIPT_DIR"
echo "🐍 시스템 Python: $PYTHON_PATH"
echo "🔗 가상환경 Python: $VENV_PYTHON"
echo "⚙️ cron 작업: $CRON_JOB"
echo ""

# Python 패키지 설치 확인
echo "🔍 필수 패키지 설치 확인..."
source "$VENV_DIR/bin/activate"
pip list | grep -E "(clickhouse-connect|pandas|PyYAML|openpyxl)"
if [ $? -ne 0 ]; then
    echo "📦 누락된 패키지 설치 중..."
    pip install -r requirements.txt
fi
deactivate

# 기존 cron 작업 확인
echo "🔍 기존 cron 작업 확인 중..."
if crontab -l 2>/dev/null | grep -q "clickhouse_reporter"; then
    echo "⚠️  기존 ClickHouse Reporter cron 작업이 발견되었습니다."
    echo "기존 작업을 제거하고 새로 설정하시겠습니까? (y/n)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        # 기존 작업 제거
        crontab -l 2>/dev/null | grep -v "clickhouse_reporter" | crontab -
        echo "✅ 기존 작업 제거 완료"
    else
        echo "❌ 설정을 취소했습니다."
        exit 1
    fi
fi

# 새 cron 작업 추가
echo "📝 새 cron 작업 추가 중..."
(crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -

# 설정 확인
echo "✅ cron 설정 완료!"
echo ""
echo "📋 현재 cron 작업 목록:"
crontab -l 2>/dev/null | grep -E "(clickhouse_reporter|^#|^$)"
echo ""
echo "🕘 실행 일정: 매일 오전 10시 00분"
echo "📝 실행 로그: ~/clickhouse_reporter/logs/cron_YYYYMMDD.log"
echo "🐍 가상환경 사용: $VENV_PYTHON"
echo ""
echo "🧪 수동 테스트 방법:"
echo "  cd ~/clickhouse_reporter"
echo "  source venv/bin/activate"
echo "  python main.py"
echo "  deactivate"
echo ""
echo "📊 cron 상태 확인:"
echo "  sudo service cron status"
echo "  sudo service cron start  # cron 서비스 시작"
echo ""
echo "🔍 cron 로그 확인:"
echo "  grep CRON /var/log/syslog | tail -10"
echo ""
echo "🧪 cron 환경 테스트:"
echo "  cd ~/clickhouse_reporter && $VENV_PYTHON main.py"
