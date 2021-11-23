enum ResponseStatus { success, failed }

class LResponse<T> {
  LResponse(
      {required this.responseStatus,
      this.message = 'An error occurred!',
      this.data});
  ResponseStatus responseStatus;
  String message;
  T? data;

  @override
  String toString() {
    return 'LResponse{responseStatus: $responseStatus, message: $message, data: $data}';
  }
}
