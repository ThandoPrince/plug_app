class ApiError {
  final String? general;
  final Map<String, String> fieldErrors;

  ApiError({
    this.general,
    required this.fieldErrors,
  });
}