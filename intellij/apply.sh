#!/usr/bin/env bash
set -euo pipefail

IDEA_APP="/Applications/IntelliJ IDEA CE.app"
JETBRAINS_BASE="$HOME/Library/Application Support/JetBrains"

IDEA_DIR=$(ls -d "$JETBRAINS_BASE/IdeaIC"* 2>/dev/null | sort -V | tail -1)

if [[ -z "$IDEA_DIR" ]]; then
  if [[ ! -d "$IDEA_APP" ]]; then
    echo "IntelliJ IDEA CE não encontrado em $IDEA_APP. Instale primeiro."
    exit 1
  fi

  VERSION=$(defaults read "$IDEA_APP/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null)
  MAJOR=$(echo "$VERSION" | cut -d. -f1,2)

  IDEA_DIR="$JETBRAINS_BASE/IdeaIC${MAJOR}"
  echo "Criando diretório de configuração: $IDEA_DIR"
  mkdir -p "$IDEA_DIR"
fi

echo "Configurando: $IDEA_DIR"
cp "$(dirname "$0")/idea.vmoptions" "$IDEA_DIR/idea.vmoptions"
echo "✓ idea.vmoptions aplicado"
