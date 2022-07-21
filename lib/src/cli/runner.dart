part of minerva_cli;

class Runner {
  Future<void> run(List<String> arguments) async {
    var runner = CommandRunner('minerva', 'Server side framework for Dart.');

    runner.addCommand(CreateCommand());
    runner.addCommand(RunCommand());

    await runner.run(arguments).catchError((error) {
      if (error is UsageException) {
        print('${error.message}\n\n${error.usage}');
      }
    });
  }
}
