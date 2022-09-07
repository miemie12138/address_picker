import 'package:flutter/material.dart';

import 'address_service.dart';
import 'address_model.dart';

/// 省市区选择器(使用示例见address_manage)
class AddressPickerDialog extends StatefulWidget {
  /// 省
  final String? province;
  final String? provinceCode;

  /// 市
  final String? city;
  final String? cityCode;

  /// 区
  final String? district;
  final String? districtCode;

  /// 街道
  final String? street;

  ///是否只展示省市
  final bool? isCity;

  /// 选择事件
  final Function(int, String, String) onChanged; // 参数分别为下标、id、name
  const AddressPickerDialog({
    Key? key,
    required this.onChanged,
    this.province,
    this.provinceCode,
    this.city,
    this.cityCode,
    this.district,
    this.districtCode,
    this.street,
    this.isCity,
  }) : super(key: key);

// 省市区选择器
  static showAddressSheet(
      {required BuildContext context,
      String? province,
      String? provinceCode,
      String? city,
      String? cityCode,
      String? district,
      String? districtCode,
      String? street,
      bool? isCity,
      required Function(int, String, String) onChanged}) async {
    return showModalBottomSheet(
      context: context,
      // 使用true则高度不受16分之9的最高限制
      isScrollControlled: true,
      builder: (BuildContext context) {
        return AddressPickerDialog(
          province: province ?? '',
          provinceCode: provinceCode ?? '',
          city: city ?? "",
          cityCode: cityCode ?? "",
          district: district ?? '',
          districtCode: districtCode ?? '',
          street: street ?? '',
          isCity: isCity,
          onChanged: (index, id, name) {
            onChanged.call(index, id, name);
          },
        );
      },
    );
  }

  @override
  AddressPickerDialogState createState() => AddressPickerDialogState();
}

