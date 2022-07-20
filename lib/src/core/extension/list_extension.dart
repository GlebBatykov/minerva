part of minerva_core;

extension ListExtension<T> on List<T> {
  List<T> intersection(List<T> other) {
    var list = <T>[];

    var first = toSet().toList();
    var second = other.toSet().toList();

    for (var i = 0; i < first.length; i++) {
      for (var j = 0; j < second.length; j++) {
        if (first[i] == second[j]) {
          list.add(first[i]);
          break;
        }
      }
    }

    return list;
  }
}
