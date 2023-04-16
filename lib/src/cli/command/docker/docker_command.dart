part of minerva_cli;

class DockerCommand extends Command {
  @override
  String get name => 'docker';

  @override
  String get description => 'Generate docker file.';

  @override
  String get usage => '''
    -$directoryOptionAbbr  --$directoryOptionName     points to the directory.
    -$compileTypeOptionAbbr, --$compileTypeOptionName  specifies compile type of project in docker container. Possible values: AOT (default), JIT.
  ''';

  DockerCommand() {
    argParser.addOption(
      directoryOptionName,
      abbr: directoryOptionAbbr,
      defaultsTo: Directory.current.path,
    );
    argParser.addOption(
      compileTypeOptionName,
      abbr: compileTypeOptionAbbr,
      defaultsTo: CompileType.aot.toString(),
      allowed: CompileType.values.map((e) => e.name),
    );
  }

  @override
  Future<void> run() async {
    final args = argResults!;

    final directoryPath =
        Directory.fromUri(Uri.directory(args[directoryOptionName]))
            .absolute
            .path;

    final compileType = CompileType.fromName(args[compileTypeOptionName]);

    await CreateDockerFileCLICommand(
      directoryPath,
      compileType,
    ).run();
  }
}
