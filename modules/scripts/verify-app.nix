# Roda a bateria de lint/test de um produto do monorepo mobile da Stone.
# Só faz sentido no host de trabalho.
{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "verify-app";

  runtimeInputs = with pkgs; [ bash ];

  text = ''
    # Uso: verify-app <tribe> <product> [print]

    if [ $# -lt 2 ]; then
        echo "Uso: $0 <tribe> <product> [print]"
        echo "  tribe: nome da tribe (ex: engagement)"
        echo "  product: nome do produto (ex: credit-transparency)"
        echo "  print: (opcional) true para apenas imprimir o comando, false para executá-lo"
        echo "         se não for fornecido, o comando será executado"
        exit 1
    fi

    TRIBE=$1
    PRODUCT=$2
    PRINT=''${3:-false}

    if [ "$PRINT" != "true" ] && [ "$PRINT" != "false" ]; then
        echo "Erro: O parâmetro 'print' deve ser 'true' ou 'false'"
        exit 1
    fi

    COMMAND="./gradlew \\
    :products:$TRIBE:$PRODUCT:android-ui:detekt \\
    :products:$TRIBE:$PRODUCT:android-ui:lintKotlinAndroidTest \\
    :products:$TRIBE:$PRODUCT:android-ui:lintKotlinDebug \\
    :products:$TRIBE:$PRODUCT:android-ui:lintKotlinTest \\
    :products:$TRIBE:$PRODUCT:android-ui:lintKotlinTestFixtures \\
    :products:$TRIBE:$PRODUCT:android-ui:lintKotlin \\
    :products:$TRIBE:$PRODUCT:common:lintKotlinCommonMain \\
    :products:$TRIBE:$PRODUCT:common:lintKotlinCommonTest \\
    :products:$TRIBE:$PRODUCT:common:lintKotlinIosMain \\
    :products:$TRIBE:$PRODUCT:common:kspReleaseKotlinAndroid \\
    :products:$TRIBE:$PRODUCT:common:compileReleaseKotlinAndroid \\
    :products:$TRIBE:$PRODUCT:common:test \\
    :products:$TRIBE:$PRODUCT:android-ui:detekt \\
    :products:$TRIBE:$PRODUCT:common:detekt \\
    :products:$TRIBE:$PRODUCT:android-ui:compileDebugUnitTestKotlin \\
    :products:$TRIBE:$PRODUCT:common:compileDebugUnitTestKotlin \\
    :products:$TRIBE:$PRODUCT:android-ui:verifyPaparazziDebug \\
    :products:$TRIBE:$PRODUCT:common:compileCommonMainKotlinMetadata"

    if [ "$PRINT" = "true" ]; then
        echo "$COMMAND"
    else
        eval "$COMMAND"
    fi
  '';
}
