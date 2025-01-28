// The callback function should always be a top-level function.
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'package:alarm/alarm.dart';
import 'package:alarm/service/alarm_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:photomall_uptime/controllers/splash_screen_view_model.dart';
import 'package:photomall_uptime/preferences/preference_helper.dart';
import 'package:photomall_uptime/utils/battery_utils.dart';
import '../api/api_call.dart';
import '../constants/common_constants.dart';
import '../dao/event_listener_dao.dart';
import '../dao/logs_dao.dart';
import '../drift_db/database.dart' as db;
import 'package:drift/drift.dart' as drift;
import 'package:http/http.dart' as http;

import '../drift_db/database.dart';
import '../preferences/preference_constants.dart';

class MyTaskHandler extends TaskHandler {
  SendPort? _sendPort;
  int _eventCount = 0;
  var num = '';
  List<EventListenerData> websites = [];
  bool isRinging =false;
  List<EventListenerData> liveStatus =[];

  BatteryUtils batteryUtils = BatteryUtils();
  EventListenerDao eventListenerDao = EventListenerDao();
  List<db.EventListenerCompanion> eventListenerEntity = [];

  // Called when the task is started.
  @override
  void onStart(DateTime timestamp) async {
    // You can use the getData function to get the stored data.
    final customData =
        await FlutterForegroundTask.getData<String>(key: 'customData');
    showLog('customData: $customData');
  }

  // Called every [interval] milliseconds in [ForegroundTaskOptions].
  @override
  void onRepeatEvent(DateTime timestamp) async {
    InternetConnectionStatus data =
        await InternetConnectionChecker().connectionStatus;
    showLog('callbackDispatcher $data');
    showLog('sim');
    if (data == InternetConnectionStatus.connected) {
      await fetchStatusCode();
    } else {
      showLog('No internet connection');
    }
    liveStatus = await eventListenerDao.getEvents();
    await AlarmStorage.init();
    isRinging =await Alarm.isRinging(42);
    FlutterForegroundTask.updateService(
      notificationButtons: [
        (isRinging)
            ? const NotificationButton(id: 'stop alarm', text: 'Stop Alarm')
            : const NotificationButton(
                id: 'Stop Monitor',
                text: 'Stop Monitors')
      ],
      notificationTitle: appName,
      notificationText: 'Running In Background',
    );
    // Send data to the main isolate.
    // sendPort?.send(_eventCount);
    _eventCount++;
  }

  // Called when the notification button on the Android platform is pressed.
  @override
  void onDestroy(DateTime timestamp) async {
    showLog('onDestroy');
  }

  // Called when the notification button on the Android platform is pressed.
  @override
  Future<void> onNotificationButtonPressed(String id) async {
    showLog('onNotificationButtonPressed >> $id');
    if(id=='stop alarm'){
       eventListenerDao
          .updateAlarmStatusFalse(
          url:
              liveStatus[0].websiteURl);
      showLog('id is $id');
    }if(id=='Stop Monitor'){
      showLog('id is $id');
       setMonitorValueFalse();
      FlutterForegroundTask.stopService();


    }
  }

  // Called when the notification itself on the Android platform is pressed.
  //
  // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
  // this function to be called.
  @override
  void onNotificationPressed() {
    // Note that the app will only route to "/resume-route" when it is exited so
    // it will usually be necessary to send a message through the send port to
    // signal it to restore state when the app is already started.
    //FlutterForegroundTask.launchApp("/resume-route");
    // _sendPort?.send('onNotificationPressed');
  }

  Future<String> callbackDispatcher() async {
    showLog('Background Services are Working!');

    return 'jay';
  }

