import 'dart:io';
import 'dart:isolate';

//import 'package:auto_start_flutter/auto_start_flutter.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:photomall_uptime/commonWidgets/common_app_bar.dart';
import 'package:photomall_uptime/commonWidgets/common_text.dart';
import 'package:photomall_uptime/preferences/preference_helper.dart';
import 'package:photomall_uptime/utils/toast_utils.dart';
import 'package:photomall_uptime/viewModel/home_route_view_model.dart';

import '../api/api_call.dart';
import '../commonWidgets/base_widget.dart';
import '../commonWidgets/common_button.dart';
import '../commonWidgets/menu_pop_up.dart';
import '../constants/common_constants.dart';
import '../constants/route_paths_constants.dart';
import '../controllers/background_task_controller.dart';
import '../drift_db/database.dart';
import '../preferences/preference_constants.dart';

class HomeRoute extends StatefulWidget {
  const HomeRoute({super.key});

  @override
  State<HomeRoute> createState() => _HomeRouteState();
}

@pragma('vm:entry-point')
void startCallback() {
  // The setTaskHandler function must be called to handle the task in the background.
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class _HomeRouteState extends State<HomeRoute> {
  ReceivePort? _receivePort;
  MyTaskHandler myTaskHandler = MyTaskHandler();
  BaseWidget<HomeRouteViewModel>? baseWidget;

  Future<void> _requestPermissionForAndroid() async {
    if (!Platform.isAndroid) {
      return;
    }

    // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
    // onNotificationPressed function to be called.
    //
    // When the notification is pressed while permission is denied,
    // the onNotificationPressed function is not called and the app opens.
    //
    // If you do not use the onNotificationPressed or launchApp function,
    // you do not need to write this code.
    if (!await FlutterForegroundTask.canDrawOverlays) {
      // This function requires `android.permission.SYSTEM_ALERT_WINDOW` permission.
      await FlutterForegroundTask.openSystemAlertWindowSettings();
    }

    // Android 12 or higher, there are restrictions on starting a foreground service.
    //
    // To restart the service on device reboot or unexpected problem, you need to allow below permission.
    if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
      // This function requires `android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` permission.
      await FlutterForegroundTask.requestIgnoreBatteryOptimization();
    }

    // Android 13 and higher, you need to allow notification permission to expose foreground service notification.
    final NotificationPermission notificationPermissionStatus =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermissionStatus != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }
  }

  void _initForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        // foregroundServiceType: AndroidForegroundServiceType.DATA_SYNC,
        channelId: 'foreground_service',
        channelName: 'Foreground Service Notification',
        channelDescription:
            'This notification appears when the foreground service is running.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 30000,
        isOnceEvent: false,
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  Future<ServiceRequestResult> _startForegroundTask() async {
    var res = await myTaskHandler.callbackDispatcher();
    showLog('message is $res');
    // You can save data using the saveData function.
    await FlutterForegroundTask.saveData(key: 'customData', value: 'hello');

    // Register the receivePort before starting the service.
    //final ReceivePort? receivePort = FlutterForegroundTask.receivePort;
    //final bool isRegistered = _registerReceivePort(receivePort);
    //if (!isRegistered) {
    // showLog('Failed to register receivePort!');
    // return false;
    //}

    if (await FlutterForegroundTask.isRunningService) {
      return FlutterForegroundTask.restartService();
    } else {
      return FlutterForegroundTask.startService(
        notificationTitle: 'Foreground Service is running',
        notificationText: 'Tap to return to the app',
        notificationIcon: null,
        callback: startCallback,
      );
    }
  }

  Future<ServiceRequestResult> _stopForegroundTask() {
    return FlutterForegroundTask.stopService();
  }

  bool _registerReceivePort(ReceivePort? newReceivePort) {
    if (newReceivePort == null) {
      return false;
    }

    _closeReceivePort();

    _receivePort = newReceivePort;
    _receivePort?.listen((data) async {
      if (data is int) {
        showLog('eventCount: $data');
      } else if (data is String) {
        if (data == 'onNotificationPressed') {
          if (!context.mounted) return;
          Navigator.of(context).pushNamed(RoutePaths.home);
        }
      } else if (data is DateTime) {
        showLog('timestamp: ${data.toString()}');
      }
    });

    return _receivePort != null;
  }

  void _closeReceivePort() {
    _receivePort?.close();
    _receivePort = null;
  }

  Future<void> _requestPermissions() async {
    // Android 13+, you need to allow notification permission to display foreground service notification.
    //
    // iOS: If you need notification, ask for permission.
    final NotificationPermission notificationPermissionStatus =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermissionStatus != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    ///auto start
    //getAutoStartPermission();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _requestPermissionForAndroid();
      _requestPermissions();
      _initForegroundTask();
      //_startForegroundTask();
      // You can get the previous ReceivePort without restarting the service.
      if (await FlutterForegroundTask.isRunningService) {
        //final newReceivePort = FlutterForegroundTask.receivePort;
        //_registerReceivePort(newReceivePort);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    baseWidget = BaseWidget(
      model: HomeRouteViewModel(),
      onModelReady: (model) async {
        await model.getInitialValues();
      },
      builder: (context, model, child) {
        return WithForegroundTask(
            child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: Scaffold(
            backgroundColor: Colors.black,
            appBar: CommonAppBar(
              isAppBarTitleWidget: true,
              isMainPage: true,
              title: appName,
              actions: const [

              ],
            ),
            body: DoubleBackToCloseApp(
                snackBar: const SnackBar(
                  content: Text('Press back again to exit the $appName app'),
                ),
                child: buildContentView(model)),
            floatingActionButton: Row(mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    _showMonitorBottomSheet(context, model);
                  },
                  child: const Icon(Icons.add),
                ),
                (model.monitor == true)
                    ? FloatingActionButton.extended(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  onPressed: () async {
                    showLog('setMonitorValueFalse init');
                    _stopForegroundTask();
                    model.setMonitorValueFalse();
                    await ToastUtils.getAlert(context,'Monitors are stopped', Colors.red);

                  },
                  icon: const Icon(
                    Icons.stop_circle_sharp,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Stop Monitors',
                    style: TextStyle(color: Colors.white),
                  ),
                )
                    : FloatingActionButton.extended(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  onPressed: () async {
                    if(model.liveStatus.isNotEmpty){
                            showLog('setMonitorValue init');
                            _startForegroundTask();
                            await model.setMonitorValue();
                          }else{
                      await ToastUtils.getAlert(context,'Please add web URLs and start monitoring.', Colors.red);
                    }
                        },
                  icon: const Icon(
                    Icons.restart_alt,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Start Monitors',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ));
      },
    );
    return baseWidget!;
  }

  Widget buildContentView(HomeRouteViewModel model) {
    buttonBuilder(String text, {VoidCallback? onPressed}) {
      return ElevatedButton(
        onPressed: onPressed,
        child: Text(text),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Center(
        child: model.isLoading
            ? CircularProgressIndicator()
            : SingleChildScrollView(
                controller: model.scrollController,
                child: Form(
                  key: model.formKey,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SpinKitRipple(
                          itemBuilder: (_, int index) {
                            return DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: Colors.green,
                              ),
                            );
                          },
                          size: 200.0,
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        ListView.builder(
                            padding: const EdgeInsets.all(15),
                            shrinkWrap: true,
                            itemCount: model.liveStatus.length,
                            itemBuilder: (context, index) {
                              final website = model.liveStatus[index];
                              return Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                          child: CommonText(
                                        text: "${website.websiteURl}",
                                        styleFor: 'title',
                                      )),
                                      IconButton(
                                          onPressed: () async {
                                            await model.eventListenerDao
                                                .deleteEventListenerBYUrl(
                                                    url: website.websiteURl);
                                          },
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.white,
                                          )),
                                      Container(
                                        color: Colors.transparent,
                                        width: 55,
                                        height: 55.0,
                                        child: SpinKitWave(
                                          itemBuilder: (_, int index) {
                                            return DecoratedBox(
                                              decoration: BoxDecoration(
                                                color: !website.live
                                                    ? Colors.red
                                                    : Colors.green,
                                              ),
                                            );
                                          },
                                          size: 50.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Divider()
                                ],
                              );
                            }),
                        const SizedBox(
                          height: 25,
                        ),
                        (model.isRinging)
                            ? Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(100)),
                                child: IconButton(
                                    onPressed: () async {
                                      showLog('IconButton clicked');

                                      await model.eventListenerDao
                                          .updateAlarmStatusFalse(
                                              url: model
                                                  .liveStatus[0].websiteURl);
                                    },
                                    icon: const Icon(
                                      Icons.stop,
                                      color: Colors.red,
                                      size: 45,
                                    )),
                              )
                            : const SizedBox(),
                      ]),
                ),
              ),
      ),
    );
  }

  void _showMonitorBottomSheet(BuildContext context, HomeRouteViewModel model) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // allows full screen height
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        String? _labelText = 'Website URL';
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom, top: 25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  validator: (value) {
                    const urlPattern = r'^(https?:\/\/)?' // Protocol (optional)
                        r'((www\.)?|(?!www\.)?)' // 'www.' (optional)
                        r'[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)+.*$'; // Domain and top-level domain

                    final regex = RegExp(urlPattern);
                    if (value == null ||
                        value.isEmpty ||
                        !regex.hasMatch(value)) {
                      return 'Enter a valid website URL!';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.url,
                  controller: model.webUrlController,
                  decoration: InputDecoration(
                    labelText: _labelText,
                    labelStyle: const TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 15,
                        color: Colors.black),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 2.0),
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: const Color(photomallConnectLogoColour)
                            .withOpacity(.5),
                        width: 2.0,
                      ),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10.0)),
                    ),
                    errorText: null,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: CommonButton(
                  onTap: () async {
                    var web = model.webUrlController.text;

                    showLog('web is $web');
                    if (model.formKey.currentState!.validate()) {
                      await model.upsertWebsitesIntoDb(websiteUrl: web);
                      (model.monitor != true) ? _startForegroundTask() : null;
                      model.webUrlController.text = '';
                      model.setMonitorValue();
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Invalid Website URL: ${model.webUrlController.text}'),
                        ),
                      );
                    }
                  },
                  title: 'Monitor',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
