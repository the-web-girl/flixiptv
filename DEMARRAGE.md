# 🚀 Guide de démarrage rapide — FlixIPTV

## Étape 1 — Installer Flutter

1. Aller sur https://flutter.dev/docs/get-started/install
2. Choisir votre OS (Windows ou macOS)
3. Suivre le guide d'installation
4. Dans un terminal, vérifier : `flutter doctor`
   - Tout doit être ✅ (sauf éventuellement Chrome)

---

## Étape 2 — Cloner et configurer le projet

```bash
# Cloner
git clone https://github.com/VOTRE_USER/flixiptv.git
cd flixiptv

# Installer les dépendances Flutter
flutter pub get
```

---

## Étape 3 — Tester en local (sans build)

### Sur Android (téléphone connecté en USB)
```bash
# Activer le débogage USB sur le téléphone :
# Paramètres → À propos → Appuyer 7x sur N° de build → Options développeur → Débogage USB

flutter devices          # Vérifier que le téléphone est détecté
flutter run              # Lancer l'app
```

### Sur Windows
```bash
flutter run -d windows
```

---

## Étape 4 — Builder un APK Android à distribuer

```bash
flutter build apk --release
```
→ L'APK est dans : `build/app/outputs/flutter-apk/app-release.apk`

**Partager l'APK :**
- Via Google Drive, Dropbox, WeTransfer
- Via GitHub Releases (voir ci-dessous)
- Directement par WhatsApp/Telegram (max 100 MB)

---

## Étape 5 — Builder pour Windows

```bash
# Option 1 : script automatique
powershell -ExecutionPolicy Bypass -File build_windows.ps1

# Option 2 : manuel
flutter config --enable-windows-desktop
flutter build windows --release
```
→ L'EXE est dans : `build/windows/x64/runner/Release/flixiptv.exe`
→ **Important** : distribuer tout le dossier `Release/`, pas seulement le .exe

---

## Étape 6 — Publier sur GitHub Releases

1. Créer un compte GitHub si pas déjà fait
2. Nouveau repository : `flixiptv` (public)
3. Pousser le code :
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git branch -M main
   git remote add origin https://github.com/VOTRE_USER/flixiptv.git
   git push -u origin main
   ```
4. Sur GitHub → onglet **Releases** → **Create a new release**
5. Tag : `v1.0.0`
6. Uploader `app-release.apk` et `flixiptv-windows.zip`
7. Publier → le lien de téléchargement est prêt !

---

## Build automatique via GitHub Actions

Le fichier `.github/workflows/build.yml` est déjà configuré.
À chaque fois que vous créez un tag `v*` sur GitHub, les APK et ZIP
sont automatiquement buildés et attachés à la Release.

```bash
git tag v1.0.1
git push origin v1.0.1
# → GitHub Actions lance le build automatiquement
```

---

## Tester avec la playlist incluse

Dans l'app, onglet **Playlist**, la liste de test est pré-renseignée :
```
https://raw.githubusercontent.com/Rodri200906/IPTV-Rodri/main/IPTV-Rodri.m3u
```
Appuyer sur la carte pour la charger. Les chaînes apparaissent dans les 3 sections.

---

## Problèmes fréquents

| Problème | Solution |
|---|---|
| `flutter doctor` montre des erreurs Android | Installer Android Studio + accepter les licences : `flutter doctor --android-licenses` |
| Le téléphone n'est pas détecté | Vérifier le câble USB et le mode Débogage USB |
| L'APK ne s'installe pas | Activer "Sources inconnues" dans les paramètres Android |
| Un flux ne se lit pas | Utiliser le bouton VLC dans le lecteur |
| `pub get` échoue | Vérifier la connexion internet, relancer |

---

## Structure des fichiers importants

```
flixiptv/
├── lib/
│   ├── main.dart              ← Point d'entrée (modifier le titre ici)
│   ├── theme.dart             ← Couleurs et thème (personnaliser ici)
│   ├── models/media_item.dart ← Structure des données M3U
│   ├── services/m3u_parser.dart ← Logique de parsing
│   ├── providers/iptv_provider.dart ← État global
│   └── screens/
│       ├── home_screen.dart   ← Navigation principale (5 onglets)
│       ├── playlist_screen.dart ← Écran d'ajout de playlist
│       ├── media_list_screen.dart ← Listes chaînes/films/séries
│       ├── player_screen.dart ← Lecteur vidéo + bouton VLC
│       └── favorites_screen.dart ← Favoris
├── pubspec.yaml               ← Dépendances (ne pas modifier sans raison)
├── android/                   ← Config Android
└── .github/workflows/         ← Build automatique CI/CD
```
