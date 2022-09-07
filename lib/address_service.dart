import 'dart:convert';
import 'package:flutter/services.dart';
import 'address_model.dart';
import 'address_new_model.dart';

class AddressService {
  AddressService._();
  static List<AddressNewModel> addressList = [];
  //市列表
  static List<Children>? city = [];
  //区列表
  static List<ChildrenCity>? districts = [];

  /// 获取省列表
  static Future<List<AddressNewModel>> getAddress() async {
    dynamic list = await rootBundle.loadString("images/json/address.json");
    return AddressNewModel.fromList(json.decode(list));
  }

  /// 获取省列表
  static Future<List<AddressModel>> getProvince() async {
    addressList = await getAddress();
    List<AddressModel> province = [];
    for (var its in addressList) {
      AddressModel addressModel = AddressModel(its.id, its.name);
      province.add(addressModel);
    }
    return province;
  }

  /// 获取市列表
  static Future<List<AddressModel>> getCity(String provinceCode) async {
    city = (addressList.where((element) => element.id == provinceCode).toList())[0].children ?? [];
    List<AddressModel> cityS = [];
    for (var its in city!) {
      AddressModel addressModel = AddressModel(its.id, its.name);
      cityS.add(addressModel);
    }
    return cityS;
  }

  /// 获取区列表
  static Future<List<AddressModel>> getDistrict(String cityCode) async {
    districts = (city!.where((element) => element.id == cityCode).toList())[0].children ?? [];
    List<AddressModel> districtS = [];
    for (var its in districts!) {
      AddressModel addressModel = AddressModel(its.id, its.name);
      districtS.add(addressModel);
    }
    return districtS;
  }
}
