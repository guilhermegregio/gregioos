# Segredos

Os tokens ficam **cifrados no repo** (`secrets/tokens.yaml`) e são decriptados
na ativação do sistema para `/run/secrets`, com permissão `0400`, fora do nix
store. O valor nunca passa pela avaliação do Nix.

Motivo: `environment.variables` gera `/etc/zshenv`, que é um symlink para o
store — **legível por qualquer processo da máquina** e impossível de apagar de
verdade.

Ferramenta: [sops-nix](https://github.com/Mic92/sops-nix), com chaves age
derivadas das chaves SSH de cada máquina.

## Quem pode decriptar

`.sops.yaml` lista uma chave por máquina. Cada uma decripta de forma
independente — não é esquema de "n de m".

| âncora | máquina |
| --- | --- |
| `stone` | MacBook de trabalho |
| `tuf` | NixOS |
| `nxt` | MacBook pessoal |

## Editar ou rotacionar

De qualquer máquina listada acima:

```bash
sops secrets/tokens.yaml
git commit -am "chore(sops): rotaciona token"
fr                            # só quem consome precisa
```

O `SOPS_AGE_KEY_FILE` já vem do config (`modules/home/common/sops.nix`). O que
não é declarativo é a identidade em si — em uma máquina nova, gere-a uma vez:

```bash
mkdir -p ~/.config/sops/age
ssh-to-age -private-key -i ~/.ssh/id_ed25519 > ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
```

> ⚠️ **Tem de ser a identidade age** (`AGE-SECRET-KEY-1…`) derivada da chave
> SSH, **não a chave SSH**. Explicação abaixo, em *Dois esquemas*.

## Autorizar uma máquina nova

Na máquina nova:

```bash
ssh-to-age < ~/.ssh/id_ed25519.pub     # a chave age pública dela
```

Acrescente ao `.sops.yaml` em **dois lugares** — em `keys` e em `key_groups`.
Só o primeiro deixa a chave declarada e ignorada, e o switch da máquina falha na
ativação sem explicação óbvia.

Depois, **de uma máquina que já decripta**:

```bash
sops updatekeys secrets/tokens.yaml
git commit -am "chore(sops): autoriza <host>"
```

O `updatekeys` decripta e recifra para a nova lista — por isso precisa rodar de
onde já se tem acesso.

## Adicionar um segredo

1. `sops secrets/tokens.yaml` e acrescente a chave em snake_case
2. Declare em `hosts/<host>/default.nix`, dentro de `sops.secrets`
3. Se for virar variável de ambiente, acrescente ao template `dev-env` com
   `config.sops.placeholder.<nome>`

O `placeholder` é o que mantém o valor fora do store: ele é substituído na
ativação, não na avaliação. Ler o segredo com `builtins.readFile` seria
exatamente o erro que este desenho evita.

## Diagnóstico

```bash
./dev/sops-doctor.sh
```

Compara a sua chave com os destinatários reais do arquivo, checa passphrase,
variáveis conflitantes e a identidade que o CLI vai usar.

---

## Dois esquemas — a armadilha que custa horas

`ssh-to-age` parece só traduzir um formato. Não é: há **dois esquemas
incompatíveis** de usar chave SSH com age.

| esquema | recipient no `.sops.yaml` | identidade que decripta |
| --- | --- | --- |
| X25519 derivado (`ssh-to-age`) | `age1…` | `AGE-SECRET-KEY-1…` (o `keys.txt`) |
| SSH nativo do age (`agessh`) | `ssh-ed25519 AAAA…` | a própria chave SSH |

Este repo usa o primeiro. Quando se aponta o sops para a chave SSH — via
`SOPS_AGE_SSH_PRIVATE_KEY_FILE` ou pelo default `~/.ssh/id_ed25519` — ele a lê
com `agessh` e produz identidade de **outro tipo**, que não abre esses
recipients. O sintoma é `no identity matched any of the recipients` mesmo com a
chave certa em mãos e as públicas conferindo.

**A ativação do sistema não passa por isso**: lá quem decripta é o módulo, via
`sops.age.sshKeyPaths`, que converte internamente. Daí o sintoma que mais
confunde — **o `fr` funciona e o `sops` da linha de comando não abre**.

## Outros erros

| erro | causa |
| --- | --- |
| `no identity matched`, com o doctor dizendo que a chave confere | falta o `keys.txt`; ver *Dois esquemas* |
| `unknown identity type` | `SOPS_AGE_KEY`/`SOPS_AGE_KEY_FILE` apontando para chave SSH. `unset` e use o `keys.txt` |
| `~/.ssh/id_rsa` aparece na mensagem | ruído: o sops lista os caminhos onde não achou arquivo. O erro real é a linha do `identity` |
| chave SSH com passphrase | não suportado. Gere uma sem senha e some a age pública dela ao `.sops.yaml` |
| `keys.txt` ignorado no macOS | o default do sops é `<os.UserConfigDir()>/sops/age/keys.txt` — no macOS, `~/Library/Application Support`. O config declara `SOPS_AGE_KEY_FILE` justamente para não depender disso |
| `file not found` no eval | `secrets/tokens.yaml` não foi `git add`-ado. Flake não enxerga arquivo untracked |

> O `.sops.yaml` diz para quem arquivos **novos** serão cifrados; os
> destinatários de um arquivo existente ficam gravados **dentro dele**. Os dois
> divergem em silêncio — o doctor compara os dois.

**Backup da chave privada:** ela não está no repo, de propósito. Perder a
`~/.ssh/id_ed25519` sem outra máquina autorizada torna os valores irrecuperáveis.
