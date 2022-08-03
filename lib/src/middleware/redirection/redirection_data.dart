part of minerva_middleware;

class RedirectionData {
  final HttpMethod method;

  final String path;

  final String location;

  final AuthOptions? authOptions;

  RedirectionData(
      {required this.method,
      required this.path,
      required this.location,
      this.authOptions});
}
