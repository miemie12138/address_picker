class AddressNewModel {
  String? name;
  String? id;
  List<Children>? children;

  AddressNewModel({this.name, this.id, this.children});
  static List<AddressNewModel> fromList(List<dynamic> json) {
    return json.map((e) => AddressNewModel.fromJson(e)).toList();
  }
  AddressNewModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    id = json['id'];
    if (json['children'] != null) {
      children = <Children>[];
      json['children'].forEach((v) {
        children!.add(  Children.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['id'] =id;
    if (children != null) {
      data['children'] =children!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Children {
  String? province;
  String? name;
  String? id;
  String? parentId;
  List<ChildrenCity>? children;

  Children({this.province, this.name, this.id, this.parentId, this.children});

  Children.fromJson(Map<String, dynamic> json) {
    province = json['province'];
    name = json['name'];
    id = json['id'];
    parentId = json['parent_id'];
    if (json['children'] != null) {
      children = <ChildrenCity>[];
      json['children'].forEach((v) {
        children!.add( ChildrenCity.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['province'] = province;
    data['name'] =name;
    data['id'] = id;
    data['parent_id'] = parentId;
    if (children != null) {
      data['children'] =children!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ChildrenCity {
  String? city;
  String? name;
  String? id;

  ChildrenCity({this.city, this.name, this.id});

  ChildrenCity.fromJson(Map<String, dynamic> json) {
    city = json['city'];
    name = json['name'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['city'] =city;
    data['name'] =name;
    data['id'] = id;
    return data;
  }
}