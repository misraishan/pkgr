import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;
import 'package:pkgr/commands/identity_manager.dart';
import 'package:pkgr/utils/identity.dart';
import 'package:pkgr/utils/run_command.dart';
import 'package:prompts/prompts.dart' as prompts;
import 'package:xml/xml.dart' as xml;

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

    // Step 0.5: Fetch the app's bundle identifier from the app's Info.plist
    final infoPlistPath = '$basePath/$appName.app/Contents/Info.plist';
    final bundleIdentifier = await _fetchBundleIdentifier(infoPlistPath);
    if (bundleIdentifier == null) {
      _logger.err('Failed to fetch bundle identifier');
      exit(1);
    }
    _logger.info('Bundle Identifier: $bundleIdentifier');

    // Step 1: Sign the app bundle
    final signAppCmd =
        'codesign --deep --force --sign "${applicationIdentity.id}" $basePath/$appName.app';
    await runCommand(signAppCmd);

    // Step 2: Sign with entitlements
    final signEntitlementsCmd =
        'codesign --force --deep --sign "${applicationIdentity.id}" '
        '--entitlements $entitlements --options runtime --prefix $bundleIdentifier $basePath/$appName.app/';
    await runCommand(signEntitlementsCmd);

    // Step 3: Clean and verify
    final removeQuarantine =
        'xattr -d com.apple.quarantine $basePath/$appName.app/Contents/embedded.provisionprofile';
    await runCommand(removeQuarantine);

    // Step 3.1: Verify
    final verifyCmd =
        'codesign --verify --deep --strict --verbose=2 $basePath/$appName.app';
    await runCommand(verifyCmd);

    // Step 4: Create pkg
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

  /// Fetches the bundle identifier from the Info.plist file.
  Future<String?> _fetchBundleIdentifier(String infoPlistPath) async {
    try {
      final infoPlistContent = await File(infoPlistPath).readAsString();
      final document = xml.XmlDocument.parse(infoPlistContent);

      final dictElement = document.findAllElements('dict').first;
      String? bundleIdentifier;
      bool nextIsValue = false;

      for (var child in dictElement.children) {
        if (child is xml.XmlElement) {
          if (child.name.local == 'key' &&
              child.innerText == 'CFBundleIdentifier') {
            nextIsValue = true;
          } else if (nextIsValue && child.name.local == 'string') {
            bundleIdentifier = child.innerText;
            break;
          }
        }
      }

      return bundleIdentifier;
    } on FileSystemException catch (e) {
      if (e.osError?.errorCode == 2) {
        _logger.err('Info.plist not found');
        return null;
      }
      rethrow;
    } catch (e) {
      _logger.err('Error reading or parsing Info.plist: $e');
      return null;
    }
  }
}
