#!/bin/bash

# ClickHouse Daily Reporter 설치 및 설정 스크립트
# WSL2 Ubuntu 환경에서 실행

echo "🚀 ClickHouse Daily Reporter 설치 시작"

# 1. 필요한 디렉토리 생성
echo "📁 디렉토리 생성 중..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "$SCRIPT_DIR"/{logs,output}
cd "$SCRIPT_DIR"

# 2. Python 패키지 설치 (uv 사용)
echo "📦 Python 패키지 설치 중..."
uv sync

# 3. 실행 권한 부여
echo "🔐 실행 권한 설정 중..."
chmod +x main.py

# 4. 첫 실행 (config.yaml 생성)
echo "⚙️ 설정 파일 생성 중..."
uv run python main.py

echo "✅ 설치 완료!"
echo ""
echo "📋 다음 단계:"
echo "1. config.yaml 파일을 수정하여 ClickHouse 연결 정보를 입력하세요"
echo "2. 쿼리를 원하는 대로 수정하세요"
echo "3. 테스트 실행: uv run python main.py"
echo "4. cron 설정: ./setup_cron.sh"
echo ""
echo "📄 설정 파일 위치: $SCRIPT_DIR/config.yaml"
echo "📊 출력 파일 위치: $SCRIPT_DIR/output/"
echo "📝 로그 파일 위치: $SCRIPT_DIR/logs/"

