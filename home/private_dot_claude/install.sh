#!/bin/bash

set -euo pipefail

echo "Claude Code 플러그인 설치..."

# gstack
claude plugin add garrytan/gstack || true

echo "✓ Claude Code 플러그인 설치 완료"
