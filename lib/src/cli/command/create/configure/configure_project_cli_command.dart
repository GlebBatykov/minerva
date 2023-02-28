part of minerva_cli;

class ConfigureProjectCLICommand extends CLICommand<void> {
  final String projectName;

  final String projectPath;

  final CompileType debugCompileType;

  final CompileType releaseCompileType;

  final ProjectTemplate projectTemplate;

  ConfigureProjectCLICommand({
    required this.projectName,
    required this.projectPath,
    required this.debugCompileType,
    required this.releaseCompileType,
    required this.projectTemplate,
  });

  @override
  Future<void> run() async {
    final futures = <Future>[];

    futures.add(ConfigureAppSettingCLICommand(
      projectPath: projectPath,
      debugCompileType: debugCompileType,
      releaseCompileType: releaseCompileType,
    ).run());

    futures.add(ConfigureAnalysisOptionsCLICommand(
      projectName: projectName,
      projectPath: projectPath,
      projectTemplate: projectTemplate,
    ).run());

    futures.add(ConfigurePubspecCLICommand(
      projectName: projectName,
      projectPath: projectPath,
      projectTemplate: projectTemplate,
    ).run());

    futures.add(ConfigureReadmeCLICommand(
      projectName,
      projectPath,
    ).run());

    futures.add(CreateExampleCLICommand(
      projectPath,
      projectTemplate,
    ).run());

    futures.add(CreateExampleTestCLICommand(
      projectPath,
      projectTemplate,
    ).run());

    futures.add(ConfigureGitIgnoreCLICommand(projectPath).run());

    await Future.wait(futures);
  }
}
