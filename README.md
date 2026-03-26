# 📺 FlixIPTV

Application IPTV open-source pour Android et Windows, construite avec Flutter.

## ✨ Fonctionnalités

- 📡 **3 sections distinctes** : Chaînes Live, Films, Séries — détection automatique
- 🔍 **Recherche** en temps réel dans chaque section
- 🗂️ **Filtrage par groupe/catégorie**
- ❤️ **Favoris** persistants entre les sessions
- 🎬 **Lecteur intégré** (media_kit / libmpv)
- 🔄 **Fallback VLC** : si le lecteur intégré échoue, ouvre dans VLC en 1 clic
- 📋 **Copy URL** : copie l'URL du flux dans le presse-papier
- 💾 **Sauvegarde automatique** de la dernière playlist
- 🌐 **Compatible** Android 5+ et Windows 10+

---

## 🚀 Installation rapide (utilisateur)

### Android
1. Télécharger le fichier `flixiptv.apk` depuis la section [Releases](../../releases)
2. Sur votre téléphone : **Paramètres → Sécurité → Sources inconnues → Activer**
3. Ouvrir le fichier APK et installer
4. Lancer **FlixIPTV** et entrer l'URL de votre playlist M3U

### Windows
1. Télécharger `flixiptv-windows.zip` depuis [Releases](../../releases)
2. Extraire le ZIP
3. Lancer `flixiptv.exe`

---

## 🛠️ Build depuis les sources (développeur)

### Prérequis
- [Flutter SDK](https://flutter.dev/docs/get-started/install) ≥ 3.0
- Android Studio + Android SDK (pour Android)
- Visual Studio 2022 avec "Desktop development with C++" (pour Windows)
- Git

### Installation

```bash
# Cloner le projet
git clone https://github.com/VOTRE_USER/flixiptv.git
cd flixiptv

# Installer les dépendances
flutter pub get

# Vérifier l'environnement
flutter doctor
```

### Build Android (APK)

```bash
# APK de debug (test rapide)
flutter build apk --debug

# APK de release (à distribuer)
flutter build apk --release

# L'APK se trouve dans :
# build/app/outputs/flutter-apk/app-release.apk
```

### Build Windows

```bash
# Activer le support Windows si pas déjà fait
flutter config --enable-windows-desktop

# Build
flutter build windows --release

# L'exécutable se trouve dans :
# build/windows/x64/runner/Release/
```

### Lancer en développement

```bash
# Sur appareil Android connecté
flutter run

# Sur Windows
flutter run -d windows
```

---

## 📁 Structure du projet

```
lib/
├── main.dart                  # Point d'entrée
├── theme.dart                 # Thème et couleurs
├── models/
│   └── media_item.dart        # Modèle de données M3U
├── providers/
│   └── iptv_provider.dart     # State management
├── services/
│   └── m3u_parser.dart        # Parser M3U
├── screens/
│   ├── home_screen.dart       # Navigation principale
│   ├── playlist_screen.dart   # Gestion des playlists
│   ├── media_list_screen.dart # Liste chaînes/films/séries
│   ├── player_screen.dart     # Lecteur vidéo
│   └── favorites_screen.dart  # Favoris
└── widgets/
    └── media_card.dart        # Carte média réutilisable
```

---

## 🧪 Playlist de test

Pour tester l'application, utilisez cette playlist gratuite et légale :

```
https://raw.githubusercontent.com/Rodri200906/IPTV-Rodri/main/IPTV-Rodri.m3u
```

Contient des chaînes gratuites de France, Portugal, Brésil, etc.

---

## 🎬 Option VLC

Si le lecteur intégré ne lit pas un flux correctement :
1. Appuyer sur le bouton **VLC** en haut à droite du lecteur
2. L'app ouvre automatiquement VLC avec le flux
3. Si VLC n'est pas installé, l'URL est copiée dans le presse-papier

---

## 📦 Distribuer via GitHub Releases

1. Créez un repository GitHub
2. Buildez les APK/EXE comme indiqué ci-dessus
3. Allez sur GitHub → **Releases → Create a new release**
4. Uploadez les fichiers : `app-release.apk` et le zip Windows
5. Partagez le lien de la release

---

## ⚠️ Avertissement légal

FlixIPTV est un **lecteur M3U** — il ne fournit aucun contenu.
Utilisez uniquement des listes M3U de chaînes que vous êtes autorisé à regarder.
Le respect du droit d'auteur est de la responsabilité de l'utilisateur.

---

## 📄 Licence

MIT — libre d'utilisation, modification et distribution.
