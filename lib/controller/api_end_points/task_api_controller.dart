import 'package:virtual_pa/constants.dart';
import 'package:virtual_pa/controller/api_end_points/api_controller.dart';
import 'package:virtual_pa/model/l_response.dart';
import 'package:virtual_pa/model/task.dart';

class TaskApiController extends APIController {
  static const baseUrl = '$kBaseUrl/task';
  TaskApiController() : super(baseUrl: baseUrl);

  Future<LResponse<Task?>> addTask(Task task) async {
    final LResponse<Task?> lResponse = getDefaultLResponse<Task?>();
    await withTryBlock(
        lResponse: lResponse,
        codeToHandle: () async {
          final response = await dio.post('/add', data: task.toJson());
          print(response.statusCode);
          if (getStatus(response)) {
            lResponse.data =
                Task.fromJson(getData<Map<String, dynamic>?>(response)!);
            lResponse.responseStatus = ResponseStatus.success;
            lResponse.message = 'Success';
          } else {
            lResponse.responseStatus = ResponseStatus.failed;
            lResponse.message = response.data.toString();
          }
        });
    return lResponse;
  }

  Future<LResponse<List<Task>?>> retrieveTask(String myUserId,
      {bool getForMeTask = true}) async {
    print(myUserId);

    final data = getForMeTask ? {'atuserId': myUserId} : {'byuserId': myUserId};
    final url = getForMeTask ? '/retrieve-for-me' : '/retrieve-by-me';
    final LResponse<List<Task>?> lResponse = getDefaultLResponse<List<Task>?>();
    await withTryBlock(
        lResponse: lResponse,
        codeToHandle: () async {
          final response = await dio.post(url, data: data);

          if (getStatus(response)) {
            final data = getData(response);
            if (data == null) {
              lResponse.responseStatus = ResponseStatus.failed;
              lResponse.message = 'No tasks found';
              return;
            }
            print(data);
            final List<Task> tasks = [];
            for (var task in (data as List)) {
              tasks.add(Task.fromJson(task));
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
}
