part of minerva_core;

extension StringExtension on String {
  int count(String symbol) {
    if (symbol.length == 1) {
      var counter = 0;

      for (var i = 0; i < length; i++) {
        if (this[i] == symbol) {
          counter++;
        }
      }

      return counter;
    } else {
      throw StringException(message: 'Symbol must have a length of 1.');
    }
  }
}
