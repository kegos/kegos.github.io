import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:kakao_flutter_sdk_share/kakao_flutter_sdk_share.dart';
import 'package:kakao_login_test/screens/commdetailview.dart';
import 'package:kakao_login_test/screens/commupdate.dart';
import 'package:kakao_login_test/screens/component/bottom_menu.dart';
import 'package:kakao_login_test/screens/mapscreen.dart';
import 'package:path_provider/path_provider.dart';
import '../common/commondata.dart';
import '../status/controller.dart';
import 'dart:async';
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart' as getx;
import 'package:dio/src/form_data.dart';
import 'package:kakao_flutter_sdk_talk/kakao_flutter_sdk_talk.dart';
import 'package:http_parser/http_parser.dart';
import 'package:url_launcher/url_launcher.dart';
import 'component/basket.dart';

int _id = 0;

class CommercialListViewScreenWeb extends StatefulWidget {
  const CommercialListViewScreenWeb({Key? key}) : super(key: key);

  @override
  State<CommercialListViewScreenWeb> createState() => _CommercialListViewScreenWebState();


}





class _CommercialListViewScreenWebState extends State<CommercialListViewScreenWeb> {


  @override
  void initState() {
    super.initState();
//    FlutterDownloader.registerCallback(downloadCallback as DownloadCallback);
  }



  double _lat = 0.0;
  double _lng = 0.0;
  List<Marker> _markers = [];
  PageController _controller = PageController(initialPage: 0, keepPage: false);
  PageController _controllerMain = PageController(initialPage: 0, keepPage: false);
  final ImagePicker _picker = ImagePicker();
  late GoogleMapController _mapController;
  List<dynamic> _data = [];
  var f = NumberFormat('###,###,###,###');
  List<XFile> _pickedImgs = [];





