part of minerva_cli;

class DockerCommand extends Command {
  @override
  String get name => 'docker';

  @override
  String get description => 'Generates docker file.';
}
