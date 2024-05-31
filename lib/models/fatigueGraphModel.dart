class fatigueGraph {
  bool? status;
  int? statusCode;
  List<Data>? data;

  fatigueGraph({this.status, this.statusCode, this.data});

  fatigueGraph.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    statusCode = json['status_code'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['status_code'] = this.statusCode;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? date;
  double? value;
  bool? isFatigueRight;
  bool? isMildTirednessRight;
  bool? isFatigueLeft;
  bool? isMildTirednessLeft;

  Data(
      {this.date,
        this.value,
        this.isFatigueRight,
        this.isMildTirednessRight,
        this.isFatigueLeft,
        this.isMildTirednessLeft});

  Data.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    value = json['value'];
    isFatigueRight = json['is_fatigue_right'];
    isMildTirednessRight = json['is_mild_tiredness_right'];
    isFatigueLeft = json['is_fatigue_left'];
    isMildTirednessLeft = json['is_mild_tiredness_left'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['date'] = this.date;
    data['value'] = this.value;
    data['is_fatigue_right'] = this.isFatigueRight;
    data['is_mild_tiredness_right'] = this.isMildTirednessRight;
    data['is_fatigue_left'] = this.isFatigueLeft;
    data['is_mild_tiredness_left'] = this.isMildTirednessLeft;
    return data;
  }
}
