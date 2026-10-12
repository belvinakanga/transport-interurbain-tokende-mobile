# Installation et lancement

## Ce qu'il faut avoir

| Outil | Version du poste de référence | Contrainte |
|---|---|---|
| Flutter | 3.47.7 (stable) | — |
| Dart | 3.13.5 | SDK `^3.11.0` |

Plateformes présentes : **android**, **ios**, **web**.

### Installer Flutter

Le poste de référence utilise une installation manuelle dans
`~/development/flutter`, avec le PATH ajouté en tête de `~/.zshrc`.

```bash
export PATH="$HOME/development/flutter/bin:$PATH"
flutter --version
flutter doctor
```

> Si Flutter a aussi été installé par snap, les deux cohabitent et c'est
> celui du PATH qui gagne. `sudo snap remove flutter` libère environ 3,4 Go.

## Installer les dépendances

```bash
flutter pub get
```

## Lancer

```bash
flutter devices              # appareils disponibles
flutter run                  # appareil par défaut
flutter run -d chrome        # dans le navigateur
flutter run -d emulator-5554 # émulateur Android
```

**Le backend doit tourner en parallèle :**

```bash
cd ../transport-interurbain-backend
php artisan serve
```

## Adresse de l'API

`lib/config/app_config.dart` choisit selon la plateforme :

| Plateforme | Adresse |
|---|---|
| Web (Chrome) | `http://127.0.0.1:8000/api` |
| Émulateur Android | `http://10.0.2.2:8000/api` |

`10.0.2.2` est l'adresse par laquelle l'émulateur Android joint la machine
hôte ; `127.0.0.1` y désignerait l'émulateur lui-même.

### Appareil physique

Ni l'une ni l'autre ne convient : il faut l'adresse de la machine sur le
réseau local.

```dart
// lib/config/app_config.dart
return "http://192.168.1.X:8000/api";
```

Et lancer Laravel en écoutant sur toutes les interfaces :

```bash
php artisan serve --host=0.0.0.0
```

## Vérifier le code

```bash
flutter analyze lib
```

État actuel : **0 erreur**, une vingtaine d'avertissements, tous recensés
dans [etat-des-lieux.md](etat-des-lieux.md).

## Compiler

```bash
flutter build apk --release
flutter build appbundle --release      # pour le Play Store
flutter build web --release
```

## Relire l'application dans un navigateur

Le mode web sert à relire l'interface sans émulateur. Un piège : le
**service worker** de Flutter sert indéfiniment l'ancienne version, quels
que soient les en-têtes.

```bash
flutter build web --release --pwa-strategy=none
```

`--pwa-strategy=none` empêche la génération du service worker. Si un
service worker a déjà été enregistré par une visite précédente, il faut le
désinscrire depuis les outils de développement du navigateur (Application →
Service Workers → Unregister), puis vider le cache.

## Firebase

`lib/firebase_options.dart` est généré par FlutterFire. L'application
initialise Firebase au démarrage et s'abonne aux notifications
(`NotificationService`).

```dart
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
```

Changer de projet Firebase impose de régénérer ce fichier :

```bash
flutterfire configure
```

## Dépendances

| Paquet | Rôle |
|---|---|
| `http` | appels API |
| `provider` | état partagé |
| `shared_preferences` | préférences locales |
| `flutter_secure_storage` | **jeton d'authentification** |
| `intl` | dates et nombres |
| `google_fonts` | typographie |
| `flutter_svg` | images vectorielles |
| `qr_flutter` | QR code à l'écran |
| `url_launcher` | ouvrir liens, téléphone, e-mail |
| `firebase_core`, `firebase_messaging` | notifications |
| `printing`, `pdf` | billet imprimable |

## Ressources

```yaml
assets:
  - assets/images/logo_tokende_old.png
  - assets/images/transparent-logo.png
  - assets/images/onboarding/
  - assets/images/tokende_bus_login.jpg
```

> `logo_tokende_old.png` n'est plus utilisé. Voir
> [etat-des-lieux.md](etat-des-lieux.md).
