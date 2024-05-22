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
  String? addressId;
  String? address;
  String? postalCode;
  String? city;
  String? state;
  String? country;
  String? fullAddress;
  String? fullName;
  String? phoneNumber;
  String? email;
  String? locality;
  bool? isDefault;
  String? addressType;

  Data(
      {this.addressId,
        this.address,
        this.postalCode,
        this.city,
        this.state,
        this.country,
        this.fullAddress,
        this.fullName,
        this.phoneNumber,
        this.email,
        this.locality,
        this.isDefault,
        this.addressType});

  Data.fromJson(Map<String, dynamic> json) {
    addressId = json['address_id'];
    address = json['address'];
    postalCode = json['postal_code'];
    city = json['city'];
    state = json['state'];
    country = json['country'];
    fullAddress = json['full_address'];
    fullName = json['full_name'];
    phoneNumber = json['phone_number'];
    email = json['email'];
    locality = json['locality'];
    isDefault = json['is_default'];
    addressType = json['address_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['address_id'] = this.addressId;
    data['address'] = this.address;
    data['postal_code'] = this.postalCode;
    data['city'] = this.city;
    data['state'] = this.state;
    data['country'] = this.country;
    data['full_address'] = this.fullAddress;
    data['full_name'] = this.fullName;
    data['phone_number'] = this.phoneNumber;
    data['email'] = this.email;
    data['locality'] = this.locality;
    data['is_default'] = this.isDefault;
    data['address_type'] = this.addressType;
    return data;
  }
}
