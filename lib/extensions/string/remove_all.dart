extension RemoveAll on String {
  String removeAll(Iterable<String> values) => values.fold(
        this,
        (result, value) {
          return result.replaceAll(value, '');
        },
      );
}
