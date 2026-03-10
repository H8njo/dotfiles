#!/bin/bash

# =============================================================================
# H8njo's Dotfiles Uninstaller
# =============================================================================
# 이 스크립트는 install.sh로 설치된 모든 것을 제거합니다.
# 새 맥북 상태로 완전 초기화됩니다.
# =============================================================================

set -euo pipefail

echo "=== H8njo's Dotfiles Uninstaller ==="
echo ""
echo "⚠️  경고: 이 스크립트는 다음을 모두 삭제합니다:"
echo "    - 모든 Homebrew 패키지 및 앱"
echo "    - Homebrew 자체"
echo "    - Oh My Zsh, Powerlevel10k"
echo "    - chezmoi 및 모든 dotfiles"
echo "    - tmux 플러그인"
echo "    - Neovim 설정"
echo "    - macOS 설정 초기화"
echo ""
echo "계속하시겠습니까? (yes 입력)"
read -r confirm
if [[ "$confirm" != "yes" ]]; then
  echo "취소되었습니다."
  exit 0
fi

echo ""
echo "정말로 모든 것을 삭제하시겠습니까? (DELETE 입력)"
read -r confirm2
if [[ "$confirm2" != "DELETE" ]]; then
  echo "취소되었습니다."
  exit 0
fi

echo ""
echo "삭제를 시작합니다..."
echo ""

# =============================================================================
# 1. GitHub CLI 로그아웃
# =============================================================================
echo "[ 1/10 ] GitHub CLI 로그아웃..."
if command -v gh &>/dev/null; then
  gh auth logout --hostname github.com 2>/dev/null || true
fi

# =============================================================================
# 2. Claude Code 로그아웃
# =============================================================================
echo "[ 2/10 ] Claude Code 로그아웃..."
if command -v claude &>/dev/null; then
  claude logout 2>/dev/null || true
fi

# =============================================================================
# 3. Mac App Store 앱 삭제
# =============================================================================
echo "[ 3/10 ] Mac App Store 앱 삭제..."
if command -v mas &>/dev/null; then
  # KakaoTalk
  mas uninstall 869223134 2>/dev/null || true
  # RunCat
  mas uninstall 1429033973 2>/dev/null || true
  # Folder Hub
  mas uninstall 6473019059 2>/dev/null || true
fi

# =============================================================================
# 4. Homebrew Cask 앱 삭제
# =============================================================================
echo "[ 4/10 ] Homebrew 앱 삭제..."
if command -v brew &>/dev/null; then
  # 설치된 cask 목록
  CASKS=(
    "iterm2"
    "cursor"
    "1password"
    "1password-cli"
    "karabiner-elements"
    "raycast"
    "readdle-spark"
    "obsidian"
    "arc"
    "keka"
    "aldente"
    "appcleaner"
    "claude-code"
    "font-meslo-lg-nerd-font"
  )

  for cask in "${CASKS[@]}"; do
    brew uninstall --cask "$cask" 2>/dev/null || true
  done

  # Homebrew formulae 삭제
  FORMULAE=(
    "zsh"
    "tmux"
    "git"
    "git-delta"
    "gh"
    "mas"
    "nvm"
    "pnpm"
    "neovim"
    "ripgrep"
    "fd"
    "lazygit"
    "chezmoi"
  )

  for formula in "${FORMULAE[@]}"; do
    brew uninstall "$formula" 2>/dev/null || true
  done
fi

# =============================================================================
# 5. Oh My Zsh 및 플러그인 삭제
# =============================================================================
echo "[ 5/10 ] Oh My Zsh 삭제..."
rm -rf "$HOME/.oh-my-zsh"

# =============================================================================
# 6. tmux 플러그인 삭제
# =============================================================================
echo "[ 6/10 ] tmux 플러그인 삭제..."
rm -rf "$HOME/.tmux"

# =============================================================================
# 7. Neovim/LazyVim 설정 삭제
# =============================================================================
echo "[ 7/10 ] Neovim 설정 삭제..."
rm -rf "$HOME/.config/nvim"
rm -rf "$HOME/.local/share/nvim"
rm -rf "$HOME/.local/state/nvim"
rm -rf "$HOME/.cache/nvim"

