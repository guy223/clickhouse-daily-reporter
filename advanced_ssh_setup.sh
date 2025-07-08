#!/bin/bash

# 고급 SSH 설정 - 더 안정적인 SSH 에이전트 관리
# keychain 도구를 사용한 방법

echo "🔧 고급 SSH 에이전트 설정 (keychain 사용)"

# keychain 설치 확인 및 설치
if ! command -v keychain &> /dev/null; then
    echo "📦 keychain 설치 중..."
    sudo apt update
    sudo apt install -y keychain
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

# SSH config 설정 추가
if [ ! -f "$SSH_CONFIG_FILE" ] || ! grep -q "github.com" "$SSH_CONFIG_FILE"; then
    echo "⚙️ SSH config 최적화..."
    cat >> "$SSH_CONFIG_FILE" << 'EOF'

# GitHub 설정
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    AddKeysToAgent yes
    UseKeychain yes
    IdentitiesOnly yes
    ServerAliveInterval 60
    ServerAliveCountMax 10
EOF
    echo "✅ SSH config 설정 완료"
fi

# 권한 설정
chmod 600 "$SSH_CONFIG_FILE"
chmod 700 "$HOME/.ssh"

# 현재 세션에서 keychain 시작
echo "🚀 keychain으로 SSH 키 등록..."
echo "passphrase를 입력하세요 (마지막으로!): "
eval $(keychain --eval --agents ssh id_ed25519)

# Git 연결 테스트
echo "🧪 GitHub 연결 테스트..."
ssh -T git@github.com

echo ""
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

