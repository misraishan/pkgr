import 'dart:io';

class CommandResult {
  final String stdout;
  final int exitCode;

  CommandResult({required this.stdout, required this.exitCode});

  bool get isSuccess => exitCode == 0;
  bool get isFailure => exitCode != 0;

  String get errorMessage =>
      'Command failed with exit code $exitCode\nstdout: $stdout\nstderr: $stderr';
}

Future<CommandResult> runCommand(String command) async {
  final result = await Process.run('sh', ['-c', command]);

  if (result.exitCode != 0) {
    throw Exception('Command failed with exit code ${result.exitCode}\n'
        'stdout: ${result.stdout}\n'
        'stderr: ${result.stderr}');
  }

  return CommandResult(
      stdout: result.stdout.toString(), exitCode: result.exitCode);
}
