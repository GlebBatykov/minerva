import 'package:minerva/minerva.dart';

void endpointsBuilder(Endpoints endpoints) {
  //
  endpoints.ws('/hello', (context, socket) {
    socket.add('Hello, world!');

    socket.close();
  });
}

void main() async {
  //
  var setting = ServerSetting('127.0.0.1', 5555);

  //
  await Minerva.bind(setting: setting, builder: endpointsBuilder);
}
