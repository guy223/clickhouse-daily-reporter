#!/bin/bash

# 가상환경 설정 및 패키지 설치 스크립트

echo "🐍 Python 가상환경 설정 시작"

# 현재 디렉토리 확인
if [ ! -f "main.py" ]; then
    echo "❌ main.py 파일이 없습니다. clickhouse_reporter 디렉토리에서 실행해주세요."
    exit 1
fi

# 가상환경 생성
if [ ! -d "venv" ]; then
    echo "📦 가상환경 생성 중..."
    python3 -m venv venv
    if [ $? -ne 0 ]; then
        echo "❌ 가상환경 생성 실패. python3-venv 패키지를 설치해주세요:"
        echo "   sudo apt update && sudo apt install python3-venv"
        exit 1
    fi
    echo "✅ 가상환경 생성 완료"
else
    echo "ℹ️  가상환경이 이미 존재합니다."
fi

# 가상환경 활성화
echo "🔗 가상환경 활성화..."
source venv/bin/activate

# pip 업그레이드
echo "📦 pip 업그레이드..."
pip install --upgrade pip

# 패키지 설치
echo "📚 필수 패키지 설치 중..."
pip install -r requirements.txt

# 설치된 패키지 확인
echo "✅ 설치된 패키지 목록:"
pip list | grep -E "(clickhouse-connect|pandas|PyYAML|openpyxl)"

# 테스트 실행
echo ""
echo "🧪 설치 테스트..."
python -c "
import clickhouse_connect
import pandas as pd
import yaml
import openpyxl
print('✅ 모든 필수 모듈이 정상적으로 설치되었습니다!')
"

if [ $? -eq 0 ]; then
    echo "✅ 가상환경 설정 완료!"
    echo ""
    echo "📋 사용 방법:"
    echo "  # 가상환경 활성화"
    echo "  source venv/bin/activate"
    echo ""
    echo "  # 스크립트 실행"
    echo "  python main.py"
    echo ""
    echo "  # 가상환경 비활성화"
    echo "  deactivate"
    echo ""
    echo "📁 가상환경 경로: $(pwd)/venv"
    echo "🐍 Python 경로: $(pwd)/venv/bin/python"
else
    echo "❌ 패키지 설치에 문제가 있습니다."
    exit 1
fi

# 가상환경 비활성화
deactivate

echo ""
echo "🎉 가상환경 설정이 완료되었습니다!"
echo "이제 cron 설정을 실행하세요: bash setup_cron.sh"

