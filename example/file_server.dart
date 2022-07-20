import 'dart:io';

import 'package:minerva/minerva.dart';

void serverBuilder(ServerContext context) {
  //
  context.store['directory'] = 'someDirectory';
}

void endpointsBuilder(Endpoints endpoints) {
  //
  endpoints.get('/file', (context, request) async {
    var fileName = request.requestedUri.queryParameters['fileName'];

    if (fileName != null) {
      var directory = context.store['directory']!;

      var file = File.fromUri(Uri.file('$directory/$fileName'));

      if (await file.exists()) {
        return FileResult(file, name: fileName);
      } else {
        return NotFoundResult(body: 'File not exists');
      }
    }
  });
}

void main() async {
  //
  var setting = ServerSetting('127.0.0.1', 5555);

  //
  await Minerva.bind(setting: setting, builder: endpointsBuilder);
}
