#!/bin/bash

# ClickHouse Daily Reporter cron 설정 스크립트
# 매일 오전 9:30에 실행되도록 설정

echo "⏰ cron 설정 시작"

# 현재 사용자와 경로 정보
USER=$(whoami)
SCRIPT_DIR="$HOME/clickhouse_reporter"
PYTHON_PATH=$(which python3)

# cron 작업 내용
CRON_JOB="30 9 * * * cd $SCRIPT_DIR && $PYTHON_PATH main.py >> logs/cron_$(date +\%Y\%m\%d).log 2>&1"

echo "👤 사용자: $USER"
echo "📁 스크립트 경로: $SCRIPT_DIR"
echo "🐍 Python 경로: $PYTHON_PATH"
echo "⚙️ cron 작업: $CRON_JOB"
echo ""

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
echo "🕘 실행 일정: 매일 오전 9시 30분"
echo "📝 실행 로그: ~/clickhouse_reporter/logs/cron_YYYYMMDD.log"
echo ""
echo "🧪 테스트 실행 방법:"
echo "  cd ~/clickhouse_reporter"
echo "  python3 main.py"
echo ""
echo "📊 cron 상태 확인:"
echo "  sudo service cron status"
echo "  sudo service cron start  # cron 서비스 시작"
echo ""
echo "🔍 cron 로그 확인:"
echo "  grep CRON /var/log/syslog | tail -10"