  void _addbasket() async {
    if(_id == 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(
          "선택된 물건이 없습니다.")));
      return;
    }
    addData(_id, 'C');
    // basketList  = await getAllItems();
    // print('==============');
    // print(basketList[0].id);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(
        "관심 물건으로 추가됨")));
  }






  Future<List> paginationAssetList() async {
    final controller = getx.Get.put(Controller());
    final String minPrice;
    final String maxPrice;
    String minPrice2 = '0';
    String maxPrice2 = '0';
    String minSize = '0';
    String maxSize = '300';
    final String callname;

    if (controller.selectGubun.value == '매매') {
      maxPrice = controller.maxPrice.value.toString();
      minPrice = controller.minPrice.value.toString();
    } else  {
      minPrice = '${controller.minDeposit.value.toString()}';
      maxPrice = '${controller.maxDeposit.value.toString()}';
      minPrice2 = '${controller.minMonthly.value.toString()}';
      maxPrice2 = '${controller.maxMonthly.value.toString()}';
    }
    minSize = '${controller.minSize.value.toString()}';
    maxSize = '${controller.maxSize.value.toString()}';
    callname = '${controller.selectCallname.value}';

    try {
      final dio = Dio();

      final response = await dio.post(
          '$appServerURL/commselected',
          data: {
            'gubun': '${controller.selectGubun.value}',
            'callname': '${callname}',
            'minp': '${minPrice}',
            'maxp': '${maxPrice}',
            'minp2': '${minPrice2}',
            'maxp2': '${maxPrice2}',
            'mins': '${minSize}',
            'maxs': '${maxSize}',
          }
      );


      dio.close();


      return response.data;


    } catch(e) {
      print(e);
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final _authentication = FirebaseAuth.instance;


    return Scaffold(
      appBar: AppBar(
        title: const Text('상업용 부동산'),
        actions: [
          IconButton(
            onPressed: () {
              _addbasket();
            },
            icon: const Icon(Icons.shopping_cart),
          ),

          IconButton(
            onPressed: () {
              getx.Get.to(() => const MapScreen());
            },
            icon: const Icon(Icons.map),
          ),

        ],
      ),

      bottomNavigationBar: BottomMenuBar(),

      body: Row(
        children: [
          Container(
            width: 490,
            color: Theme.of(context).colorScheme.background,
            child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: FutureBuilder(
                    future: paginationAssetList(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        return CustomScrollView(
                          slivers: [
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 10.0),
                                    child: CommCard(
                                      id: snapshot.data[index]['id'],
                                      image: Image.network(
                                        snapshot.data[index]['img_1'] == ''
                                            ? '$appServerURL/sample.jpg'
                                            : '$appServerURL/${snapshot.data[index]['img_1']}',
                                        fit: BoxFit.cover,
                                      ),
                                      division: snapshot.data[index]['division'],
                                      price: snapshot.data[index]['price'],
                                      price2: snapshot.data[index]['price2'] ?? 0,
                                      eliv: snapshot.data[index]['eliv'] ?? '',
                                      parking : snapshot.data[index]['parking'] ?? '',
                                      size: snapshot.data[index]['size'] ?? 0,
                                      entitleprice: snapshot.data[index]['entitleprice'] ?? 0,
                                      indate: snapshot.data[index]['indate'] ?? '',
                                      floor: snapshot.data[index]['floor'] ?? '',
                                      type: snapshot.data[index]['type'] ?? '',
                                      addr: snapshot.data[index]['addr'] ?? '',
                                      callname: snapshot.data[index]['sub_addr'] ?? '',
                                      naver_no: snapshot.data[index]['naver_no'] ?? '',
                                    ),
                                  );
                                },
                                childCount: snapshot.data.length,
                              ),
                            ),
                          ],
                        );

                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
          const VerticalDivider(
            width: 1,
            thickness: 1,
            color: Colors.grey,
          ),
          if(_id == 0) Container(),
          if(_id != 0) _CommDetail(),

        ],
      ),
    );
  }

  Future<dynamic> _showdialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('선택한 조건의 물건이 없습니다.'),
            actions: [
              TextButton(
                onPressed: () {
                  getx.Get.back();
                },
                child: const Text('확인'),
              ),
            ],
          );
        }
    );
  }

  Future<Position> getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);

    final dio = Dio();

    final response2 = await dio.post(
        '$appServerURL/nearlist',
        data: {
          'id': _id,
          'lat': position.latitude,
          'lng': position.longitude,
          'type': 'C',
        }
    );

    if(response2.data.length > 0) {
      for(int i = 0; i < response2.data.length; i++) {
        _markers.add(
          Marker(
            markerId: MarkerId('marker_${i + 1}'),
            position: LatLng((response2.data[i]['lat']/1.0), (response2.data[i]['lng']/1.0)),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            infoWindow: InfoWindow(
              onTap: () {
                print('marker_${i + 1} clicked');
                getx.Get.offAll(
                  CommDetailViewScreen(
                    id: response2.data[i]['id'],
                  ),);
              },
              title: response2.data[i]['sub_addr'],
              snippet: '${(response2.data[i]['deposit']/10000).round()}/${(response2.data[i]['monthly']/10000).round()} ${response2.data[i]['size']}평',
            ),
          ),
        );
      }
      _mapController.reactive();
    }

    dio.close();

    return position;
  }
}



class CommCard extends StatefulWidget {
  final int id;
  final Widget image;
  final String division;
  final int price;
  final int price2;
  final String eliv;
  final String parking;
  final int size;
  final int entitleprice;
  final String indate;
  final String floor;
  final String type;
  final String addr;
  final String callname;
  final String naver_no;



  const CommCard({
    required this.price,
    required this.price2,
    required this.id,
    required this.image,
    required this.division,
    required this.entitleprice,
    required this.floor,
    required this.indate,
    required this.parking,
    required this.eliv,
    required this.size,
    required this.type,
    required this.addr,
    required this.callname,
    required this.naver_no,

    Key? key}) : super(key: key);

  @override
  State<CommCard> createState() => _CommCardState();
}

