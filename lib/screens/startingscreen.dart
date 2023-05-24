import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kakao_login_test/screens/commercialscreen.dart';
import 'package:kakao_login_test/screens/component/bottom_menu.dart';
import 'package:kakao_login_test/screens/homebasketlist.dart';
import 'package:kakao_login_test/screens/mapscreen.dart';
import 'package:kakao_login_test/screens/registrationscreen.dart';
import 'package:kakao_login_test/screens/residentialscreen.dart';

import '../common/commondata.dart';
import '../status/controller.dart';


class StartScreen extends StatelessWidget {
  const StartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _authentication = FirebaseAuth.instance;
    final controller = Get.put(Controller());


    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('스마일 부동산 물건 관리'),
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
        margin: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Obx((){ // Obx 사용 시 따로 Controller 명시 X 보여줄 위젯만. 근데 Get.put을 반드시 사용
              return Text(
                '${controller.userName.value} 회원님 환영합니다.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              );
            }),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).colorScheme.secondary,
                      padding: const EdgeInsets.all(40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      final dio = Dio();
                      final response = await dio.get('$appServerURL/regi_maxvalue');

                      controller.maxS(response.data[0]['maxs'].round());
                      controller.maxPrice(response.data[0]['maxs'].round());
                      controller.maxJ(response.data[0]['maxj'].round());
                      controller.maxJeonse(response.data[0]['maxj'].round());
                      controller.maxM(response.data[0]['maxm'].round());
                      controller.maxMonthly(response.data[0]['maxm'].round());
                      controller.maxD(response.data[0]['maxd'].round());
                      controller.maxDeposit(response.data[0]['maxd'].round());
                      controller.minS(response.data[0]['mins'].round());
                      controller.minPrice(response.data[0]['mins'].round());
                      controller.minJ(response.data[0]['minj'].round());
                      controller.minJeonse(response.data[0]['minj'].round());
                      controller.minM(response.data[0]['minm'].round());
                      controller.minMonthly(response.data[0]['minm'].round());
                      controller.minD(response.data[0]['mind']);
                      controller.minDeposit(response.data[0]['mind'].round());
                      controller.selectGubun('전세');
                      controller.minSize(response.data[0]['minz'].round());
                      controller.minZ(response.data[0]['minz'].round());
                      controller.maxSize(response.data[0]['maxz'].round());
                      controller.maxZ(response.data[0]['maxz'].round());

                      dio.close();

                      Get.offAll(() => ResidentialScreen());
                    },
                    child: Text(
                        '주거용 부동산',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w300,
                        ),
                     ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).colorScheme.secondary,
                      padding: const EdgeInsets.all(40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      final dio = Dio();
                      final response = await dio.get('$appServerURL/comm_maxvalue');

                      controller.maxS(response.data[0]['maxs'].round());
                      controller.maxPrice(response.data[0]['maxs'].round());
                      controller.maxE(response.data[0]['maxe'].round());
                      controller.maxEntitle(response.data[0]['maxe'].round());
                      controller.maxM(response.data[0]['maxm'].round());
                      controller.maxMonthly(response.data[0]['maxm'].round());
                      controller.maxD(response.data[0]['maxd'].round());
                      controller.maxDeposit(response.data[0]['maxd'].round());
                      controller.minS(response.data[0]['mins'].round());
                      controller.minPrice(response.data[0]['mins'].round());
                      controller.minE(response.data[0]['mine'].round());
                      controller.minEntitle(response.data[0]['mine'].round());
                      controller.minM(response.data[0]['minm'].round());
                      controller.minMonthly(response.data[0]['minm'].round());
                      controller.minD(response.data[0]['mind'].round());
                      controller.minDeposit(response.data[0]['mind'].round());
                      controller.selectGubun('전세');
                      controller.minSize(response.data[0]['minz'].round());
                      controller.minZ(response.data[0]['minz'].round());
                      controller.maxSize(response.data[0]['maxz'].round());
                      controller.maxZ(response.data[0]['maxz'].round());

                      dio.close();
                      Get.offAll (() => CommercialScreen());
                    },
                    child: const Text('상업용 부동산',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).colorScheme.secondary,
                      padding: const EdgeInsets.all(40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Get.offAll (() => RegistrationScreen());
                    },
                    child: const Text('신규 물건 등록',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).colorScheme.secondary,
                      padding: const EdgeInsets.all(40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Get.offAll (() => HomeBasketListViewScreen());
                    },
                    child: const Text('관심 물건 보기',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )
    );
  }
}
