part of minerva_cli;

class Runner {
  Future<void> run(List<String> args) async {
    var runner = CommandRunner(
        'minerva', 'Server side framework for Dart. Version 0.3.2.');

    runner.addCommand(CreateCommand());
    runner.addCommand(RunCommand());
    runner.addCommand(BuildCommand());
    runner.addCommand(ClearCommand());
    runner.addCommand(DockerCommand());
    runner.addCommand(TestCommand());
    runner.addCommand(DebugCommand());

    await runner.run(args).catchError((error) {
      if (error is UsageException) {
        print('${error.message}\n\n${error.usage}');
      }
    });
  }
}
