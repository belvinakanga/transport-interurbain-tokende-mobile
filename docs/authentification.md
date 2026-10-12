# Démarrage, onboarding et connexion

## Le premier lancement

```
main()
 ├─ Firebase.initializeApp()
 ├─ runApp(TokendeApp) ──▶ SplashScreen
 └─ NotificationService.initialize()

SplashScreen
   ├─ onboarding_vu == true  ──▶ LoginScreen
   └─ sinon ─────────────────▶ OnboardingScreen
```

## Onboarding

`lib/screens/onboarding/onboarding_screen.dart`

Présentation en pages, affichée **une seule fois** : la clé
`onboarding_vu` est posée dans `SharedPreferences` à la fin.

```dart
static const String cleOnboardingVu = 'onboarding_vu';
```

L'écran a été ramené à l'essentiel lors de la refonte : une pastille
orange, **un seul** indicateur de progression, **un seul** bouton. Il y
avait auparavant deux indicateurs et deux boutons concurrents.

Pour le revoir en développement : désinstaller l'application, ou effacer
ses données.

## Connexion

`lib/screens/auth/login_screen.dart`

```http
POST /api/login
{ "email": "…", "password": "…" }
```

Le jeton renvoyé est rangé dans **`flutter_secure_storage`** sous la clé
`auth_token` — chiffré par le système, pas dans les préférences en clair.

Les champs de profil (`user_name`, `user_email`, `user_id`, `user_role`)
sont conservés à côté pour éviter un appel réseau à chaque ouverture
d'écran.

> **Les écrans de connexion et d'inscription sont hors du périmètre de la
> refonte visuelle.** `login_screen.dart` a été restauré depuis git ; seul
> le branchement de la récupération de mot de passe (`_forgotPassword()` et
> un import) y a été ajouté ensuite.

## Inscription

`lib/screens/auth/register_screen.dart` → `POST /api/register`.

## Mot de passe oublié

Voir [mot-de-passe-oublie.md](mot-de-passe-oublie.md).

## Utiliser le jeton

```dart
final storage = const FlutterSecureStorage();
final token = await storage.read(key: 'auth_token');

headers: {
  'Authorization': 'Bearer $token',
  'Accept': 'application/json',
}
```

## Déconnexion

`POST /api/logout` révoque le jeton côté serveur, puis le stockage local
est vidé.

> Un changement de mot de passe révoque **tous** les jetons de
> l'utilisateur : il est déconnecté de tous ses appareils.

## Notifications

`NotificationService.initialize()` s'abonne à Firebase Messaging au
démarrage. `lib/firebase_options.dart` est généré par FlutterFire — le
régénérer avec `flutterfire configure` en cas de changement de projet.
