part of minerva_cli;

class DockerCommand extends Command {
  @override
  String get name => 'docker';

  @override
  String get description => 'Generate docker file.';

  @override
  String get usage => '''
    -d  --directory     points to the directory.
    -c, --compile-type  specifies compile type of project in docker container. Possible values: AOT (default), JIT.
  ''';

  DockerCommand() {
    argParser.addOption(
      'directory',
      abbr: 'd',
      defaultsTo: Directory.current.path,
    );
    argParser.addOption(
      'compile-type',
      abbr: 'c',
      defaultsTo: CompileType.aot.toString(),
      allowed: CompileType.values.map((e) => e.name),
    );
  }

  @override
  Future<void> run() async {
    final directoryPath =
        Directory.fromUri(Uri.directory(argResults!['directory']))
            .absolute
            .path;

    final compileType = argResults!['compile-type'];

    await CreateDockerFileCLICommand(
      directoryPath,
      compileType,
    ).run();
  }
}
