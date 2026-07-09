import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:proact/constants/constants.dart';
import 'package:proact/notification_service.dart';
import 'package:proact/utils/app_urls.dart';
import 'package:proact/utils/hive_store_util.dart';
import 'package:proact/utils/utils.dart';

import '../../controller/home_controller.dart';
import '../../services/http_service.dart';

// #region debug-point A:dbg-reporter
const String _dbgUrl =
    String.fromEnvironment('DEBUG_SERVER_URL', defaultValue: 'http://192.168.1.150:7777/event');
const String _dbgSessionId =
    String.fromEnvironment('DEBUG_SESSION_ID', defaultValue: 'proact-ai-not-working');
void _dbg(String hypothesisId, String location, String msg,
    [Map<String, Object?> data = const {}]) {
  () async {
    try {
      final payload = jsonEncode({
        'sessionId': _dbgSessionId,
        'runId': 'pre',
        'hypothesisId': hypothesisId,
        'location': location,
        'msg': msg,
        'data': data,
        'ts': DateTime.now().millisecondsSinceEpoch,
      });
      final client = HttpClient();
      final req = await client.postUrl(Uri.parse(_dbgUrl));
      req.headers.contentType = ContentType.json;
      req.write(payload);
      await req.close();
      client.close();
    } catch (_) {}
  }();
}
// #endregion

class GeminiPrompt extends StatefulWidget {
  final Function(List<Map<String, dynamic>>) onSubmit;
  final int eventId;

  GeminiPrompt({required this.onSubmit, required this.eventId});

  @override
  _GeminiPromptState createState() => _GeminiPromptState();
}

class _GeminiPromptState extends State<GeminiPrompt> {
  final TextEditingController _controller = TextEditingController();
  String _response = '';
  String _message = '';
  HttpService httpService = HttpService();

  int? _extractRequestedDurationMinutes(String input) {
    final text = input.toLowerCase();
    if (RegExp(r'\bhalf an hour\b').hasMatch(text)) return 30;
    if (RegExp(r'\b(an|a|one)\s+hour\b').hasMatch(text)) return 60;
    final hourMatch =
        RegExp(r'\bfor\s+(\d+)\s*(hours|hour|hrs|hr)\b').firstMatch(text);
    if (hourMatch != null) {
      final hours = int.tryParse(hourMatch.group(1) ?? '');
      if (hours != null && hours > 0) return hours * 60;
    }
    final minMatch =
        RegExp(r'\bfor\s+(\d+)\s*(minutes|minute|mins|min)\b').firstMatch(text);
    if (minMatch != null) {
      final mins = int.tryParse(minMatch.group(1) ?? '');
      if (mins != null && mins > 0) return mins;
    }
    return null;
  }

  bool _looksLikeSingleTaskRequest(String input) {
    final text = input.toLowerCase();
    if (text.contains('\n')) return false;
    if (text.contains(',')) return false;
    if (RegExp(r'\b(and|then|also|plus)\b').hasMatch(text)) return false;
    if (RegExp(r'\btask\s*\d+\b').hasMatch(text)) return false;
    return true;
  }

  String _extractTaskTitle(String input) {
    final text = input.trim();
    final forIndex = text.toLowerCase().indexOf(' for ');
    final raw = (forIndex > 0) ? text.substring(0, forIndex) : text;
    final cleaned = raw
        .replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (cleaned.isEmpty) return 'Task';
    return cleaned.substring(0, 1).toUpperCase() + cleaned.substring(1);
  }

