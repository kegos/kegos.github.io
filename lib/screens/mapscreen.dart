
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kakao_login_test/screens/assetdetailview.dart';
import 'package:kakao_login_test/screens/commdetailview.dart';
import 'package:kakao_login_test/screens/component/bottom_menu.dart';

import '../common/commondata.dart';
import 'component/basket.dart';

var setNum = 0;

final _listController = ScrollController();
List<Marker> _markers = [];
double _lat = 35.1419004;
double _lng = 129.0628395;
List<dynamic> _result = [];
String _type2 = 'C';
bool _isloading = false;

Future<List> pagenationMapData() async {
  LocationPermission permission = await Geolocator.requestPermission();
  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best);

  _lat = position.latitude;
  _lng = position.longitude;
  return [];
}


late GoogleMapController _mapController;


class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Map<String, String> formData = {};
  final _searchController = TextEditingController();
  String _floor = '0';
  String _type = 'C';
  final _size = TextEditingController();
  final _deposit = TextEditingController();
  final _monthly = TextEditingController();
  final _salesprice = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
  if(setNum == 0 ) {
    pagenationMapData();
    setNum++;
  }
  if(kIsWeb)
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height - 70,
          child: kIsWeb ? _webMap() : _androidMap(),
        ),
      ),
      bottomNavigationBar: BottomMenuBar(),
    );
  else
   return Scaffold(
     backgroundColor: Theme.of(context).colorScheme.background,
     appBar: AppBar(
       title: Text('지도'),
       centerTitle: true,
       backgroundColor: Theme.of(context).colorScheme.primary,
       elevation: 0,
     ),
     body: SingleChildScrollView(
       child: Container(
         width: MediaQuery.of(context).size.width,
         height: MediaQuery.of(context).size.height - 170,
         child: kIsWeb ? _webMap() : _androidMap(),
       ),
     ),
     bottomNavigationBar: BottomMenuBar(),
   );
  }


  Widget _webMap() {
    return _isloading ? Container(child: Center( child: CircularProgressIndicator())) : Column(
      children: [
        Row(
          children: [
            Container(
              width: MediaQuery.of(context).size.width - 370,
              height: MediaQuery.of(context).size.height - 280,
              child: GoogleMap(
                mapType: MapType.normal,
                mapToolbarEnabled: true,
                minMaxZoomPreference: MinMaxZoomPreference(1, 20),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: true,
                initialCameraPosition: CameraPosition(
                  target: LatLng(_lat, _lng),
                  zoom: 18,
                ),
                 onMapCreated: (GoogleMapController controller) {
                   _mapController = controller;
                 },
                markers: Set.from(_markers),
              ),
            ),
            Container(
              width: 370,
              height: MediaQuery.of(context).size.height - 280,
              child: CustomScrollView(
                controller: _listController,
                slivers: [
                  if(_result.length == 0) SliverToBoxAdapter(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text('검색된 데이터가 없습니다.'),
                    ),
                  ),
                  if(_result.length > 0)
                    SliverList(
                        delegate: SliverChildBuilderDelegate (
                          (context, index) {
                            if(_result.length > 0) {
                                return Dismissible(
                                key: Key(_result[index]['id'].toString()),
                                background: Container(
                                  margin: const EdgeInsets.all(8),
                                  padding: const EdgeInsets.all(20),
                                  alignment: Alignment.centerLeft,
                                  color: Colors.red,
                                  child: const Icon(Icons.delete,size: 36,),
                                ),
                                secondaryBackground: Container(
                                  margin: const EdgeInsets.all(8),
                                  padding: const EdgeInsets.all(20),
                                  alignment: Alignment.centerRight,
                                  color: Colors.blue,
                                  child: const Icon(Icons.archive,size: 36,),
                                ),
                                confirmDismiss: (direction) async {
                                  if(direction == DismissDirection.endToStart) {
                                    return await showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text("관심 물건 추가"),
                                          content: const Text("관심 물건으로 추가하시겠습니까?"),
                                          actions: <Widget>[
                                            TextButton(
                                                onPressed: () async {
                                                  addData(_result[index]['id'],'C');
                                                  // basketList  = await getAllItems();
                                                  // print('==============');
                                                  // print(basketList[0].id);
                                                  Navigator.of(context).pop(false);
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(content: Text("관심 물건으로 추가됨")));
                                                },
                                                child: const Text("예")
                                            ),
                                            TextButton(
                                                onPressed: () => Navigator.of(context).pop(false),
                                                child: const Text("아니오")
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  } else {
                                    return await showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text("거래 완료"),
                                          content: const Text("거래가 완료되었습니까?"),
                                          actions: <Widget>[
                                            TextButton(
                                                onPressed: () async{
                                                  final dio = Dio();
                                                  try {
                                                    final response = await dio.post(
                                                        '$appServerURL/setstatuscomm',
                                                        data: {
                                                          'uuid': _result[index]['id'],
                                                        }
                                                    );
                                                  } catch (e) {
                                                    print(e);
                                                  }

                                                  dio.close();
                                                  Navigator.of(context).pop(true);
                                                  // ScaffoldMessenger.of(context)
                                                  //     .showSnackBar(SnackBar(content: Text("$_result[index]['callname'] 거래 완료됨")));
                                                },
                                                child: const Text("예")
                                            ),
                                            TextButton(
                                                onPressed: () => Navigator.of(context).pop(false),
                                                child: const Text("아니오")
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                },
                                child: GestureDetector(
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    child: Row(
                                      children: [
                                        if(_result[index]['${_type2 == 'C' ? "img_1" : "img1"}'] == '')
                                          Container(
                                            width: 88,
                                            height: 88,
                                            child: Image.asset('image/smile.jpg',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        if(_result[index]['${_type2 == 'C' ? "img_1" : "img1"}'] != '')
                                          Container(
                                            width: 88,
                                            height: 88,
                                            child: Image.network('$appServerURL/${_result[index]['${_type2 == 'C' ? "img_1" : "img1"}']}',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        SizedBox(width: 4),
                                        Container(
                                          height: 88,
                                          width: 270,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              if(_result[index]['naver_no'] != '')
                                                Text(
                                                  _result[index]['sub_addr'],
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                              if(_result[index]['naver_no'] == '')
                                                Text(
                                                  _result[index]['sub_addr'],
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              if(_result[index]['deposit'] > 0)
                                                  Text(
                                                    '보:${(_result[index]['deposit'] / 10000).round()}/${(_result[index]['monthly'] / 10000).round()}             ${_result[index]['size'].round()}평   ${_result[index]['floor']}층',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                              if(_result[index]['deposit'] == 0)
                                                Text(
                                                  '                             ${(_type2 == 'C' ? _result[index]['size'] : _result[index]['size']).round()}평   ${_result[index]['floor']}층',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              if(_type2 == 'C')
                                                Text(
                                                  '관리비:${_result[index]['adminprice']}  권리금:${(_result[index]['entitleprice'] / 10000).round()}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              if(_type2 != 'C')
                                                if(_result[index]['entitleprice'] > 0)
                                                  Text(
                                                    '전:${(_result[index]['entitleprice'] / 10000).round()}',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                              if(_result[index]['salesprice'] > 0)
                                                Text(
                                                  '매:${(_result[index]['salesprice'] / 10000).round()}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              if(_type2 == 'C')
                                                Text(
                                                  '엘베:${_result[index]['eliv'] == '1' ? 'O' : 'X' }  주차:${_result[index]['parking']}대                 ${_result[index]['owner']}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              if(_type2 != 'C')
                                                Text(
                                                  '방/화 : ${_result[index]['eliv']}/${_result[index]['parking']}      ${_result[index]['division']}향            ${_result[index]['owner']}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              // ${_result[index]['salesprice'] > 0 ? (_result[index]['salesprice'] / 10000).round() : ''}
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  onDoubleTap: () {
                                    if(_type == 'C')
                                      Get.to(
                                        CommDetailViewScreen(
                                          id:_result[index]['id'],
                                        ),
                                      );
                                    else
                                      Get.to(
                                        AssetDetailViewScreen(
                                          id:_result[index]['id'],
                                        ),
                                      );
                                  },
                                  onTap: () {
                                    _mapController.animateCamera(
                                      CameraUpdate.newCameraPosition(
                                        CameraPosition(
                                          target: LatLng((_type2 == 'C' ? _result[index]['lat'] / 1.0 : _result[index]['lat']),
                                              (_type2 == 'C' ? _result[index]['lng'] / 1.0 : _result[index]['lng'])),
                                          zoom: 17,
                                        ),
                                      ),
                                    );
                                  }
                                ),
                              );
                            } else {
                              return Center(child: CircularProgressIndicator());
                            }
                          },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        _searchForm(),
      ],
    );
  }


  Widget _androidMap()  {

    return _isloading ? Container(child: Center( child: CircularProgressIndicator())) : Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.height  - 460,
          child: GoogleMap(
            mapType: MapType.normal,
            mapToolbarEnabled: true,
            minMaxZoomPreference: MinMaxZoomPreference(1, 20),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            initialCameraPosition: CameraPosition(
              target: LatLng(_lat, _lng),
              zoom: 18,
            ),
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            markers: Set.from(_markers),
          ),
        ),
        _searchFormMobile(),
      ],
    );
  }

  Widget _searchForm() {
    return  Container(
      padding: const EdgeInsets.all(8.0),
      width: MediaQuery.of(context).size.width,
      height: 210,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('종류 : '),
                DropdownButton(
                  value: _type,
                  onChanged: (value) {
                    setState(() {
                      _type = value.toString();
                    });
                  },
                  items: [
                    DropdownMenuItem(
                      child: Text('주거'),
                      value: 'H',
                    ),
                    DropdownMenuItem(
                      child: Text('상가/사무실'),
                      value: 'C',
                    ),
                  ],
                ),
                Text('층 : '),
                DropdownButton(
                  value: _floor,
                  onChanged: (value) {
                    setState(() {
                      _floor = value.toString();
                    });
                  },
                  items: [
                    DropdownMenuItem(
                      child: Text('무관'),
                      value: '0',
                    ),            DropdownMenuItem(
                      child: Text('1층'),
                      value: '1',
                    ),            DropdownMenuItem(
                      child: Text('1-2층'),
                      value: '2',
                    ),
                    DropdownMenuItem(
                      child: Text('2층 이상'),
                      value: '3',
                    ),
                  ],
                ),
                Text('평수 : '),
                Container(
                  width: MediaQuery.of(context).size.width * 0.1,
                  child: TextFormField(
                    controller: _size,
                    keyboardType: TextInputType.number,
                    onSaved: (value) {
                      if(value!.isEmpty) {
                        formData['size'] = '0';
                      } else {
                        formData['size'] = value!;
                      }
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    textAlign: TextAlign.end,
                    decoration: InputDecoration(
                      hintText: '검색 기준 넓이를 입력하세요',
                      suffixIcon: IconButton(
                        onPressed: () {
                          _deposit.clear();
                        },
                        icon: const Icon(Icons.clear),
                      ),
                    ),
                  ),
                ),
                Text('검색어 : '),
                Container(
                  width: MediaQuery.of(context).size.width * 0.2,
                  child: TextFormField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '검색어를 입력하세요',
                      suffixIcon: IconButton(
                        onPressed: () {
                          _searchController.clear();
                        },
                        icon: const Icon(Icons.clear),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Text('매매 : '),
                Container(
                  width: MediaQuery.of(context).size.width * 0.2,
                  child: TextFormField(
                    controller: _salesprice,
                    keyboardType: TextInputType.number,
                    onSaved: (value) {
                      if(value!.isEmpty) {
                        formData['price'] = '0';
                      } else {
                        formData['price'] = value!;
                      }
                    },
                    inputFormatters: [
                      CurrencyTextInputFormatter(
                        locale: 'ko',
                        decimalDigits: 0,
                        symbol: '₩',
                      )
                    ],
                    textAlign: TextAlign.end,
                    decoration: InputDecoration(
                      hintText: '매매 기준 가격을 입력 하세요',
                      suffixIcon: IconButton(
                        onPressed: () {
                          _salesprice.clear();
                        },
                        icon: const Icon(Icons.clear),
                      ),
                    ),
                  ),
                ),
                Text('보증금 : '),
                Container(
                  width: MediaQuery.of(context).size.width * 0.2,
                  child: TextFormField(
                    controller: _deposit,
                    keyboardType: TextInputType.number,
                    onSaved: (value) {
                      if(value!.isEmpty) {
                        formData['deposit'] = '0';
                      } else {
                        formData['deposit'] = value!;
                      }
                    },
                    inputFormatters: [
                      CurrencyTextInputFormatter(
                        locale: 'ko',
                        decimalDigits: 0,
                        symbol: '₩',
                      )
                    ],
                    textAlign: TextAlign.end,
                    decoration: InputDecoration(
                      hintText: '보증금 기준 가격을 입력하세요',
                      suffixIcon: IconButton(
                        onPressed: () {
                          _deposit.clear();
                        },
                        icon: const Icon(Icons.clear),
                      ),
                    ),
                  ),
                ),
                Text('월세 : '),
                Container(
                  width: MediaQuery.of(context).size.width * 0.2,
                  child: TextFormField(
                    controller: _monthly,
                    keyboardType: TextInputType.number,
                    onSaved: (value) {
                      if(value!.isEmpty) {
                        formData['monthly'] = '0';
                      } else {
                        formData['monthly'] = value!;
                      }
                    },
                    inputFormatters: [
                      CurrencyTextInputFormatter(
                        locale: 'ko',
                        decimalDigits: 0,
                        symbol: '₩',
                      )
                    ],
                    textAlign: TextAlign.end,
                    decoration: InputDecoration(
                      hintText: '월세 기준 가격을 입력하세요',
                      suffixIcon: IconButton(
                        onPressed: () {
                          _monthly.clear();
                        },
                        icon: const Icon(Icons.clear),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.all(10),
              width: MediaQuery.of(context).size.width,
              height: 70,
              child: ElevatedButton(
                  onPressed: (){
                    if(_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      _type2 = _type;
                    }
                    _search(
                        _searchController.text,
                        _type,
                        _floor,
                        formData['size'] == null ? '0' : formData['size']!.replaceAll('₩', '').replaceAll(',', ''),
                        formData['price'] == null ? '0' : formData['price']!.replaceAll('₩', '').replaceAll(',', ''),
                        formData['deposit'] == null ? '0' : formData['deposit']!.replaceAll('₩', '').replaceAll(',', ''),
                        formData['monthly'] == null ? '0' : formData['monthly']!.replaceAll('₩', '').replaceAll(',', '')
                    );
                  },
                  child: Text('검색')
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _searchFormMobile() {
    return  Container(
      height: 290,
      padding: const EdgeInsets.all(8.0),
      width: MediaQuery.of(context).size.width,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('종류 : '),
                DropdownButton(
                  value: _type,
                  onChanged: (value) {
                    setState(() {
                      _type = value.toString();
                    });
                  },
                  items: [
                    DropdownMenuItem(
                      child: Text('주거'),
                      value: 'H',
                    ),
                    DropdownMenuItem(
                      child: Text('상가/사무실'),
                      value: 'C',
                    ),
                  ],
                ),
                Text('층 : '),
                DropdownButton(
                  value: _floor,
                  onChanged: (value) {
                    setState(() {
                      _floor = value.toString();
                    });
                  },
                  items: [
                    DropdownMenuItem(
                      child: Text('무관'),
                      value: '0',
                    ),
                    DropdownMenuItem(
                      child: Text('1층'),
                      value: '1',
                    ),
                    DropdownMenuItem(
                      child: Text('1-2층'),
                      value: '2',
                    ),
                    DropdownMenuItem(
                      child: Text('2층 이상'),
                      value: '3',
                    ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('평수 : '),
                Container(
                  width: MediaQuery.of(context).size.width * 0.2,
                  child: TextFormField(
                    controller: _size,
                    keyboardType: TextInputType.number,
                    onSaved: (value) {
                      if(value!.isEmpty) {
                        formData['size'] = '0';
                      } else {
                        formData['size'] = value!;
                      }
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    textAlign: TextAlign.end,
                    decoration: InputDecoration(
                      hintText: '기준 넓이를 입력하세요',
                      suffixIcon: IconButton(
                        onPressed: () {
                          _deposit.clear();
                        },
                        icon: const Icon(Icons.clear),
                      ),
                    ),
                  ),
                ),
                Text('검색어 : '),
                Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: TextFormField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '검색어를 입력하세요',
                      suffixIcon: IconButton(
                        onPressed: () {
                          _searchController.clear();
                        },
                        icon: const Icon(Icons.clear),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('매매 : '),
                Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  child: TextFormField(
                    controller: _salesprice,
                    keyboardType: TextInputType.number,
                    onSaved: (value) {
                      if(value!.isEmpty) {
                        formData['price'] = '0';
                      } else {
                        formData['price'] = value!;
                      }
                    },
                    inputFormatters: [
                      CurrencyTextInputFormatter(
                        locale: 'ko',
                        decimalDigits: 0,
                        symbol: '₩',
                      )
                    ],
                    textAlign: TextAlign.end,
                    decoration: InputDecoration(
                      hintText: '매매 기준 가격을 입력 하세요',
                      suffixIcon: IconButton(
                        onPressed: () {
                          _salesprice.clear();
                        },
                        icon: const Icon(Icons.clear),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('보증금 : '),
                Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: TextFormField(
                    controller: _deposit,
                    keyboardType: TextInputType.number,
                    onSaved: (value) {
                      if(value!.isEmpty) {
                        formData['deposit'] = '0';
                      } else {
                        formData['deposit'] = value!;
                      }
                    },
                    inputFormatters: [
                      CurrencyTextInputFormatter(
                        locale: 'ko',
                        decimalDigits: 0,
                        symbol: '₩',
                      )
                    ],
                    textAlign: TextAlign.end,
                    decoration: InputDecoration(
                      hintText: '보증금 기준 가격을 입력하세요',
                      suffixIcon: IconButton(
                        onPressed: () {
                          _deposit.clear();
                        },
                        icon: const Icon(Icons.clear),
                      ),
                    ),
                  ),
                ),
                Text('월세 : '),
                Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: TextFormField(
                    controller: _monthly,
                    keyboardType: TextInputType.number,
                    onSaved: (value) {
                      if(value!.isEmpty) {
                        formData['monthly'] = '0';
                      } else {
                        formData['monthly'] = value!;
                      }
                    },
                    inputFormatters: [
                      CurrencyTextInputFormatter(
                        locale: 'ko',
                        decimalDigits: 0,
                        symbol: '₩',
                      )
                    ],
                    textAlign: TextAlign.end,
                    decoration: InputDecoration(
                      hintText: '월세 기준 가격을 입력하세요',
                      suffixIcon: IconButton(
                        onPressed: () {
                          _monthly.clear();
                        },
                        icon: const Icon(Icons.clear),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.all(10),
              width: MediaQuery.of(context).size.width,
              height: 70,
              child: ElevatedButton(
                  onPressed: (){
                    if(_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                    }
                    _search(
                        _searchController.text,
                        _type,
                        _floor,
                        formData['size'] == null ? '0' : formData['size']!.replaceAll('₩', '').replaceAll(',', ''),
                        formData['price'] == null ? '0' : formData['price']!.replaceAll('₩', '').replaceAll(',', ''),
                        formData['deposit'] == null ? '0' : formData['deposit']!.replaceAll('₩', '').replaceAll(',', ''),
                        formData['monthly'] == null ? '0' : formData['monthly']!.replaceAll('₩', '').replaceAll(',', '')
                    );
                  },
                  child: Text('검색')
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _search(
      String _searchtxt,
      String _type,
      String _floor,
      String _size,
      String _salesprice,
      String _deposit,
      String _monthly,
      ) async {
    _result = [];


    setState(() {
      _isloading = true;
    });

    final dio = Dio();


    final response = await dio.post('$appServerURL/mapselected', data: {
      'gubun': _type,
      'size': _size,
      'floor': _floor,
      'price': _salesprice,
      'deposit': _deposit,
      'monthly': _monthly,
      'callname': _searchtxt ?? '',
    });

    if (response.data.length > 0) {
      _isloading = false;
      _result = response.data;
      _markers.clear();
      for (int i = 0; i < response.data.length; i++) {
        _markers.add(
          Marker(
            markerId: MarkerId('marker_${i + 1}'),
            position: LatLng((_type2 == 'C' ? (response.data[i]['lat'] / 1.0) : response.data[i]['lat']),
                (_type2 == 'C' ? (response.data[i]['lng'] / 1.0) : response.data[i]['lng'])),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
            infoWindow: InfoWindow(
              onTap: () {
                print('marker_${i + 1} clicked');
                if(_type2 == 'C')
                  Get.to(
                    CommDetailViewScreen(
                      id: response.data[i]['id'],
                    ),
                  );
                else
                  Get.to(
                    AssetDetailViewScreen(
                      id: response.data[i]['id'],
                    ),
                  );
              },
              title: response.data[i]['sub_addr'],
              snippet:
              '${(response.data[i]['deposit'] / 10000).round()}/${(response.data[i]['monthly'] / 10000).round()} ${response.data[i]['size'].round()}평',
            ),
            onTap: () {
              if(kIsWeb)
                _listController.jumpTo(i * 96.0);
            },
          ),
        );
      }
    }


    dio.close();

    _mapController.reactive();
    setState(() {
      _markers = _markers;
    });
  }
}
