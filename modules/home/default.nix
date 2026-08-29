# Ponto de entrada do home-manager nas três máquinas. `common` vale em todas;
# a segunda camada entra pela plataforma.
#
# `hostPlatform` vem de specialArgs, não de `pkgs.stdenv`: referenciar `pkgs`
# (ou qualquer coisa derivada de `config`) dentro de `imports` dá recursão
# infinita, já que os imports é que produzem o `config`.
{ hostPlatform, ... }: {
  imports = [ ./common ]
    ++ (if hostPlatform == "darwin" then [ ./darwin ] else [ ./linux ]);
}
