import 'dart:async';
import 'dart:io';

import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:alarm/service/alarm_storage.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photomall_uptime/api/api_call.dart';
import 'package:photomall_uptime/commonWidgets/base_widget.dart';
import 'package:photomall_uptime/commonWidgets/common_button.dart';
import 'package:photomall_uptime/dao/event_listener_dao.dart';
import 'package:photomall_uptime/drift_db/database.dart';
import 'package:photomall_uptime/utils/battery_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/common_constants.dart';
import '../controllers/background_task_controller.dart';
import '../controllers/log_out_controller.dart';
import '../controllers/splash_screen_view_model.dart';
import '../preferences/preference_constants.dart';
import '../preferences/preference_helper.dart';
import 'package:drift/drift.dart'as drift;
class HomeRouteViewModel extends BaseObserver {
  @override
  void onInternetConnectionBack() {
    // TODO: implement onInternetConnectionBack
  }

  Api api = Api(null);
  TextEditingController webUrlController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  EventListenerDao eventListenerDao =EventListenerDao();
  List<EventListenerData> liveStatus =[];
  ScrollController scrollController = ScrollController();
  BatteryUtils batteryUtils = BatteryUtils();
  MyTaskHandler myTaskHandler = MyTaskHandler();
  LogOutController logOutController = LogOutController();
  bool isRunning = false;
  bool monitor = false;
  final List<Widget> children = <Widget>[];

  bool isRinging =false;
  bool isLoading = false;
  getInitialValues() async {
    isLoading =true;
    await checkUrlsInDb();
    await checkBackgroundTaskRunningOrNot();
    await checkAndroidScheduleExactAlarmPermission();
    await getMonitorValue();
   // await getWebsitesFromDb();
    isLoading =false;
    startRepeatingTimer();
    setBusy(true);

  }


  getMonitorValue() async {
    monitor = await PreferenceHelper.getBool(monitorKey);
    showLog('getMonitorValue $monitor');
  }
  setMonitorValue()async{
    await PreferenceHelper.setBool(monitorKey, true);
    monitor = await PreferenceHelper.getBool(monitorKey);

    notifyListeners();
    showLog('setMonitorValue $monitor');
  }  setMonitorValueFalse()async{
    await PreferenceHelper.setBool(monitorKey, false);
    monitor = await PreferenceHelper.getBool(monitorKey);

    notifyListeners();
    showLog('setMonitorValue $monitor');
  }

  Future<void> checkAndroidScheduleExactAlarmPermission() async {
    final status = await Permission.scheduleExactAlarm.status;
    showLog('Schedule exact alarm permission: $status.');
    if (status.isDenied) {
      showLog('Requesting schedule exact alarm permission...');
      final res = await Permission.scheduleExactAlarm.request();
      showLog('Schedule exact alarm permission ${res.isGranted ? '' : 'not'} granted.');
    }
  }
  checkUrlsInDb() async {
    var websites = await eventListenerDao.getEvents();
    showLog('checkUrlsInDb $websites');
    if(websites.isEmpty){
      children.add(const SizedBox());
    }

  }


  checkBackgroundTaskRunningOrNot() async {
    bool backgroundTask = await PreferenceHelper.getBool(backgroundTaskKey);
    if (backgroundTask) {
      isRunning = true;
      setBusy(true);
    }
    showLog('backgroundTask model $backgroundTask');

  }

  String getTimeFromTimestamp(DateTime timestamp) {
    final DateFormat formatter = DateFormat('hh:mm a'); // 12-hour format with AM/PM
    return formatter.format(timestamp);
  }

  upsertWebsitesIntoDb({required String websiteUrl})async{
    showLog('upsertWebsitesIntoDb $websiteUrl ');
    await eventListenerDao.insertEvents(
      [EventListenerCompanion(inTime: drift.Value(DateTime.now().toString()),live:drift.Value(true),websiteURl: drift.Value(websiteUrl) )]
    );
    notifyListeners();
    showLog('  $websiteUrl inserted');

  }

  Stream<List<EventListenerData>> getWebsitesFromDb() {
    return eventListenerDao.watchEvents();
  }
  Timer? _timer;

  void startRepeatingTimer() {

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      showLog('This message is printed every second');
      liveStatus = await eventListenerDao.getEvents();
      await AlarmStorage.init();
      isRinging =await Alarm.isRinging(42);

      notifyListeners();

      // To stop the timer, use timer.cancel()
    });
  }

  void stopRepeatingTimer() {
    _timer?.cancel();
  }

  Icon getIcon(String status) {
    showLog('getIcon $status');
    switch (status) {
      case 'outgoing':
        return const Icon(Icons.call_made);
      case 'missed':
        return const Icon(Icons.call_missed);
      case 'incoming':
        return const Icon(Icons.call_received);
      default:
        return const Icon(Icons.help); // Default icon if status doesn't match
    }
  }

  onPop(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Are you sure want to exit ?'),
              actions: [
                CommonButton(
                    onTap: () {
                      Navigator.of(context).pop();
                      SystemChannels.platform
                          .invokeMethod('SystemNavigator.pop');
                    },
                    title: 'close'),
                CommonButton(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    title: 'Back')
              ],
            ));
  }
}
