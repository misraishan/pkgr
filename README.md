# PKGR

PKGR is a command-line tool that helps you package your Flutter app into a single pkg binary for Mac App Store deployment. It automates the process of signing and packaging your app, making it easier to prepare for App Store submission.

## Installation

```bash
dart pub global activate pkgr
```

## Usage

### List Available Signing Identities

To see all available signing identities in your keychain:

```bash
pkgr list-identities
```

### Build and Package Your App

To build and package your Flutter app:

```bash
pkgr build \
  --app-name YourAppName \
  --identity "3rd Party Mac Developer Application: Your Name (TEAM_ID)" \
  --entitlements path/to/entitlements.plist \
  --output ./dist
```

#### Parameters

- `--app-name`: The name of your Flutter app (required)
- `--identity`: Your developer identity for signing (required)
- `--entitlements`: Path to your entitlements file (required)
- `--output`: Output directory for the pkg file (defaults to current directory)

## Example

Here's a complete example for packaging a Flutter app named "MyApp":

```bash
# First, list available identities
pkgr list-identities

# Then build the package
pkgr build \
  --app-name MyApp \
  --identity "3rd Party Mac Developer Application: John Doe (ABCD1234)" \
  --entitlements macos/Runner/Release.entitlements \
  --output ./dist
```

## Requirements

- macOS
- Flutter SDK
- Apple Developer Account
- Valid signing certificates in your keychain

## Development

To contribute to PKGR:

1. Clone the repository
2. Install dependencies: `dart pub get`
3. Run tests: `dart test`
4. Build the package: `dart pub build`

## License

MIT License
