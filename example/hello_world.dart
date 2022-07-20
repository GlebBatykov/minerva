import 'package:minerva/minerva.dart';

void endpointsBuilder(Endpoints endpoints) {
  endpoints.get(
      '/hello', (context, request) => OkResult(body: 'Hello, world!'));
}

void main() async {
  var setting = ServerSetting('127.0.0.1', 5555);

  await Minerva.bind(setting: setting, builder: endpointsBuilder);
}
