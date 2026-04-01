abstract class Failure {
  final String message;
  const Failure({required this.message});
}

class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Cache error occurred'});
}

class ServerFailure extends Failure {
  const ServerFailure({super.message = 'Server error occurred'});
}

class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}