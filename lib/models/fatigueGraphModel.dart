
import 'dart:ffi';
class FatigueGraph {
  bool status;
  int statusCode;
  List<Data> data;

  FatigueGraph({required this.status, required this.statusCode, required this.data});

  factory FatigueGraph.fromJson(Map<String, dynamic> json) {
    return FatigueGraph(
      status: json['status'],
      statusCode: json['status_code'],
      data: json['data'] != null
          ? List<Data>.from(json['data'].map((item) => Data.fromJson(item)))
          : <Data>[],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['status_code'] = statusCode;
    data['data'] = this.data.map((v) => v.toJson()).toList();
    return data;
  }
}

class Data {
  String date;
  double value;
  bool isFatigueRight;
  bool isMildTirednessRight;
  bool isFatigueLeft;
  bool isMildTirednessLeft;

  Data({
    required this.date,
    required this.value,
    required this.isFatigueRight,
    required this.isMildTirednessRight,
    required this.isFatigueLeft,
    required this.isMildTirednessLeft,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      date: json['date'],
      value: json['value'].toDouble(),
      isFatigueRight: json['is_fatigue_right'],
      isMildTirednessRight: json['is_mild_tiredness_right'],
      isFatigueLeft: json['is_fatigue_left'],
      isMildTirednessLeft: json['is_mild_tiredness_left'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = this.date;
    data['value'] = this.value;
    data['is_fatigue_right'] = this.isFatigueRight;
    data['is_mild_tiredness_right'] = this.isMildTirednessRight;
    data['is_fatigue_left'] = this.isFatigueLeft;
    data['is_mild_tiredness_left'] = this.isMildTirednessLeft;
    return data;
  }
}
