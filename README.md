# H8njo's dotfiles

Managed with [chezmoi](https://www.chezmoi.io/).

## Machines

- MacBook Pro M4 (Work)
- MacBook Pro M1 (Home)

## Quick Start

새 맥북에서 한 줄로 전체 설정 완료:

```bash
curl -fsLS https://raw.githubusercontent.com/h8njo/dotfiles/main/install.sh | bash
```

## Installation Flow

스크립트가 자동으로 진행하며, 필요한 시점에 대기합니다 (Enter 키 불필요):

```
Phase 1: Homebrew
  └─ brew 설치 (없으면)

Phase 2: iTerm2
  └─ 설치 후 iTerm2에서 재실행 안내 (Terminal.app이면)

Phase 3: 1Password
  ├─ 앱 + CLI 설치
  ├─ 앱 자동 실행
  ├─ SSH Agent 활성화 대기 (자동 폴링)
  └─ CLI 연동 대기 (자동 폴링)

Phase 4: Brewfile 패키지
  ├─ mas 설치
  ├─ App Store 로그인 대기 (자동 폴링)
  └─ 모든 패키지 설치 (cursor, tmux 등)

Phase 5: chezmoi (dotfiles)
  ├─ 1Password 시크릿으로 gitconfig 생성
  └─ run_once scripts 실행 (oh-my-zsh, cursor extensions 등)

Phase 6: 인증
  ├─ GitHub CLI (브라우저)
  └─ Claude Code (브라우저)
```

## 사용자가 해야 할 것

스크립트 실행 중 앱이 자동으로 열리고, 설정 완료시 자동 감지됩니다:

### 1Password (앱이 자동으로 열림)
1. **로그인** (Face ID / 비밀번호)
2. **Settings → Developer** 탭
3. **Use the SSH Agent** 켜기
4. **Integrate with 1Password CLI** 켜기
5. **Allow Git commit signing** 켜기

### App Store (앱이 자동으로 열림)
1. **Apple ID로 로그인**

### GitHub / Claude Code
1. **브라우저에서 인증 완료**

## Packages

### Homebrew CLI
- git, git-delta, gh, nvm, pnpm, mas
- neovim, ripgrep, fd, lazygit, tmux, zsh

### Apps
- iTerm2, Cursor, 1Password, Karabiner-Elements, Raycast
- Spark, Obsidian, Arc, Keka, AlDente, AppCleaner
- Claude Code

### Mac App Store
- KakaoTalk, RunCat, Folder Hub

## Structure

```
.
├── install.sh                    # Bootstrap script (자동화)
├── uninstall.sh                  # 완전 초기화 script
├── home/
│   ├── .Brewfile                 # Homebrew packages
│   ├── .chezmoi.toml.tmpl        # chezmoi config (1Password secrets)
│   ├── .chezmoiscripts/          # Auto-run scripts
│   │   ├── install-oh-my-zsh.sh
│   │   ├── install-cursor-extensions.sh
│   │   ├── install-tmux-plugins.sh
│   │   └── configure-macos.sh
│   ├── dot_gitconfig.tmpl        # Git config (delta, 1Password signing)
│   ├── dot_gitignore             # Global gitignore
│   ├── dot_zshrc                 # Zsh config (Oh My Zsh, P10k)
│   ├── dot_p10k.zsh              # Powerlevel10k config
│   ├── private_dot_ssh/config    # SSH config (1Password Agent)
│   └── private_dot_config/
│       ├── iterm2/               # iTerm2 settings
│       ├── karabiner/            # Karabiner (Shift+Space → F13)
│       ├── nvim/                 # Neovim (LazyVim)
│       └── tmux/                 # tmux (catppuccin, vim-navigator)
├── .chezmoiroot
└── README.md
```

## Post-Install (수동 설정)

### Raycast
- 첫 실행 시 초기 설정
- 단축키: Cmd+Space로 Spotlight 대체 권장

### Karabiner-Elements
- System Settings → Privacy → Accessibility 권한 허용

### 입력소스 전환 (Shift+Space)
- System Settings → Keyboard → Keyboard Shortcuts → Input Sources
- "Select the previous input source" → **F13**으로 변경
- Karabiner가 Shift+Space → F13 매핑

### Cursor
- GitHub 계정 로그인 (Settings Sync)

## Uninstall

모든 것을 삭제하고 새 맥북 상태로 초기화:

```bash
curl -fsLS https://raw.githubusercontent.com/h8njo/dotfiles/main/uninstall.sh | bash
```

삭제되는 항목:
- 모든 Homebrew 패키지 및 Homebrew 자체
- 모든 cask 앱 (iTerm2, Cursor, 1Password 등)
- Oh My Zsh, Powerlevel10k, zsh 플러그인
- tmux 플러그인, Neovim 설정
- chezmoi 및 모든 dotfiles
- macOS 설정 (기본값으로 복원)

## Manual Setup

```bash
# 수동 설치 (1Password 먼저 설정 필요)
sh -c "$(curl -fsLS get.chezmoi.io)"
chezmoi init --apply h8njo/dotfiles
brew bundle --global
gh auth login --git-protocol ssh --web
```
