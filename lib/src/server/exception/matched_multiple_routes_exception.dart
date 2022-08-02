part of minerva_server;

class MatchedMultipleRoutesException extends MinervaException {
  MatchedMultipleRoutesException()
      : super('The request matched multiple endpoints.');
}
