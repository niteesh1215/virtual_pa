import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtual_pa/controller/api_end_points/task_api_controller.dart';
import 'package:virtual_pa/controller/api_end_points/user_api_controller.dart';
import 'package:virtual_pa/model/app_theme.dart';
import 'package:virtual_pa/model/l_response.dart';
import 'package:virtual_pa/model/registered_contact.dart';
import 'package:virtual_pa/model/task.dart';
import 'package:virtual_pa/model/tasks.dart';
import 'package:virtual_pa/model/user.dart';
import 'package:virtual_pa/utilities/common_functions.dart';
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
  bool _showForMeTaskList = true;
  Tasks? tasks;
  late User user;
  final TaskApiController taskApiController = TaskApiController();

  @override
  void initState() {
    super.initState();
  }

  void _showForMeList(bool value) {
    if (_showForMeTaskList == value) return;
    setState(() {
      _showForMeTaskList = value;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<User>(context, listen: false);
    tasks = Provider.of<Tasks>(context, listen: false);
    print(_showForMeTaskList);
    return Column(
      children: [
        Container(
          color: context.read<AppTheme>().backgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: CustomChip(
                    label: const Text('For Me'),
                    onPressed: () async {
                      _showForMeList(true);
                    },
                    isSelected: _showForMeTaskList,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: CustomChip(
                    label: const Text('By Me'),
                    onPressed: () {
                      _showForMeList(false);
                    },
                    isSelected: !_showForMeTaskList,
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
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<LResponse<List<Task>?>>(
              future: taskApiController.retrieveTask(user.userId!,
                  getForMeTask: _showForMeTaskList),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.data!.data != null &&
                    snapshot.data!.data!.isNotEmpty) {
                  tasks!.addTasks(snapshot.data!.data!, shouldNotify: false);
                  print(snapshot.data!.data!);
                } else {
                  return Center(
                    child: Text(
                      'No tasks ' +
                          (_showForMeTaskList ? 'for you yet' : 'by you yet'),
                    ),
                  );
                }
                return Consumer<Tasks>(
                  builder: (context, _, __) {
                    return ListView.builder(
                      itemCount: tasks!.list.length,
                      itemBuilder: (context, index) {
                        final task = tasks!.list[index];
                        task.registeredContact = RegisteredContact(
                            phoneNo: task.byUserPhoneNo!, id: task.byUserId);
                        //todo find registered contact
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 5.0),
                          child: Container(
                            constraints: const BoxConstraints(
                              maxHeight: 100,
                            ),
                            child: ListTile(
                              tileColor: Theme.of(context).colorScheme.surface,
                              shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      color:
                                          context.read<AppTheme>().borderColor),
                                  borderRadius: BorderRadius.circular(18.0)),
                              title: Text(
                                CommonFunctions.cutString(task.taskString, 100),
                              ),
                              subtitle: _showForMeTaskList
                                  ? ChangeNotifierProvider.value(
                                      value: task.registeredContact,
                                      builder: (context, snapshot) {
                                        return ByText(task: task);
                                      },
                                    )
                                  : null,
                              trailing: Column(
                                children: [
                                  Text(
                                    CommonFunctions.getddMMyyyy(
                                        task.completeBy!),
                                  ),
                                  Text(
                                    task.urgent ? 'URGENT' : '',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText2!
                                        .copyWith(
                                            color: context
                                                .read<AppTheme>()
                                                .successColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              }),
        )
      ],
    );
  }
}

class ByText extends StatelessWidget {
  const ByText({
    Key? key,
    required this.task,
  }) : super(key: key);

  final Task task;

  @override
  Widget build(BuildContext context) {
    final registeredContact = Provider.of<RegisteredContact>(context);
    return Text(
        'By ${registeredContact.fullName ?? registeredContact.phoneNo}');
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
