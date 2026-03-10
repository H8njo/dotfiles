#!/bin/bash

set -euo pipefail

# Setup logging
LOG_FILE="/tmp/dotfiles_install_$(date +%Y%m%d_%H%M%S).log"
exec 1> >(tee -a "$LOG_FILE")
exec 2>&1

echo "=== H8njo's Dotfiles Installer ==="
echo "Log file: $LOG_FILE"
echo ""

# 1. Install Homebrew
if ! command -v brew &> /dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Setup Homebrew environment
eval "$(/opt/homebrew/bin/brew shellenv)"

# 2. Install iTerm2
echo ""
echo "Installing iTerm2..."
if [ ! -d "/Applications/iTerm.app" ]; then
  brew install --cask iterm2
else
  echo "iTerm2 already installed"
fi

# 3. Terminal restart checkpoint
echo ""
echo "============================================"
echo "  iTerm2 설치가 완료되었습니다!"
echo "  계속하려면:"
echo ""
echo "  1. iTerm2를 열기"
echo "  2. iTerm2를 재시작하기"
echo "  3. iTerm2에서 이 스크립트를 다시 실행하기"
echo ""
echo "============================================"
echo ""
set +e
read -p "iTerm2를 열고 재시작한 후 Enter를 누르세요..."
set -e

# 4. Install chezmoi and apply dotfiles (in iTerm2)
echo ""
echo "Installing chezmoi and applying dotfiles..."
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply git@github.com:h8njo/dotfiles.git

# 5. Install 1Password (in iTerm2)
if [ ! -d "/Applications/1Password.app" ]; then
  echo "Installing 1Password..."
  brew install --cask 1password 1password-cli
else
  echo "1Password already installed"
fi

# 6. Wait for 1Password setup
echo ""
echo "============================================"
echo "  1Password 설정이 필요합니다:"
echo "  1. 1Password 앱 열기"
echo "  2. 로그인하기"
echo "  3. Settings → Developer → 'Use the SSH Agent' 활성화"
echo "  4. Settings → Developer → 'Allow Git commit signing' 활성화"
echo "============================================"
echo ""
set +e
read -p "설정 완료 후 Enter를 누르세요..."
set -e

# 7. Verify SSH Agent
echo "SSH Agent 확인 중..."
SOCKET_PATH="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
if [ -S "$SOCKET_PATH" ]; then
  echo "✓ SSH Agent 연결 성공!"
else
  echo "⚠ 1Password SSH Agent 소켓이 없습니다."
  echo "1Password 앱을 다시 확인하고, Settings → Developer에서:"
  echo "  - 'Use the SSH Agent' 활성화"
  echo "  - 'Allow Git commit signing' 활성화"
  set +e
  read -p "완료 후 Enter를 누르세요..."
  set -e

  # 다시 확인
  if ! [ -S "$SOCKET_PATH" ]; then
    echo "❌ SSH Agent가 여전히 연결되지 않습니다."
    echo "1Password 설정을 다시 확인해주세요."
    exit 1
  fi
fi

# 8. Install Brewfile packages
echo ""
echo "Installing Brewfile packages..."
BREWFILE="$HOME/.Brewfile"
if [ -f "$BREWFILE" ]; then
  brew bundle --file "$BREWFILE" || {
    echo "⚠ Brewfile 설치 중 일부 패키지가 실패했을 수 있습니다."
  }
else
  echo "⚠ Brewfile을 찾을 수 없습니다: $BREWFILE"
fi

# 9. Authenticate GitHub CLI
echo ""
if command -v gh &> /dev/null; then
  if ! gh auth status &> /dev/null; then
    echo "Authenticating GitHub CLI..."
    set +e
    gh auth login --git-protocol ssh --web
    set -e
  else
    echo "✓ GitHub CLI 이미 인증됨"
  fi
else
  echo "⚠ GitHub CLI가 설치되지 않았습니다."
fi

# 10. Authenticate Claude Code
if command -v claude &> /dev/null; then
  echo "Authenticating Claude Code..."
  set +e
  claude login
  set -e
else
  echo "⚠ Claude Code가 설치되지 않았습니다."
fi

echo ""
echo "=== 설치 완료! ==="
echo "iTerm2 터미널을 재시작하세요."
