class CacheException implements Exception {
  final String message;
  const CacheException({this.message = 'Cache error occurred'});
}

class ValidationException implements Exception {
  final String message;
  const ValidationException({required this.message});
}