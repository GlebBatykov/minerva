part of minerva_cli;

class ConfigureProjectCLICommand extends CLICommand<void> {
  final String projectName;

  final String projectPath;

  final CompileType debugCompileType;

  final CompileType releaseCompileType;

  final ProjectTemplate projectTemplate;

  ConfigureProjectCLICommand(this.projectName, this.projectPath,
      this.debugCompileType, this.releaseCompileType, this.projectTemplate);

  @override
  Future<void> run() async {
    final futures = <Future>[];

    futures.add(ConfigureAppSettingCLICommand(
            projectPath, debugCompileType, releaseCompileType)
        .run());

    futures.add(ConfigureAnalysisOptionsCLICommand(
            projectName, projectPath, projectTemplate)
        .run());

    futures.add(
        ConfigurePubspecCLICommand(projectName, projectPath, projectTemplate)
            .run());

    futures.add(ConfigureReadmeCLICommand(projectName, projectPath).run());

    futures.add(CreateExampleCLICommand(projectPath, projectTemplate).run());

    futures
        .add(CreateExampleTestCLICommand(projectPath, projectTemplate).run());

    futures.add(ConfigureGitIgnoreCLICommand(projectPath).run());

    await Future.wait(futures);
  }
}
