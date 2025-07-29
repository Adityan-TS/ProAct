
class TaskModel {
  final int id;
  String title;
  String startTime;
  String endTime;
  int status;
  final String createdBy;
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.createdBy,
    required this.createdAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      status: json['status'],
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'start_time': startTime,
      'end_time': endTime,
      'status': status,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toLocalJson() {
    return {
      'name': title,
      'startTime': startTime,
      'endTime': endTime,
      'currenttimeinmillis': '${DateTime.now().millisecondsSinceEpoch}',
      'donesStatus': status == 0 ? 'false' : 'true'
    };
  }
}
