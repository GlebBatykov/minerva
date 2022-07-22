import 'package:minerva/minerva.dart';

void endpointsBuilder(Endpoints endpoints) {
  //
  endpoints.get('/hello', (context, request) {
    //
    context.logger.info('Log!');

    return 'Hello, world!';
  });
}

void main() async {
  //
  var setting = ServerSetting('127.0.0.1', 5555);

  //
  await Minerva.bind(setting: setting, builder: endpointsBuilder);
}