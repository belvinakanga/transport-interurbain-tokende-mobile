# Catalogue des écrans

Quinze écrans ont été refondus visuellement. Les méthodes de logique ont été
conservées à l'identique — **97 d'entre elles vérifiées par comparaison de
hachage SHA-256** avant et après refonte.

## Démarrage

| Écran | Fichier | Rôle |
|---|---|---|
| Splash | `splash/splash_screen.dart` | logo, puis aiguillage |
| Onboarding | `onboarding/onboarding_screen.dart` | présentation en pages |

L'onboarding a été ramené à l'essentiel : une pastille orange, **un seul**
indicateur de progression, **un seul** bouton. La clé `onboarding_vu` le
fait disparaître définitivement.

## Authentification

| Écran | Fichier |
|---|---|
| Connexion | `auth/login_screen.dart` |
| Inscription | `auth/register_screen.dart` |
| Mot de passe oublié | `auth/forgot_password.dart` |
| Nouveau mot de passe | `auth/reset_password_screen.dart` |

> Les écrans de connexion et d'inscription sont **hors du périmètre de la
> refonte visuelle**. `login_screen.dart` a été restauré depuis git ; seul
> le branchement de la récupération de mot de passe y a été ajouté.

> `auth/otp_screen.dart` appartenait à l'ancien parcours par SMS. Il n'est
> plus appelé : code mort.

## Accueil et recherche

| Écran | Fichier | Rôle |
|---|---|---|
| Accueil | `home/home_screen.dart` | tableau de bord + conteneur des onglets |
| Carte de recherche | `home/widgets/home_search_card.dart` | départ, arrivée, date |
| Prochain départ | `home/widgets/tk_next_trip_card.dart` | rappel du voyage à venir |
| Résultats | `search/search_results_screen.dart` | trajets trouvés |
| Détails trajet | `search/trip_details_screen.dart` | horaires, prix, agence |

Le raccourci « Support » a été renommé **« Assistance »** et ouvre
`HelpSupportScreen`.

## Réservation

| Écran | Fichier |
|---|---|
| Sélection des sièges | `booking/seat_selection_screen.dart` |
| Informations voyageurs | `booking/passenger_information_screen.dart` |
| Récapitulatif | `booking/booking_summary_screen.dart` |
| Paiement | `booking/payment_screen.dart` |

Détails dans [parcours-reservation.md](parcours-reservation.md).

## Mes voyages

`voyages/mes_voyages_screen.dart` — 1997 lignes, le plus gros fichier.

Deux sous-onglets : **Réservations** et **Achats**. Chaque ligne affiche un
`TkChip.statut()` et, pour un voyage honoré, les boutons « Voir mon
billet » et « Donner mon avis ».

Un statut `Confirmée` est traité comme payé (`estHonoree`), au même titre
que `payée`.

## Profil

| Écran | Fichier |
|---|---|
| Profil | `profile/profile_screen.dart` |
| Informations personnelles | `profile/personal_information_screen.dart` |
| Paramètres | `profile/settings_screen.dart` |
| Aide et assistance | `profile/help_support_screen.dart` |

`settings_screen.dart` contient sept classes. Son `_changePassword` est
**encore un bouchon** : « sera connectée à Laravel prochainement ».

## Avis

`avis/avis_screen.dart` — noter un voyage effectué, consulter les avis.

## Support

| Écran | Fichier |
|---|---|
| Liste des conversations | `support/support_screen.dart` |
| Fil d'une conversation | `support/conversation_screen.dart` |
| Nouvelle conversation | `support/nouvelle_conversation_screen.dart` |

## Volume

Environ **22 500 lignes avant refonte, 18 000 après** — à fonctionnalités
égales, plus deux fonctionnalités ajoutées (récupération de mot de passe,
billet imprimable).
