part of minerva_cli;

class RunCommand extends Command {
  @override
  String get name => 'run';

  @override
  String get description => 'Run Minerva server.';

  @override
  String get usage => '''

  ''';

  @override
  Future<void> run() async {}
}
