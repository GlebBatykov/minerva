part of minerva_cli;

class CreateExampleCLICommand extends CLICommand<void> {
  final String projectPath;

  CreateExampleCLICommand(this.projectPath);

  @override
  Future<void> run() async {
    var mainFile = File.fromUri(Uri.file('$projectPath/lib/main.dart'));

    var endpointBuilderFile =
        File.fromUri(Uri.file('$projectPath/lib/endpoints_builder.dart'));

    var serverBuilderFile =
        File.fromUri(Uri.file('$projectPath/lib/server_builder.dart'));

    await Future.wait([
      mainFile.create(),
      endpointBuilderFile.create(),
      serverBuilderFile.create()
    ]);

    var endpointBuilderContent = '''
import 'package:minerva/minerva.dart';

void endpointsBuilder(Endpoints endpoints) {
  // Create route for GET requests with path '/hello'
  endpoints.get('/hello', (context, request) {
    var message = context.store['message'];

    return message;
  });
}
''';

    var serverBuilderContent = '''
import 'package:minerva/minerva.dart';

void serverBuilder(ServerContext context) {
  // Inject dependency or resource
  context.store['message'] = 'Hello, world!';
}
''';

    var mainContent = '''
import 'package:minerva/minerva.dart';

import 'endpoints_builder.dart';
import 'server_builder.dart';

void main(List<String> args) async {
  // Create server setting
  var setting = MinervaSetting(endpointsBuilder: endpointsBuilder, serverBuilder: serverBuilder);

  // Bind server
  await Minerva.bind(args: args, setting: setting);
}
''';

    await Future.wait([
      endpointBuilderFile.writeAsString(endpointBuilderContent),
      serverBuilderFile.writeAsString(serverBuilderContent),
      mainFile.writeAsString(mainContent)
    ]);
  }
}
