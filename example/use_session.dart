import 'package:minerva/minerva.dart';

void endpointsBuilder(Endpoints endpoints) {
  //
  endpoints.get('/counter', (context, request) {
    var session = request.session;

    if (session.isNew) {
      session['counter'] = 0;

      return 0;
    } else {
      var counter = session['counter'] as int;

      counter++;

      session['counter'] = counter;

      return counter;
    }
  });
}

void main() async {
  //
  var setting = ServerSetting('127.0.0.1', 5555);

  //
  await Minerva.bind(setting: setting, builder: endpointsBuilder);
}
