# H8njo's dotfiles

Managed with [chezmoi](https://www.chezmoi.io/).

## Machines

- MacBook Pro M4 (Work)
- MacBook Pro M1 (Home)

## Quick Start

```bash
curl -fsLS https://raw.githubusercontent.com/h8njo/dotfiles/main/install.sh | bash
```

## What it does

1. Homebrew 설치
2. 1Password 설치
3. **[수동]** 1Password 로그인 + SSH Agent 활성화
4. chezmoi로 dotfiles 적용
5. Brewfile 패키지 설치
6. GitHub CLI 인증
7. Claude Code 인증

## Packages

### Homebrew
- git, git-delta, gh, nvm, pnpm, mas

### Apps
- iTerm2, Cursor, 1Password, Karabiner-Elements, Raycast
- Spark, Obsidian, Arc, Keka, AlDente, AppCleaner
- Claude Code

### Mac App Store
- KakaoTalk, RunCat

## Structure

```
.
├── install.sh                    # Bootstrap script
├── home/
│   ├── .Brewfile                 # Homebrew packages
│   ├── .chezmoi.toml.tmpl        # chezmoi config (1Password)
│   ├── .chezmoiscripts/          # Auto-run scripts
│   │   ├── run_once_install-oh-my-zsh.sh
│   │   └── run_once_install-cursor-extensions.sh
│   ├── dot_gitconfig.tmpl        # Git config (delta, aliases)
│   ├── dot_gitignore             # Global gitignore
│   ├── dot_zshrc                 # Zsh config (Oh My Zsh, P10k)
│   ├── dot_p10k.zsh              # Powerlevel10k config
│   ├── private_dot_ssh/config    # SSH config (1Password Agent)
│   └── private_dot_config/
│       ├── iterm2/               # iTerm2 settings
│       └── karabiner/            # Karabiner config (Shift+Space → F13)
├── .chezmoiroot
└── README.md
```

## Post-Install (수동 설정)

### 1Password (필수)
- 앱 로그인
- Settings → Developer → "Use the SSH Agent" 활성화
- Settings → Developer → "Allow Git commit signing" 활성화

### Raycast
- 첫 실행 시 초기 설정
- 단축키 설정 (Cmd+Space로 Spotlight 대체 권장)

### Karabiner-Elements
- 첫 실행 시 System Settings → Privacy → Accessibility 권한 허용

### 입력소스 전환 단축키
- System Settings → Keyboard → Keyboard Shortcuts → Input Sources
- "Select the previous input source" → F13으로 변경
- Karabiner가 Shift+Space → F13 매핑하므로, Shift+Space로 입력소스 전환됨

### Mac App Store
- `mas`로 설치하려면 App Store에 먼저 로그인 필요

### Cursor
- GitHub 계정 로그인 (Settings Sync)

## Manual Setup

```bash
# If you prefer manual installation
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply git@github.com:h8njo/dotfiles.git
brew bundle --global
gh auth login --git-protocol ssh --web
```
