class OfferData {
  bool? status;
  int? statusCode;
  Data? data;
  int? userPoints;
  int? userPercentage;

  OfferData(
      {this.status,
        this.statusCode,
        this.data,
        this.userPoints,
        this.userPercentage});

  OfferData.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    statusCode = json['status_code'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    userPoints = json['user_points'];
    userPercentage = json['user_percentage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['status_code'] = this.statusCode;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['user_points'] = this.userPoints;
    data['user_percentage'] = this.userPercentage;
    return data;
  }
}

class Data {
  String? offerId;
  String? createdOn;
  String? updatedOn;
  String? title;
  String? image;
  String? description;
  int? requiredPoints;
  String? createdBy;
  String? updatedBy;

  Data(
      {this.offerId,
        this.createdOn,
        this.updatedOn,
        this.title,
        this.image,
        this.description,
        this.requiredPoints,
        this.createdBy,
        this.updatedBy});

  Data.fromJson(Map<String, dynamic> json) {
    offerId = json['offer_id'];
    createdOn = json['created_on'];
    updatedOn = json['updated_on'];
    title = json['title'];
    image = json['image'];
    description = json['description'];
    requiredPoints = json['required_points'];
    createdBy = json['created_by'];
    updatedBy = json['updated_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['offer_id'] = this.offerId;
    data['created_on'] = this.createdOn;
    data['updated_on'] = this.updatedOn;
    data['title'] = this.title;
    data['image'] = this.image;
    data['description'] = this.description;
    data['required_points'] = this.requiredPoints;
    data['created_by'] = this.createdBy;
    data['updated_by'] = this.updatedBy;
    return data;
  }
}
