part of minerva_server;

class MatchedMultipleEndpointsException extends MinervaException {
  MatchedMultipleEndpointsException()
      : super('The request matched multiple endpoints.');
}
