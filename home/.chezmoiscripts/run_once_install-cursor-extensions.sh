#!/bin/bash

# Install Cursor extensions
if command -v cursor &> /dev/null; then
  echo "Installing Cursor extensions..."

  # Icons & Theme
  cursor --install-extension pkief.material-icon-theme

  # Editor
  cursor --install-extension esbenp.prettier-vscode
  cursor --install-extension dbaeumer.vscode-eslint
  cursor --install-extension biomejs.biome
  cursor --install-extension usernamehw.errorlens
  cursor --install-extension yoavbls.pretty-ts-errors

  # Git
  cursor --install-extension eamodio.gitlens
  cursor --install-extension github.vscode-github-actions

  # Web Development
  cursor --install-extension bradlc.vscode-tailwindcss
  cursor --install-extension styled-components.vscode-styled-components
  cursor --install-extension dsznajder.es7-react-js-snippets
  cursor --install-extension heybourn.headwind

  # Utilities
  cursor --install-extension christian-kohler.path-intellisense
  cursor --install-extension formulahendry.auto-rename-tag
  cursor --install-extension wayou.vscode-todo-highlight
  cursor --install-extension cardinal90.multi-cursor-case-preserve
  cursor --install-extension anseki.vscode-color
  cursor --install-extension irongeek.vscode-env
  cursor --install-extension yoshinorin.current-file-path
  cursor --install-extension grapecity.gc-excelviewer

  # Figma
  cursor --install-extension figma.figma-vscode-extension

  echo "Cursor extensions installed!"
else
  echo "Cursor not found. Install it first: brew install --cask cursor"
fi
