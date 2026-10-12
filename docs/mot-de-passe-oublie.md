# Mot de passe oublié

Parcours en trois écrans. L'utilisateur reçoit un code à 6 chiffres par
e-mail.

```
Connexion
   │  « Mot de passe oublié ? »
   ▼
forgot_password.dart          saisie de l'adresse e-mail
   │  POST /api/forgot-password
   ▼
reset_password_screen.dart    code + nouveau mot de passe
   │  POST /api/verify-reset-code
   │  POST /api/reset-password
   ▼
Connexion
```

## Les écrans

| Fichier | Rôle |
|---|---|
| `auth/forgot_password.dart` | demande du code |
| `auth/reset_password_screen.dart` | vérification et changement |

`forgot_password.dart` a été **réécrit** : il demandait un numéro de
téléphone, il demande désormais une adresse e-mail, puisque c'est par
e-mail que le code part.

## Le service

`lib/services/password_reset_service.dart` — les trois appels, délai de
20 secondes.

```dart
await PasswordResetService.demanderCode(email);
await PasswordResetService.verifierCode(email, code);
await PasswordResetService.reinitialiser(
  email: email,
  code: code,
  motDePasse: nouveau,
);
```

Les erreurs du serveur remontent via `PasswordResetException`, dont le
message est affiché tel quel :

```dart
try {
  await PasswordResetService.demanderCode(email);
  TkToast.succes(context, 'Code envoyé par e-mail');
} on PasswordResetException catch (e) {
  TkToast.erreur(context, e.message);
}
```

## Les règles côté serveur

| Règle | Valeur |
|---|---|
| Validité du code | 15 minutes |
| Usage | unique |
| Stockage | haché |
| Envois | 5 par heure et par adresse |
| Tentatives | 10 par heure et par adresse |

À la réussite, **tous les jetons Sanctum sont révoqués** : l'utilisateur
est déconnecté partout.

Les réponses sont **identiques qu'un compte existe ou non** : l'écran ne
permet pas de découvrir qui est inscrit.

## En développement : retrouver le code

`MAIL_MAILER=log` côté serveur, donc **aucun e-mail ne part**. Le code est
dans le journal Laravel :

```bash
cd ../transport-interurbain-backend
grep -oE "[0-9]{6}" storage/logs/laravel.log | tail -1
```

## Code mort

`auth/otp_screen.dart` appartenait à l'ancien parcours par SMS. **Il n'est
plus appelé par aucun écran.**
