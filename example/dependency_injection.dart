import 'package:minerva/minerva.dart';

void serverBuilder(ServerContext context) {
  //
  context.store['message'] = 'Hello, world!';
}

void endpointsBuilder(Endpoints endpoints) {
  //
  endpoints.get('/hello', (context, request) {
    //
    var message = context.store['message'];

    return message;
  });
}

void main() async {
  //
  var setting = ServerSetting('127.0.0.1', 5555, builder: serverBuilder);

  //
  await Minerva.bind(setting: setting, builder: endpointsBuilder);
}
