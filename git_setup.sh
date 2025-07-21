#!/bin/bash

# ClickHouse Reporter Git 설정 및 GitHub 업로드 스크립트
# GitHub.com 및 GitHub Enterprise 지원

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
echo "👤 Git 사용자 정보 설정..."

# GitHub 플랫폼 선택
echo "사용할 GitHub 플랫폼을 선택하세요:"
echo "1) GitHub.com (github.com)"
echo "2) Samsung GitHub Enterprise (github.ecodesamsung.com)"
echo "3) 기타 GitHub Enterprise"
read -p "선택하세요 (1-3): " platform_choice

case $platform_choice in
    1)
        GITHUB_HOST="github.com"
        GITHUB_URL="https://github.com"
        echo "✅ GitHub.com 선택"
        ;;
    2)
        GITHUB_HOST="github.ecodesamsung.com"
        GITHUB_URL="https://github.ecodesamsung.com"
        echo "✅ Samsung GitHub Enterprise 선택"
        ;;
    3)
        read -p "GitHub Enterprise 호스트를 입력하세요 (예: github.company.com): " GITHUB_HOST
        GITHUB_URL="https://$GITHUB_HOST"
        echo "✅ $GITHUB_HOST 선택"
        ;;
    *)
        echo "❌ 잘못된 선택입니다. GitHub.com을 기본값으로 사용합니다."
        GITHUB_HOST="github.com"
        GITHUB_URL="https://github.com"
        ;;
esac

# 사용자 정보 입력
if [ -z "$(git config user.name)" ]; then
    if [ "$GITHUB_HOST" = "github.ecodesamsung.com" ]; then
        read -p "Git 사용자 이름을 입력하세요 (예: Jihoon Kim): " username
        read -p "Git 이메일을 입력하세요 (예: jhk2025.kim@partner.samsung.com): " email
    else
        read -p "Git 사용자 이름을 입력하세요: " username
        read -p "Git 이메일을 입력하세요: " email
    fi
    git config user.name "$username"
    git config user.email "$email"
fi

echo "Git 사용자: $(git config user.name) <$(git config user.email)>"

# 첫 커밋
echo "📝 첫 커밋 생성..."
git add .
git commit -m "feat: Initial commit - ClickHouse Daily Reporter

- Add automated ClickHouse query execution with uv package management
- Support k8s kubectl port-forwarding
- Excel output with multiple sheets and styling
- Cron scheduling support with uv integration
- Comprehensive logging and error handling
- Type safety improvements with defensive programming"

echo "✅ Git 저장소 설정 완료!"
echo ""
echo "📋 다음 단계:"

if [ "$GITHUB_HOST" = "github.ecodesamsung.com" ]; then
    echo "1. Samsung GitHub Enterprise에서 새 저장소 생성 ($GITHUB_URL/new)"
    echo "   - Repository name: clickhouse_reporter"
    echo "   - Description: Automated ClickHouse reporting tool for k8s environments"
    echo "   - Private 선택 (권장)"
    echo "   - README, .gitignore, license는 체크하지 마세요 (이미 있음)"
    echo ""
    echo "2. SSH 키가 등록되었는지 확인:"
    echo "   $GITHUB_URL/settings/keys"
    echo ""
    echo "3. 저장소 생성 후 다음 명령어 실행:"
    echo "   git remote add origin git@$GITHUB_HOST:YOUR_USERNAME/clickhouse_reporter.git"
    echo "   git branch -M master"
    echo "   git push -u origin master"
else
    echo "1. $GITHUB_HOST에서 새 저장소 생성 ($GITHUB_URL/new)"
    echo "   - Repository name: clickhouse-daily-reporter"
    echo "   - Description: Automated ClickHouse reporting tool for k8s environments"
    echo "   - Public 또는 Private 선택"
    echo "   - README, .gitignore, license는 체크하지 마세요 (이미 있음)"
    echo ""
    echo "2. 저장소 생성 후 다음 명령어 실행:"
    echo "   git remote add origin git@$GITHUB_HOST:YOUR_USERNAME/clickhouse-daily-reporter.git"
    echo "   git branch -M main"
    echo "   git push -u origin main"
fi

echo ""
echo "🔑 SSH 설정이 필요한 경우:"
echo "   bash advanced_ssh_setup.sh"
echo ""

# GitHub CLI 확인
if command -v gh &> /dev/null; then
    echo "🔧 GitHub CLI가 설치되어 있습니다."
    if [ "$GITHUB_HOST" = "github.com" ]; then
        echo "GitHub.com에 바로 업로드하시겠습니까? (y/n)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            echo "📤 GitHub.com에 저장소 생성 및 업로드 중..."
            gh repo create clickhouse-daily-reporter --public --source=. --remote=origin --push
            echo "✅ GitHub 업로드 완료!"
            echo "🌐 저장소 URL: https://github.com/$(gh api user --jq .login)/clickhouse-daily-reporter"
        fi
    else
        echo "💡 GitHub Enterprise 환경에서는 수동으로 저장소를 생성해주세요."
    fi
else
    echo "💡 GitHub CLI를 설치하면 명령어 한 번으로 업로드할 수 있습니다:"
    echo "   https://cli.github.com/"
fi

echo ""
echo "🎉 설정 완료! Git으로 프로젝트를 관리할 수 있습니다."