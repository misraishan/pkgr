import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;
import 'package:pkgr/commands/identity_manager.dart';
import 'package:pkgr/utils/identity.dart';
import 'package:pkgr/utils/run_command.dart';
import 'package:prompts/prompts.dart' as prompts;

/// A class to handle the packaging and signing of Flutter apps for Mac App Store.
class BuildManager {
  final _logger = Logger();
  final identityManager = IdentityManager();

  /// Signs and packages a Flutter app for Mac App Store submission.
  Future<void> buildPackage({
    required String appName,
    required Identity applicationIdentity,
    required Identity installerIdentity,
    required String entitlements,
    required String provisionProfile,
    String output = '.',
    String basePath = 'build/macos/Build/Products/Release',
  }) async {
    _logger.info('Building $appName...');

    // Step 0: Copy the provision profile to the app
    final embeddedProvisionProfile =
        '$basePath/$appName.app/Contents/embedded.provisionprofile';
    File(embeddedProvisionProfile).createSync(recursive: true);
    File(provisionProfile).copySync(embeddedProvisionProfile);

    // Step 1: Sign the app bundle
    final signAppCmd =
        'codesign --deep --force --sign "${applicationIdentity.id}" $basePath/$appName.app';
    await runCommand(signAppCmd);

    // Step 2: Sign with entitlements
    final signEntitlementsCmd =
        'codesign --force --deep --sign "${applicationIdentity.id}" '
        '--entitlements $entitlements --options runtime --prefix app.$appName $basePath/$appName.app/';
    await runCommand(signEntitlementsCmd);

    // Step 3: Create pkg
    final pkgCmd =
        'productbuild --component $basePath/$appName.app /Applications '
        '--sign "${installerIdentity.id}" ${path.join(output, '$appName.pkg')}';
    await runCommand(pkgCmd);

    _logger.success('Build completed successfully!');
  }

  Future<void> interactiveBuilder() async {
    _logger.info("Let's build your Flutter app package step by step.");

    // Make sure it's root of a Flutter project
    final currentDir = Directory.current.path;
    final isFlutterProject = await File('$currentDir/pubspec.yaml').exists();
    if (!isFlutterProject) {
      _logger.err(
          'This is not a Flutter project. Please run this command from the root of your Flutter project.');
      exit(1);
    }

    // Step 1: App Name
    final appName = prompts.get('What is your app name?', defaultsTo: 'Runner');
    if (appName.isEmpty) {
      _logger.err('App name is required');
      exit(1);
    }

    // Step 2: List identities
    _logger.info('\nFetching available signing identities...');
    await identityManager.getSigningIdentities();
    if (identityManager.identities.isEmpty) {
      _logger
          .err('No signing identities found. Please add one to your keychain.');
      exit(1);
    }

    // Step 2.1: Select Application Identity
    final selectedApplicationIdentity = prompts.choose(
      'Select an application signing identity:',
      identityManager.identities,
      defaultsTo: identityManager.preferredApplicationIdentity ??
          identityManager.identities.first,
    );

    // Step 2.2: Select Installer Identity
    final selectedInstallerIdentity = prompts.choose(
      'Select an installer signing identity:',
      identityManager.identities,
      defaultsTo: identityManager.preferredInstallerIdentity ??
          identityManager.identities.first,
    );

    // Step 3: Entitlements file
    final entitlements = prompts.get(
      'Path to entitlements file',
      defaultsTo: 'macos/Runner/Release.entitlements',
    );

    // Step 4: Provision profile
    final provisionProfile = prompts.get(
      'Path to provision profile file (this should not be committed to git)',
    );

    // Step 5: Output directory
    final output = prompts.get(
      'Output directory',
      defaultsTo: './build/macos/Build/Products/Release',
    );

    // Confirm
    _logger.info('\n${lightCyan.wrap('Build Configuration:')}');
    _logger.info('App Name: $appName');
    _logger.info('Application Identity: ${selectedApplicationIdentity?.id}');
    _logger.info('Installer Identity: ${selectedInstallerIdentity?.id}');
    _logger.info('Entitlements: $entitlements');
    _logger.info('Provision Profile: $provisionProfile');
    _logger.info('Output: $output');

    final confirm = prompts.getBool('Proceed with build?', defaultsTo: true);
    if (!confirm) {
      _logger.info('Build cancelled');
      exit(0);
    }

    // Build
    final progress = _logger.progress('Building package...');
    await buildPackage(
      appName: appName,
      applicationIdentity: selectedApplicationIdentity!,
      installerIdentity: selectedInstallerIdentity!,
      entitlements: entitlements,
      provisionProfile: provisionProfile,
      output: output,
    );
    progress.complete('Package built successfully!');
  }
}
