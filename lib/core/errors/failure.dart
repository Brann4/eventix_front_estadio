abstract class Failure {
  final String message;
  const Failure(this.message);
}

class DataSourceFailure extends Failure {
  const DataSourceFailure(String message) : super(message);
}