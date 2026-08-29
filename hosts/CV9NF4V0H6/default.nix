# MacBook de trabalho (Stone). Tudo aqui é o que NÃO pode vazar para o Mac
# pessoal: CA corporativa, tokens e o toolchain mobile.
{ config, pkgs, username, ... }:
let
  # Bundle gerado na máquina (runbook, fase 3) — não versionado, o config só
  # aponta para o caminho.
  caBundle = "/etc/ssl/certs/combined-ca.pem";

  xcode15 = import ../../modules/scripts/xcode15.nix { inherit pkgs; };
  verify-app = import ../../modules/scripts/verify-app.nix { inherit pkgs; };
in {
  # Ferramentas do monorepo mobile — não fazem sentido no Mac pessoal.
  environment.systemPackages = [
    xcode15
    verify-app
    pkgs.android-tools
    pkgs.sdkmanager
  ];

  # GID do nixbld desta instalação de Nix. Confirmar com:
  #   dscl . -read /Groups/nixbld PrimaryGroupID
  ids.gids.nixbld = 350;

  nix.settings = {
    ssl-cert-file = caBundle;
    # o proxy corporativo derruba conexões HTTP/2 do Nix
    http2 = false;
  };

  environment.variables = {
    # Netskope faz TLS inspection; o Nix não lê o Keychain do macOS.
    NIX_SSL_CERT_FILE = caBundle;
    SSL_CERT_FILE = caBundle;
    CURL_CA_BUNDLE = caBundle;
    REQUESTS_CA_BUNDLE = caBundle;
    # CAINFO é o arquivo; CAPATH seria um diretório de certificados com hashes.
    # O dotfiles usava CAPATH apontando para o .pem, o que o git ignora — era o
    # motivo de o lazy.nvim falhar ao clonar plugins atrás do Netskope.
    GIT_SSL_CAINFO = caBundle;
    # o Node (usado por LSPs e ferramentas do nvim) lê esta, não as de cima
    NODE_EXTRA_CA_CERTS = caBundle;

    # Username não é segredo; os tokens saíram daqui para o sops (abaixo).
    MOBILE_PLATFORM_GITHUB_USERNAME = "guilhermegregio";
  };

  # Tokens da Stone: cifrados em secrets/tokens.yaml, decriptados na ativação
  # para /run/secrets, fora do store. O valor nunca passa pela avaliação do
  # Nix — é o `placeholder` que garante isso.
  sops = {
    defaultSopsFile = ../../secrets/tokens.yaml;
    age.sshKeyPaths = [ "/Users/${username}/.ssh/id_ed25519" ];

    secrets = {
      mobile_platform_github_token.owner = username;
      custom_github_pat_package.owner = username;
      temp_tap_sdk_ios_token.owner = username;
    };

    # Um arquivo só para o zsh dar source, em vez de três. O sourcing está em
    # modules/home/darwin/default.nix, via osConfig.
    templates."dev-env" = {
      owner = username;
      mode = "0400";
      content = ''
        export MOBILE_PLATFORM_GITHUB_TOKEN="${config.sops.placeholder.mobile_platform_github_token}"
        export CUSTOM_GITHUB_PERSONAL_ACCESS_TOKEN_PACKAGE="${config.sops.placeholder.custom_github_pat_package}"
        export TEMP_TAP_SDK_IOS_TOKEN="${config.sops.placeholder.temp_tap_sdk_ios_token}"
      '';
    };
  };

  # Toolchain iOS/Android e apps corporativos — só nesta máquina.
  homebrew = {
    brews = [ "xcode-kotlin" "mint" "sourcery" "carthage" ];

    casks = [
      "android-studio"
      "intellij-idea-ce"
      "zoom"
      "slack"
    ];
  };
}
