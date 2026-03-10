#!/bin/bash

set -e

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
if [ -S "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock" ]; then
  echo "SSH Agent 연결 성공!"
else
  echo "경고: 1Password SSH Agent 소켓이 없습니다."
  echo "1Password 앱을 확인하고, Settings → Developer에서:"
  echo "  - 'Use the SSH Agent' 활성화"
  echo "  - 'Allow Git commit signing' 활성화"
  read -p "완료 후 Enter를 누르세요..."
fi

# 5. Install chezmoi and apply dotfiles
echo "Installing chezmoi and applying dotfiles..."
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply git@github.com:h8njo/dotfiles.git

# 6. Install Brewfile packages
echo "Installing Brewfile packages..."
brew bundle --global

# 7. Authenticate GitHub CLI
if ! gh auth status &> /dev/null; then
  echo "Authenticating GitHub CLI..."
  gh auth login --git-protocol ssh --web
fi

# 8. Authenticate Claude Code
if command -v claude &> /dev/null; then
  echo "Authenticating Claude Code..."
  claude login
fi

echo ""
echo "=== 설치 완료! ==="
echo "터미널을 재시작하세요."
