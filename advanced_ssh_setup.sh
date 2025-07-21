#!/bin/bash

# 고급 SSH 설정 - GitHub 및 GitHub Enterprise 지원
# keychain 도구를 사용한 안정적인 SSH 에이전트 관리

echo "🔧 고급 SSH 에이전트 설정 (keychain 사용)"

# GitHub 플랫폼 선택
echo "SSH 설정할 GitHub 플랫폼을 선택하세요:"
echo "1) GitHub.com (github.com)"
echo "2) Samsung GitHub Enterprise (github.ecodesamsung.com)"
echo "3) 기타 GitHub Enterprise"
echo "4) 모든 플랫폼"
read -p "선택하세요 (1-4): " platform_choice

case $platform_choice in
    1)
        PLATFORMS=("github.com")
        echo "✅ GitHub.com 설정"
        ;;
    2)
        PLATFORMS=("github.ecodesamsung.com")
        echo "✅ Samsung GitHub Enterprise 설정"
        ;;
    3)
        read -p "GitHub Enterprise 호스트를 입력하세요 (예: github.company.com): " custom_host
        PLATFORMS=("$custom_host")
        echo "✅ $custom_host 설정"
        ;;
    4)
        PLATFORMS=("github.com" "github.ecodesamsung.com")
        echo "✅ 모든 플랫폼 설정"
        ;;
    *)
        echo "❌ 잘못된 선택입니다. GitHub.com을 기본값으로 사용합니다."
        PLATFORMS=("github.com")
        ;;
esac

# keychain 설치 확인 및 설치
if ! command -v keychain &> /dev/null; then
    echo "📦 keychain 설치 중..."
    sudo apt update
    sudo apt install -y keychain
fi

# SSH 키 존재 확인
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    echo "🔑 SSH 키가 없습니다. 새로 생성하겠습니다."
    read -p "이메일 주소를 입력하세요: " email
    ssh-keygen -t ed25519 -C "$email" -f "$HOME/.ssh/id_ed25519"
    echo "✅ SSH 키 생성 완료"
fi

# ~/.bashrc에 keychain 설정 추가
BASHRC_FILE="$HOME/.bashrc"
KEYCHAIN_CONFIG='
# Keychain을 이용한 SSH 에이전트 관리
if command -v keychain &> /dev/null; then
    eval $(keychain --eval --agents ssh id_ed25519)
fi'

# 기존 SSH 에이전트 설정 제거 (있다면)
if grep -q "SSH 에이전트 자동 시작" "$BASHRC_FILE"; then
    echo "🧹 기존 SSH 에이전트 설정 제거..."
    sed -i '/# SSH 에이전트 자동 시작/,/^fi$/d' "$BASHRC_FILE"
fi

# keychain 설정 추가
if ! grep -q "keychain" "$BASHRC_FILE"; then
    echo "📝 ~/.bashrc에 keychain 설정 추가..."
    echo "$KEYCHAIN_CONFIG" >> "$BASHRC_FILE"
    echo "✅ ~/.bashrc 설정 완료"
else
    echo "ℹ️  keychain 설정이 이미 존재합니다."
fi

# SSH config 파일 최적화
SSH_CONFIG_FILE="$HOME/.ssh/config"
mkdir -p "$HOME/.ssh"

# 각 플랫폼에 대해 SSH config 설정
for platform in "${PLATFORMS[@]}"; do
    echo "⚙️ $platform SSH config 설정..."
    
    # 기존 설정이 있는지 확인
    if [ ! -f "$SSH_CONFIG_FILE" ] || ! grep -q "$platform" "$SSH_CONFIG_FILE"; then
        cat >> "$SSH_CONFIG_FILE" << EOF

# $platform 설정
Host $platform
    HostName $platform
    User git
    IdentityFile ~/.ssh/id_ed25519
    AddKeysToAgent yes
    UseKeychain yes
    IdentitiesOnly yes
    ServerAliveInterval 60
    ServerAliveCountMax 10
EOF
        echo "✅ $platform SSH config 설정 완료"
    else
        echo "ℹ️  $platform SSH config가 이미 존재합니다."
    fi
done

# 권한 설정
chmod 600 "$SSH_CONFIG_FILE" 2>/dev/null
chmod 700 "$HOME/.ssh"

# 현재 세션에서 keychain 시작
echo "🚀 keychain으로 SSH 키 등록..."
echo "SSH 키의 passphrase를 입력하세요:"
eval $(keychain --eval --agents ssh id_ed25519)

# 각 플랫폼에 대해 연결 테스트
echo ""
echo "🧪 SSH 연결 테스트..."
for platform in "${PLATFORMS[@]}"; do
    echo "Testing $platform..."
    ssh -T git@$platform
    echo ""
done

# SSH 키 등록 안내
echo "🔑 SSH 키 등록 안내:"
echo ""
echo "다음 공개키를 각 플랫폼에 등록하세요:"
echo "----------------------------------------"
cat "$HOME/.ssh/id_ed25519.pub"
echo "----------------------------------------"
echo ""

for platform in "${PLATFORMS[@]}"; do
    if [ "$platform" = "github.com" ]; then
        echo "📋 GitHub.com에 SSH 키 등록:"
        echo "   1. https://github.com/settings/keys 접속"
        echo "   2. 'New SSH key' 클릭"
        echo "   3. Title: 'ClickHouse Reporter - $(hostname)'"
        echo "   4. 위의 공개키 전체 복사 붙여넣기"
        echo "   5. 'Add SSH key' 클릭"
    elif [ "$platform" = "github.ecodesamsung.com" ]; then
        echo "📋 Samsung GitHub Enterprise에 SSH 키 등록:"
        echo "   1. https://github.ecodesamsung.com/settings/keys 접속"
        echo "   2. 'New SSH key' 클릭"
        echo "   3. Title: 'ClickHouse Reporter - $(hostname)'"
        echo "   4. 위의 공개키 전체 복사 붙여넣기"
        echo "   5. 'Add SSH key' 클릭"
    else
        echo "📋 $platform에 SSH 키 등록:"
        echo "   1. https://$platform/settings/keys 접속"
        echo "   2. 'New SSH key' 클릭"
        echo "   3. Title: 'ClickHouse Reporter - $(hostname)'"
        echo "   4. 위의 공개키 전체 복사 붙여넣기"
        echo "   5. 'Add SSH key' 클릭"
    fi
    echo ""
done

echo "🎉 고급 SSH 설정 완료!"
echo ""
echo "🔧 keychain의 장점:"
echo "✅ 더 안정적인 SSH 에이전트 관리"
echo "✅ 시스템 재부팅 후에도 자동으로 키 로드"
echo "✅ 여러 터미널에서 SSH 에이전트 공유"
echo "✅ 메모리 효율적인 키 관리"
echo ""
echo "🔄 현재 터미널에서 바로 적용:"
echo "   source ~/.bashrc"
echo ""
echo "🧪 SSH 키 등록 후 연결 테스트:"
for platform in "${PLATFORMS[@]}"; do
    echo "   ssh -T git@$platform"
done