# =============================================================================
# 8. chezmoi 및 dotfiles 삭제
# =============================================================================
echo "[ 8/10 ] chezmoi 및 dotfiles 삭제..."
rm -rf "$HOME/.local/share/chezmoi"
rm -rf "$HOME/.config/chezmoi"
rm -f "$HOME/.chezmoi.toml"

# Dotfiles 삭제
rm -f "$HOME/.zshrc"
rm -f "$HOME/.zprofile"
rm -f "$HOME/.p10k.zsh"
rm -f "$HOME/.gitconfig"
rm -f "$HOME/.gitignore"
rm -f "$HOME/.Brewfile"
rm -rf "$HOME/.config/iterm2"
rm -rf "$HOME/.config/karabiner"
rm -rf "$HOME/.config/tmux"
rm -rf "$HOME/.config/raycast"
rm -rf "$HOME/.ssh/config"

# pnpm, nvm 삭제
rm -rf "$HOME/Library/pnpm"
rm -rf "$HOME/.nvm"

# chezmoi 바이너리 삭제
rm -f "$HOME/.local/bin/chezmoi"
rm -rf "$HOME/bin/chezmoi"

# =============================================================================
# 9. macOS 설정 초기화
# =============================================================================
echo "[ 9/10 ] macOS 설정 초기화..."

# Keyboard - 기본값으로 복원
defaults delete NSGlobalDomain InitialKeyRepeat 2>/dev/null || true
defaults delete NSGlobalDomain KeyRepeat 2>/dev/null || true
defaults delete NSGlobalDomain ApplePressAndHoldEnabled 2>/dev/null || true

# Dock - 기본값으로 복원
defaults delete com.apple.dock autohide 2>/dev/null || true
defaults delete com.apple.dock autohide-delay 2>/dev/null || true
defaults delete com.apple.dock autohide-time-modifier 2>/dev/null || true

# Finder - 기본값으로 복원
defaults delete com.apple.finder ShowStatusBar 2>/dev/null || true
defaults delete com.apple.finder ShowPathbar 2>/dev/null || true
defaults delete NSGlobalDomain AppleShowAllExtensions 2>/dev/null || true
defaults delete com.apple.finder FXEnableExtensionChangeWarning 2>/dev/null || true
defaults delete com.apple.finder AppleShowAllFiles 2>/dev/null || true

# Desktop (Sonoma+)
defaults delete com.apple.WindowManager EnableStandardClickToShowDesktop 2>/dev/null || true

# iTerm2 설정 삭제
defaults delete com.googlecode.iterm2 PrefsCustomFolder 2>/dev/null || true
defaults delete com.googlecode.iterm2 LoadPrefsFromCustomFolder 2>/dev/null || true

# 변경사항 적용
killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true

# =============================================================================
# 10. Homebrew 완전 삭제
# =============================================================================
echo "[ 10/10 ] Homebrew 삭제..."
if command -v brew &>/dev/null; then
  # Homebrew 공식 uninstall 스크립트
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)" -- --force
fi

# Homebrew 잔여 파일 삭제
sudo rm -rf /opt/homebrew 2>/dev/null || true
rm -rf "$HOME/.homebrew" 2>/dev/null || true

# =============================================================================
# 완료
# =============================================================================
echo ""
echo "============================================"
echo "  🧹 삭제 완료!"
echo "============================================"
echo ""
echo "다음 단계:"
echo "  1. 터미널 재시작 (또는 새 터미널 열기)"
echo "  2. 기본 zsh 셸로 돌아갑니다"
echo ""
echo "삭제되지 않은 항목 (수동 삭제 필요):"
echo "  - 1Password 계정 데이터 (앱 삭제됨, 클라우드 데이터 유지)"
echo "  - Cursor/VSCode 확장 및 설정 (GitHub Sync로 복원 가능)"
echo "  - 브라우저 데이터 (Arc)"
echo "  - Raycast 설정"
echo ""
