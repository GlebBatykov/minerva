part of minerva_cli;

class ClearDirectoryCLICommand extends CLICommand<void> {
  final String directoryPath;

  ClearDirectoryCLICommand(this.directoryPath);

  @override
  Future<void> run() async {
    var directory = Directory.fromUri(Uri.directory(directoryPath));

    var futures = <Future>[];

    if (await directory.exists()) {
      var size = 0;

      var fileCount = 0;

      var childrens = await directory.list(recursive: true).toList();

      childrens = childrens.whereType<File>().toList();

      for (var entity in childrens) {
        fileCount++;

        var stat = await entity.stat();

        size += stat.size;

        futures.add(entity.delete());
      }

      await Future.wait(futures);

      await directory.delete(recursive: true);

      print('Cleared files: $fileCount');
      print('Cleared size: $size byte');
    }
  }
}
