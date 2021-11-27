import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:virtual_pa/controller/api_end_points/appointment_api_controller.dart';
import 'package:virtual_pa/controller/api_end_points/task_api_controller.dart';
import 'package:virtual_pa/controller/firebase_auth_controller.dart';
import 'package:virtual_pa/controller/hive_controller.dart';
import 'package:virtual_pa/model/app_theme.dart';
import 'package:virtual_pa/model/appointment.dart';
import 'package:virtual_pa/model/appointments.dart';
import 'package:virtual_pa/model/l_response.dart';
import 'package:virtual_pa/model/registered_contact.dart';
import 'package:virtual_pa/model/task.dart';
import 'package:virtual_pa/model/tasks.dart';
import 'package:virtual_pa/model/user.dart';
import 'package:virtual_pa/utilities/common_functions.dart';
import 'package:virtual_pa/utilities/custom_navigator.dart';
import 'package:virtual_pa/view/component/buttons/custom_icon_button.dart';
import 'package:virtual_pa/view/component/custom_chip.dart';
import 'package:virtual_pa/view/screen/authentication_and_registration/sign_in_screen.dart';
import 'package:virtual_pa/view/screen/create/create_screen.dart';
import 'package:virtual_pa/view/screen/preferences/preferences.dart';

import '../welcome_screen.dart';

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
    final _tasks = Provider.of<Tasks>(context, listen: false);
    _tasks.userId = _user.userId;
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
        drawer: SizedBox(
          width: 240,
          child: Drawer(
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
                  title: const Text('Preferences'),
                  onTap: () {
                    CustomNavigator.navigateTo(
                        context, (context) => const Preferences());
                  },
                ),
                const Spacer(),
                ListTile(
                  title: Row(
                    children: const [
                      Text('Logout'),
                      Spacer(),
                      Icon(Icons.logout)
                    ],
                  ),
                  onTap: () async {
                    CommonFunctions.showCircularLoadingIndicatorDialog(context);
                    await Provider.of<FirebaseAuthController>(context,
                            listen: false)
                        .signOut();
                    await Provider.of<HiveController>(context, listen: false)
                        .deleteUser();
                    CustomNavigator.navigateToAndRemoveUntil(
                        context, (context) => const WelcomeScreen());
                  },
                )
              ],
            ),
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
  Tasks? tasks;
  late User user;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<User>(context, listen: false);
    if (tasks == null) {
      tasks = Provider.of<Tasks>(context, listen: false);
      tasks!.userId = user.userId;
      tasks!.loadTasks(shouldNotifyListeners: false);
    }
    final registeredContacts =
        Provider.of<RegisteredContacts>(context, listen: false);
    return Column(
      children: [
        Container(
          color: context.read<AppTheme>().backgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Consumer<Tasks>(
              builder: (context, tasks, _) {
                return Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: CustomChip(
                        label: const Text('For Me'),
                        onPressed: () async {
                          tasks.showForMeTask = true;
                        },
                        isSelected: tasks.showForMeTask,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: CustomChip(
                        label: const Text('By Me'),
                        onPressed: () {
                          tasks.showForMeTask = false;
                        },
                        isSelected: !tasks.showForMeTask,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: CustomChip(
                        label: const Text('Urgent'),
                        onPressed: () {
                          tasks.showOnlyUrgent = !tasks.showOnlyUrgent;
                        },
                        isSelected: tasks.showOnlyUrgent,
                      ),
                    ),
                    const Spacer(),
                    CustomIconButton(
                      icon: FaIcon(
                        !tasks.isAscendingOrder
                            ? FontAwesomeIcons.sortAmountDown
                            : FontAwesomeIcons.sortAmountUp,
                      ),
                      onPressed: () {
                        tasks.isAscendingOrder = !tasks.isAscendingOrder;
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        Expanded(
          child: Consumer<Tasks>(
            builder: (context, tasks, _) {
              return tasks.isTaskLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : tasks.list.isEmpty
                      ? Center(
                          child: Text(tasks.showForMeTask
                              ? 'No tasks for you yet'
                              : 'No tasks by you'),
                        )
                      : RefreshIndicator(
                          onRefresh: () async => tasks.loadTasks(),
                          child: ListView.builder(
                            itemCount: tasks.list.length,
                            itemBuilder: (context, index) {
                              final task = tasks.list[index];
                              task.registeredContact = tasks.showForMeTask
                                  ? RegisteredContact(
                                      phoneNo: task.byUserPhoneNo!,
                                      id: task.byUserId)
                                  : RegisteredContact(id: task.atUserId);

                              registeredContacts.searchRegisteredContact(
                                  task.registeredContact!);

                              return user.userId != task.byUserId
                                  ? child(context, task, tasks)
                                  : Dismissible(
                                      key: ValueKey<String>(task.taskId!),
                                      background: Container(
                                        color: Colors.red,
                                        child: Row(
                                          children: const [
                                            Icon(Icons.delete),
                                            SizedBox(
                                              width: 10.0,
                                            ),
                                            Text('Delete')
                                          ],
                                        ),
                                      ),
                                      direction: DismissDirection.startToEnd,
                                      onDismissed: (direction) async {
                                        final taskApiController =
                                            TaskApiController();
                                        CommonFunctions
                                            .showCircularLoadingIndicatorDialog(
                                                context);
                                        final lResponse =
                                            await taskApiController
                                                .deleteTask(task.taskId!);
                                        if (lResponse.responseStatus ==
                                            ResponseStatus.success) {
                                          tasks.deleteTask(task);
                                        }
                                        Navigator.pop(context);
                                      },
                                      confirmDismiss: (direction) async {
                                        return showDialog<bool>(
                                          context: context,
                                          barrierDismissible:
                                              false, // user must tap button!
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0)),
                                              title: const Text('Delete'),
                                              content: const Text(
                                                  'Do you want to delete this task ?'),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: Text(
                                                    'Yes',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText2!
                                                        .copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .errorColor),
                                                  ),
                                                  onPressed: () async {
                                                    Navigator.pop(
                                                        context, true);
                                                  },
                                                ),
                                                TextButton(
                                                  child: Text('No',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyText2!
                                                          .copyWith(
                                                              color: context
                                                                  .read<
                                                                      AppTheme>()
                                                                  .successColor)),
                                                  onPressed: () {
                                                    Navigator.pop(
                                                        context, false);
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: child(context, task, tasks),
                                    );
                            },
                          ),
                        );
            },
          ),
        ),
      ],
    );
  }

  Padding child(BuildContext context, Task task, Tasks tasks) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(color: context.read<AppTheme>().borderColor),
          borderRadius: BorderRadius.circular(18.0),
        ),
        constraints: const BoxConstraints(
          maxHeight: 100,
        ),
        child: ListTile(
          onTap: () {
            CommonFunctions.showBottomSheet(context,
                child: TaskDetails(task: task));
          },
          tileColor: Colors.transparent,
          title: Text(
            CommonFunctions.cutString(task.taskString, 100),
          ),
          subtitle: ChangeNotifierProvider.value(
            value: task.registeredContact,
            builder: (context, snapshot) {
              return ByText(
                precedingString: tasks.showForMeTask ? 'By' : 'To',
              );
            },
          ),
          trailing: Column(
            children: [
              Text(
                CommonFunctions.getddMMyyyy(task.completeBy!),
              ),
              Text(
                task.urgent ? 'URGENT' : '',
                style: Theme.of(context)
                    .textTheme
                    .bodyText2!
                    .copyWith(color: context.read<AppTheme>().successColor),
              ),
              Flexible(
                child: FittedBox(
                  child: getStatusText(
                    task.taskStatus,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget getStatusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.queued:
        return Text('QUEUED',
            style: Theme.of(context)
                .textTheme
                .bodyText2!
                .copyWith(color: Colors.deepOrange));
      case TaskStatus.started:
        return Text('STARTED',
            style: Theme.of(context)
                .textTheme
                .bodyText2!
                .copyWith(color: Colors.deepPurpleAccent));
      case TaskStatus.completed:
        return Text('COMPLETED',
            style: Theme.of(context)
                .textTheme
                .bodyText2!
                .copyWith(color: context.read<AppTheme>().successColor));
    }
  }
}

class ByText extends StatelessWidget {
  const ByText({Key? key, this.precedingString = 'By'}) : super(key: key);

  final String precedingString;

  @override
  Widget build(BuildContext context) {
    final registeredContact = Provider.of<RegisteredContact>(context);
    return Text(
      '$precedingString ${registeredContact.fullName ?? registeredContact.phoneNo}',
      style: Theme.of(context)
          .textTheme
          .bodyText2!
          .copyWith(color: context.read<AppTheme>().successColor),
    );
  }
}

class AppointmentView extends StatefulWidget {
  const AppointmentView({Key? key}) : super(key: key);

  @override
  _AppointmentViewState createState() => _AppointmentViewState();
}

class _AppointmentViewState extends State<AppointmentView> {
  late User user;
  Appointments? appointments;

  @override
  Widget build(BuildContext context) {
    user = Provider.of<User>(context, listen: false);
    if (appointments == null) {
      appointments = Provider.of<Appointments>(context);
      appointments!.userId = user.userId;
      appointments!.loadAppointments(shouldNotifyListeners: false);
    }
    final registeredContacts =
        Provider.of<RegisteredContacts>(context, listen: false);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Consumer<Appointments>(
            builder: (context, appointments, _) {
              return Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: CustomChip(
                        label: const Text('For Me'),
                        onPressed: () {
                          appointments.showForMeAppointment = true;
                        },
                        isSelected: appointments.showForMeAppointment),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: CustomChip(
                        label: const Text('By Me'),
                        onPressed: () {
                          appointments.showForMeAppointment = false;
                        },
                        isSelected: !appointments.showForMeAppointment),
                  ),
                  const Spacer(),
                  CustomIconButton(
                    icon: FaIcon(
                      !appointments.isAscendingOrder
                          ? FontAwesomeIcons.sortAmountDown
                          : FontAwesomeIcons.sortAmountUp,
                    ),
                    onPressed: () {
                      appointments.isAscendingOrder =
                          !appointments.isAscendingOrder;
                    },
                  ),
                ],
              );
            },
          ),
        ),
        Expanded(
          child: Consumer<Appointments>(
            builder: (context, appointments, _) {
              if (appointments.isAppointmentLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (appointments.list.isEmpty) {
                return Center(
                  child: Text(
                    'No appointments ' +
                        (appointments.showForMeAppointment
                            ? 'for you yet'
                            : 'by you yet'),
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () async => appointments.loadAppointments(),
                child: ListView.builder(
                  itemCount: appointments.list.length,
                  itemBuilder: (context, index) {
                    final appointment = appointments.list[index];
                    appointment.byRegisteredContact =
                        appointments.showForMeAppointment
                            ? RegisteredContact(
                                phoneNo: appointment.phoneNo,
                                id: appointment.byUserId)
                            : RegisteredContact(id: appointment.atUserId);
                    registeredContacts.searchRegisteredContact(
                        appointment.byRegisteredContact!);
                    return user.userId != appointment.byUserId
                        ? child(context, appointment, appointments)
                        : Dismissible(
                            key: ValueKey<String>(appointment.appointmentId!),
                            background: Container(
                              color: Colors.red,
                              child: Row(
                                children: const [
                                  Icon(Icons.delete),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Text('Delete')
                                ],
                              ),
                            ),
                            direction: DismissDirection.startToEnd,
                            onDismissed: (direction) async {
                              final appointmentApiController =
                                  AppointmentApiController();
                              CommonFunctions
                                  .showCircularLoadingIndicatorDialog(context);
                              final lResponse = await appointmentApiController
                                  .deleteAppointment(
                                      appointment.appointmentId!);
                              if (lResponse.responseStatus ==
                                  ResponseStatus.success) {
                                appointments.deleteAppointment(appointment);
                              }
                              Navigator.pop(context);
                            },
                            confirmDismiss: (direction) async {
                              return showDialog<bool>(
                                context: context,
                                barrierDismissible:
                                    false, // user must tap button!
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0)),
                                    title: const Text('Delete'),
                                    content: const Text(
                                        'Do you want to delete this appointment ?'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text(
                                          'Yes',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2!
                                              .copyWith(
                                                  color: Theme.of(context)
                                                      .errorColor),
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context, true);
                                        },
                                      ),
                                      TextButton(
                                        child: Text('No',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2!
                                                .copyWith(
                                                    color: context
                                                        .read<AppTheme>()
                                                        .successColor)),
                                        onPressed: () {
                                          Navigator.pop(context, false);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: child(context, appointment, appointments),
                          );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Padding child(BuildContext context, Appointment appointment,
      Appointments appointments) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(color: context.read<AppTheme>().borderColor),
          borderRadius: BorderRadius.circular(18.0),
        ),
        constraints: const BoxConstraints(
          maxHeight: 100,
        ),
        child: ListTile(
          onTap: () {
            CommonFunctions.showBottomSheet(
              context,
              child: AppointmentDetails(
                appointment: appointment,
              ),
            );
          },
          tileColor: Colors.transparent,
          title: Text(
            CommonFunctions.cutString(appointment.appointmentString!, 80),
          ),
          subtitle: ChangeNotifierProvider.value(
            value: appointment.byRegisteredContact,
            builder: (context, snapshot) {
              return ByText(
                precedingString:
                    appointments.showForMeAppointment ? 'By' : 'To',
              );
            },
          ),
          trailing: Column(
            children: [
              Text(
                CommonFunctions.getddMMyyyy(appointment.date!),
              ),
              getStatusText(appointment.status)
            ],
          ),
        ),
      ),
    );
  }

  Widget getStatusText(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return Text('PENDING',
            style: Theme.of(context)
                .textTheme
                .bodyText2!
                .copyWith(color: Colors.deepPurpleAccent));
      case AppointmentStatus.rejected:
        return Text('REJECTED',
            style: Theme.of(context)
                .textTheme
                .bodyText2!
                .copyWith(color: Colors.deepOrange));
      case AppointmentStatus.completed:
        return Text('COMPLETED',
            style: Theme.of(context)
                .textTheme
                .bodyText2!
                .copyWith(color: context.read<AppTheme>().successColor));
    }
  }
}

class TaskDetails extends StatefulWidget {
  const TaskDetails({Key? key, required this.task}) : super(key: key);
  final Task task;

  @override
  State<TaskDetails> createState() => _TaskDetailsState();
}

class _TaskDetailsState extends State<TaskDetails> {
  updateTaskStatus(TaskStatus status) async {
    if (widget.task.taskStatus != status) {
      CommonFunctions.showCircularLoadingIndicatorDialog(context);
      final lResponse = await TaskApiController()
          .updateTaskStatus(widget.task.taskId!, status);
      if (lResponse.responseStatus == ResponseStatus.success) {
        Navigator.pop(context);
        setState(() {
          widget.task.taskStatus = status;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context, listen: false);
    final successStyle = Theme.of(context)
        .textTheme
        .bodyText2!
        .copyWith(color: context.read<AppTheme>().successColor);
    const space = SizedBox(
      height: 8,
    );
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Task Details'),
              CustomIconButton(
                iconData: Icons.close,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          Text(widget.task.taskString),
          space,
          Row(
            children: [
              const Text('Complete By : '),
              Text(
                CommonFunctions.getddMMyyyyhmmssa(widget.task.completeBy!),
                style: successStyle,
              ),
            ],
          ),
          if (widget.task.urgent) space,
          Text(
            widget.task.urgent ? 'URGENT' : '',
            style: successStyle,
          ),
          space,
          if (widget.task.byUserId == user.userId)
            Row(
              children: [
                const Text('Task Status : '),
                Text(
                  widget.task.taskStatus.toString(),
                  style: successStyle,
                ),
              ],
            ),
          space,
          Row(
            children: [
              const Text('By : '),
              if (user.userId != widget.task.byUserId)
                ChangeNotifierProvider.value(
                  value: widget.task.registeredContact,
                  builder: (context, snapshot) {
                    return const ByText();
                  },
                )
              else
                Text(
                  'You',
                  style: successStyle,
                )
            ],
          ),
          space,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomChip(
                label: const Text('Queued'),
                onPressed: () async {
                  updateTaskStatus(TaskStatus.queued);
                },
                isSelected: widget.task.taskStatus == TaskStatus.queued,
              ),
              CustomChip(
                label: const Text('Started'),
                onPressed: () {
                  updateTaskStatus(TaskStatus.started);
                },
                isSelected: widget.task.taskStatus == TaskStatus.started,
              ),
              CustomChip(
                label: const Text('Completed'),
                onPressed: () {
                  updateTaskStatus(TaskStatus.completed);
                },
                isSelected: widget.task.taskStatus == TaskStatus.completed,
              )
            ],
          ),
        ],
      ),
    );
  }
}

class AppointmentDetails extends StatefulWidget {
  const AppointmentDetails({Key? key, required this.appointment})
      : super(key: key);

  final Appointment appointment;

  @override
  State<AppointmentDetails> createState() => _AppointmentDetailsState();
}

class _AppointmentDetailsState extends State<AppointmentDetails> {
  updateAppointmentStatus(AppointmentStatus status) async {
    if (widget.appointment.status != status) {
      CommonFunctions.showCircularLoadingIndicatorDialog(context);
      final lResponse = await AppointmentApiController()
          .updateAppointmentStatus(widget.appointment.appointmentId!, status);
      if (lResponse.responseStatus == ResponseStatus.success) {
        Navigator.pop(context);
        setState(() {
          widget.appointment.status = status;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final successStyle = Theme.of(context)
        .textTheme
        .bodyText2!
        .copyWith(color: context.read<AppTheme>().successColor);
    const space = SizedBox(
      height: 8,
    );
    final user = Provider.of<User>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Appointment Details'),
              CustomIconButton(
                iconData: Icons.close,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          Text(widget.appointment.appointmentString ?? ''),
          space,
          Row(
            children: [
              const Text('Appointment date : '),
              Text(
                CommonFunctions.getddMMyyyy(widget.appointment.date!),
                style: successStyle,
              ),
            ],
          ),
          space,
          Row(
            children: [
              const Text('Appointment Slot : '),
              Text(
                widget.appointment.slot ?? '',
                style: successStyle,
              ),
            ],
          ),
          space,
          Row(
            children: [
              const Text('To : '),
              if (user.userId != widget.appointment.atUserId)
                ChangeNotifierProvider.value(
                  value: widget.appointment.byRegisteredContact,
                  builder: (context, snapshot) {
                    return const ByText(
                      precedingString: '',
                    );
                  },
                )
              else
                Text(
                  'You',
                  style: successStyle,
                )
            ],
          ),
          space,
          Row(
            children: [
              const Text('By : '),
              if (user.userId != widget.appointment.byUserId)
                ChangeNotifierProvider.value(
                  value: widget.appointment.byRegisteredContact,
                  builder: (context, snapshot) {
                    return const ByText();
                  },
                )
              else
                Text(
                  'You',
                  style: successStyle,
                )
            ],
          ),
          space,
          if (widget.appointment.atUserId == user.userId)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomChip(
                  label: const Text('Pending'),
                  onPressed: () async {
                    updateAppointmentStatus(AppointmentStatus.pending);
                  },
                  isSelected:
                      widget.appointment.status == AppointmentStatus.pending,
                ),
                CustomChip(
                  label: const Text('Rejected'),
                  onPressed: () {
                    updateAppointmentStatus(AppointmentStatus.rejected);
                  },
                  isSelected:
                      widget.appointment.status == AppointmentStatus.rejected,
                ),
                CustomChip(
                  label: const Text('Completed'),
                  onPressed: () {
                    updateAppointmentStatus(AppointmentStatus.completed);
                  },
                  isSelected:
                      widget.appointment.status == AppointmentStatus.completed,
                )
              ],
            ),
        ],
      ),
    );
  }
}