class _CommCardState extends State<CommCard> {
  updateLatLng() async {
    final dio = Dio();
    double _lat = 0.0;
    double _lng = 0.0;

    String gpsUrl =
        'https://maps.googleapis.com/maps/api/geocode/json?address=${widget.addr}&key=$googleMapKey&language=ko';

    final responseGps = await dio.get(gpsUrl);

    var rst = jsonDecode(responseGps.toString());

    _lat = rst['results'][0]['geometry']['location']['lat'];
    _lng = rst['results'][0]['geometry']['location']['lng'];
    // print(response.data[0]['addr']);
    // print ('========================================');
    // print(_lat.toString());
    // print('========================================');


    try {
      final response = await dio.post(
          '$appServerURL/updatelatlng',
          data: {
            'id': widget.id,
            'lat': _lat,
            'lng': _lng,
          }
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    var f = NumberFormat('###,###,###,###');
    _CommercialListViewScreenWebState? parent = context.findAncestorStateOfType<_CommercialListViewScreenWebState>();
//    updateLatLng();

    return Dismissible(
      key: Key(widget.id.toString()),
      background: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(20),
        alignment: Alignment.centerLeft,
        color: Colors.red,
        child: const Icon(Icons.delete, size: 36,),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(20),
        alignment: Alignment.centerRight,
        color: Colors.blue,
        child: const Icon(Icons.archive, size: 36,),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("관심 물건 추가"),
                content: const Text("관심 물건으로 추가하시겠습니까?"),
                actions: <Widget>[
                  TextButton(
                      onPressed: () async {
                        addData(widget.id, 'C');
                        // basketList  = await getAllItems();
                        // print('==============');
                        // print(basketList[0].id);
                        Navigator.of(context).pop(false);
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(
                            "${widget.callname} 관심 물건으로 추가됨")));
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
                      onPressed: () async {
                        final dio = Dio();
                        try {
                          final response = await dio.post(
                              '$appServerURL/setstatuscomm',
                              data: {
                                'uuid': widget.id,
                              }
                          );
                        } catch (e) {
                          print(e);
                        }

                        dio.close();
                        Navigator.of(context).pop(true);
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(
                            "${widget.callname} 거래 완료됨")));
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
      onDismissed: (direction) {
        // Remove the item from the data source.
        // setState(() {
        //   _items.removeAt(index);
        // });
        //
        // Then show a snackbar.
        if (direction == DismissDirection.endToStart) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("${widget.callname} 관심 물건 추가")));
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("${widget.callname} 거래 완료됨")));
        }
      },

      child: GestureDetector(
        onTap: () {
          parent!.setState(() {
            _id = widget.id;
          });
          // getx.Get.to(() =>
          //     CommDetailViewScreen(
          //       id: id,
          //     ));
        },
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Theme
                .of(context)
                .colorScheme
                .primary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                SizedBox(
                  height: 95,
                  width: 95,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: widget.image,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IntrinsicHeight(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${widget.division}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Theme
                                      .of(context)
                                      .colorScheme
                                      .primaryContainer,
                                ),
                              ),
                              Text(
                                '${widget.size} 평',
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Theme
                                        .of(context)
                                        .colorScheme
                                        .primaryContainer
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                if (widget.price2 != 0)
                                  Text(
                                    '${f.format(int.parse(widget.price.toString()) /
                                        10000)}만원 / ${f.format(
                                        int.parse(widget.price2.toString()) /
                                            10000)}만원',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Theme
                                          .of(context)
                                          .colorScheme
                                          .primaryContainer,
                                    ),
                                  ),
                                if (widget.price2 == 0)
                                  Text(
                                    '${f.format(int.parse(widget.price.toString()) /
                                        10000)}만원',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Theme
                                          .of(context)
                                          .colorScheme
                                          .primaryContainer,
                                    ),
                                  ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  '${widget.type}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Theme
                                        .of(context)
                                        .colorScheme
                                        .primaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 4,),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '엘리베이터 : ${widget.eliv == "1"
                                    ? "O"
                                    : "X"} / 주차 : ${(widget.parking == "")
                                    ? "0"
                                    : widget.parking}대',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Theme
                                      .of(context)
                                      .colorScheme
                                      .primaryContainer,
                                ),
                              ),
                              Text(
                                '${widget.floor} 층',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Theme
                                      .of(context)
                                      .colorScheme
                                      .primaryContainer,
                                ),
                              ),
                            ]
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if(widget.entitleprice > 0)
                              Text(
                                '권리금 : ${f.format(
                                    int.parse(widget.entitleprice.toString()) /
                                        10000)}만원',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Theme
                                      .of(context)
                                      .colorScheme
                                      .primaryContainer,
                                ),
                              ),
                            if(widget.entitleprice == 0)
                              Text(
                                '권리금 : -',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Theme
                                      .of(context)
                                      .colorScheme
                                      .primaryContainer,
                                ),
                              ),
                            if(widget.naver_no != '')
                              Text(
                                '${widget.naver_no}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.red,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _CommDetail extends StatefulWidget {
  const _CommDetail({Key? key}) : super(key: key);

  @override
  State<_CommDetail> createState() => _CommDetailState();
}

