#!/usr/bin/env bash
# Diagnóstico do sops: responde por que um arquivo não abre para edição.
# Não imprime segredo nenhum — só chaves públicas e comparações.
set -uo pipefail

cd "$(dirname "$0")/.."
KEY=${SOPS_AGE_SSH_PRIVATE_KEY_FILE:-$HOME/.ssh/id_ed25519}
FILE=${1:-secrets/tokens.yaml}

# funciona antes do primeiro switch, quando os CLIs ainda não estão no PATH
have() { command -v "$1" >/dev/null 2>&1; }
ssh_to_age() {
  if have ssh-to-age; then ssh-to-age "$@"
  else nix shell "nixpkgs#ssh-to-age" -c ssh-to-age "$@"; fi
}

say() { printf '\n\033[1m%s\033[0m\n' "$1"; }
ok()  { printf '  \033[32mok\033[0m    %s\n' "$1"; }
bad() { printf '  \033[31mFALHA\033[0m %s\n' "$1"; }
inf() { printf '        %s\n' "$1"; }

say "1. chave privada"
if [ -f "$KEY" ]; then
  ok "existe: $KEY"
else
  bad "não existe: $KEY"
  inf "gere com: ssh-keygen -t ed25519 -N '' -f $KEY"
  exit 1
fi

say "2. passphrase (o sops NÃO suporta chave protegida)"
if ssh-keygen -y -P "" -f "$KEY" >/dev/null 2>&1; then
  ok "sem passphrase"
else
  bad "a chave pede senha — o sops não consegue usá-la"
  inf "opções: ssh-keygen -p -f $KEY   (remove a senha)"
  inf "        ou gere uma chave só para o sops e some a age pública ao .sops.yaml"
fi

say "3. chave age derivada (pública)"
MINE=$(ssh_to_age < "$KEY.pub" 2>/dev/null)
if [ -n "$MINE" ]; then
  ok "$MINE"
else
  bad "ssh-to-age falhou sobre $KEY.pub"
  exit 1
fi

say "4. destinatários declarados em .sops.yaml"
if [ -f .sops.yaml ]; then
  rg -o "age1[a-z0-9]{20,}" .sops.yaml | sort -u | sed 's/^/        /'
else
  bad ".sops.yaml não existe"
fi

say "5. destinatários REAIS dentro de $FILE"
if [ -f "$FILE" ]; then
  RECIPIENTS=$(rg -o "age1[a-z0-9]{20,}" "$FILE" | sort -u)
  echo "$RECIPIENTS" | sed 's/^/        /'
else
  bad "$FILE não existe"
  exit 1
fi

say "6. veredito"
if echo "$RECIPIENTS" | rg -qx "$MINE"; then
  ok "a sua chave está entre os destinatários — deve abrir"
  inf "se ainda falhar, veja o item 2 (passphrase)"
else
  bad "a sua chave NÃO está entre os destinatários deste arquivo"
  inf "o .sops.yaml diz para quem arquivos NOVOS serão cifrados;"
  inf "os deste arquivo foram gravados quando ele foi criado."
  inf ""
  inf "conserto (valores de teste): corrija o .sops.yaml, rm $FILE e recrie"
  inf "conserto (valores reais):    de uma máquina que ainda decripta,"
  inf "                             sops updatekeys $FILE"
fi

say "7. ambiente"
inf "SOPS_AGE_SSH_PRIVATE_KEY_FILE = ${SOPS_AGE_SSH_PRIVATE_KEY_FILE:-(não definida)}"
inf "SOPS_AGE_KEY_FILE             = ${SOPS_AGE_KEY_FILE:-(não definida)}"
inf "sops                          = $(command -v sops || echo '(fora do PATH)')"
