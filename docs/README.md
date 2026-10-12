# Documentation — Tokende mobile

Application Flutter destinée aux voyageurs : recherche de trajets, choix
des sièges, paiement mobile money, billet avec QR code.

Elle consomme l'API du dépôt `transport-interurbain-backend`.

## Par où commencer

| Vous voulez… | Document |
|---|---|
| installer et lancer | [installation.md](installation.md) |
| comprendre l'organisation | [architecture.md](architecture.md) |
| reprendre le visuel | [stylisation.md](stylisation.md) |
| réutiliser les composants | [composants-tk.md](composants-tk.md) |

## Fonctionnalités

| Sujet | Document |
|---|---|
| Démarrage, onboarding, connexion | [authentification.md](authentification.md) |
| Mot de passe oublié | [mot-de-passe-oublie.md](mot-de-passe-oublie.md) |
| Navigation entre les écrans | [navigation.md](navigation.md) |
| Catalogue des écrans | [ecrans.md](ecrans.md) |
| Réserver un voyage | [parcours-reservation.md](parcours-reservation.md) |
| Billet, QR code, impression | [billets.md](billets.md) |
| Appels réseau | [services-api.md](services-api.md) |

## Transversal

| Sujet | Document |
|---|---|
| Dettes, code mort, limites | [etat-des-lieux.md](etat-des-lieux.md) |
| Pannes courantes | [depannage.md](depannage.md) |

## Le dépôt backend

L'API Laravel vit dans `transport-interurbain-backend`, avec sa propre
documentation dans `docs/`. Le contrat entre les deux y est décrit dans
`docs/api.md`.

---

Documentation rédigée le 12 octobre 2026 à partir du code tel qu'il existe.
Ce qui ne fonctionne pas est écrit comme tel.
