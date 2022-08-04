part of minerva_middleware;

class MatchedMultipleEndpointsException extends MinervaException {
  MatchedMultipleEndpointsException()
      : super('The request matched multiple endpoints.');
}