  fetchStatusCode() async {
    final googleResponse = await http
        .get(Uri.parse('https://www.google.com/'))
        .timeout(const Duration(seconds: 10));
    showLog('googleResponse ${googleResponse.statusCode}');

    if (googleResponse.statusCode == 200) {
      String? title = 'Server Down';
      String? alarmStatus = '';
      await AlarmStorage.init();
      bool ifAnyWebsitesDown = false;
      bool isRinging = await Alarm.isRinging(42);
      websites = await eventListenerDao.getEvents();
      if (websites.isNotEmpty) {
        for (int i = 0; i < websites.length; i++) {
          if (websites[i].live == false) {
            ifAnyWebsitesDown = true;
          }
          if (websites[0].inTime == '2') {
            showLog('alarm status from db ${websites[0].inTime}');
            alarmStatus = '2';
          } else {
            alarmStatus = '1';
          }
        }
        for (int i = 0; i < websites.length; i++) {
          final url = Uri.parse(websites[i].websiteURl);
          var alarmSettings = AlarmSettings(
            id: 42,
            dateTime: DateTime.now(),
            assetAudioPath: 'assets/images/alarm.mp3',
            loopAudio: true,
            vibrate: true,
            volume: 1.0,
            fadeDuration: 3.0,
            notificationTitle: title,
            notificationBody: websites[i].websiteURl,
            enableNotificationOnKill: true,
          );
          try {
            showLog('websites fetchStatusCode $url --- .$ifAnyWebsitesDown');

            final response =
                await http.get(url).timeout(const Duration(seconds: 10));
            showLog('response body: ${response.statusCode}');
            if (response.statusCode == 200) {
              await AlarmStorage.init();
              (ifAnyWebsitesDown == true)
                  ? null
                  : await eventListenerDao.updateAlarmStatusTrue(
                      url: websites[0].websiteURl);

              (ifAnyWebsitesDown != true) ? await Alarm.stopAll() : null;
              showLog(
                  'Request was successful with status code: ${response.statusCode}');

              await eventListenerDao.updateStatusTrue(
                  url: websites[i].websiteURl);
            } else if (response.statusCode == 500 ||
                response.statusCode == 502 ||
                response.statusCode == 503) {
              showLog('$url is down. SocketException:  $alarmStatus');
              try {
                await AlarmStorage.init();
                (alarmStatus == '2')
                    ? await Alarm.stopAll()
                    : await Alarm.set(alarmSettings: alarmSettings);

                showLog('$url is down else alarm status :$alarmStatus');
                await eventListenerDao.updateStatusFalse(
                    url: websites[i].websiteURl);
              } catch (e, s) {
                showLog('Failed to set alarm: $e,$s');
              }
            } else {
              showLog(
                  'Request failed with status code: ${response.statusCode}');
              //await AlarmStorage.init();
              // (alarmStatus == '2')
              // ? await Alarm.stopAll()
              //: await Alarm.set(alarmSettings: alarmSettings);

              showLog('$url is down else alarm status :$alarmStatus');
              //  await eventListenerDao.updateStatusFalse(
              // url: websites[i].websiteURl);
            }
          } on TimeoutException {
            showLog('$url request timed out. TimeoutException: $alarmStatus');
          } on SocketException {
            showLog('$url is down. SocketException:  $alarmStatus');
            InternetConnectionStatus data =
                await InternetConnectionChecker().connectionStatus;
            showLog('callbackDispatcher $data');
            showLog('sim');
            if (data == InternetConnectionStatus.connected) {
              try {
                await AlarmStorage.init();
                (alarmStatus == '2')
                    ? await Alarm.stopAll()
                    : await Alarm.set(alarmSettings: alarmSettings);

                showLog('$url is down else alarm status :$alarmStatus');
                await eventListenerDao.updateStatusFalse(
                    url: websites[i].websiteURl);
              } catch (e, s) {
                showLog('Failed to set alarm: $e,$s');
              }
            }
          } on http.ClientException catch (e) {
            /* showLog('$url is down. ClientException: ${e.message}');
          await eventListenerDao.updateStatusFalse(url: websites[i].websiteURl);

          await Alarm.set(alarmSettings: alarmSettings);*/
          } catch (e) {
            showLog('$url is down. Unhandled exception:a $e');
            /* await eventListenerDao.updateStatusFalse(url: websites[i].websiteURl);

          await Alarm.set(alarmSettings: alarmSettings);*/
          }
        }
      } else {
        await AlarmStorage.init();

        isRinging ? await Alarm.stopAll() : null;
        _stopForegroundTask();
        await setMonitorValueFalse();
        showLog('websites not found in local Db');
      }
    }
  }

  Future<ServiceRequestResult> _stopForegroundTask() {
    return FlutterForegroundTask.stopService();
  }

  setMonitorValueFalse() async {
    await PreferenceHelper.setBool(monitorKey, false);
  }

  static const MethodChannel _channel =
      MethodChannel('com.example/background_tasks');

  static Future<void> registerBootReceiver() async {
    try {
      await _channel.invokeMethod('registerBootReceiver');
    } on PlatformException catch (e) {
      print("Failed to register boot receiver: '${e.message}'.");
    }
  }
}