class _CommDetailState extends State<_CommDetail> {
  double _lat = 0.0;
  double _lng = 0.0;
  List<Marker> _markers = [];
  PageController _controller = PageController(initialPage: 0, keepPage: false);
  PageController _controllerMain = PageController(initialPage: 0, keepPage: false);
  final ImagePicker _picker = ImagePicker();
  late GoogleMapController _mapController;
  List<dynamic> _data = [];
  var f = NumberFormat('###,###,###,###');
  List<XFile> _pickedImgs = [];

  Future<void> _pickImg() async {
    final List<XFile>? images = await _picker.pickMultiImage(
      imageQuality: 20,
      maxWidth: 1024,
    );
    if (images != null) {
      setState(() {
        _pickedImgs = images;
      });
    }
  }



  Widget _SubTitle(String title) {
    return Container(
      width: MediaQuery.of(context).size.width - 520,
      padding: EdgeInsets.all(5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w400,
          color: Theme.of(context).colorScheme.onSecondary,
        ),
      ),
    );
  }

  void _kakaoMsg () async {
    final FeedTemplate defaultFeed = FeedTemplate(
      content: Content(
        title: _data[0]["division"],
        description: _data[0]["etc"],
        imageUrl: Uri.parse(
            _data[0]['img_1'] == ''
                ? '$appServerURL/sample.jpg'
                : '$appServerURL/${_data[0]['img_1']}'),
        link: Link(
            webUrl: Uri.parse(''),
            mobileWebUrl: Uri.parse('')),
      ),
      itemContent: ItemContent(
        // profileText: 'Kakao',
        // profileImageUrl: Uri.parse(
        //     'https://mud-kage.kakao.com/dn/Q2iNx/btqgeRgV54P/VLdBs9cvyn8BJXB3o7N8UK/kakaolink40_original.png'),
        titleImageUrl: Uri.parse(
            _data[0]['img_1'] == ''
                ? '$appServerURL/sample.jpg'
                : '$appServerURL/${_data[0]['img_1']}'),
        titleImageText: _data[0]["division"],
        titleImageCategory: '${_data[0]["floor"]}층',
        items: [
          ItemInfo(item: '매매가', itemOp: '${f.format(int.parse(_data[0]['salesprice'].toString())/10000)}만'),
          ItemInfo(item: '보증금/월세', itemOp: '${f.format(int.parse(_data[0]['deposit'].toString())/10000)}/${f.format(int.parse(_data[0]['monthly'].toString())/10000)}만'),
          ItemInfo(item: '관리비', itemOp: _data[0]['adminprice']),
          ItemInfo(item: '권리금', itemOp: '${f.format(int.parse(_data[0]['entitleprice'].toString())/10000)}만'),
          ItemInfo(item: '엘베/주차', itemOp: '${_data[0]['eliv'] == '1' ? '있음' : '없음'}/ ${_data[0]['parking'] == '' ? '0' : _data[0]['parking']}대')
        ],
        // sum: 'total',
        // sumOp: '15000원',
      ),
//      social: Social(likeCount: 286, commentCount: 45, sharedCount: 845),
      buttons: [
        // Button(
        //   title: '웹으로 보기',
        //   link: Link(
        //     webUrl: Uri.parse('https: //developers.kakao.com'),
        //     mobileWebUrl: Uri.parse('https: //developers.kakao.com'),
        //   ),
        // ),
        // Button(
        //   title: '앱으로보기',
        //   link: Link(
        //     androidExecutionParams: {'key1': 'value1', 'key2': 'value2'},
        //     iosExecutionParams: {'key1': 'value1', 'key2': 'value2'},
        //   ),
        // ),
      ],
    );

    bool isKakaoTalkSharingAvailable = await ShareClient.instance.isKakaoTalkSharingAvailable();

    if (isKakaoTalkSharingAvailable) {
      try {
        Uri uri =
        await ShareClient.instance.shareDefault(template: defaultFeed);
        await ShareClient.instance.launchKakaoTalk(uri);
        print('카카오톡 공유 완료');
      } catch (error) {
        print('카카오톡 공유 실패 $error');
      }
    } else {
      try {
        Uri shareUrl = await WebSharerClient.instance
            .makeDefaultUrl(template: defaultFeed);
        await launchBrowserTab(shareUrl, popupOpen: true);
      } catch (error) {
        print('카카오톡 공유 실패 $error');
      }
    }
  }

  Future<List> pagenationDetailData() async {

    final dio = Dio();
    final response = await dio.post(
        '$appServerURL/commdetail',
        data: {
          'id': _id,
        }
    );

    _data = response.data;

    _lat = double.parse(response.data[0]['lat'].toString());
    _lng = double.parse(response.data[0]['lng'].toString());


    final response2 = await dio.post(
        '$appServerURL/nearlist',
        data: {
          'id': _id,
          'lat': _lat,
          'lng': _lng,
          'type': 'C',
        }
    );

    if(response2.data.length > 0) {
      for(int i = 0; i < response2.data.length; i++) {
        _markers.add(
          Marker(
            markerId: MarkerId('marker_${i + 1}'),
            position: LatLng((response2.data[i]['lat']/1.0), (response2.data[i]['lng']/1.0)),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            infoWindow: InfoWindow(
              onTap: () {
                print('marker_${i + 1} clicked');
                getx.Get.offAll(
                  CommDetailViewScreen(
                    id: response2.data[i]['id'],
                  ),);
              },
              title: response2.data[i]['sub_addr'],
              snippet: '${(response2.data[i]['deposit']/10000).round()}/${(response2.data[i]['monthly']/10000).round()} ${response2.data[i]['size']}평',
            ),
          ),
        );
      }
    }



    dio.close();
    return response.data;
  }

  final _formKey = GlobalKey<FormState>();




  @override
  Widget build(BuildContext context) {

    List<String> _imgList = [];
    List<Widget> _boxContents = [
      IconButton(
        onPressed: () {
          _pickImg();
        },
        icon: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.red,
              width: 3,
            ),
          ),
          child: Icon(
            Icons.photo,
            color: Colors.red,
            size: 24,
          ),
        ),
      ),
      Container(),
      Container(),
      Container(),
      Container(),
      Container(),
      Container(),
      Container(),
      _pickedImgs.length <= 9 ? Container() : FittedBox(
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Text(
            '+${(_pickedImgs.length - 9).toString()}',
            style: Theme.of(context).textTheme.subtitle2?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    ];




    return Container(
      margin: const EdgeInsets.all(4),
      child: FutureBuilder(
        future: pagenationDetailData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            _imgList = [
              snapshot.data[0]['img_1'],
              snapshot.data[0]['img_2'],
              snapshot.data[0]['img_3'],
              snapshot.data[0]['img_4'],
              snapshot.data[0]['img_5'],
              snapshot.data[0]['img_6'],
              snapshot.data[0]['img_7'],
              snapshot.data[0]['img_8'],
              snapshot.data[0]['img_9'],
            ];
            return SingleChildScrollView(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 510,
                  height: 3000,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SubTitle('물건개요'),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        snapshot.data[0]['sub_addr'],
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            snapshot.data[0]['division'],
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                          Text(
                            snapshot.data[0]['type'] ?? '',
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '면적 : ${snapshot.data[0]['size'] ?? ''}평',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                          Text(
                            '${snapshot.data[0]['floor'] ?? ''}${snapshot.data[0]['totalfloor'] == 0 ? '' : '/'}${snapshot.data[0]['totalfloor'] == 0 ? '' : snapshot.data[0]['totalfloor']}층',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),

                        ],
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '주차 : ${snapshot.data[0]['parking'] == '' ? '0' : snapshot.data[0]['parking']}대',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                          Text(
                            '엘베 : ${snapshot.data[0]['eliv'] == '1' ? '있음' : '없음'}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        '${snapshot.data[0]['addr'] ?? ''}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '네이버 매물번호 : ${snapshot.data[0]['naver_no'] ?? ''}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                          Text(
                            '${snapshot.data[0]['direction'] ?? ''}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width - 510,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(8),
                              primary: Theme.of(context).colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            onPressed: () {
                              getx.Get.off(() => CommUpdateScreen(
                                  id: _id,
                                  type: 1
                              ));
                            },
                            child: Text(
                              '자료수정',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w400,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            )
                        ),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width - 510,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(8),
                              primary: Theme.of(context).colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            onPressed: () {
                              _kakaoMsg();
                            },
                            child: Text(
                              '카카오로 보내기',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w400,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            )
                        ),
                      ),
                      Divider(color: Theme.of(context).colorScheme.primary, thickness: 1.0),
                      Column(
                        children: [
                          _SubTitle('물건가격'),
                          SizedBox(
                            height: 8,
                          ),
                          if(snapshot.data[0]['deposit'] > 0)
                            Row(
                              children: [
                                Text(
                                  '임대료 : ${f.format(int.parse(snapshot.data[0]['deposit'].toString())/10000)}',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w400,
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  ),
                                ),
                                Text(
                                  ' / ${f.format(int.parse(snapshot.data[0]['monthly'].toString())/10000)}만원',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w400,
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      if(snapshot.data[0]['salesprice'] > 0)
                        Text(
                          '매매가 : ${f.format(int.parse(snapshot.data[0]['salesprice'].toString())/10000)}만원',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        '관리비 : ${snapshot.data[0]['adminprice']}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        '권리금 : ${f.format(int.parse(snapshot.data[0]['entitleprice'].toString())/10000)}만원',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      Divider(color: Theme.of(context).colorScheme.primary, thickness: 1.0),
                      _SubTitle('연락처'),
                      SizedBox(
                        height: 8,
                      ),
                      RichText(
                        text : TextSpan(
                          text: '${snapshot.data[0]['name'] ?? ''} : ${snapshot.data[0]['tel'] ?? ''}',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                            color: Colors.blue,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              await launchUrl(Uri.parse('tel:${snapshot.data[0]['tel']}' ?? ''));
                            },
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      RichText(
                        text : TextSpan(
                          text: '${snapshot.data[0]['name2'] ?? ''} : ${snapshot.data[0]['tel2'] ?? ''}',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                            color: Colors.blue,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              await launchUrl(Uri.parse('tel:${snapshot.data[0]['tel2']}' ?? ''));
                            },
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Divider(color: Theme.of(context).colorScheme.primary, thickness: 1.0),
                      _SubTitle('기 타'),
                      Text('접수일자 : ${DateFormat('yyyy/MM/dd').format(DateTime.parse(snapshot.data[0]['date']))}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text('${snapshot.data[0]['etc'] ?? ''}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),

                      Divider(color: Theme.of(context).colorScheme.primary, thickness: 1.0),
                      _SubTitle('상세위치'),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        '${snapshot.data[0]['addr'] ?? ''}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      Text(
                        '${snapshot.data[0]['addr2'] ?? ''}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      GestureDetector(
                        onTap: () {
                        },
                        child: Container(
                          margin: EdgeInsets.all(3.0),
                          height: 500,
                          width: MediaQuery.of(context).size.width - 520,
                          child: Image.network('https://maps.googleapis.com/maps/api/staticmap?center=&{$_lat,$_lng},zoom=13&size=${(MediaQuery.of(context).size.width - 520).round()}x500&maptype=roadmap&markers=color:red%7C$_lat,$_lng&key=$googleMapKey'),
                        ),
                      ),
                      _SubTitle('사진'),
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 510,
                        height: (MediaQuery.of(context).size.width - 510) * 0.65,
                        child : GridView.count(
                          crossAxisCount: 3,
                          mainAxisSpacing: 5.0,
                          crossAxisSpacing: 5.0,
                          childAspectRatio: 2/1.3,
                          padding: EdgeInsets.all(5.0),
                          children: List.generate(9,
                            (index) => DottedBorder(
                              color: Theme.of(context).colorScheme.primary,
                              strokeWidth: 1,
                              dashPattern: [5, 5],
                              child: GestureDetector(
                                child: Container(
                                  decoration:
                                  index <= _pickedImgs.length -1
                                      ? BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Theme.of(context).colorScheme.primaryContainer,
                                    image: DecorationImage(
                                      image: FileImage(File(_pickedImgs[index].path)),
                                      fit: BoxFit.fitHeight,
                                    ),
                                  ) :
                                  index <= _imgList.length -1
                                      ? BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Theme.of(context).colorScheme.primaryContainer,
                                    image: DecorationImage(
                                      image: _imgList[index] == '' ? NetworkImage('$appServerURL/sample.jpg',) :  NetworkImage('$appServerURL/${_imgList[index]}',),
                                      fit: BoxFit.fitHeight,
                                    ),
                                  ) : null,
                                  child : Center(child: _boxContents[index]),
                                ),
                                // onTap: () async {
                                //   String dir = (await getApplicationDocumentsDirectory()).path;
                                //   try{
                                //     await FlutterDownloader.enqueue(
                                //       url: "${_imgList[index] == '' ? NetworkImage('$appServerURL/sample.jpg',) :  NetworkImage('$appServerURL/${_imgList[index]}',)}", 	// file url
                                //       savedDir: '$dir/',	// 저장할 dir
                                //       fileName: "${_imgList[index] == '' ? 'sample.jpg' :  _imgList[index]}",	// 파일명
                                //       saveInPublicStorage: true ,	// 동일한 파일 있을 경우 덮어쓰기 없으면 오류발생함!
                                //     );
                                //
                                //
                                //     print("파일 다운로드 완료");
                                //   }catch(e){
                                //     print("eerror :::: $e");
                                //   }
                                //
                                // },
                              ),
                            ),
                          ),
                        ),
                      ),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Theme.of(context).colorScheme.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),

                              onPressed: _pickedImgs.length == 0
                                  ? null
                                  : () async {
                                final List<MultipartFile> _files =  _pickedImgs.map((img) => MultipartFile.fromFileSync(img.path,  contentType: new MediaType("image", "jpg"))).toList();
                                FormData _formData = FormData.fromMap({"uploadfile": _files});

                                Dio dio = Dio();

                                // dio.options.headers["authorization"] = AuthProvider.token;
                                dio.options.contentType = 'multipart/form-data';
                                dio.options.maxRedirects.isFinite;
                                try {
                                  final res = await dio.post('$appServerURL/upload', data: _formData).then(
                                          (res) async {
                                        if (res.data.length > 0) {
                                          for(int i = 0; i < res.data.length; i++) {
                                            Dio dio2 = Dio();
                                            final response = await dio2.post(
                                                '$appServerURL/imgupdate',
                                                data: {
                                                  'id': '${snapshot.data[0]['id']}',
                                                  'imgname': '${res.data[i]['filename']}',
                                                  'no': '${i + 1}',
                                                }
                                            );
                                            dio2.close();
                                          }
                                        }
                                      }
                                  );
                                } catch (e) {
                                  print(e);
                                }


                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('사진이 수정되었습니다.'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );

                                Future.delayed(const Duration(milliseconds: 600), () {
                                  getx.Get.offAll(() => CommDetailViewScreen(id: snapshot.data[0]['id'],));
                                });

                                dio.close();
                              },
                              child: Text(
                                '사진 수정',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ]
                      ),
                      Divider(color: Theme.of(context).colorScheme.primary, thickness: 1.0),

                      SizedBox(
                        height: 6,
                      ),
                    ],
                  ),
                ),
              );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}