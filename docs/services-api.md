# Appels réseau

## Pas de client centralisé

Chaque écran et chaque service appelle `http` directement et relit le jeton
depuis le stockage sécurisé :

```dart
final storage = const FlutterSecureStorage();
final token = await storage.read(key: 'auth_token');

final reponse = await http.get(
  Uri.parse('${AppConfig.baseUrl}/reservations'),
  headers: {
    'Authorization': 'Bearer $token',
    'Accept': 'application/json',
  },
);
```

C'est répétitif, et la gestion d'erreur varie d'un écran à l'autre. Un
client unique serait le premier refactor utile.

## Les services existants

### `VillesService`

Référentiel de villes partagé avec le back-office.

```dart
final villes = await VillesService.charger();
VillesService.viderCache();
```

Cache en mémoire, **repli sur une liste locale** si l'API est injoignable :
le formulaire de recherche reste utilisable hors ligne.

### `TarifService`

Frais de service par billet, lus sur `GET /api/tarification`.

```dart
await TarifService.charger();        // 100.0
TarifService.fraisParBillet;         // dernière valeur connue, sans réseau
```

Cache en mémoire, repli à 100 si l'API est injoignable. Lire le tarif
plutôt que l'écrire en dur évite que l'écran annonce un total différent de
celui qui sera débité.

### `PasswordResetService`

Les trois appels du mot de passe oublié. Délai de 20 secondes.
`PasswordResetException` porte les messages du serveur jusqu'à l'écran.

Voir [mot-de-passe-oublie.md](mot-de-passe-oublie.md).

### `ProchainVoyageService`

Alimente la carte « prochain départ » de l'accueil. Le modèle
`ProchainVoyage` sait extraire, d'une réponse de réservation, le premier
billet, les noms des voyageurs et les numéros de sièges — logique
d'extraction regroupée là plutôt que dupliquée dans les écrans.

### `SupportService`

Conversations avec l'administration.

Utilise `AppConfig.baseUrl`. Elle pointait auparavant sur
`http://192.168.1.84:8000/api`, une adresse de réseau local devenue morte :
le support ne répondait plus alors que tout le reste fonctionnait.

### `NotificationService`

Firebase : autorisation, jeton push, réception des alertes. Déclare
l'appareil au serveur après la connexion, l'oublie à la déconnexion.

`NotificationService.compteurNonLues` est un `ValueNotifier` : la pastille
de la cloche le suit et bouge sans recharger l'écran.

### `NotificationsService`

Lit les notifications **du serveur**, pas de Firebase. Une alerte push peut
ne jamais arriver ; la notification, elle, reste consultable.

```dart
await NotificationsService.charger();        // la liste
await NotificationsService.compterNonLues(); // la pastille
await NotificationsService.marquerLue(id);
```

Détail complet dans `docs/notifications.md` du dépôt backend.

### `ApiService`

Ne contient qu'une méthode, `getTrajets()`. Vestige d'une tentative de
centralisation abandonnée.

### `BilletPdf`

Pas un service réseau : génère le PDF du billet. Voir
[billets.md](billets.md).

## Fichiers vides

Trois fichiers de `services/` font **0 ligne** :

- `auth_service.dart`
- `reservation_service.dart`

Ainsi que `config/app_routes.dart` et, dans `screens/home/widgets/` :
`bottom_nav_bar.dart`, `popular_trip_card.dart`, `promo_banner.dart`.

Ce sont des intentions jamais réalisées. À supprimer.

## Adresses codées en dur

`AppConfig` existe, mais **la plupart des écrans redéfinissent l'adresse
chez eux** :

| Fichier | Adresse |
|---|---|
| `services/api_service.dart` | `127.0.0.1:8000` |
| `services/support_service.dart` | **`192.168.1.84:8000`** (morte) |
| `screens/booking/payment_screen.dart` | duplique la logique de plateforme |
| `screens/booking/booking_summary_screen.dart` | idem |
| `screens/booking/seat_selection_screen.dart` | `127.0.0.1:8000` |
| `screens/voyages/mes_voyages_screen.dart` | `127.0.0.1:8000` |
| `screens/auth/register_screen.dart` | `127.0.0.1:8000` |
| `screens/avis/avis_screen.dart` | `127.0.0.1:8000` |
| `screens/profile/personal_information_screen.dart` | duplique |
| `screens/home/home_screen.dart` | duplique |

Seuls `prochain_voyage_service`, `villes_service`,
`password_reset_service`, `mes_voyages_screen`, `home_screen` et
`login_screen` utilisent `AppConfig`.

**Conséquence pratique :** changer d'adresse de serveur impose de modifier
une dizaine de fichiers, et un oubli donne un écran qui échoue seul. Les
écrans en `127.0.0.1` ne fonctionnent pas sur émulateur Android, qui exige
`10.0.2.2`.

## Stockage

| Clé | Mécanisme | Contenu |
|---|---|---|
| `auth_token` | `flutter_secure_storage` | jeton Sanctum |
| `user_name`, `user_email`, `user_id`, `user_role` | `flutter_secure_storage` | profil |
| `onboarding_vu` | `SharedPreferences` | onboarding déjà affiché |
| `dark_mode` | `SharedPreferences` | **inutilisé** |

Le jeton est bien dans le stockage **chiffré par le système**, pas dans les
préférences en clair.
