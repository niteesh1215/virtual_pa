import 'package:dio/dio.dart';
import 'package:virtual_pa/model/l_response.dart';

class APIController {
  late final Dio dio;
  APIController({required String baseUrl}) {
    dio = Dio();
    dio.options.baseUrl = baseUrl;
    dio.options.sendTimeout = 30000;
    dio.options.receiveTimeout = 30000;
    dio.options.contentType = 'application/json';
  }

  Future<void> withTryBlock(
      {required LResponse lResponse, required Function codeToHandle}) async {
    try {
      await codeToHandle();
    } on DioError catch (e) {
      lResponse.message = getErrorMessage(e.type);
    } catch (e) {
      print(e.toString());
      print('#001 Error while adding user');
    }
  }

  String getErrorMessage(DioErrorType dioErrorType) {
    switch (dioErrorType) {
      case DioErrorType.connectTimeout:
      case DioErrorType.receiveTimeout:
      case DioErrorType.sendTimeout:
        return 'Please check your internet connection';
      case DioErrorType.cancel:
        return 'Request was cancelled';
      case DioErrorType.response:
        return 'Server error';
      case DioErrorType.other:
        return 'An error occurred!';
    }
  }

  LResponse<T> getDefaultLResponse<T>() {
    return LResponse<T>(
      responseStatus: ResponseStatus.failed,
    );
  }

  bool getStatus(Response response) {
    return response.statusCode == 200 && response.data['status'] == 'success';
  }

  T getData<T>(Response response) {
    return response.data['data'];
  }
}
