# PKGR

PKGR is a command-line tool that helps you package your Flutter app into a single pkg binary for Mac App Store deployment. It automates the process of signing and packaging your app, making it easier to prepare for App Store submission.

## Installation

Add `pkgr` to your project as a dependency:

```yaml
dependencies:
  pkgr:
    git:
      url: https://github.com/misraishan/pkgr
      ref: main
```

## Usage

### List Available Signing Identities

To see all available signing identities in your keychain:

```bash
pkgr list-identities
```

### Build and Package Your App

To package your Flutter app:

```bash
pkgr build
```

## Example

Here's a complete example for packaging a Flutter app named "MyApp":

TODO: Add example

## Requirements

- macOS
- Flutter SDK
- Apple Developer Account
- Valid signing certificates through [Apple Developer Portal](https://developer.apple.com/account/resources/certificates/list)

## Development

To contribute to PKGR:

1. Clone the repository
2. Install dependencies: `dart pub get`
3. Run tests: `dart test` (I should make tests...)

## License

MIT License
