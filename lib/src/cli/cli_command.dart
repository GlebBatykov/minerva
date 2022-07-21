part of minerva_cli;

abstract class CLICommand<T> {
  FutureOr<T> run();
}
