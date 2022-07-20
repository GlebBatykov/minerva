part of minerva_core;

class MinervaException implements Exception {
  final String? message;

  MinervaException([this.message]);

  @override
  String toString() {
    if (message != null) {
      return '$runtimeType: ${message!}';
    } else {
      return super.toString();
    }
  }
}
