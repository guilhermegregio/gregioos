# MacBook de trabalho (Stone). Tudo aqui é o que NÃO pode vazar para o Mac
# pessoal: CA corporativa, tokens e o toolchain mobile.
{ pkgs, ... }:
let
  # Bundle gerado na máquina (runbook, fase 3) — não versionado, o config só
  # aponta para o caminho.
  caBundle = "/etc/ssl/certs/combined-ca.pem";

  xcode15 = import ../../modules/scripts/xcode15.nix { inherit pkgs; };
  verify-app = import ../../modules/scripts/verify-app.nix { inherit pkgs; };
in {
  # Ferramentas do monorepo mobile — não fazem sentido no Mac pessoal.
  environment.systemPackages = [ xcode15 verify-app ];

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
    GIT_SSL_CAPATH = caBundle;
    REQUESTS_CA_BUNDLE = caBundle;

    # FIXME: placeholders, como já era no dotfiles — preenchidos na máquina.
    # Follow-up 7.4 do plano: mover para agenix e parar de versionar o campo.
    MOBILE_PLATFORM_GITHUB_USERNAME = "guilhermegregio";
    MOBILE_PLATFORM_GITHUB_TOKEN = "<REPLACE>";
    CUSTOM_GITHUB_PERSONAL_ACCESS_TOKEN_PACKAGE = "<REPLACE>";
    TEMP_TAP_SDK_IOS_TOKEN = "<REPLACE>";
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
