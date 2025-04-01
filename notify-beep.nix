{ pkgs ? import <nixpkgs> {} }:

pkgs.writeShellApplication {
  name = "notify-beep";

  # Lista de dependências necessárias para o script
  runtimeInputs = with pkgs; [
    bash
    nodejs
  ];

  text = ''
    # Script para emitir um beep de notificação
    # Usado para alertar sobre ações que requerem atenção manual
    
    # Emitir o beep usando Node.js
    node -e "console.log('\007')"
    
    # Se um argumento for passado, também exibe uma mensagem
    if [ $# -gt 0 ]; then
        echo "🔔 Atenção: $*"
    fi
  '';
}