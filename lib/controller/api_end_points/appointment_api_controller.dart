import 'package:virtual_pa/constants.dart';
import 'package:virtual_pa/controller/api_end_points/api_controller.dart';
import 'package:virtual_pa/model/appointment.dart';
import 'package:virtual_pa/model/l_response.dart';

class AppointmentApiController extends APIController {
  static const baseUrl = '$kBaseUrl/appointment';
  AppointmentApiController() : super(baseUrl: baseUrl);

  Future<LResponse<Appointment?>> addAppointment(
    Appointment appointment,
  ) async {
    final LResponse<Appointment?> lResponse =
        getDefaultLResponse<Appointment?>();
    await withTryBlock(
        lResponse: lResponse,
        codeToHandle: () async {
          final response = await dio.post('/add', data: appointment.toJson());
          print('appoinment');
          print(response.data);
          if (getStatus(response)) {
            lResponse.data =
                Appointment.fromJson(getData<Map<String, dynamic>?>(response)!);
            print(lResponse.data);
            lResponse.responseStatus = ResponseStatus.success;
            lResponse.message = 'Success';
          } else {
            lResponse.responseStatus = ResponseStatus.failed;
            lResponse.message = response.data.toString();
          }
        });
    return lResponse;
  }

  Future<LResponse<List<Appointment>?>> retrieveAppointment(String myUserId,
      {getForMeAppointment = true}) async {
    final data =
        getForMeAppointment ? {'atuserId': myUserId} : {'byuserId': myUserId};
    final url = getForMeAppointment ? '/retrieve-for-me' : '/retrieve-by-me';

    final LResponse<List<Appointment>?> lResponse =
        getDefaultLResponse<List<Appointment>?>();
    await withTryBlock(
        lResponse: lResponse,
        codeToHandle: () async {
          final response = await dio.post(url, data: data);
          if (getStatus(response)) {
            final data = getData(response);
            if (data == null) {
              lResponse.responseStatus = ResponseStatus.failed;
              lResponse.message = 'No appointments found';
              return;
            }
            print(data);
            final List<Appointment> tasks = [];
            for (var task in (data as List)) {
              tasks.add(Appointment.fromJson(task));
            }
            lResponse.data = tasks;
            lResponse.responseStatus = ResponseStatus.success;
            lResponse.message = 'Success';
          } else {
            lResponse.responseStatus = ResponseStatus.failed;
            lResponse.message = response.data.toString();
          }
        });
    return lResponse;
  }

  Future<LResponse<String?>> deleteAppointment(String appointmentId) async {
    final LResponse<String?> lResponse = getDefaultLResponse<String?>();
    await withTryBlock(
      lResponse: lResponse,
      codeToHandle: () async {
        final response = await dio.delete('/delete-appointment', data: {
          '_id': appointmentId,
        });
        if (getStatus(response)) {
          lResponse.data = 'Deleted successfully';
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

  Future<LResponse<String?>> updateAppointmentStatus(
      String taskId, AppointmentStatus status) async {
    final LResponse<String?> lResponse = getDefaultLResponse<String?>();
    await withTryBlock(
      lResponse: lResponse,
      codeToHandle: () async {
        final response = await dio.put('/update-status', data: {
          '_id': taskId,
          'status': status.toString(),
        });
        if (getStatus(response)) {
          lResponse.data = 'Updated successfully';
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
