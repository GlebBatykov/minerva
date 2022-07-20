part of minerva_http;

enum HttpMethod {
  get('GET'),
  post('POST'),
  put('PUT'),
  head('HEAD'),
  delete('DELETE'),
  patch('PATCH'),
  options('OPTIONS'),
  trace('TRACE');

  final String value;

  const HttpMethod(this.value);
}
