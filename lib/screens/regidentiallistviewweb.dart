import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kakao_login_test/screens/assetdetailview.dart';
import 'package:kakao_login_test/screens/component/bottom_menu.dart';
import 'package:kakao_login_test/screens/mapscreen.dart';
import '../common/commondata.dart';
import '../status/controller.dart';
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart' as getx;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:dio/src/form_data.dart';
import 'package:flutter/foundation.dart';
import 'package:kakao_login_test/screens/assetupdate.dart';
import 'package:kakao_flutter_sdk_share/kakao_flutter_sdk_share.dart';
import 'package:kakao_flutter_sdk_talk/kakao_flutter_sdk_talk.dart';
import 'package:http_parser/http_parser.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:kakao_login_test/screens/component/basket.dart';


int _id = 0;


class AssetCard extends StatelessWidget {
  final int id;
  final Widget image;
  final String callname;
  final int price;
  final int price2;
  final int room;
  final int bath;
  final int size;
  final String direction;
  final String indate;
  final int floor;
  final int totalfloor;
  final String type;
  final String gubun;
  final String addr;
  final String naver_no;

  const AssetCard({
    required this.price,
    required this.price2,
    required this.id,
    required this.image,
    required this.callname,
    required this.direction,
    required this.floor,
    required this.totalfloor,
    required this.indate,
    required this.bath,
    required this.room,
    required this.size,
    required this.type,
    required this.gubun,
    required this.addr,
    required this.naver_no,
    Key? key}) : super(key: key);


