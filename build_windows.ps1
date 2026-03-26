# build_windows.ps1 - Script de build FlixIPTV pour Windows
# Lancez avec : powershell -ExecutionPolicy Bypass -File build_windows.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   FlixIPTV - Build Script Windows" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Vérifier Flutter
try {
    flutter --version | Out-Null
    Write-Host "[OK] Flutter détecté" -ForegroundColor Green
} catch {
    Write-Host "[ERREUR] Flutter non trouvé. Installez Flutter : https://flutter.dev" -ForegroundColor Red
    exit 1
}

# Activer Windows desktop
Write-Host "`n[1/4] Activation du support Windows..." -ForegroundColor Yellow
flutter config --enable-windows-desktop

# Installer les dépendances
Write-Host "[2/4] Installation des dépendances..." -ForegroundColor Yellow
flutter pub get

# Build
Write-Host "[3/4] Build en cours (peut prendre quelques minutes)..." -ForegroundColor Yellow
flutter build windows --release

# Zipper
Write-Host "[4/4] Création de l'archive..." -ForegroundColor Yellow
$source = "build\windows\x64\runner\Release"
$dest = "flixiptv-windows.zip"

if (Test-Path $dest) { Remove-Item $dest }
Compress-Archive -Path "$source\*" -DestinationPath $dest

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "   Build terminé avec succes !" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "Fichiers :" -ForegroundColor White
Write-Host "  - EXE : $source\flixiptv.exe" -ForegroundColor White
Write-Host "  - ZIP : $dest" -ForegroundColor White
Write-Host "`nPour distribuer, partagez le fichier ZIP." -ForegroundColor Cyan
