import 'package:virtual_pa/constants.dart';
import 'package:virtual_pa/controller/api_end_points/api_controller.dart';
import 'package:virtual_pa/model/l_response.dart';
import 'package:virtual_pa/model/user.dart';

class UserAPIController extends APIController {
  static const baseUrl = '$kBaseUrl/user';

  UserAPIController() : super(baseUrl: baseUrl);

  Future<LResponse<User?>> addUser(User user) async {
    final lResponse = getDefaultLResponse<User?>();
    await withTryBlock(
      lResponse: lResponse,
      codeToHandle: () async {
        final response = await dio.post('/add', data: user.toJson());
        if (getStatus(response)) {
          lResponse.data = User.fromJson(getData<Map<String,dynamic>?>(response)!);
          lResponse.responseStatus = ResponseStatus.success;
          lResponse.message = 'Success';
        } else {
          lResponse.responseStatus = ResponseStatus.failed;
          lResponse.message = response.data.toString();
        }
      },
    );
    return lResponse;
  }

  Future<LResponse<User?>> retrieveUser(
      {String? userId, String? phoneNo}) async {
    assert(userId != null || phoneNo != null, 'userId or phoneNo is required');

    final lResponse = getDefaultLResponse<User?>();
    final data = userId == null ? {'phoneNo': phoneNo} : {'_id': userId};
    await withTryBlock(
      lResponse: lResponse,
      codeToHandle: () async {
        final response = await dio.post('/retrieve', data: data);
        if (getStatus(response)) {
          if (getData(response) == null) {
            print('null');
            lResponse.responseStatus = ResponseStatus.failed;
            lResponse.message = 'User not found';
            return;
          }
          lResponse.data = User.fromJson(getData<Map<String,dynamic>?>(response)!);
          lResponse.responseStatus = ResponseStatus.success;
          lResponse.message = 'Success';
        } else {
          lResponse.responseStatus = ResponseStatus.failed;
          lResponse.message = response.data.toString();
        }
      },
    );
    return lResponse;
  }
}
