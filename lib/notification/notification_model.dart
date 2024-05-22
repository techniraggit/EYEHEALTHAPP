class NotificationModel {
  bool? status;
  int? statusCode;
  List<NotificationData>? data;
  int? isReadFalseCount;

  NotificationModel(
      {this.status, this.statusCode, this.data, this.isReadFalseCount});

  NotificationModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    statusCode = json['status_code'];
    if (json['data'] != null) {
      data = <NotificationData>[];
      json['data'].forEach((v) {
        data!.add(NotificationData.fromJson(v));
      });
    }
    isReadFalseCount = json['is_read_false_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['status'] = status;
    data['status_code'] = statusCode;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['is_read_false_count'] = isReadFalseCount;
    return data;
  }
}

class NotificationData {
  int? id;
  String? title;
  String? message;
  String? created;
  bool? isRead;
  bool isExpanded = false;

  NotificationData({this.id, this.title, this.message, this.created, this.isRead});

  NotificationData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    message = json['message'];
    created = json['created'];
    isRead = json['is_read'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['message'] = message;
    data['created'] = created;
    data['is_read'] = isRead;
    return data;
  }
}