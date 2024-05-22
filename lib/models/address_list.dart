class AddressList {
  bool? status;
  int? statusCode;
  List<Data>? data;

  AddressList({this.status, this.statusCode, this.data});

  AddressList.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    statusCode = json['status_code'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['status_code'] = statusCode;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? addressId;
  String? address;
  String? postalCode;
  String? city;
  String? state;
  String? country;
  String? fullAddress;

  Data(
      {this.addressId,
        this.address,
        this.postalCode,
        this.city,
        this.state,
        this.country,
        this.fullAddress});

  Data.fromJson(Map<String, dynamic> json) {
    addressId = json['address_id'];
    address = json['address'];
    postalCode = json['postal_code'];
    city = json['city'];
    state = json['state'];
    country = json['country'];
    fullAddress = json['full_address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['address_id'] = addressId;
    data['address'] = address;
    data['postal_code'] = postalCode;
    data['city'] = city;
    data['state'] = state;
    data['country'] = country;
    data['full_address'] = fullAddress;
    return data;
  }
}