  int _timeToMinutes(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length < 2) return 0;
    final h = int.tryParse(parts[0].trim()) ?? 0;
    final m = int.tryParse(parts[1].trim().substring(0, 2)) ?? 0;
    return (h.clamp(0, 23) * 60) + m.clamp(0, 59);
  }

  String _minutesToTime(int minutes) {
    final m = minutes % (24 * 60);
    final h = (m ~/ 60).toString().padLeft(2, '0');
    final mm = (m % 60).toString().padLeft(2, '0');
    return '$h:$mm';
  }

  List<Map<String, int>> _busyIntervals(List<Map<String, dynamic>> events) {
    final intervals = <Map<String, int>>[];
    for (final e in events) {
      final s = (e['start_time'] ?? '').toString();
      final en = (e['end_time'] ?? '').toString();
      if (s.contains(':') && en.contains(':')) {
        final start = _timeToMinutes(s);
        final end = _timeToMinutes(en);
        if (end > start) intervals.add({'start': start, 'end': end});
      }
    }
    intervals.sort((a, b) => (a['start'] ?? 0).compareTo(b['start'] ?? 0));
    return intervals;
  }

  List<Map<String, dynamic>> _normalizeSchedule({
    required List<Map<String, dynamic>> tasks,
    required List<Map<String, int>> busy,
    int? forceSingleDurationMinutes,
    int? earliestStartMinutes,
  }) {
    if (tasks.isEmpty) return tasks;

    final now = DateTime.now();
    final nextPerfectHour = earliestStartMinutes ??
        ((DateTime(now.year, now.month, now.day, now.hour + 1, 0).hour * 60));

    final source = List<Map<String, dynamic>>.from(tasks);

    if (forceSingleDurationMinutes != null && forceSingleDurationMinutes > 0) {
      final t = Map<String, dynamic>.from(source.first);
      final startMin = _timeToMinutes((t['start_time'] ?? '').toString());
      var start = startMin < nextPerfectHour ? nextPerfectHour : startMin;
      var end = start + forceSingleDurationMinutes;
      bool moved;
      do {
        moved = false;
        for (final b in busy) {
          final bs = b['start'] ?? 0;
          final be = b['end'] ?? 0;
          if (start < be && end > bs) {
            start = be;
            end = start + forceSingleDurationMinutes;
            moved = true;
          }
        }
      } while (moved);
      t['start_time'] = _minutesToTime(start);
      t['end_time'] = _minutesToTime(end);
      return [t];
    }

    final normalized = <Map<String, dynamic>>[];
    int cursor = nextPerfectHour;
    for (final raw in source) {
      final t = Map<String, dynamic>.from(raw);
      final startMin = _timeToMinutes((t['start_time'] ?? '').toString());
      final endMin = _timeToMinutes((t['end_time'] ?? '').toString());
      var duration = endMin - startMin;
      if (duration <= 0) duration = 60;

      var start = startMin < cursor ? cursor : startMin;
      var end = start + duration;

      bool moved;
      do {
        moved = false;
        for (final b in busy) {
          final bs = b['start'] ?? 0;
          final be = b['end'] ?? 0;
          if (start < be && end > bs) {
            start = be;
            end = start + duration;
            moved = true;
          }
        }
      } while (moved);

      t['start_time'] = _minutesToTime(start);
      t['end_time'] = _minutesToTime(end);
      normalized.add(t);
      cursor = end;
    }
    return normalized;
  }

  Future<void> _submitEventPromptToGemini(String prompt) async {
    try {
      // #region debug-point D:event-prompt:start
      _dbg('D', 'gemini_prompt.dart:_submitEventPromptToGemini', '[DEBUG] ai:eventPrompt:start', {
        'eventId': widget.eventId,
        'promptLen': prompt.length,
      });
      // #endregion
      // Define events variable and add event details to the prompt
      List<Map<String, dynamic>> events =
      []; // Replace with your actual events list

      String eventDataJson = HiveStoreUtil.getString(HiveStoreUtil.eventData,defaultVal: '[]');
      events = List<Map<String, dynamic>>.from(
        (jsonDecode(eventDataJson) as List)
            .map((e) => Map<String, String>.from(e)),
      );
      // #region debug-point D:event-prompt:events-loaded
      _dbg('D', 'gemini_prompt.dart:_submitEventPromptToGemini', '[DEBUG] ai:eventPrompt:eventsLoaded', {
        'eventsCount': events.length,
        'eventDataLen': eventDataJson.length,
      });
      // #endregion

      String? startTime =
      events[widget.eventId]['Start_time']; // nullable String
      String? endTime = events[widget.eventId]['end_time']; // nullable String

      String promptWithMessage =
          'Imagine you have been given the following task: "' +
              events[widget.eventId]["name"]! +
              ' from ' +
              startTime! +
              ' to ' +
              endTime! +
              '". To better understand and approach this task effectively, consider asking questions that clarify: ' +
              prompt;

      print("prompt message ${promptWithMessage}");

      var response = await httpService.postRequest(AppUrls.gemini_url,showLoading: true,closeLoading: true,rowData: {
        "contents": [
          {
            "parts": [{"text" : promptWithMessage}]
          }
        ]
      });
      if(checkResponse(response.statusCode)){
        List parts = response.data["candidates"][0]["content"]["parts"] ?? []; // Display AI response
        print("response from ai ${response}");
        _controller.clear(); // Clear the text field after submission
        // });
        Navigator.pop(context);
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: Colors.black26,
                title: Text(
                  '${prompt} for \n"${events[widget.eventId]["name"]}"',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                actions: [
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.close,
                        color: Colors.white,
                      ))
                ],
                content: Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(color: Colors.white),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Text(
                      parts.isEmpty ? "No response" : parts.first['text'],
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                ),
              );
            });
      } else {
        Utils.showToast(
          response.data?['error']?['message']?.toString() ?? 'AI request failed',
        );
      }

    } catch (e) {
      // #region debug-point E:event-prompt:error
      _dbg('E', 'gemini_prompt.dart:_submitEventPromptToGemini', '[DEBUG] ai:eventPrompt:error', {
        'error': e.toString(),
      });
      // #endregion
      print('Error sending prompt to AI: $e');
      // Handle error scenario, such as showing a snackbar
    }
  }

  Future<void> _submitCreateEventPromptToGemini(String prompt) async {
    // final gemini = Gemini.instance; // Initialize Gemini instance

    try {
      // #region debug-point D:create-prompt:start
      _dbg('D', 'gemini_prompt.dart:_submitCreateEventPromptToGemini', '[DEBUG] ai:createPrompt:start', {
        'eventId': widget.eventId,
        'promptLen': prompt.length,
      });
      // #endregion
      // Get current time formatted in 24-hour format
      String currentTime = DateFormat.Hm().format(DateTime.now());

      // Construct the prompt message with the current time included
      String promptWithMessage = prompt;

      // Define events variable and add event details to the prompt
      List<Map<String, dynamic>> events =
      []; // Replace with your actual events list

      String eventDataJson = HiveStoreUtil.getString(HiveStoreUtil.eventData,defaultVal: '[]');
      events = List<Map<String, dynamic>>.from(
        (jsonDecode(eventDataJson) as List)
            .map((e) => Map<String, dynamic>.from(e)),
      );
      // #region debug-point D:create-prompt:events-loaded
      _dbg('D', 'gemini_prompt.dart:_submitCreateEventPromptToGemini', '[DEBUG] ai:createPrompt:eventsLoaded', {
        'eventsCount': events.length,
        'eventDataLen': eventDataJson.length,
      });
      // #endregion

      // Create a set to track used timings
      // Set<String> usedTimingsSet = {};
      final busySlots = <String>[];

      for (int i = 0; i < events.length; i++) {
        String? startTime = events[i]['start_time']; // nullable String
        String? endTime = events[i]['end_time']; // nullable String

        // Ensure startTime and endTime are not null before using them
        if (startTime != null && endTime != null) {
          busySlots.add('$startTime - $endTime');
          // Ensure the timings are unique before adding to the set
          // if (!usedTimingsSet.contains(formattedTiming)) {
          //   promptWithMessage +=
          //       'TASK ${i + 1} == ${events[i]['name']} == $startTime - $endTime\n\n';

          //   usedTimingsSet.add(formattedTiming); // Add to used timings set
          // }
        }
      }

      final requestedDuration = _extractRequestedDurationMinutes(prompt);
      final forceSingle = requestedDuration != null && _looksLikeSingleTaskRequest(prompt);
      final requestedTitle = _extractTaskTitle(prompt);

      if (busySlots.isNotEmpty) {
        promptWithMessage +=
            "\nBusy time slots (do NOT overlap with any of these):\n${busySlots.join('\n')}\n";
      }

      promptWithMessage += "\nRules:\n";
      promptWithMessage += "1) Tasks must not overlap existing busy time slots.\n";
      promptWithMessage += "2) Tasks must not overlap each other. Schedule sequentially.\n";
      promptWithMessage +=
          "3) Earliest possible start time is the next perfect hour after ($currentTime).\n";
      promptWithMessage += "4) Use 24-hour time format HH:MM.\n";

      if (forceSingle) {
        promptWithMessage += "5) Create exactly ONE task only. Do not split into parts.\n";
        promptWithMessage +=
            "6) Duration must be exactly the requested duration in one continuous block.\n";
        promptWithMessage += "7) Task name must be relevant with no extra content.\n";
        promptWithMessage +=
            "\nReturn exactly one line in this format:\nTask 1) # TASK NAME # HH:MM - HH:MM\n";
      } else {
        promptWithMessage += "5) Do not schedule multiple tasks in the same time range.\n";
        promptWithMessage +=
            "\nReturn tasks one per line in this format:\nTask N) # TASK NAME # HH:MM - HH:MM\n";
      }

      print("prompt message ${promptWithMessage}");
      var response = await httpService.postRequest(AppUrls.gemini_url,showLoading: true,closeLoading: true,rowData: {
        "contents": [
          {
            "parts": [{"text" : promptWithMessage}]
          }
        ]
      });
      if(checkResponse(response.statusCode)) {
        List parts = response.data["candidates"][0]["content"]["parts"] ?? []; // Display AI response
        String responseText = parts.isEmpty ? "No response received" : parts.first['text'];
        setState(() {
          _response = responseText; // Display AI response
          _controller.clear(); // Clear the text field after submission
        });

        // Parse response into a list of event data
        List<Map<String, dynamic>> parsedEventData = _parseEventData(responseText, events.length);
        parsedEventData = _normalizeSchedule(
          tasks: parsedEventData,
          busy: _busyIntervals(events),
          forceSingleDurationMinutes: forceSingle ? requestedDuration : null,
        );
        widget.onSubmit(parsedEventData); // Pass parsed data back to parent widget
      } else {
        Utils.showToast(
          response.data?['error']?['message']?.toString() ?? 'AI request failed',
        );
      }
    } catch (e) {
      // #region debug-point E:create-prompt:error
      _dbg('E', 'gemini_prompt.dart:_submitCreateEventPromptToGemini', '[DEBUG] ai:createPrompt:error', {
        'error': e.toString(),
      });
      // #endregion
      print('Error sending prompt to AI: $e');
      // Handle error scenario, such as showing a snackbar
    }
  }

  List<Map<String, dynamic>> _parseEventData(
      String? response, int prevEventCount) {
    List<Map<String, dynamic>> eventData = [];

    if (response != null && response.isNotEmpty) {
      List<String> lines = response.split('\n');
      String? noOfTasks;

      for (String line in lines) {
        if (line.startsWith('No Of Tasks = ')) {
          noOfTasks = line.substring('No Of Tasks = '.length).trim();
        } else if (line.startsWith('Task')) {
          // Assuming line format: Task 1) # NAME OF THE TASK # START TIME - END TIME
          List<String> parts = line.split('#');

          if (parts.length >= 3) {
            String name = parts[1].trim();
            String timeFrame = parts[2].trim();

            // Extract start and end time from timeFrame
            // Example timeFrame: "NAME OF THE TASK # START TIME - END TIME"
            int startIndex = timeFrame.indexOf('#') + 1;
            int endIndex = timeFrame.lastIndexOf('-');

            if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
              String startTime =
              timeFrame.substring(startIndex, endIndex).trim();
              String endTime = timeFrame.substring(endIndex + 1).trim();

              DateTime now = DateTime.now();
              var timings = startTime.split(":");
              int startHour = int.parse(timings[0]);
              int startMinutes = int.parse(timings[1].substring(0, 2));
              var startDateTime = DateTime(
                  now.year, now.month, now.day, startHour, startMinutes);
              startDateTime = startDateTime.subtract(Duration(minutes: 5));

              print("new event number ${prevEventCount + eventData.length}");
              int eventNotifyId = prevEventCount + eventData.length;
              notifyService.scheduleNotification(
                  "Remainder",
                  "${name} ${startTime} - ${endTime}",
                  eventNotifyId,
                  startDateTime.day,
                  startDateTime.hour,
                  startDateTime.minute);
              eventData.add({
                'title': name,
                'start_time': startTime,
                'end_time': endTime,
                'status': 0
              });
            }
          }
        }
      }
    }

    return eventData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

       // Set background color to white
      body: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),

        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Get.theme.iconTheme.color == Colors.black ? Colors.black : Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25))
              ),
              child: Padding(
                padding: const EdgeInsets.all(17.0),
                child: Row(
                  children: [
                    Icon(CupertinoIcons.chat_bubble_text_fill,color: Get.theme.scaffoldBackgroundColor,size: 25,),
                    SizedBox(width: 15,),
                    Text("ProAct Ai",style: TextStyle(color: Get.theme.scaffoldBackgroundColor,fontWeight: FontWeight.w500,fontSize: 16),)
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.0),
                reverse: true, // Start scrolling from the bottom
                child: Column(
                  // crossAxisAlignment: CrossAxisAlignment.stretch,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Display prompt sent to Gemini
                    if (_message.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: 10.0),
                            padding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 16.0),
                            decoration: BoxDecoration(
                              color: Get.theme.iconTheme.color,
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            child: Text('${_message}',style: TextStyle(color: Get.theme.scaffoldBackgroundColor,fontSize: 15),),
                          ),
                        ],
                      ),

                    // Display response received from Gemini
                    if (_response.isNotEmpty)
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7
                        ),
                        // width: ,
                        margin: EdgeInsets.only(bottom: 10.0),
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 16.0),
                        decoration: BoxDecoration(
                          color: Color(0xffd5d5d5),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        child: Text('AI response: $_response',style: TextStyle(color: Colors.black,fontSize: 15)),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                // padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 3.0),
                decoration: BoxDecoration(
                  // color: Theme.of(context).primaryColor,
                  border: Border.all(color: Get.theme.iconTheme.color ?? Colors.black),
                  borderRadius: BorderRadius.circular(50)
                  // BorderRadius.only(
                  //   topLeft: Radius.circular(10.0),
                  //   topRight: Radius.circular(10.0),
                  // ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: TextField(
                          style: TextStyle(fontSize: 15),
                          controller: _controller,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            hintText: 'Enter Your Tasks',
                            hintStyle: TextStyle(fontSize: 15),
                            isCollapsed: true, // Optional: removes extra padding
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.0),
                    Container(
                      decoration: BoxDecoration(
                          color: Get.theme.iconTheme.color,
                        borderRadius: BorderRadius.horizontal(right: Radius.circular(50))
                      ),
                      child: IconButton(
                        icon: Icon(Icons.send, color: Get.theme.scaffoldBackgroundColor,size: 20,),
                        onPressed: () {
                          if (_controller.text.isNotEmpty) {
                            _message = _controller.text;
                            // #region debug-point D:send-pressed
                            _dbg('D', 'gemini_prompt.dart:onPressed', '[DEBUG] ai:sendPressed', {
                              'eventId': widget.eventId,
                              'textLen': _controller.text.length,
                            });
                            // #endregion
                            if (widget.eventId >= 0) {
                              _submitEventPromptToGemini(_controller.text);
                            } else {
                              _submitCreateEventPromptToGemini(_controller.text);
                            }
                            HomeController controller = Get.find();
                            controller.loadUserTasks();
                          }
                        },
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
