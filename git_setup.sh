#!/bin/bash

# ClickHouse Reporter Git 설정 및 GitHub 업로드 스크립트

echo "🚀 ClickHouse Reporter Git 설정 시작"

# 현재 디렉토리 확인
if [ ! -f "main.py" ]; then
    echo "❌ main.py 파일이 없습니다. clickhouse_reporter 디렉토리에서 실행해주세요."
    exit 1
fi

# Git 초기화
echo "📁 Git 저장소 초기화..."
git init

# .gitignore 파일 생성 (이미 있다면 스킵)
if [ ! -f ".gitignore" ]; then
    echo "📝 .gitignore 파일 생성..."
    cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST

# Virtual environments
venv/
env/
ENV/
.venv/
.env

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Project specific
# 민감한 정보 제외
config.yaml
config_production.yaml
config_local.yaml

# 출력 파일 제외
output/
logs/
*.xlsx
*.csv
*.log

# 임시 파일
*.tmp
*.temp
.cache/
EOF
fi

# config.example.yaml 생성 (config.yaml을 기반으로)
if [ -f "config.yaml" ] && [ ! -f "config.example.yaml" ]; then
    echo "📄 config.example.yaml 생성..."
    cp config.yaml config.example.yaml
    
    # 민감한 정보 마스킹
    sed -i 's/username: .*/username: "your_username"/' config.example.yaml
    sed -i 's/password: .*/password: "your_password"/' config.example.yaml
    
    echo "⚠️  config.example.yaml에서 민감한 정보가 마스킹되었습니다."
fi

# Git 사용자 정보 확인
echo "👤 Git 사용자 정보 확인..."
if [ -z "$(git config user.name)" ]; then
    echo "Git 사용자 이름을 입력하세요:"
    read -r username
    git config user.name "$username"
fi

if [ -z "$(git config user.email)" ]; then
    echo "Git 이메일을 입력하세요:"
    read -r email
    git config user.email "$email"
fi

echo "Git 사용자: $(git config user.name) <$(git config user.email)>"

# 첫 커밋
echo "📝 첫 커밋 생성..."
git add .
git commit -m "feat: Initial commit - ClickHouse Daily Reporter

- Add automated ClickHouse query execution
- Support k8s kubectl port-forwarding
- Excel output with multiple sheets
- Cron scheduling support
- Comprehensive logging and error handling"

echo "✅ Git 저장소 설정 완료!"
echo ""
echo "📋 다음 단계:"
echo "1. GitHub에서 새 저장소 생성 (https://github.com/new)"
echo "   - Repository name: clickhouse-daily-reporter"
echo "   - Description: Automated ClickHouse reporting tool for k8s environments"
echo "   - Public 또는 Private 선택"
echo "   - README, .gitignore, license는 체크하지 마세요 (이미 있음)"
echo ""
echo "2. 저장소 생성 후 다음 명령어 실행:"
echo "   git remote add origin https://github.com/YOUR_USERNAME/clickhouse-daily-reporter.git"
echo "   git branch -M main"
echo "   git push -u origin main"
echo ""
echo "3. 또는 GitHub CLI 사용 (gh 명령어가 설치되어 있다면):"
echo "   gh repo create clickhouse-daily-reporter --public --source=. --remote=origin --push"
echo ""

# GitHub CLI 확인
if command -v gh &> /dev/null; then
    echo "🔧 GitHub CLI가 설치되어 있습니다."
    echo "GitHub에 바로 업로드하시겠습니까? (y/n)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo "📤 GitHub에 저장소 생성 및 업로드 중..."
        gh repo create clickhouse-daily-reporter --public --source=. --remote=origin --push
        echo "✅ GitHub 업로드 완료!"
        echo "🌐 저장소 URL: https://github.com/$(gh api user --jq .login)/clickhouse-daily-reporter"
    fi
else
    echo "💡 GitHub CLI를 설치하면 명령어 한 번으로 업로드할 수 있습니다:"
    echo "   https://cli.github.com/"
fi

echo ""
echo "🎉 설정 완료! Git으로 프로젝트를 관리할 수 있습니다."
