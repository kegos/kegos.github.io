import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:kakao_login_test/common/commondata.dart';
import 'package:kakao_login_test/screens/main_screen.dart';







void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await FlutterDownloader.initialize(
  //     debug: true
  // );
  KakaoSdk.init(nativeAppKey: '45ce62ef8ac5361d8994f2a9ca50a1ed');
  if(kIsWeb) {
    KakaoSdk.init(javaScriptAppKey: kakaoJsKey);
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyCWyKObSmj6xrjVqwYpI-vzsNGkLfi-2-I",
            authDomain: "smilerealestate-e93fd.firebaseapp.com",
            projectId: "smilerealestate-e93fd",
            storageBucket: "smilerealestate-e93fd.appspot.com",
            messagingSenderId: "600825662425",
            appId: "1:600825662425:web:05a4d055d272c0c45b27c8",
            measurementId: "G-TM4G73DX95"
        )
    );
  } else {
    await Firebase.initializeApp(
        name: 'SmileRealEstate',
        options: FirebaseOptions(
            apiKey: "AIzaSyCWyKObSmj6xrjVqwYpI-vzsNGkLfi-2-I",
            authDomain: "smilerealestate-e93fd.firebaseapp.com",
            projectId: "smilerealestate-e93fd",
            storageBucket: "smilerealestate-e93fd.appspot.com",
            messagingSenderId: "600825662425",
            appId: "1:600825662425:web:05a4d055d272c0c45b27c8",
            measurementId: "G-TM4G73DX95"
        )
    );
  }




  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
//        primarySwatch: Colors.indigo,
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            brightness: Brightness.light,
          )
      ),
      // darkTheme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(
      //       seedColor: seedColor,
      //       brightness: Brightness.dark,
      //     )
      // ),
      themeMode: ThemeMode.system,
      home: LoginSignupScreen(),
//      home: ListViewScreen(),
    );
  }
}


