# Dépannage

## L'application n'atteint pas le serveur

### Le backend tourne-t-il ?

```bash
curl -s -o /dev/null -w "%{http_code}\n" http://127.0.0.1:8000/api/trajets
```

`200` attendu. Sinon :

```bash
cd ../transport-interurbain-backend
php artisan serve
```

### La bonne adresse selon la cible

| Cible | Adresse |
|---|---|
| Chrome / web | `127.0.0.1:8000` |
| Émulateur Android | `10.0.2.2:8000` |
| Appareil physique | l'IP de la machine sur le réseau local |

`10.0.2.2` est l'adresse par laquelle l'émulateur joint la machine hôte ;
`127.0.0.1` y désignerait l'émulateur lui-même.

Pour un appareil physique, lancer Laravel sur toutes les interfaces :

```bash
php artisan serve --host=0.0.0.0
```

### Un seul écran échoue, les autres marchent

C'est le symptôme typique d'une **adresse codée en dur**. Une dizaine
d'écrans redéfinissent l'adresse au lieu d'utiliser `AppConfig` :

```bash
grep -rn "http://" lib --include='*.dart' | grep -v firebase_options
```

Le cas le plus courant : le support, qui pointe sur `192.168.1.84:8000`,
une adresse morte. Voir [etat-des-lieux.md](etat-des-lieux.md).

---

## Le navigateur sert une vieille version

Le **service worker** de Flutter sert indéfiniment la version qu'il a mise
en cache, quels que soient les en-têtes envoyés.

```bash
flutter build web --release --pwa-strategy=none
```

Si un service worker est déjà enregistré : outils de développement →
Application → Service Workers → **Unregister**, puis vider le cache et
recharger.

Changer de port ne suffit pas toujours — un service worker reste attaché à
son origine.

---

## Les heures affichent `--:--`

La colonne d'arrivée s'appelle **`heure_fin`** côté serveur, pas
`heure_arrivee`.

Utiliser `FormatTrajet`, qui lit d'abord les champs déjà mis en forme par
le serveur :

```dart
FormatTrajet.heureDepart(trajet);   // 08h00
FormatTrajet.heureArrivee(trajet);  // 12h30
FormatTrajet.duree(trajet);         // 4 h 30
FormatTrajet.dateEtHeure(trajet);   // 20 octobre 2026 · 08h00
```

Ces fonctions renvoient **`null` quand la donnée manque**, pour que l'écran
masque la ligne au lieu d'afficher un tiret.

---

## Une puce de statut reste grise

Le statut n'est pas reconnu. Utiliser `TkChip.statut()`, qui normalise la
casse :

```dart
TkChip.statut(reservation['statut'])
```

Valeurs reconnues : `payée`, `confirmée`, `en attente`, `pending`,
`annulée`, `échoué`, `failed`. Pour une valeur nouvelle, l'ajouter au
`switch` de `lib/widgets/tk/tk_chip.dart`.

---

## Un trajet n'apparaît pas dans la recherche

`GET /api/trajets` **masque les trajets des agences suspendues**. Vérifier
côté backend :

```bash
cd ../transport-interurbain-backend
php artisan tinker --execute='foreach (\App\Models\Agence::all() as $a)
  echo $a->nom_agence . " actif=" . var_export($a->actif, true) . PHP_EOL;'
```

---

## Le QR code du billet ne mène nulle part

`billets.qr_code` vaut `NULL` en base : le QR encode une adresse sans
identifiant.

**Rien à corriger côté Flutter** — la génération doit être réparée côté
Laravel. Voir [billets.md](billets.md).

---

## Le mode sombre ne s'active pas

C'est attendu : `main.dart` ne fournit **aucun `darkTheme`**. Toute la
palette sombre est écrite mais inatteignable. Voir
[etat-des-lieux.md](etat-des-lieux.md).

---

## Le code de réinitialisation n'arrive pas

`MAIL_MAILER=log` côté serveur : aucun e-mail ne part.

```bash
cd ../transport-interurbain-backend
grep -oE "[0-9]{6}" storage/logs/laravel.log | tail -1
```

---

## Après un changement de dépendances

```bash
flutter clean
flutter pub get
```

## Vérifier l'état du code

```bash
flutter analyze lib      # attendu : 0 erreur, 23 avertissements
flutter doctor
```
