import 'package:virtual_pa/constants.dart';
import 'package:virtual_pa/controller/api_end_points/api_controller.dart';
import 'package:virtual_pa/model/appointment_slot.dart';
import 'package:virtual_pa/model/l_response.dart';
import 'package:virtual_pa/model/preference_data.dart';
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
          lResponse.data =
              User.fromJson(getData<Map<String, dynamic>?>(response)!);
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

  Future<LResponse<User?>> login(User user) async {
    final lResponse = getDefaultLResponse<User?>();
    await withTryBlock(
      lResponse: lResponse,
      codeToHandle: () async {
        final response = await dio.post('/login', data: {
          "phoneNo": user.phoneNo,
          "password": user.password,
        });
        if (getStatus(response)) {
          lResponse.data =
              User.fromJson(getData<Map<String, dynamic>?>(response)!);
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
          if (getData(response) == null || getData(response).isEmpty) {
            lResponse.responseStatus = ResponseStatus.failed;
            lResponse.message = 'User not found';
            return;
          }
          lResponse.data =
              User.fromJson(Map<String, dynamic>.from(getData(response)[0]));
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

  Future<LResponse<List<Map<String, dynamic>>?>> retrieveRegisterUsers(
      List<String> phoneNos) async {
    final lResponse = getDefaultLResponse<List<Map<String, dynamic>>?>();
    await withTryBlock(
        lResponse: lResponse,
        codeToHandle: () async {
          print(phoneNos);
          final response = await dio
              .post('/retrieve-registered-user', data: {"phoneNo": phoneNos});
          print(response.data);
          if (getStatus(response)) {
            var data = getData(response);
            data = data.cast<Map<String, dynamic>>();
            if (data == null) {
              lResponse.responseStatus = ResponseStatus.failed;
              lResponse.message = 'No registered user found';
              return;
            }
            lResponse.data = data;
            lResponse.responseStatus = ResponseStatus.success;
            lResponse.message = 'Success';
          } else {
            lResponse.responseStatus = ResponseStatus.failed;
            lResponse.message = response.data.toString();
          }
        });
    return lResponse;
  }

  Future<LResponse<List<AppointmentSlot>?>> retrieveAppointment(
      String userId) async {
    final lResponse = getDefaultLResponse<List<AppointmentSlot>?>();
    await withTryBlock(
        lResponse: lResponse,
        codeToHandle: () async {
          final response = await dio
              .post('/retrieve-appointment-slots', data: {'_id': userId});
          print(response.data);
          if (getStatus(response)) {
            var data = getData(response);
            if (data == null) {
              lResponse.responseStatus = ResponseStatus.failed;
              lResponse.message = 'Appointment not enabled for this user';
              return;
            }
            final appointmentSlotsMap = data[0]['appointmentSlots']
                .cast<Map<String, dynamic>>() as List<Map<String, dynamic>>;
            print('hi bro');
            lResponse.data = appointmentSlotsMap
                .map((slot) => AppointmentSlot.fromJSON(slot))
                .toList();
            lResponse.responseStatus = ResponseStatus.success;
            lResponse.message = 'Success';
          } else {
            lResponse.responseStatus = ResponseStatus.failed;
            lResponse.message = response.data.toString();
          }
        });
    return lResponse;
  }

  Future<LResponse<User?>> updatePreferences(
      {required String userId,
      required PreferencesData preferencesData}) async {
    final lResponse = getDefaultLResponse<User?>();
    await withTryBlock(
        lResponse: lResponse,
        codeToHandle: () async {
          final response = await dio.put('/update-preferences', data: {
            '_id': userId,
            'taskLimit': preferencesData.taskLimit,
            'appointmentSlots': preferencesData.appointmentSlots
                .map<Map<String, dynamic>>((slot) {
              return slot.toJSON();
            }).toList(),
            'isAppointmentEnabled': preferencesData.isAppointmentEnabled
          });
          print(response.data.toString());
          if (getStatus(response)) {
            var data = getData<Map<String, dynamic>?>(response);
            if (data == null) {
              lResponse.responseStatus = ResponseStatus.failed;
              lResponse.message = 'An error occurred';
              return;
            }
            final user = User.fromJson(data);
            lResponse.responseStatus = ResponseStatus.success;
            lResponse.data = user;
            lResponse.message = 'Success';
          } else {
            print('hi');
            lResponse.responseStatus = ResponseStatus.failed;
            lResponse.message = response.data.toString();
          }
        });
    return lResponse;
  }
}
