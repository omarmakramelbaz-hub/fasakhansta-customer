class FavoriteModel {
  int? id;
  int? vendorId;
  String? vendorName;
  String? name;
  String? status;
  num? avgRate;
  String? address;
  String? logo;
  String? bgImage;
  String? deliveryTime;
  String? lat;
  String? lng;
  String? createdAt;

  FavoriteModel({
    this.id,
    this.vendorId,
    this.vendorName,
    this.name,
    this.status,
    this.avgRate,
    this.address,
    this.logo,
    this.bgImage,
    this.deliveryTime,
    this.lat,
    this.lng,
    this.createdAt,
  });

  FavoriteModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    vendorId = json['vendor_id'];
    vendorName = json['vendor_name'];
    name = json['name'];
    status = json['status'];
    avgRate = json['avg_rate'];
    address = json['address'];
    logo = json['logo'];
    bgImage = json['bg_image'];
    deliveryTime = json['delivery_time'];
    lat = json['lat'];
    lng = json['lng'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['vendor_id'] = vendorId;
    data['vendor_name'] = vendorName;
    data['name'] = name;
    data['status'] = status;
    data['avg_rate'] = avgRate;
    data['address'] = address;
    data['logo'] = logo;
    data['bg_image'] = bgImage;
    data['delivery_time'] = deliveryTime;
    data['lat'] = lat;
    data['lng'] = lng;
    data['created_at'] = createdAt;
    return data;
  }
}
