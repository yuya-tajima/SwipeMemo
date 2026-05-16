# AGENTS.md

## Project

SwipeMemo is an existing App Store iPhone app built with UIKit, Storyboard, Swift, CocoaPods, and RealmSwift.

Use `SwipeMemo.xcworkspace` for Xcode and CLI builds. Do not build from `SwipeMemo.xcodeproj` directly after running CocoaPods.

## Dependencies

- Run `pod install` after checkout or after changing `Podfile`.
- Keep dependency updates explicit. Do not run `pod update` unless the task asks for a dependency upgrade.
- Do not edit generated files under `Pods/`.
- Commit `Podfile.lock` when CocoaPods metadata changes intentionally.

## Do Not Change Without Explicit Instruction

- Bundle Identifier: `jp.tajima-taso.yuya.tajima.SwipeMemo`
- Signing Team and provisioning settings
- App capabilities and entitlements
- Deployment target
- Product name and app identity
- Realm model and migration behavior
- App Store privacy-related behavior
- Machine-specific absolute paths in committed files

## Xcode Project Rules

- When adding a Swift file, add it to the `SwipeMemo` target membership and Sources build phase.
- Keep Storyboard changes scoped and verify Auto Layout on at least one modern iPhone simulator.
- Do not add external SDKs or capabilities without documenting App Store and privacy impact.

## Release Rules

- This is an existing App Store app. Keep the Bundle Identifier unchanged.
- For release work, update both `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION`.
- Use the current App Store-required Xcode and iOS SDK when archiving for upload.

## Build

List schemes:

```sh
xcodebuild -workspace SwipeMemo.xcworkspace -list
```

Build for simulator:

```sh
xcodebuild \
  -workspace SwipeMemo.xcworkspace \
  -scheme SwipeMemo \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' \
  clean build
```

Archive check:

```sh
xcodebuild archive \
  -workspace SwipeMemo.xcworkspace \
  -scheme SwipeMemo \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath build/SwipeMemo.xcarchive
```

## Done When

- The app builds from `SwipeMemo.xcworkspace`.
- Changed screens are checked in Simulator.
- Memo create, edit, delete, and persistence still work.
- New Swift files are included in the `SwipeMemo` target.
- The final response lists changed files, commands run, and remaining risks.
