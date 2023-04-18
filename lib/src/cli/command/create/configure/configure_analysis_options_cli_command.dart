part of minerva_cli;

class ConfigureAnalysisOptionsCLICommand extends CLICommand<void> {
  final String projectName;

  final String projectPath;

  final ProjectTemplate projectTemplate;

  ConfigureAnalysisOptionsCLICommand({
    required this.projectName,
    required this.projectPath,
    required this.projectTemplate,
  });

  @override
  Future<void> run() async {
    final pubSpecFile =
        File.fromUri(Uri.file('$projectPath/analysis_options.yaml'));

    await pubSpecFile.create(
      recursive: true,
    );

    await pubSpecFile.writeAsString('''
# This file configures the static analysis results for your project (errors,
# warnings, and lints).
#
# This enables the 'recommended' set of lints from `package:lints`.
# This set helps identify many issues that may lead to problems when running
# or consuming Dart code, and enforces writing Dart using a single, idiomatic
# style and format.
#
# If you want a smaller set of lints you can change this to specify
# 'package:lints/core.yaml'. These are just the most critical lints
# (the recommended set includes the core lints).
# The core lints are also what is used by pub.dev for scoring packages.

include: package:lints/recommended.yaml

linter:
  rules:
    depend_on_referenced_packages: false

# Uncomment the following section to specify additional rules.

# analyzer:
#   exclude:
#     - path/to/excluded/files/**

# For more information about the core and recommended set of lints, see
# https://dart.dev/go/core-lints

# For additional information about configuring this file, see
# https://dart.dev/guides/language/analysis-options
''');
  }
}
