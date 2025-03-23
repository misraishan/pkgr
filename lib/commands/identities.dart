import 'package:pkgr/utils/run_command.dart';

Future<List<String>> getSigningIdentities() async {
  final result = await runCommand('security find-identity -v -p macappstore');
  if (result.exitCode != 0) return [];

  final lines = result.stdout.toString().split('\n');
  return lines
      .where((line) => line.contains('Developer ID Application:'))
      .map((line) => line.split('"')[1])
      .toList();
}
