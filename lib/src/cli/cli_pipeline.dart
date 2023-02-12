part of minerva_cli;

class CLIPipeline {
  final List<CLICommand> _commands;

  CLIPipeline(List<CLICommand> commands) : _commands = commands;

  Future<void> run() async {
    for (final command in _commands) {
      try {
        await command.run();
      } catch (error, stackTrace) {
        print(error);
        print(stackTrace);
      }
    }
  }
}
