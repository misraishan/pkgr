import 'package:mason_logger/mason_logger.dart';
import 'package:pkgr/utils/run_command.dart';

class Identity {
  final String name;
  final String id;

  Identity({required this.name, required this.id});

  @override
  String toString() {
    return 'Identity(name: $name, id: $id)';
  }

  String get parts {
    return '$id\t$name';
  }

  Identity? get preferredInstallerIdentity {
    return id.contains('Installer') ? this : null;
  }

  Identity? get preferredApplicationIdentity {
    return id.contains('Application:') ? this : null;
  }
}

/// A command to get the signing identities for the current user.
class IdentityManager {
  final logger = Logger();

  /// Get the signing identities for the current user.
  Future<void> getSigningIdentities() async {
    final identities = await getSigningIdentitiesAsList();
    logger.info('Identities:\n${identities.map((e) => e.parts).join('\n')}');
  }

  /// Get the signing identities for the current user as a list of strings.
  Future<List<Identity>> getSigningIdentitiesAsList() async {
    final result = await runCommand('security find-identity -v -p macappstore');
    if (result.exitCode != 0) {
      logger.err(result.errorMessage);
      return [];
    }

    final lines = result.stdout.split('\n');
    final identities = lines
        .where((e) => !e.contains(
            'Apple Development:')) // This is not used for app store signing
        .map((e) {
          final parts = e.split(')');
          if (parts.length < 2) return null;

          final id = parts[1].split('"')[0].trim();
          final quotedName = '${parts[1].split('"')[1]})';
          return Identity(
            name: quotedName,
            id: id,
          );
        })
        .whereType<Identity>()
        .toList();

    return identities;
  }
}
