#!/bin/bash
set -e

FLUTTER_DIR="$HOME/flutter"

echo ">>> Instalando Flutter..."
git clone https://github.com/flutter/flutter.git \
  --depth 1 -b stable "$FLUTTER_DIR"

export PATH="$FLUTTER_DIR/bin:$PATH"

echo ">>> Configurando Flutter para web..."
flutter config --enable-web --no-analytics

echo ">>> Descargando dependencias..."
flutter pub get

echo ">>> Compilando para web..."
flutter build web --release --base-href "/"

echo ">>> Build completado en build/web"
