import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kakao_login_test/screens/component/bottom_menu.dart';
import 'package:kakao_login_test/screens/component/comm_card.dart';
import 'package:kakao_login_test/screens/mapscreen.dart';
import '../common/commondata.dart';
import '../status/controller.dart';


class CommercialListViewScreen extends StatelessWidget {
  const CommercialListViewScreen({Key? key}) : super(key: key);

  Future<List> paginationAssetList() async {
    final controller = Get.put(Controller());
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
              Get.to(() => const MapScreen());
            },
            icon: const Icon(Icons.map),
          ),
        ],
      ),

      bottomNavigationBar: BottomMenuBar(),

      body: Container(
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
                  Get.back();
                },
                child: const Text('확인'),
              ),
            ],
          );
        }
    );
  }
}
