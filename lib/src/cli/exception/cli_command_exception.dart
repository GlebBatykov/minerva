part of minerva_cli;

class CLICommandException extends MinervaException {
  @override
  // ignore: overridden_fields
  final String message;

  CLICommandException({required this.message});
}