  updateLatLng() async {
    final dio = Dio();
    double _lat = 0.0;
    double _lng = 0.0;

    String gpsUrl =
        'https://maps.googleapis.com/maps/api/geocode/json?address=$addr&key=$googleMapKey&language=ko';

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
            'id': id,
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
    _RegidentialListViewScreenWebState? parent = context.findAncestorStateOfType<_RegidentialListViewScreenWebState>();
    var f = NumberFormat('###,###,###,###');
//    List<basketItems> basketList = [];

//    updateLatLng();

    return Dismissible(
      // Each Dismissible must contain a Key. Keys allow Flutter to
      // uniquely identify widgets.
      key: UniqueKey(),
      // Provide a function that tells the app
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
                        addData(id,'H');
                        // basketList  = await getAllItems();
                        // print('==============');
                        // print(basketList[0].id);
                        Navigator.of(context).pop(false);
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text("$callname 관심 물건으로 추가됨")));
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
                              '$appServerURL/setstatushome',
                              data: {
                                'uuid': id,
                              }
                          );



                        } catch (e) {
                          print(e);
                        }

                        dio.close();
                        Navigator.of(context).pop(true);
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text("$callname 거래 완료됨")));
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
        if(direction == DismissDirection.endToStart) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("$callname 관심 물건 추가")));
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("$callname 거래 완료됨")));
        }
      },

      child: GestureDetector(
        onTap: () {
          parent!.setState(() {
            _id = id;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
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
                    child: image,
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
                              Container(
                                width: kIsWeb ? 300 : MediaQuery.of(context).size.width * 0.43,
                                child: Text(
                                  '$callname',
                                  maxLines: 1,
                                  overflow: TextOverflow.fade,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primaryContainer,
                                  ),
                                ),
                              ),
                              Container(
                                child: Text(
                                  '${(size * 0.3052).round().toString()}평',
                                  overflow: TextOverflow.fade,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primaryContainer
                                  ),
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
                                if (price2 != 0)
                                  Text(
                                    '${f.format(int.parse((price/10000).round().toString()))}만/${f.format(int.parse((price2/10000).round().toString()))}만',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primaryContainer,
                                    ),
                                  ),
                                if (price2 == 0)
                                  Text(
                                    '${f.format(int.parse((price/10000).round().toString()))}만',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primaryContainer,
                                    ),
                                  ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  '$type',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primaryContainer,
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
                                '방$room/욕실$bath',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.primaryContainer,
                                ),
                              ),
                              Text(
                                '$direction향',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.primaryContainer,
                                ),
                              ),
                              Text(
                                '${floor.toString()}/${totalfloor.toString()} (층)',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.primaryContainer,
                                ),
                              ),]
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '입주가능일 : $indate',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.primaryContainer,
                              ),
                            ),
                            if(naver_no != '')
                              Text(
                                '$naver_no',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
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


class RegidentialListViewScreenWeb extends StatefulWidget {
  const RegidentialListViewScreenWeb({Key? key}) : super(key: key);

  @override
  State<RegidentialListViewScreenWeb> createState() => _RegidentialListViewScreenWebState();
}

class _RegidentialListViewScreenWebState extends State<RegidentialListViewScreenWeb> {
  Future<List> paginationAssetList() async {
    final controller = getx.Get.put(Controller());
    final String minPrice;
    final String maxPrice;
    String minPrice2 = '0';
    String maxPrice2 = '0';
    String minSize = '0';
    String maxSize = '300';
    final String callname;
    final String roomCount;
    final String gubun;


    if (controller.selectGubun.value == '전세') {
      maxPrice = controller.maxJeonse.value.toString();
      minPrice = controller.minJeonse.value.toString();
    } else if (controller.selectGubun.value == '월세') {
      minPrice = '${controller.minDeposit.value.toString()}';
      maxPrice = '${controller.maxDeposit.value.toString()}';
      minPrice2 = '${controller.minMonthly.value.toString()}';
      maxPrice2 = '${controller.maxMonthly.value.toString()}';
    } else {
      minPrice = '${controller.minPrice.value.toString()}';
      maxPrice = '${controller.maxPrice.value.toString()}';
    }
    minSize = '${controller.minSize.value.toString()}';
    maxSize = '${controller.maxSize.value.toString()}';
    callname = '${controller.selectCallname.value}';
    roomCount = '${controller.roomCount.value}';
    gubun = '${controller.selectGubun.value}';

    try {
      final dio = Dio();

      final response = await dio.post(
          '$appServerURL/selected',
          data: {
            'gubun': '${controller.selectGubun.value}',
            'callname': '${callname}',
            'minp': '${minPrice}',
            'maxp': '${maxPrice}',
            'minp2': '${minPrice2}',
            'maxp2': '${maxPrice2}',
            'mins': '${minSize}',
            'maxs': '${maxSize}',
            'roomcount': '${roomCount}',
          }
      );


      dio.close();


      return response.data;


    } catch(e) {
      print(e);
      return [];
    }
  }


  void _addbasket() async {
    if(_id == 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(
          "선택된 물건이 없습니다.")));
      return;
    }
    addData(_id, 'H');
    // basketList  = await getAllItems();
    // print('==============');
    // print(basketList[0].id);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(
        "관심 물건으로 추가됨")));
  }




  @override
  Widget build(BuildContext context) {
    final _authentication = FirebaseAuth.instance;
    final controller = getx.Get.put(Controller());

    return Scaffold(
      appBar: AppBar(
        title: const Text('주거용 부동산'),
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
            width: 510,
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
                                  child: AssetCard(
                                    id: snapshot.data[index]['id'],
                                    image: Image.network(
                                      snapshot.data[index]['img1'] == ''
                                          ? '$appServerURL/sample.jpg'
                                          : '$appServerURL/${snapshot.data[index]['img1']}',
                                      fit: BoxFit.cover,
                                    ),
                                    callname: snapshot.data[index]['callname'],
                                    price: snapshot.data[index]['price'],
                                    price2: snapshot.data[index]['price2'] ?? 0,
                                    room: snapshot.data[index]['room'] ?? 0,
                                    bath: snapshot.data[index]['bath'] ?? 0,
                                    size: snapshot.data[index]['size'] ?? 0,
                                    direction: snapshot.data[index]['direction'],
                                    indate: snapshot.data[index]['indate'],
                                    floor: snapshot.data[index]['floor'] ?? 0,
                                    totalfloor: snapshot.data[index]['totalfloor'] ?? 0,
                                    type: snapshot.data[index]['type'] ?? '',
                                    gubun: controller.selectGubun.value,
                                    addr: snapshot.data[index]['addr'],
                                    naver_no: snapshot.data[index]['naver_no'],
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
          ),
          if(_id == 0) Container(),
          if(_id != 0) _HomeDetail(),
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
}




class _HomeDetail extends StatefulWidget {
  const _HomeDetail({Key? key}) : super(key: key);

  @override
  State<_HomeDetail> createState() => _HomeDetailState();
}

class _HomeDetailState extends State<_HomeDetail> {
  double _lat = 0.0;

  double _lng = 0.0;
  var f = NumberFormat('###,###,###,###');
  List<dynamic> _data = [];

  Future<List> pagenationDetailData() async {
    final dio = Dio();
    final response = await dio.post(
        '$appServerURL/homedetail',
        data: {
          'id': _id,
        }
    );
    print(response.data);
    _data = response.data;

    dio.close();

    _lat = double.parse(response.data[0]['lat'].toString());
    _lng = double.parse(response.data[0]['lng'].toString());
    return response.data;
  }



  void _kakaoMsg () async {
    final FeedTemplate defaultFeed = FeedTemplate(
      content: Content(
        title: _data[0]["callname"],
        // description: _data[0]["etc"],
        imageUrl: Uri.parse(
            _data[0]['img1'] == ''
                ? '$appServerURL/sample.jpg'
                : '$appServerURL/${_data[0]['img1']}'),
        link: Link(
            webUrl: Uri.parse(''),
            mobileWebUrl: Uri.parse('')),
      ),
      itemContent: ItemContent(
        // profileText: 'Kakao',
        // profileImageUrl: Uri.parse(
        //     'https://mud-kage.kakao.com/dn/Q2iNx/btqgeRgV54P/VLdBs9cvyn8BJXB3o7N8UK/kakaolink40_original.png'),
        titleImageUrl: Uri.parse(
            _data[0]['img1'] == ''
                ? '$appServerURL/sample.jpg'
                : '$appServerURL/${_data[0]['img1']}'),
        titleImageText: _data[0]["callname"],
        titleImageCategory: '${_data[0]["floor"].toString()}층',
        items: [
          ItemInfo(item: '매매가', itemOp: '${f.format(int.parse(_data[0]['salesprice'].toString())/10000)}만'),
          ItemInfo(item: '전세금', itemOp: '${f.format(int.parse(_data[0]['jeonse'].toString())/10000)}만'),
          ItemInfo(item: '월세보증금', itemOp: '${f.format(int.parse(_data[0]['deposit'].toString())/10000)}만'),
          ItemInfo(item: '월세', itemOp: '${f.format(int.parse(_data[0]['monthly'].toString())/10000)}만'),
          ItemInfo(item: '방/화', itemOp: '${_data[0]['room'].toString()}/${_data[0]['bath'].toString()}')
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



  final ImagePicker _picker = ImagePicker();

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
      width: MediaQuery.of(context).size.width - 530,
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



  @override
  Widget build(BuildContext context) {
    final _authentication = FirebaseAuth.instance;

    PageController _controller = PageController(initialPage: 0, keepPage: false);
    PageController _controllerMain = PageController(initialPage: 0, keepPage: false);
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
      width: MediaQuery.of(context).size.width - 530,
      height: 2000,
      margin: const EdgeInsets.all(8),
      child: FutureBuilder(
        future: pagenationDetailData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            _imgList = [
              snapshot.data[0]['img1'],
              snapshot.data[0]['img2'],
              snapshot.data[0]['img3'],
              snapshot.data[0]['img4'],
              snapshot.data[0]['img5'],
              snapshot.data[0]['img6'],
              snapshot.data[0]['img7'],
              snapshot.data[0]['img8'],
              snapshot.data[0]['img9'],
            ];
            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SubTitle('물건개요'),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        snapshot.data[0]['callname'],
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      Text(
                        snapshot.data[0]['type'] ?? '',
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
                        '면적 : ${snapshot.data[0]['size'] ?? ''} ㎡   (${snapshot.data[0]['sizetype'] ?? ''} 형)',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      Text(
                        '${snapshot.data[0]['floor'] ?? ''}/${snapshot.data[0]['totalfloor'] ?? ''}층',
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
                        '${snapshot.data[0]['direction'] ?? ''}향',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      Text(
                        '방${snapshot.data[0]['room'] ?? ''}/화${snapshot.data[0]['bath'] ?? ''} ',
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
                    snapshot.data[0]['addr'] ?? '',
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
                    '입주가능일 : ${snapshot.data[0]['indate']} (${snapshot.data[0]['indatetype']})',
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
                    '네이버 매물번호 : ${snapshot.data[0]['naver_no']}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(8),
                          primary: Theme.of(context).colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        onPressed: () {
                          getx.Get.off(() => AssetUpdateScreen(
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
                    width: MediaQuery.of(context).size.width,
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
                  Divider(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    thickness: 1,
                  ),
                  _SubTitle('물건가격'),
                  SizedBox(
                    height: 6,
                  ),
                  if(snapshot.data[0]['jeonse'] > 0)
                    Text(
                      '전세가 : ${f.format(int.parse((snapshot.data[0]['jeonse']/10000).round().toString()))}만원',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  if(snapshot.data[0]['deposit'] > 0)
                    Row(
                      children: [
                        Text(
                          '보증금 : ${f.format(int.parse((snapshot.data[0]['deposit']/10000).round().toString()))}만원',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                        Text(
                          ' / 월세 : ${f.format(int.parse((snapshot.data[0]['monthly']/10000).round().toString()))}만원',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  if(snapshot.data[0]['salesprice'] > 0)
                    Text(
                      '매매가 : ${f.format(int.parse((snapshot.data[0]['salesprice']/10000).round().toString()))}만원',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  if(snapshot.data[0]['loan'] > 0)
                    Text(
                      '대출금 : ${f.format(int.parse((snapshot.data[0]['loan']/10000).round().toString()))}만원',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  SizedBox(
                    height: 8,
                  ),
                  Divider(color: Theme.of(context).colorScheme.primary, thickness: 1.0),
                  _SubTitle('연락처'),
                  SizedBox(
                    height: 6,
                  ),
                  RichText(
                    text : TextSpan(
                      text: '${snapshot.data[0]['name1'] ?? ''} : ${snapshot.data[0]['phone1'] ?? ''}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        color: Colors.blue,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          await launchUrl(Uri.parse('tel:${snapshot.data[0]['phone1']}' ?? ''));
                        },
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  RichText(
                    text : TextSpan(
                      text: '${snapshot.data[0]['name2'] ?? ''} : ${snapshot.data[0]['phone2'] ?? ''}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        color: Colors.blue,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          await launchUrl(Uri.parse('tel:${snapshot.data[0]['phone2']}' ?? ''));
                        },
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Divider(color: Theme.of(context).colorScheme.primary, thickness: 1.0),
                  _SubTitle('기타'),
                  Text('접수일자 : ${DateFormat('yyyy/MM/dd').format(DateTime.parse(snapshot.data[0]['date']))}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Text('${snapshot.data[0]['description'] ?? ''}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  SizedBox(
                    height: 6,
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
                  SizedBox(
                    height: 6,
                  ),
                  Text(
                    '${snapshot.data[0]['addr2'] ?? ''}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _controllerMain.jumpToPage(1);
                    },
                    child: Container(
                      margin: EdgeInsets.all(3.0),
                      height: 500,
                      width: MediaQuery.of(context).size.width,
                      child: Image.network('https://maps.googleapis.com/maps/api/staticmap?center=&{$_lat,$_lng},zoom=13&size=${(MediaQuery.of(context).size.width - 530).round()}x500&maptype=roadmap&markers=color:red%7C$_lat,$_lng&key=$googleMapKey'),
                    ),
                  ),
                  Divider(color: Theme.of(context).colorScheme.primary, thickness: 1.0),
                  _SubTitle('사진편집'),
                  SizedBox(
                    height: (MediaQuery.of(context).size.width - 530)/1.5,
                    child : GridView.count(
                      crossAxisCount: 3,
                      mainAxisSpacing: 5.0,
                      crossAxisSpacing: 5.0,
                      childAspectRatio: 2/1.3,
                      padding: EdgeInsets.all(5.0),
                      children: List.generate(
                        9,
                            (index) => DottedBorder(
                          color: Theme.of(context).colorScheme.primary,
                          strokeWidth: 1,
                          dashPattern: [5, 5],
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
                        ),
                      ),
                    ),
                  ),
                  if(kIsWeb)
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
                              //
                              try {
                                final res = await dio.post('$appServerURL/upload', data: _formData).then(
                                        (res) async {
                                      if (res.data.length > 0) {
                                        for(int i = 0; i < res.data.length; i++) {
                                          Dio dio2 = Dio();
                                          final response = await  dio2.post(
                                              '$appServerURL/imgupdatehome',
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

                              dio.close();
                              Future.delayed(const Duration(milliseconds: 600), () {
                                getx.Get.offAll(() => AssetDetailViewScreen(id: snapshot.data[0]['id'],));
                              });
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
                ],
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