part of minerva_core;

abstract class FilePathParser {
  static String parse(String path) {
    if (path.startsWith('~/')) {
      final filePath =
          '${HostEnvironment.contentRootPath}/${path.substring(2)}';

      return filePath;
    } else {
      return path;
    }
  }
}
