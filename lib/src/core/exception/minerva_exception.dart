part of minerva_core;

abstract class MinervaException implements Exception {
  final String message;

  MinervaException(this.message);

  @override
  String toString() {
    return '$runtimeType: $message';
  }
}
