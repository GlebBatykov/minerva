part of minerva_cli;

class ConfigureProjectCLICommand extends CLICommand<void> {
  final String projectName;

  final String projectPath;

  final String debugCompileType;

  final String releaseCompileType;

  ConfigureProjectCLICommand(this.projectName, this.projectPath,
      this.debugCompileType, this.releaseCompileType);

  @override
  Future<void> run() async {
    var futures = <Future>[];

    futures.add(ConfigureAppSettingCLICommand(
            projectPath, debugCompileType, releaseCompileType)
        .run());

    futures.add(ConfigurePubspecCLICommand(projectName, projectPath).run());

    futures.add(ConfigureReadmeCLICommand(projectName, projectPath).run());

    futures.add(CreateExampleCLICommand(projectPath).run());

    futures.add(CreateExampleTestCLICommand(projectPath).run());

    futures.add(ConfigureGitIgnoreCLICommand(projectPath).run());

    await Future.wait(futures);
  }
}
