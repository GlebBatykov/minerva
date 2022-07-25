part of minerva_cli;

class ProjectClearCLICommand extends CLICommand<void> {
  final String projectPath;

  ProjectClearCLICommand(this.projectPath);

  @override
  Future<void> run() async {
    const directoryNames = ['lib', 'test'];

    var futures = <Future>[];

    for (var name in directoryNames) {
      var directory = Directory.fromUri(Uri.directory('$projectPath/$name'));

      for (var entity in await directory.list().toList()) {
        futures.add(entity.delete());
      }
    }

    futures.add(Directory.fromUri(Uri.directory('$projectPath/bin'))
        .delete(recursive: true));

    futures
        .add(Directory.fromUri(Uri.directory('$projectPath/assets')).create());

    futures.add(File.fromUri(Uri.file('$projectPath/.gitignore')).delete());

    futures.add(File.fromUri(Uri.file('$projectPath/pubspec.yaml')).delete());

    futures.add(File.fromUri(Uri.file('$projectPath/CHANGELOG.md')).delete());

    await Future.wait(futures);
  }
}
