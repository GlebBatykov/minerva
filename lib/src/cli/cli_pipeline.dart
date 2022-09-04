part of minerva_cli;

class CLIPipeline {
  final List<CLICommand> _commands;

  CLIPipeline(List<CLICommand> commands) : _commands = commands;

  Future<void> run() async {
    for (var command in _commands) {
      try {
        await command.run();
      } catch (e, s) {
        print(e);
        print(s);
      }
    }
  }
}
