import 'dart:io';

import 'package:args/args.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:pkgr/commands/build_manager.dart';
import 'package:pkgr/commands/help.dart';
import 'package:pkgr/commands/identity_manager.dart';

void main(List<String> arguments) async {
  final logger = Logger();
  final parser = ArgParser()
    ..addFlag('help',
        help: 'Show this help message', negatable: false, abbr: 'h')
    ..addFlag('no-interactive',
        help: 'Run in non-interactive mode', negatable: false, abbr: 'i');

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
    ..addOption('provision-profile',
        help:
            'Path to provision profile file (i.e. "macos/Runner.provisionprofile")',
        mandatory: true,
        valueHelp: 'provision-profile')
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
        help: 'Show this help message', negatable: false, abbr: 'h')
    ..addFlag('no-interactive',
        help: 'Run in non-interactive mode', negatable: false, abbr: 'i');

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
      showHelp(logger, parser);
      exit(0);
    }

    final command = results.command?.name;

    if (command == null) {
      logger.err('Please specify a command. Available commands:');
      exit(1);
    }

    switch (command) {
      case 'build':
        // If help
        if (results.command!['help']) {
          showHelp(logger, buildParser);
          exit(0);
        }

        final isNonInteractive = results['no-interactive'] as bool ||
            results.command!['no-interactive'] as bool;

        if (isNonInteractive) {
          logger.info('Not implemented yet');
        } else {
          await BuildManager().interactiveBuilder();
        }
        break;
      case 'list-identities':
        // If help
        if (results.command!['help']) {
          showHelp(logger, listIdentitiesParser);
          exit(0);
        }

        final progress = logger.progress('Fetching signing identities...\n');
        await IdentityManager().getSigningIdentities();
        progress.complete('Identities listed successfully!');
        break;
      default:
        logger.err('Unknown command: $command');
        exit(1);
    }
  } catch (e) {
    logger.err('Error: $e');
    exit(1);
  }
}
