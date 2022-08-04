part of minerva_middleware;

class MatchedMultipleRoutesException extends MinervaException {
  MatchedMultipleRoutesException()
      : super('The request matched multiple endpoints.');
}
