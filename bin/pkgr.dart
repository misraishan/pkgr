import 'package:args/args.dart';
import 'package:pkgr/pkgr.dart';
import 'dart:io';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag('help',
        help: 'Show this help message', negatable: false, abbr: 'h');

  // Build command
  final buildParser = ArgParser()
    ..addOption('app-name',
        help: 'Name of your Flutter build (i.e. YourAppName)',
        mandatory: true,
        valueHelp: 'app-name')
    ..addOption('identity',
        help:
            'Developer identity for signing (i.e. "Developer ID Application: Your Name (Your Team ID)")',
        mandatory: true,
        valueHelp: 'identity')
    ..addOption('entitlements',
        help: 'Path to entitlements file (i.e. "Entitlements.plist")',
        mandatory: true,
        valueHelp: 'entitlements')
    ..addOption('output',
        help:
            'Output directory for the pkg file (i.e. "./build/macos/Build/Products/Release")',
        defaultsTo: './build/macos/Build/Products/Release',
        valueHelp: 'output')
    ..addFlag('help',
        help: 'Show this help message', negatable: false, abbr: 'h');

  // List identities command
  final listIdentitiesParser = ArgParser()
    ..addFlag('help',
        help: 'Show this help message', negatable: false, abbr: 'h');

  parser.addCommand('build', buildParser);
  parser.addCommand('list-identities', listIdentitiesParser);

  try {
    final results = parser.parse(arguments);

    // Handle root-level help flag
    if (results['help'] as bool) {
      print('PKGR - A tool to package your Flutter app for Mac App Store\n');
      print(parser.usage);
      exit(0);
    }

    final command = results.command?.name;

    if (command == null) {
      print('Please specify a command. Available commands:');
      print(parser.usage);
      exit(1);
    }

    final pkgr = Pkgr();

    switch (command) {
      case 'build':
        // If help
        if (results.command!['help']) {
          print('Build a Flutter app package for Mac App Store:\n');
          print(buildParser.usage);
          exit(0);
        }

        await pkgr.buildPackage(
          appName: results.command!['app-name'],
          identity: results.command!['identity'],
          entitlements: results.command!['entitlements'],
          output: results.command!['output'],
        );
        break;
      case 'list-identities':
        // If help
        if (results.command!['help']) {
          print('List available signing identities:\n');
          print(listIdentitiesParser.usage);
          exit(0);
        }

        await pkgr.listIdentities();
        break;
      default:
        print('Unknown command: $command');
        print(parser.usage);
        exit(1);
    }
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}
