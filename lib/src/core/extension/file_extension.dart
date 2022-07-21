part of minerva_core;

extension FileExtension on File {
  String get fileExtension => basename(path).split('.').last;
}
