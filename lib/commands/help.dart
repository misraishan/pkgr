import 'package:mason_logger/mason_logger.dart';
import 'package:args/args.dart';

void showHelp(Logger logger, ArgParser parser) {
  logger.info('''
${lightMagenta.wrap('PKGR')}
${lightGray.wrap('=====================')}

Usage: pkgr <command> [options]

Available commands:
  build       Build a package for the Mac App Store
  list-identities  List available signing identities

Options:
  --app-name      Name of your Flutter build (i.e. YourAppName)
  --identity      Developer identity for signing (i.e. "Developer ID Application: Your Name (Your Team ID)")
  --provision-profile  Path to provision profile file (i.e. "macos/Runner.provisionprofile")
  --entitlements    Path to entitlements file (i.e. "Entitlements.plist")
  --output          Output directory for the pkg file (i.e. "./build/macos/Build/Products/Release")

  --help          Show this help message
  --no-interactive   Run in non-interactive mode
''');
}
