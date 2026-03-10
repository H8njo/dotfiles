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

## Manual Setup

```bash
# If you prefer manual installation
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply git@github.com:h8njo/dotfiles.git
brew bundle --global
```

## Structure

```
.
├── install.sh             # Bootstrap script
├── home/
│   ├── .Brewfile          # Homebrew packages
│   ├── .chezmoiscripts/   # Auto-run scripts
│   ├── dot_gitconfig      # Git config
│   ├── dot_zshrc          # Zsh config
│   └── private_dot_ssh/   # SSH config (1Password)
├── .chezmoiroot           # Source directory
└── README.md
```
