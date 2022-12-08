enum LottieAnimations {
  dataNotFound(name: 'data_not_found'),
  empty(name: 'empty'),
  error(name: 'error'),
  loading(name: 'loading'),
  smallError(name: 'small_error');

  final String name;
  const LottieAnimations({
    required this.name,
  });
}
