# One Piece TCG Collection

A mobile app for One Piece Card Game collectors: track what you own, build
and validate decks, browse the full card catalog, and keep an eye on the
market value of your collection.

> **Status:** early planning / pre-development. No app code exists in this
> repository yet — this README describes the product as it's being scoped.

## Platform

Native mobile:

- **iOS** — Swift
- **Android** — Kotlin

## Planned features

- **Collection tracking** — add and remove cards you own, with quantity,
  condition, and foil/parallel (alt-art, manga, etc.) variant tracked
  separately per card.
- **Deck building** — build decks and validate them against official
  deck-building rules (single leader, color restrictions, 50-card deck,
  card-copy limits).
- **Card database & search** — browse and search the full card catalog by
  set, color, card type, cost, power, and ability text.
- **Price tracking** — track market value of individual cards and your whole
  collection over time, sourced from a card-pricing provider.

## Tech stack

| Layer          | Choice                        |
|----------------|--------------------------------|
| iOS            | Swift, SwiftUI                |
| Android        | Kotlin, Jetpack Compose        |
| Card data      | TBD — evaluating card-database and pricing APIs |
| Backend/sync   | TBD                            |

## Getting started

Not yet available — project scaffolding hasn't been created. This section
will cover build/run instructions for both the iOS and Android clients once
development starts.

## Roadmap

1. Scaffold iOS and Android projects.
2. Integrate a card-database source and seed the local card catalog.
3. Ship collection tracking (v1).
4. Add deck building + deck validation.
5. Add price tracking.
