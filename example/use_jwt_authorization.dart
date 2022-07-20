import 'package:minerva/minerva.dart';

void endpointsBuilder(Endpoints endpoints) {
  //
  endpoints.get('/hello', (context, request) => 'Hello, world!',
      authOptions: AuthOptions(roles: ['User'], permissionLevel: 1));

  //
  endpoints.get('/user', (context, request) => 'Some user info',
      authOptions: AuthOptions(roles: ['Admin']));

  endpoints.get('/endpoint', (context, request) => 'Some endpoint!',
      authOptions: AuthOptions(permissionLevel: 2));
}

bool tokenVerify(ServerContext context, String token) {
  //

  return true;
}

Role getRole(ServerContext context, String token) {
  //

  return Role('User');
}

void main() async {
  //
  var middlewares = [
    ErrorMiddleware(),
    AuthMiddleware(tokenVerify: tokenVerify, getRole: getRole),
    EndpointMiddleware()
  ];

  //
  var setting = ServerSetting('127.0.0.1', 5555, middlewares: middlewares);

  //
  await Minerva.bind(setting: setting, builder: endpointsBuilder);
}