class AddressPickerDialogState extends State<AddressPickerDialog> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final ScrollController _controller = ScrollController();
  int _index = 0; // 当前下标
  final _positions = [0, 0, 0]; // 三级联动选择的position
  List<Tab> _myTabs = [];
  List<AddressModel> _provinceList = []; // 省列表
  List<AddressModel> _cityList = []; // 市列表
  List<AddressModel> _districtList = []; // 区列表
  List<AddressModel> _mList = []; // 当前列表数据
  String newProvinceCode = ''; //选择后的省
  String newCityCode = ''; //选择后的市
  String newDistrictCode = ''; //选择后的区
  bool _isCity = false;
  @override
  void initState() {
    super.initState();
    _isCity = widget.isCity ?? false;
    _tabController = TabController(vsync: this, length: _isCity == true ? 2 : 3);
    // 设置默认值
    getProvince();

    newProvinceCode = widget.provinceCode ?? '';
    newCityCode = widget.cityCode ?? '';
    newDistrictCode = widget.districtCode ?? '';

    if (!_isCity) {
      _myTabs = <Tab>[const Tab(text: '请选择'), const Tab(text: ''), const Tab(text: '')]; // TabBar初始化3个，其中两个文字置空
      _myTabs[2] = Tab(text: widget.district ?? '');
    } else {
      _myTabs = <Tab>[const Tab(text: '请选择'), const Tab(text: '')];
    }
    _myTabs[0] = Tab(text: widget.province == '' ? '请选择' : widget.province);
    _myTabs[1] = Tab(text: widget.city ?? '');
    _tabController!.animateTo(_index, duration: const Duration(microseconds: 0));
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  // 获取省列表
  void getProvince() async {
    List<AddressModel> list = await AddressService.getProvince();
    setState(() {
      _provinceList = list;
      _mList = list;
    });
  }

  // 获取市列表
  Future<List<AddressModel>> getCity({required String provinceCode}) async {
    List<AddressModel> list = await AddressService.getCity(provinceCode);

    return list;
  }

  // 获取区列表
  Future<List<AddressModel>> getDistrict({required String cityCode}) async {
    List<AddressModel> list = await AddressService.getDistrict(cityCode);
    return list;
  }

  void setIndex(int index) {
    setState(() {
      _index = index;
    });
  }

  void setList(int index) async {
    switch (index) {
      case 0:
        setState(() {
          _mList = _provinceList;
        });
        break;
      case 1:
        _cityList = await getCity(provinceCode: newProvinceCode);
        setState(() {
          _mList = _cityList;
        });
        break;
      case 2:
        _districtList = await getDistrict(cityCode: newCityCode);
        setState(() {
          _mList = _districtList;
        });
        break;
    }
  }

  void setListAndChangeTab() {
    switch (_index) {
      case 1:
        setState(() {
          _mList = _cityList;
          _myTabs[1] = const Tab(text: '请选择');
          if (!_isCity) {
            _myTabs[2] = const Tab(text: '');
          }
        });
        break;
      case 2:
        setState(() {
          _mList = _districtList;
          _myTabs[2] = const Tab(text: '请选择');
        });
        break;
    }
  }

  // 选中某个tab
  void checkedTab(int index) async {
    // 将选中的返回到父组件
    widget.onChanged(_index, _mList[index].id ?? '', _mList[index].name ?? '');
    setState(() {
      _myTabs[_index] = Tab(text: _mList[index].name ?? '');
      _positions[_index] = index;
      _index = _index + 1;
    });
    if (_index == 1) {
      newProvinceCode = _mList[index].id ?? '';
      _cityList = await getCity(provinceCode: _mList[index].id ?? '');
    }
    if (_isCity) {
      if (_index > 1) {
        setIndex(1);
        Navigator.pop(context);
      }
    } else {
      if (_index == 2) {
        newCityCode = _mList[index].id ?? '';
        _districtList = await getDistrict(cityCode: _mList[index].id ?? '');
      }
      if (_index > 2) {
        setIndex(2);
        Navigator.pop(context);
      }
    }

    setListAndChangeTab();
    _controller.animateTo(0.0, duration: const Duration(milliseconds: 100), curve: Curves.ease);
    _tabController!.animateTo(_index);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 11.0 / 16.0,
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: const Text(
                    '地址选择',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Positioned(
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const SizedBox(
                      height: 16.0,
                      width: 16.0,
                      child: Icon(
                        Icons.close,
                        color: Color(0xFF000000),
                        size: 24.0,
                      ),
                    ),
                  ),
                  right: 16.0,
                  top: 16.0,
                  bottom: 16.0,
                )
              ],
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Divider(),
                  Container(
                    // 隐藏点击效果
                    color: Colors.white,
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      onTap: (index) {
                        if (_myTabs[index].text!.isEmpty) {
                          // 拦截点击事件
                          _tabController!.animateTo(_index);
                          return;
                        }
                        setList(index);
                        setIndex(index);
                        _controller.animateTo(_positions[_index] * 48.0,
                            duration: const Duration(milliseconds: 10), curve: Curves.ease);
                      },
                      indicatorSize: TabBarIndicatorSize.label,
                      indicatorColor: const Color(0xff438EFF),
                      unselectedLabelColor: const Color(0xFF4A4A4A),
                      labelColor: const Color(0xff438EFF),
                      tabs: _myTabs,
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      controller: _controller,
                      itemExtent: 48.0,
                      itemBuilder: (_, index) {
                        bool flag = _mList[index].name == _myTabs[_index].text;
                        return InkWell(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: <Widget>[
                                Text(_mList[index].name ?? '',
                                    style: flag
                                        ? const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xff438EFF),
                                          )
                                        : null),
                                const SizedBox(height: 8),
                                Visibility(
                                  visible: flag,
                                  child: const Icon(
                                    Icons.done,
                                    color: Color(0xff438EFF),
                                    size: 18.0,
                                  ),
                                )
                              ],
                            ),
                          ),
                          onTap: () => checkedTab(index),
                        );
                      },
                      itemCount: _mList.length,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
