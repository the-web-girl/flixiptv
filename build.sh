#!/bin/bash
# Script de build FlixIPTV
# Usage: ./build.sh [android|windows|all]

set -e
TARGET=${1:-all}
echo "🎬 FlixIPTV Build Script"
echo "========================"

flutter pub get
echo "✅ Dépendances installées"

if [ "$TARGET" = "android" ] || [ "$TARGET" = "all" ]; then
  echo ""
  echo "📱 Build Android..."
  flutter build apk --release
  echo "✅ APK : build/app/outputs/flutter-apk/app-release.apk"
fi

if [ "$TARGET" = "windows" ] || [ "$TARGET" = "all" ]; then
  echo ""
  echo "🖥️  Build Windows..."
  flutter config --enable-windows-desktop
  flutter build windows --release
  echo "✅ Windows : build/windows/x64/runner/Release/"
fi

echo ""
echo "🎉 Build terminé !"
