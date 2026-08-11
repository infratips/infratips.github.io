#!/usr/bin/env bash
set -euo pipefail

patterns='(AKIA[0-9A-Z]{16}|-----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY-----|gh[pousr]_[A-Za-z0-9_]{30,}|github_pat_[A-Za-z0-9_]{30,})'

if git grep -nE "$patterns" -- ':!scripts/scan_secrets.sh'; then
  echo "Possivel segredo encontrado nos arquivos rastreados." >&2
  exit 1
fi

echo "Nenhum segredo de alta confianca encontrado."
