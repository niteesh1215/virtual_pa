import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';
import 'package:virtual_pa/controller/api_end_points/task_api_controller.dart';
import 'package:virtual_pa/controller/api_end_points/user_api_controller.dart';
import 'package:virtual_pa/model/app_theme.dart';
import 'package:virtual_pa/model/l_response.dart';
import 'package:virtual_pa/model/registered_contact.dart';
import 'package:virtual_pa/model/task.dart';
import 'package:virtual_pa/model/tasks.dart';
import 'package:virtual_pa/model/user.dart';
import 'package:virtual_pa/view/component/buttons/custom_icon_button.dart';
import 'package:virtual_pa/view/component/custom_chip.dart';
import 'package:virtual_pa/view/screen/create/create_screen.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home-screen';
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late User _user;
  void onPressFAB() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const CreateScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _user = Provider.of<User>(context, listen: false);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          /*leading: CustomIconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.menu,
              color: Colors.white,
            ),
          ),*/
          bottom: const TabBar(tabs: [
            Tab(
              text: 'Tasks',
            ),
            Tab(
              text: 'Appointment',
            ),
          ]),
        ),
        drawer: Drawer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DrawerHeader(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _user.name ?? '',
                      style: Theme.of(context).textTheme.headline6,
                      textAlign: TextAlign.left,
                    ),
                    Text(
                      '${_user.phoneNo ?? ''}\n${_user.userId}',
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
              ListTile(
                title: const Text('Account Settings'),
                onTap: () {},
              ),
              ListTile(
                title: const Text('Preferences'),
                onTap: () {},
              )
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            TaskView(),
            AppointmentView(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: onPressFAB,
          child: const Icon(
            Icons.add,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

class TaskView extends StatefulWidget {
  const TaskView({Key? key}) : super(key: key);

  @override
  State<TaskView> createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {
  final ValueNotifier<bool> _showForMeTaskList = ValueNotifier<bool>(true);
  Tasks? tasks;
  late User user;

  final TaskApiController taskApiController = TaskApiController();

  @override
  void initState() {
    _showForMeTaskList.addListener(() {});
    super.initState();
  }

  @override
  void dispose() {
    _showForMeTaskList.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<User>(context, listen: false);
    if (tasks == null) {
      tasks = Provider.of<Tasks>(context);
      for (int i = 0; i < 50; i++) {
        tasks!.addTask(
          Task(
            taskId: '$i',
            taskString: 'Complete presentation',
            atUserId: '$i',
            completeBy: DateTime.now(),
            registeredContact: RegisteredContact(
              id: '$i',
              phoneNo: '+919657121851',
              fullName: 'Niteesh',
            ),
          ),
          shouldNotify: false,
        );
      }
    }
    return Column(
      children: [
        Container(
          color: context.read<AppTheme>().backgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ValueListenableBuilder<bool>(
                valueListenable: _showForMeTaskList,
                builder: (context, value, _) {
                  return Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: CustomChip(
                          label: const Text('For Me'),
                          onPressed: () async {
                            _showForMeTaskList.value = true;
                            final userAPIController = UserAPIController();
                            final LResponse response =
                                await userAPIController.retrieveUser(
                                    userId: '6199f651fa4aacb6415d1c5');
                            print(response.data);
                            print(response.message);
                            print(response.responseStatus);
                          },
                          isSelected: value,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: CustomChip(
                          label: const Text('By Me'),
                          onPressed: () {
                            _showForMeTaskList.value = false;
                          },
                          isSelected: !value,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: CustomChip(
                          label: const Text('Urgent'),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  );
                }),
          ),
        ),
        Expanded(
          child: FutureBuilder<LResponse<List<Task>?>>(
              future: taskApiController.retrieveTask(user.userId!,
                  getForMeTask: false),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  print(snapshot.data);
                }
                return ListView.builder(
                  itemCount: tasks!.list.length,
                  itemBuilder: (context, index) {
                    final task = tasks!.list[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 5.0),
                      child: ListTile(
                        tileColor: Theme.of(context).colorScheme.surface,
                        shape: RoundedRectangleBorder(
                            side: BorderSide(
                                color: context.read<AppTheme>().borderColor),
                            borderRadius: BorderRadius.circular(18.0)),
                        title: Text(
                          task.taskString,
                          overflow: TextOverflow.fade,
                        ),
                        subtitle:
                            Text('By ${task.registeredContact!.fullName}'),
                        trailing: Column(
                          children: [
                            Text(Jiffy(task.completeBy).format('dd MMM yyyy'))
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
        )
      ],
    );
  }
}

class AppointmentView extends StatefulWidget {
  const AppointmentView({Key? key}) : super(key: key);

  @override
  _AppointmentViewState createState() => _AppointmentViewState();
}

class _AppointmentViewState extends State<AppointmentView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CustomChip(
                  label: const Text('For Me'),
                  onPressed: () {},
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CustomChip(
                  label: const Text('By Me'),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        )
      ],
    );
    ;
  }
}
