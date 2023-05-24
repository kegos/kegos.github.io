
import 'dart:async';
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart' as getx;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:dio/src/form_data.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kakao_login_test/screens/commupdate.dart';
import 'package:kakao_login_test/screens/component/bottom_menu.dart';
import 'package:kakao_flutter_sdk_share/kakao_flutter_sdk_share.dart';
import 'package:kakao_flutter_sdk_talk/kakao_flutter_sdk_talk.dart';
import 'package:http_parser/http_parser.dart';
import 'package:kakao_login_test/screens/mapscreen.dart';

import 'package:url_launcher/url_launcher.dart';

import '../common/commondata.dart';

class CommDetailViewScreen extends StatefulWidget {
  final int id;


  CommDetailViewScreen({
    required this.id,
    Key? key}) : super(key: key);


  @override
  State<CommDetailViewScreen> createState() => _CommDetailViewScreenState();
}

class _CommDetailViewScreenState extends State<CommDetailViewScreen> {
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
      width: MediaQuery.of(context).size.width,
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
            webUrl: Uri.parse('https://blog.naver.com/smkim7015'),
            mobileWebUrl: Uri.parse('https://blog.naver.com/smkim7015')),
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
          'id': widget.id,
        }
    );

    _data = response.data;

    _lat = double.parse(response.data[0]['lat'].toString());
    _lng = double.parse(response.data[0]['lng'].toString());


    final response2 = await dio.post(
        '$appServerURL/nearlist',
        data: {
          'id': widget.id,
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
  Widget build(BuildContext context)  {
    final _authentication = FirebaseAuth.instance;


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





    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('물건 상세보기'),
        actions: [
          IconButton(
            onPressed: () {
              _kakaoMsg();
            },
            icon: const Icon(Icons.share),
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
      body: Container(
        margin: const EdgeInsets.all(8),
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
                          '방향 : ${snapshot.data[0]['direction'] ?? ''}',
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
                            getx.Get.off(() => CommUpdateScreen(
                                id: widget.id,
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
                    Divider(color: Theme.of(context).colorScheme.primary, thickness: 1.0),

                    if(!kIsWeb)
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: (MediaQuery.of(context).size.width / 13) * 7,
                        child: PageView(
                          controller: _controller,
                          children: [
                            if(snapshot.data[0]['img_1'] != '')
                                ClipRRect(
                                  child: Image.network('$appServerURL/${snapshot.data[0]['img_1']}',
                                    fit: BoxFit.fitHeight,
                                  ),
                                ),
                            if(snapshot.data[0]['img_1'] == '')
                              ClipRRect(
                                child: Image.asset('image/smile.jpg',
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                            if(snapshot.data[0]['img_2'] != '')
                              ClipRRect(
                                child: Image.network('$appServerURL/${snapshot.data[0]['img_2']}',
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                            if(snapshot.data[0]['img_2'] == '')
                              ClipRRect(
                                child: Image.asset('image/smile.jpg',
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                            if(snapshot.data[0]['img_3'] != '')
                              ClipRRect(
                                child: Image.network('$appServerURL/${snapshot.data[0]['img_3']}',
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                            if(snapshot.data[0]['img_3'] == '')
                              ClipRRect(
                                child: Image.asset('image/smile.jpg',
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                            if(snapshot.data[0]['img_4'] != '')
                              ClipRRect(
                                child: Image.network('$appServerURL/${snapshot.data[0]['img_4']}',
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                            if(snapshot.data[0]['img_4'] == '')
                              ClipRRect(
                                child: Image.asset('image/smile.jpg',
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                            if(snapshot.data[0]['img_5'] != '')
                              ClipRRect(
                                child: Image.network('$appServerURL/${snapshot.data[0]['img_5']}',
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                            if(snapshot.data[0]['img_5'] == '')
                              ClipRRect(
                                child: Image.asset('image/smile.jpg',
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                            if(snapshot.data[0]['img_6'] != '')
                              ClipRRect(
                                child: Image.network('$appServerURL/${snapshot.data[0]['img_6']}',
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                            if(snapshot.data[0]['img_6'] == '')
                              ClipRRect(
                                child: Image.asset('image/smile.jpg',
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                            if(snapshot.data[0]['img_7'] != '')
                              ClipRRect(
                                child: Image.network('$appServerURL/${snapshot.data[0]['img_7']}',
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                            if(snapshot.data[0]['img_7'] == '')
                              ClipRRect(
                                child: Image.asset('image/smile.jpg',
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                            if(snapshot.data[0]['img_8'] != '')
                              ClipRRect(
                                child: Image.network('$appServerURL/${snapshot.data[0]['img_8']}',
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                            if(snapshot.data[0]['img_8'] == '')
                              ClipRRect(
                                child: Image.asset('image/smile.jpg',
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                            if(snapshot.data[0]['img_9'] != '')
                              ClipRRect(
                                child: Image.network('$appServerURL/${snapshot.data[0]['img_9']}',
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                            if(snapshot.data[0]['img_9'] == '')
                              ClipRRect(
                                child: Image.asset('image/smile.jpg',
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                          ],
                        ),
                      ),
                    if(kIsWeb)
                      SizedBox(
                        height: MediaQuery.of(context).size.width/1.5,
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
                                  image: _imgList[index] == '' ? DecorationImage(image: AssetImage('image/smile.jpg',), fit: BoxFit.fitHeight,)
                                      : DecorationImage(image: NetworkImage('$appServerURL/${_imgList[index]}'), fit: BoxFit.fitHeight,),
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
                        _controllerMain.jumpToPage(1);
                      },
                      child: Container(
                        margin: EdgeInsets.all(3.0),
                        height: 200,
                        width: MediaQuery.of(context).size.width,
                        child: Image.network('https://maps.googleapis.com/maps/api/staticmap?center=&{$_lat,$_lng},zoom=13&size=${(MediaQuery.of(context).size.width*0.97).round()}x197&maptype=roadmap&markers=color:red%7C$_lat,$_lng&key=$googleMapKey'),
                      ),
                    ),
                    Divider(color: Theme.of(context).colorScheme.primary, thickness: 1.0),
                    if(!kIsWeb)
                      _SubTitle('사진편집'),
                    SizedBox(
                      height: 8,
                    ),
                    if(!kIsWeb)
                      SizedBox(
                        height: MediaQuery.of(context).size.width/1.5,
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
                                  image: _imgList[index] == '' ? DecorationImage(image: AssetImage('image/smile.jpg',), fit: BoxFit.fitHeight,)
                                      : DecorationImage(image: NetworkImage('$appServerURL/${_imgList[index]}'), fit: BoxFit.fitHeight,),
                                ) : null,
                                child : Center(child: _boxContents[index]),

                              ),
                            ),
                          ),
                        ),
                      ),
                    if(!kIsWeb)
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
                                await dio.post('$appServerURL/upload', data: _formData).then(
                                        (res) async {
                                      if (res.data.length > 0) {
                                        Dio dio2 = Dio();
                                        for(int i = 0; i < res.data.length; i++) {

                                          await dio2.post(
                                              '$appServerURL/imgupdate',
                                              data: {
                                                'id': '${snapshot.data[0]['id']}',
                                                'imgname': '${res.data[i]['filename']}',
                                                'no': '${i + 1}',
                                              }
                                          );

                                        }
                                        dio2.close();
                                      }
                                    }
                                ).then(
                                        (value) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('사진이 수정되었습니다.'),
                                          duration: Duration(seconds: 1),
                                        ),
                                      );

                                      Future.delayed(const Duration(milliseconds: 600), () {
                                        getx.Get.offAll(() => CommDetailViewScreen(id: snapshot.data[0]['id'],));
                                      });
                                    }
                                ).catchError((e) {
                                  print(e);
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
                    SizedBox(
                      height: 6,
                    ),
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
      ),
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
          'id': widget.id,
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

