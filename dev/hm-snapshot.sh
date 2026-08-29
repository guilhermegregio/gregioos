#!/usr/bin/env bash
# Extrai o "perfil observável" do home-manager de um host: pacotes, arquivos
# gerenciados, aliases, activation e variáveis de sessão.
#
# Para que serve: numa refatoração estrutural o drvPath muda mesmo sem nada
# mudar de fato — separar módulos em camadas reordena a concatenação de listas
# como `home.packages`, e isso já altera o hash. Comparar dois snapshots
# distingue "mudou de verdade" de "só mudou a ordem".
#
#   ./dev/hm-snapshot.sh antes.txt
#   git checkout <outro-estado>
#   ./dev/hm-snapshot.sh depois.txt
#   diff antes.txt depois.txt
set -euo pipefail

OUT=${1:?uso: hm-snapshot.sh <arquivo-de-saida> [host] [usuario]}
HOST=${2:-gregio-asus-tuf-f15}
USER_=${3:-gregio}
HM=".#nixosConfigurations.${HOST}.config.home-manager.users.${USER_}"

cd "$(dirname "$0")/.."

{
  echo "### PACKAGES (ordenado)"
  nix eval --json "$HM.home.packages" --apply 'ps: builtins.sort (a: b: a < b) (map (p: p.name or "?") ps)' 2>/dev/null \
    | jq -r '.[]'

  echo "### FILES (ordenado)"
  nix eval --json "$HM.home.file" --apply 'builtins.attrNames' 2>/dev/null | jq -r '.[]' | sort

  echo "### XDG CONFIG FILES (ordenado)"
  nix eval --json "$HM.xdg.configFile" --apply 'builtins.attrNames' 2>/dev/null | jq -r '.[]' | sort

  echo "### SHELL ALIASES"
  nix eval --json "$HM.programs.zsh.shellAliases" 2>/dev/null | jq -S -r 'to_entries[] | "\(.key) = \(.value)"'

  echo "### ACTIVATION ENTRIES (ordenado)"
  nix eval --json "$HM.home.activation" --apply 'builtins.attrNames' 2>/dev/null | jq -r '.[]' | sort

  echo "### SESSION VARIABLES"
  nix eval --json "$HM.home.sessionVariables" 2>/dev/null | jq -S -r 'to_entries[] | "\(.key) = \(.value)"'
} > "$OUT" 2>&1

echo "snapshot em $OUT ($(wc -l < "$OUT") linhas)"
