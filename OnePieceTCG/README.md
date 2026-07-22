# OnePieceTCG

SwiftUI iOS app (iOS 17+) for logging a One Piece TCG collection. This ticket
only scaffolds the project shell — no data/persistence yet (see #3).

## Structure

- `project.yml` — [XcodeGen](https://github.com/yonaskolb/XcodeGen) spec; the
  source of truth for the project. `OnePieceTCG.xcodeproj` is generated from
  it and committed so the project builds without XcodeGen installed.
- `OnePieceTCG/` — app sources (`App/`, `Views/`, `Assets.xcassets`).
- `OnePieceTCGTests/` — unit test target.

If you change `project.yml`, regenerate the project:

```bash
brew install xcodegen   # once
cd OnePieceTCG
xcodegen generate
```

## Build & run

```bash
open OnePieceTCG.xcodeproj   # then Cmd+R in Xcode, or:
xcodebuild -project OnePieceTCG.xcodeproj -scheme OnePieceTCG \
  -destination 'platform=iOS Simulator,name=iPhone 17' build
```

## Test

```bash
xcodebuild -project OnePieceTCG.xcodeproj -scheme OnePieceTCG \
  -destination 'platform=iOS Simulator,name=iPhone 17' test
```

## What's here

A tab-based navigation shell with 4 placeholder tabs: Browse, Collection,
Stats, Settings. App icon and launch screen are minimal placeholders to be
refined later.
