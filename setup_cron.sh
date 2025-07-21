#!/bin/bash

# ClickHouse Daily Reporter cron 설정 스크립트
# 매일 오전 10:00에 실행되도록 설정 (uv 환경 사용)

echo "⏰ cron 설정 시작"

# 현재 사용자와 경로 정보
USER=$(whoami)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UV_PATH=$(which uv)

# uv 설치 확인
if [ -z "$UV_PATH" ]; then
    echo "❌ uv가 설치되지 않았습니다. 먼저 uv를 설치해주세요:"
    echo "   curl -LsSf https://astral.sh/uv/install.sh | sh"
    exit 1
fi

# uv 프로젝트 초기화 및 의존성 설치
echo "📦 uv 의존성 확인 및 설치..."
cd "$SCRIPT_DIR"
uv sync

# cron 작업 내용 (uv run 사용)
CRON_JOB="00 10 * * * cd $SCRIPT_DIR && $UV_PATH run python main.py >> logs/cron_\\$(date +\\\\%Y\\\\%m\\\\%d).log 2>&1"

echo "👤 사용자: $USER"
echo "📁 스크립트 경로: $SCRIPT_DIR"
echo "🚀 uv 경로: $UV_PATH"
echo "⚙️ cron 작업: $CRON_JOB"
echo ""

# Python 패키지 설치 확인
echo "🔍 필수 패키지 설치 확인..."
uv run python -c "
import clickhouse_connect
import pandas as pd
import yaml
import openpyxl
print('✅ 모든 필수 모듈이 정상적으로 설치되었습니다!')
"

if [ $? -ne 0 ]; then
    echo "❌ 패키지 설치에 문제가 있습니다."
    exit 1
fi

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
(crontab -l 2>/dev/null; echo "# ClickHouse Daily Reporter (uv)"; echo "$CRON_JOB") | crontab -

# 설정 확인
echo "✅ cron 설정 완료!"
echo ""
echo "📋 현재 cron 작업 목록:"
crontab -l 2>/dev/null | grep -E "(clickhouse_reporter|uv run|^#|^$)"
echo ""
echo "🕘 실행 일정: 매일 오전 10시 00분"
echo "📝 실행 로그: $SCRIPT_DIR/logs/cron_YYYYMMDD.log"
echo "🚀 uv 사용: $UV_PATH run python main.py"
echo ""
echo "🧪 수동 테스트 방법:"
echo "  cd $SCRIPT_DIR"
echo "  uv run python main.py"
echo ""
echo "📊 cron 상태 확인:"
echo "  sudo service cron status"
echo "  sudo service cron start  # cron 서비스 시작"
echo ""
echo "🔍 cron 로그 확인:"
echo "  grep CRON /var/log/syslog | tail -10"
echo ""
echo "🧪 cron 환경 테스트:"
echo "  cd $SCRIPT_DIR && $UV_PATH run python main.py"