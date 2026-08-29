# Nova máquina NixOS

Instalação limpa até `fr` funcionando.

> **Nota de honestidade:** ao contrário do [guia de macOS](./nova-maquina-macos.md),
> que já rodou duas vezes, este descreve o procedimento padrão do NixOS adaptado
> a este repo — as duas máquinas Linux existentes são anteriores a esta config.
> Os passos 1–3 são o instalador do NixOS, não este repo; os 4 em diante são
> específicos daqui e conferem com o que está no `flake.nix`.

## Antes

- **Hostname** — vai ser o attr no `flake.nix`
- **Perfil** — hoje só existe `nvidia-laptop`, que importa o hardware do host,
  `modules/drivers` e `modules/core`. Se a máquina não for um laptop com GPU
  chaveável, vale criar outro perfil em vez de forçar este.

---

## 1–3. Instalar o NixOS

Procedimento padrão: boot pelo ISO, particionar, montar em `/mnt`, e

```bash
nixos-generate-config --root /mnt
```

Guarde o `/mnt/etc/nixos/hardware-configuration.nix` — é o único arquivo desta
etapa que interessa ao repo.

## 4. Criar o host

Do ISO mesmo, ou de outra máquina antes de instalar:

```bash
git clone https://github.com/guilhermegregio/gregioos.git
cd gregioos
mkdir -p hosts/<host>
cp /mnt/etc/nixos/hardware-configuration.nix hosts/<host>/hardware.nix
```

E o `hosts/<host>/variables.nix`, copiando de um existente:

```nix
{
  gitUsername = "Seu Nome";
  gitEmail = "voce@exemplo.com";

  browser  = "zen-browser";   # ou brave, google-chrome-stable
  terminal = "ghostty";

  keyboardLayout = "us";
  consoleKeyMap  = "us";

  # A versão em que a máquina foi instalada. NÃO atualizar depois: não traz
  # pacote novo nenhum, só troca defaults de dados stateful.
  systemStateVersion = "26.05";
  # Contrato do home-manager, independente do de cima.
  homeStateVersion   = "26.05";
}
```

> Os dois `stateVersion` são separados de propósito: têm semânticas
> independentes e o macOS usa valores diferentes. Ver a explicação em
> `hosts/gregio-asus-tuf-f15/variables.nix`.

## 5. Registrar no flake

Em `flake.nix`, dentro de `nixosConfigurations`:

```nix
<host> = mkNixos { host = "<host>"; };
```

O helper assume `username = "gregio"`, `profile = "nvidia-laptop"` e
`system = "x86_64-linux"` — passe explicitamente o que divergir:

```nix
<host> = mkNixos {
  host = "<host>";
  username = "outro";
  profile = "outro-perfil";
};
```

**Commite antes de buildar.** O flake só enxerga arquivos trackeados pelo git —
um `hardware.nix` novo e não adicionado dá "file not found" numa mensagem que
não ajuda.

## 6. Instalar

```bash
nixos-install --flake ".#<host>"
```

> As aspas importam se o shell do ISO tiver `EXTENDED_GLOB`; não custa nada.

Depois do reboot, clone o repo em `~/gregioos` (o caminho está no `NH_FLAKE` do
`nh` e no symlink do Neovim):

```bash
git clone https://github.com/guilhermegregio/gregioos.git ~/gregioos
```

## 7. Verificação

Terminal novo:

```bash
alias fr                  # nh os switch --hostname <host>
fr                        # deve dizer "No version or size changes"

for c in eza fd rg herdr tig yazi gh nvim zellij sops; do
  command -v $c >/dev/null && echo "ok    $c" || echo "FALTA $c"
done

ls -l ~/.config/nvim      # -> ~/gregioos/modules/home/common/nvim
```

E o visual: GNOME com o tema do Stylix (catppuccin-mocha), teclado `us intl`
com CapsLock como AltGr.

## 8. Segredos (opcional)

Para **editar** os segredos do repo desta máquina, ver
[segredos-sops.md](./segredos-sops.md). Hoje nenhum host NixOS *consome*
segredos na ativação — se for preciso, além da chave é necessário acrescentar
`inputs.sops-nix.nixosModules.sops` ao `mkNixos` e declarar `sops.secrets`.

---

## Depois

```bash
fr    # rebuild
fu    # rebuild + update dos inputs
ncg   # garbage collect + reboot
```

## Problemas conhecidos

| erro | causa e solução |
| --- | --- |
| `Path ... is not tracked by Git` | arquivo novo não adicionado. `git add -A` antes do build |
| aliases antigos após um switch | sessões abertas antes mantêm os aliases velhos; abra um terminal novo |
| `does not provide attribute` | o `--hostname` aponta para um attr que não existe mais. Confira com `nix eval ".#nixosConfigurations" --apply builtins.attrNames` |
| build quebra depois de `fu` | breakage do nixpkgs novo. Rode `nix build` do toplevel **antes** de commitar o lock — o `flake check` não compila |

## Trocar de GPU ou de hardware

Os drivers ficam em `modules/drivers` e são ligados no perfil, não no host:

```nix
drivers.nvidia.enable = true;
drivers.nvidia-prime = {
  enable = true;
  intelBusID  = "PCI:0:2:0";
  nvidiaBusID = "PCI:1:0:0";
};
```

Os IDs saem de `lspci | rg -i "vga|3d"`, convertendo hex para decimal.
