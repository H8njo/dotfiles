#!/bin/bash

set -euo pipefail

# Setup logging
LOG_FILE="/tmp/dotfiles_install_$(date +%Y%m%d_%H%M%S).log"
exec 1> >(tee -a "$LOG_FILE")
exec 2>&1

echo "=== H8njo's Dotfiles Installer ==="
echo "Log file: $LOG_FILE"
echo ""

# Helper function: wait for condition with spinner
wait_for() {
  local message="$1"
  local check_cmd="$2"
  local timeout="${3:-300}"  # default 5 minutes
  local elapsed=0
  local spinner='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'

  printf "%s " "$message"
  while ! eval "$check_cmd" 2>/dev/null; do
    local i=$(( elapsed % ${#spinner} ))
    printf "\r%s %s" "$message" "${spinner:$i:1}"
    sleep 1
    elapsed=$((elapsed + 1))
    if [ $elapsed -ge $timeout ]; then
      printf "\r%s ❌ 타임아웃\n" "$message"
      return 1
    fi
  done
  printf "\r%s ✓\n" "$message"
  return 0
}

# =============================================================================
# PHASE 1: Homebrew (모든 것의 기반)
# =============================================================================
echo "[ Phase 1: Homebrew ]"

if ! command -v brew &> /dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Setup Homebrew environment (필수 - 이후 모든 brew 명령에 필요)
eval "$(/opt/homebrew/bin/brew shellenv)"
echo "✓ Homebrew 준비 완료"

# =============================================================================
# PHASE 2: iTerm2 (올바른 터미널 환경 필요)
# =============================================================================
echo ""
echo "[ Phase 2: iTerm2 ]"

if [ ! -d "/Applications/iTerm.app" ]; then
  echo "Installing iTerm2..."
  brew install --cask iterm2
fi

# iTerm2에서 실행 중인지 확인 - 아니면 재시작 요청
if [[ "${TERM_PROGRAM:-}" != "iTerm.app" ]]; then
  echo ""
  echo "============================================"
  echo "  iTerm2 설치가 완료되었습니다!"
  echo ""
  echo "  다음 단계:"
  echo "  1. iTerm2 앱 열기"
  echo "  2. iTerm2에서 다음 명령 실행:"
  echo ""
  echo "  curl -fsLS https://raw.githubusercontent.com/h8njo/dotfiles/main/install.sh | bash"
  echo ""
  echo "============================================"
  exit 0
fi

echo "✓ iTerm2에서 실행 중"

# =============================================================================
# PHASE 3: 1Password (chezmoi 시크릿에 필요)
# =============================================================================
echo ""
echo "[ Phase 3: 1Password ]"

# 1Password 앱 설치
if [ ! -d "/Applications/1Password.app" ]; then
  echo "Installing 1Password..."
  brew install --cask 1password
fi

# 1Password CLI 설치
if ! command -v op &> /dev/null; then
  echo "Installing 1Password CLI..."
  brew install --cask 1password-cli
fi

echo "✓ 1Password 설치 완료"

# SSH Agent 소켓 확인
SOCKET_PATH="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

if [ -S "$SOCKET_PATH" ]; then
  echo "✓ 1Password SSH Agent 이미 활성화됨"
else
  # 1Password 앱 열기
  echo ""
  echo "1Password 앱을 열고 있습니다..."
  open -a "1Password"
  sleep 2

  echo ""
  echo "╔══════════════════════════════════════════════╗"
  echo "║  1Password에서 다음 설정을 완료하세요:       ║"
  echo "║                                              ║"
  echo "║  1. 로그인 (Face ID / 비밀번호)              ║"
  echo "║  2. Settings → Developer 탭으로 이동         ║"
  echo "║  3. 'Use the SSH Agent' 켜기                 ║"
  echo "║  4. 'Integrate with 1Password CLI' 켜기      ║"
  echo "║  5. 'Allow Git commit signing' 켜기          ║"
  echo "║                                              ║"
  echo "║  설정이 완료되면 자동으로 진행됩니다...      ║"
  echo "╚══════════════════════════════════════════════╝"
  echo ""

  # SSH Agent 소켓 대기
  if ! wait_for "SSH Agent 소켓 대기 중..." "[ -S \"$SOCKET_PATH\" ]" 600; then
    echo ""
    echo "❌ SSH Agent가 활성화되지 않았습니다."
    echo "1Password → Settings → Developer에서 'Use the SSH Agent'를 활성화하세요."
    exit 1
  fi
fi

# 1Password CLI 연동 확인
if ! op account list &>/dev/null; then
  echo ""
  echo "1Password CLI 연동을 확인하고 있습니다..."
  echo "(Settings → Developer → 'Integrate with 1Password CLI' 켜기)"
  echo ""

  if ! wait_for "1Password CLI 연동 대기 중..." "op account list &>/dev/null" 600; then
    echo ""
    echo "❌ 1Password CLI 연동에 실패했습니다."
    exit 1
  fi
fi

echo "✓ 1Password CLI 연동 완료"

# 1Password 데이터 접근 테스트
echo ""
echo "1Password 데이터 접근 테스트 중..."

# 1Password 앱을 포그라운드로 가져오기 (인증 팝업이 보이도록)
open -a "1Password"
sleep 1

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║  1Password 앱에서 인증을 승인하세요:         ║"
echo "║                                              ║"
echo "║  1. 1Password 앱이 열렸습니다                ║"
echo "║  2. '터미널 접근 허용' 팝업이 뜨면 승인      ║"
echo "║  3. Face ID / Touch ID / 비밀번호 인증       ║"
echo "║                                              ║"
echo "║  인증이 완료되면 자동으로 진행됩니다...      ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# 첫 번째 시도 - 인증 팝업을 보이게 함 (출력 표시)
echo "1Password 데이터 읽기 시도 중..."
echo "(1Password 앱에서 '터미널 접근 허용' 팝업이 뜨면 승인하세요)"
echo ""

if op read "op://Personal/Github-H8njo/username"; then
  echo ""
  echo "✓ 1Password 데이터 접근 가능"
else
  echo ""
  echo "❌ 1Password 데이터 접근에 실패했습니다."
  echo ""
  echo "확인사항:"
  echo "  1. 1Password 앱이 잠금 해제되어 있는지 확인"
  echo "  2. Settings → Developer → 'Integrate with 1Password CLI' 켜져있는지 확인"
  echo "  3. 1Password 앱에서 '터미널 접근 허용' 팝업을 승인했는지 확인"
  echo ""
  echo "다시 시도하려면 install.sh를 다시 실행하세요."
  exit 1
fi

# =============================================================================
# PHASE 4: Brewfile 패키지 (chezmoi scripts 의존성)
# =============================================================================
# 중요: chezmoi scripts가 cursor, tmux 등을 필요로 하므로 먼저 설치
echo ""
echo "[ Phase 4: Brewfile 패키지 ]"

# 임시로 Brewfile 다운로드 (chezmoi 적용 전)
TEMP_BREWFILE="/tmp/dotfiles_Brewfile"
echo "Brewfile 다운로드 중..."
curl -fsSL "https://raw.githubusercontent.com/h8njo/dotfiles/main/home/.Brewfile" -o "$TEMP_BREWFILE"

# mas 먼저 설치 (App Store 앱 설치용)
if ! command -v mas &>/dev/null; then
  echo "Installing mas (Mac App Store CLI)..."
  brew install mas
fi

# Mac App Store 로그인 확인
echo ""
echo "Mac App Store 앱 설치를 위해 로그인 상태를 확인합니다..."
if ! mas account &>/dev/null; then
  echo ""
  echo "╔══════════════════════════════════════════════╗"
  echo "║  App Store 로그인이 필요합니다:              ║"
  echo "║                                              ║"
  echo "║  1. App Store 앱 열기                        ║"
  echo "║  2. Apple ID로 로그인                        ║"
  echo "║                                              ║"
  echo "║  로그인이 완료되면 자동으로 진행됩니다...    ║"
  echo "╚══════════════════════════════════════════════╝"
  echo ""

  open -a "App Store"

  if ! wait_for "App Store 로그인 대기 중..." "mas account &>/dev/null" 600; then
    echo ""
    echo "⚠ App Store 로그인을 건너뜁니다. MAS 앱은 나중에 수동 설치하세요."
    # mas 라인 제거한 Brewfile 생성
    grep -v "^mas " "$TEMP_BREWFILE" > "${TEMP_BREWFILE}.nomas"
    mv "${TEMP_BREWFILE}.nomas" "$TEMP_BREWFILE"
  fi
fi

echo "Brewfile 패키지 설치 중... (시간이 걸릴 수 있습니다)"
brew bundle --file "$TEMP_BREWFILE" || {
  echo "⚠ 일부 패키지 설치에 실패했을 수 있습니다."
}

rm -f "$TEMP_BREWFILE"
echo "✓ Brewfile 패키지 설치 완료"

# =============================================================================
# PHASE 5: chezmoi (dotfiles 적용)
# =============================================================================
# 이제 모든 의존성이 설치되었으므로 chezmoi scripts가 정상 동작
echo ""
echo "[ Phase 5: chezmoi (dotfiles) ]"

if ! command -v chezmoi &> /dev/null; then
  echo "Installing chezmoi..."
  sh -c "$(curl -fsLS get.chezmoi.io)"
fi

# chezmoi init --apply (1Password 시크릿 사용)
echo "dotfiles 적용 중..."
chezmoi init --apply h8njo/dotfiles

echo "✓ dotfiles 적용 완료"

# =============================================================================
# PHASE 6: 인증 (GitHub CLI, Claude Code)
# =============================================================================
echo ""
echo "[ Phase 6: 인증 ]"

# GitHub CLI
if command -v gh &> /dev/null; then
  if ! gh auth status &> /dev/null; then
    echo ""
    echo "GitHub CLI 인증 - 브라우저에서 완료하세요..."
    gh auth login --git-protocol ssh --web
  else
    echo "✓ GitHub CLI 이미 인증됨"
  fi
fi

# Claude Code
if command -v claude &> /dev/null; then
  echo ""
  echo "Claude Code 인증..."
  claude login
fi

# =============================================================================
# 완료
# =============================================================================
echo ""
echo "============================================"
echo "  🎉 설치 완료!"
echo "============================================"
echo ""
echo "iTerm2를 재시작하면 모든 설정이 적용됩니다."
echo ""
echo "수동 설정이 필요한 항목:"
echo "  - Raycast: 초기 설정 및 단축키"
echo "  - Karabiner: Accessibility 권한 허용"
echo "  - 입력소스: System Settings → Keyboard → Input Sources → F13"
echo "  - Cursor: GitHub 계정 로그인 (Settings Sync)"
echo ""
