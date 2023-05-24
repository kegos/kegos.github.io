
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart' as getx;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:dio/src/form_data.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kakao_login_test/screens/assetupdate.dart';
import 'package:kakao_login_test/screens/component/bottom_menu.dart';
import 'package:kakao_flutter_sdk_share/kakao_flutter_sdk_share.dart';
import 'package:kakao_flutter_sdk_talk/kakao_flutter_sdk_talk.dart';
import 'package:http_parser/http_parser.dart';
import 'package:kakao_login_test/screens/mapscreen.dart';
import 'package:url_launcher/url_launcher.dart';

import '../common/commondata.dart';
import 'component/basket.dart';


class AssetDetailViewScreen extends StatefulWidget {
  final int id;

  AssetDetailViewScreen({
    required this.id,
    Key? key}) : super(key: key);

  @override
  State<AssetDetailViewScreen> createState() => _AssetDetailViewScreenState();
}

class _AssetDetailViewScreenState extends State<AssetDetailViewScreen> {
  double _lat = 0.0;

  double _lng = 0.0;
  var f = NumberFormat('###,###,###,###');
  List<dynamic> _data = [];

  Future<List> pagenationDetailData() async {
    final dio = Dio();
    final response = await dio.post(
        '$appServerURL/homedetail',
        data: {
          'id': widget.id,
        }
    );
    print(response.data);
    _data = response.data;

    dio.close();

    _lat = double.parse(response.data[0]['lat'].toString());
    _lng = double.parse(response.data[0]['lng'].toString());
    return response.data;
  }


  void _addbasket() async {
    if(widget.id == 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(
          "선택된 물건이 없습니다.")));
      return;
    }
    addData(widget.id, 'H');
    // basketList  = await getAllItems();
    // print('==============');
    // print(basketList[0].id);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(
        "관심 물건으로 추가됨")));
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
            webUrl: Uri.parse('https://blog.naver.com/smkim7015'),
            mobileWebUrl: Uri.parse('https://blog.naver.com/smkim7015')),
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



  @override
  Widget build(BuildContext context)  {
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





    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          title: const Text('주거 상세보기'),
          actions: [
            IconButton(
              onPressed: () {
                _addbasket();
              },
              icon: const Icon(Icons.shopping_cart),
            ),
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
      body: Container(
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
                        Divider(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          thickness: 1,
                        ),
                        if(!kIsWeb)
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: (MediaQuery.of(context).size.width / 13) * 7,
                            child: PageView(
                                    controller: _controller,
                                    children: [
                                        ClipRRect(
                                          child: Image.network(
                                            snapshot.data[0]['img1'] == ''
                                                ? '$appServerURL/sample.jpg'
                                                : '$appServerURL/${snapshot.data[0]['img1']}',
                                            fit: BoxFit.fitHeight,
                                          ),
                                        ),
                                      ClipRRect(
                                        child: Image.network(
                                          snapshot.data[0]['img2'] == ''
                                              ? '$appServerURL/sample.jpg'
                                              : '$appServerURL/${snapshot.data[0]['img2']}',
                                          fit: BoxFit.fitHeight,
                                        ),
                                      ),
                                      if(snapshot.data[0]['img3'] != '')
                                        ClipRRect(
                                          child: Image.network(
                                            '$appServerURL/${snapshot.data[0]['img3']}',
                                            fit: BoxFit.fitHeight,
                                          ),
                                        ),
                                      if(snapshot.data[0]['img4'] != '')
                                        ClipRRect(
                                          child: Image.network(
                                            '$appServerURL/${snapshot.data[0]['img4']}',
                                            fit: BoxFit.fitHeight,
                                          ),
                                        ),
                                      if(snapshot.data[0]['img5'] != '')
                                        ClipRRect(
                                          child: Image.network(
                                            '$appServerURL/${snapshot.data[0]['img5']}',
                                            fit: BoxFit.fitHeight,
                                          ),
                                        ),
                                      if(snapshot.data[0]['img6'] != '')
                                        ClipRRect(
                                          child: Image.network(
                                            '$appServerURL/${snapshot.data[0]['img6']}',
                                            fit: BoxFit.fitHeight,
                                          ),
                                        ),
                                      if(snapshot.data[0]['img7'] != '')
                                        ClipRRect(
                                          child: Image.network(
                                            '$appServerURL/${snapshot.data[0]['img7']}',
                                            fit: BoxFit.fitHeight,
                                          ),
                                        ),
                                      if(snapshot.data[0]['img8'] != '')
                                        ClipRRect(
                                          child: Image.network(
                                            '$appServerURL/${snapshot.data[0]['img8']}',
                                            fit: BoxFit.fitHeight,
                                          ),
                                        ),
                                      if(snapshot.data[0]['img9'] != '')
                                        ClipRRect(
                                          child: Image.network(
                                            '$appServerURL/${snapshot.data[0]['img9']}',
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
      bottomNavigationBar: BottomMenuBar(),
    );
  }
}
