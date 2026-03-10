# H8njo's dotfiles

Managed with [chezmoi](https://www.chezmoi.io/).

## Machines

- MacBook Pro M4 (Work)
- MacBook Pro M1 (Home)

## Setup

```bash
# Install chezmoi and apply dotfiles
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply h8njo

# Or if chezmoi is already installed
chezmoi init --apply h8njo
```

## Brewfile

```bash
# Install packages
brew bundle --global
```

## Structure

```
.
├── home/
│   ├── .Brewfile          # Homebrew packages
│   └── .chezmoiignore     # Files to ignore
├── .chezmoiroot           # Source directory
└── README.md
```
