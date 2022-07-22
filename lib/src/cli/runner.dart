part of minerva_cli;

class Runner {
  Future<void> run(List<String> args) async {
    var runner = CommandRunner('minerva', 'Server side framework for Dart.');

    runner.addCommand(CreateCommand());
    runner.addCommand(RunCommand());
    runner.addCommand(BuildCommand());
    runner.addCommand(ClearCommand());

    await runner.run(args).catchError((error) {
      if (error is UsageException) {
        print('${error.message}\n\n${error.usage}');
      }
    });
  }
}
