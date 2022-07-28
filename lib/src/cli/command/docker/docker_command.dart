part of minerva_cli;

class DockerCommand extends Command {
  @override
  String get name => 'docker';

  @override
  String get description => 'Generates docker file.';

  @override
  String get usage => '''
    -d  --directory     points to the directory.
    -c, --compile-type  specifies compile type of project in docker container. Possible values: AOT (default), JIT.
  ''';

  DockerCommand() {
    argParser.addOption('directory',
        abbr: 'd', defaultsTo: Directory.current.path);
    argParser.addOption('compile-type',
        abbr: 'c', defaultsTo: 'AOT', allowed: ['AOT', 'JIT']);
  }

  @override
  Future<void> run() async {
    var directoryPath =
        Directory.fromUri(Uri.directory(argResults!['directory']))
            .absolute
            .path;

    var compileType = argResults!['compile-type'];

    await CreateDockerFileCLICommand(directoryPath, compileType).run();
  }
}
