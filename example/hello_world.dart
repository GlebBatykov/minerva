import 'package:minerva/minerva.dart';

void endpointsBuilder(Endpoints endpoints) {
  // Create route for GET requests with path '/hello'
  endpoints.get('/hello', (context, request) {
    var message = context.store['message'];

    return message;
  });
}

void main() async {
  // Create server setting
  var setting = ServerSetting('127.0.0.1', 5000);

  // Bind server
  await Minerva.bind(setting: setting, builder: endpointsBuilder);
}
