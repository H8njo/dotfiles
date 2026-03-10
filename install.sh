#!/bin/bash

set -euo pipefail

echo "=== H8njo's Dotfiles Installer ==="
echo ""

# 1. Install Homebrew
if ! command -v brew &> /dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "Homebrew already installed"
fi

# 2. Install 1Password
if [ ! -d "/Applications/1Password.app" ]; then
  echo "Installing 1Password..."
  brew install --cask 1password 1password-cli
else
  echo "1Password already installed"
fi

# 3. Wait for 1Password setup
echo ""
echo "============================================"
echo "  1Password 설정이 필요합니다:"
echo "  1. 1Password 앱 열기"
echo "  2. 로그인하기"
echo "  3. Settings → Developer → 'Use the SSH Agent' 활성화"
echo "  4. Settings → Developer → 'Allow Git commit signing' 활성화"
echo "============================================"
echo ""
read -p "설정 완료 후 Enter를 누르세요..."

# 4. Verify SSH Agent
echo "SSH Agent 확인 중..."
SOCKET_PATH="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
if [ -S "$SOCKET_PATH" ]; then
  echo "✓ SSH Agent 연결 성공!"
else
  echo "⚠ 1Password SSH Agent 소켓이 없습니다."
  echo "1Password 앱을 다시 확인하고, Settings → Developer에서:"
  echo "  - 'Use the SSH Agent' 활성화"
  echo "  - 'Allow Git commit signing' 활성화"
  read -p "완료 후 Enter를 누르세요..."

  # 다시 확인
  if ! [ -S "$SOCKET_PATH" ]; then
    echo "⚠ 계속 문제가 있습니다. 스크립트를 계속 진행합니다..."
  fi
fi

# 5. Install chezmoi and apply dotfiles
echo ""
echo "Installing chezmoi and applying dotfiles..."
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply git@github.com:h8njo/dotfiles.git || {
  echo "⚠ chezmoi 설치 중 오류가 발생했습니다."
  echo "다음 명령어로 수동 설치를 시도해주세요:"
  echo "sh -c \"\$(curl -fsLS get.chezmoi.io)\" -- init --apply git@github.com:h8njo/dotfiles.git"
  read -p "계속하려면 Enter를 누르세요..."
}

# 6. Install Brewfile packages
echo ""
echo "Installing Brewfile packages..."
brew bundle --global || {
  echo "⚠ Brewfile 설치 중 일부 패키지가 실패했을 수 있습니다."
}

# 7. Authenticate GitHub CLI
echo ""
if ! gh auth status &> /dev/null; then
  echo "Authenticating GitHub CLI..."
  gh auth login --git-protocol ssh --web || echo "⚠ GitHub CLI 인증 실패"
else
  echo "✓ GitHub CLI 이미 인증됨"
fi

# 8. Authenticate Claude Code
if command -v claude &> /dev/null; then
  echo "Authenticating Claude Code..."
  claude login || echo "⚠ Claude Code 인증 실패"
else
  echo "⚠ Claude Code가 설치되지 않았습니다."
fi

echo ""
echo "=== 설치 완료! ==="
echo "터미널을 재시작하세요."
