import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:kakao_login_test/common/commondata.dart';
import 'package:kakao_login_test/config/palette.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kakao_login_test/kakao/main_view_model.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:kakao_login_test/screens/startingscreen.dart';

import '../kakao/kakao_login.dart';
import '../status/controller.dart';

class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({Key? key}) : super(key: key);

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  final viewModel = MainViewModel(KakaoLogin());
  final _authentication = FirebaseAuth.instance;
  final controller = Get.put(Controller());

  bool isSignupScreen = true;
  final _formKey = GlobalKey<FormState>();
  String userName = '';
  String userEmail = '';
  String userPassword = '';

  void _tryVlidation() {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      _formKey.currentState!.save();
    } else {
      print('Validation Failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,

      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  // image: DecorationImage(
                  //   image: AssetImage('image/red.jpg'),
                  //   fit: BoxFit.fill,
                  // ),
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: Container(
                  padding: EdgeInsets.only(top: 90, left: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: 'Welcome to ',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            letterSpacing: 1.0,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: isSignupScreen ? '스마일부동산' : 'Back!',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                letterSpacing: 1.0,
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(isSignupScreen ? 'Signup to continue' : 'Login to continue',
                          style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                            letterSpacing: 1.0,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // 배경
            AnimatedPositioned(
              duration: Duration(milliseconds: 500),
              curve: Curves.easeIn,
              top: 180,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeIn,
                  padding: EdgeInsets.only(top: 20),
                  height: isSignupScreen ? 280 : 250,
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  width: MediaQuery.of(context).size.width - 40,
                  decoration: BoxDecoration(
                    //color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.secondary,
                        spreadRadius: 5,
                        blurRadius: 1,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Column(

                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isSignupScreen = false;
                                });
                              },
                              child: Column(
                                children: [
                                  Text(
                                    'Login',
                                    style: TextStyle(
                                      color: !isSignupScreen ? Theme.of(context).colorScheme.onSecondary : Theme.of(context).colorScheme.outlineVariant,
                                      letterSpacing: 1.0,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if(!isSignupScreen)
                                    Container(
                                      margin: EdgeInsets.only(top: 3),
                                      height: 2,
                                      width: 50,
                                      color: Theme.of(context).colorScheme.errorContainer,
                                    ),
                                ]
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isSignupScreen = true;
                                });
                              },
                              child: Column(
                                  children: [
                                    Text(
                                      'Signup',
                                      style: TextStyle(
                                        color: isSignupScreen ? Theme.of(context).colorScheme.onSecondary : Theme.of(context).colorScheme.outlineVariant,
                                        letterSpacing: 1.0,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if(isSignupScreen)
                                      Container(
                                        margin: EdgeInsets.only(top: 3),
                                        height: 2,
                                        width: 50,
                                        color: Theme.of(context).colorScheme.errorContainer,
                                      ),
                                  ]
                              ),
                            ),
                          ],
                        ),
                        if(isSignupScreen)
                        Container(
                          margin: EdgeInsets.only(top: 20, left: 20, right: 20),
                          child: Form(
                            key: _formKey,
                            child: Column(
                                children: [
                                  TextFormField(
                                    key: ValueKey(1),
                                    validator: (value) {
                                      if(value!.isEmpty || value.length < 4) {
                                        return 'Please enter at least 4 characters';
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      userName = value!;
                                    },
                                    onChanged: (value) {
                                      userName = value;
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'User Name',
                                      hintStyle: TextStyle(
                                        color: Theme.of(context).colorScheme.outline,
                                        letterSpacing: 1.0,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      contentPadding: EdgeInsets.all(10),
                                      prefixIcon: Icon(
                                        Icons.account_circle,
                                        color: Theme.of(context).colorScheme.outlineVariant,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context).colorScheme.outlineVariant,
                                        ),
                                        borderRadius: BorderRadius.all(Radius.circular(30)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context).colorScheme.outlineVariant,
                                        ),
                                        borderRadius: BorderRadius.all(Radius.circular(30)),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  TextFormField(
                                    key: ValueKey(2),
                                    onSaved: (value) {
                                      userEmail = value!;
                                    },
                                    onChanged: (value) {
                                      userEmail = value;
                                    },
                                    validator: (value) {
                                      if(value!.isEmpty || !value.contains('@')) {
                                        return 'Please enter a valid email address';
                                      }
                                      return null;
                                    },
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      hintText: 'Email',
                                      hintStyle: TextStyle(
                                        color: Theme.of(context).colorScheme.outline,
                                        letterSpacing: 1.0,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      contentPadding: EdgeInsets.all(10),
                                      prefixIcon: Icon(
                                        Icons.email,
                                        color: Theme.of(context).colorScheme.outlineVariant,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context).colorScheme.outlineVariant,
                                        ),
                                        borderRadius: BorderRadius.all(Radius.circular(30)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context).colorScheme.outlineVariant,
                                        ),
                                        borderRadius: BorderRadius.all(Radius.circular(30)),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  TextFormField(
                                    obscureText: true,
                                    key: ValueKey(3),
                                    onSaved: (value) {
                                      userPassword = value!;
                                    },
                                    onChanged: (value) {
                                      userPassword = value;
                                    },
                                    validator: (value) {
                                      if(value!.isEmpty || value.length < 7) {
                                        return 'Password must be at least 7 characters long';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Password',
                                      hintStyle: TextStyle(
                                        color: Theme.of(context).colorScheme.outline,
                                        letterSpacing: 1.0,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      contentPadding: EdgeInsets.all(10),
                                      prefixIcon: Icon(
                                        Icons.lock,
                                        color: Theme.of(context).colorScheme.outlineVariant,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context).colorScheme.outlineVariant,
                                        ),
                                        borderRadius: BorderRadius.all(Radius.circular(30)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context).colorScheme.outlineVariant,
                                        ),
                                        borderRadius: BorderRadius.all(Radius.circular(30)),
                                      ),
                                    ),
                                  ),
                                ],
                            ),
                          ),
                        ),
                        if(!isSignupScreen)
                          Container(
                            margin: EdgeInsets.only(top: 20, left: 20, right: 20),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    key: ValueKey(4) ,
                                    onSaved: (value) {
                                      userEmail = value!;
                                    },
                                    onChanged:  (value) {
                                      userEmail = value;
                                    },
                                    validator: (value) {
                                      if(value!.isEmpty || !value.contains('@')) {
                                        return 'Please enter a valid email address';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Email',
                                      hintStyle: TextStyle(
                                        color: Theme.of(context).colorScheme.outline,
                                        letterSpacing: 1.0,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      contentPadding: EdgeInsets.all(10),
                                      prefixIcon: Icon(
                                        Icons.email,
                                        color: Theme.of(context).colorScheme.outlineVariant,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context).colorScheme.outlineVariant,
                                        ),
                                        borderRadius: BorderRadius.all(Radius.circular(30)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context).colorScheme.outlineVariant,
                                        ),
                                        borderRadius: BorderRadius.all(Radius.circular(30)),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  TextFormField(
                                    obscureText: true,
                                    key: ValueKey(5),
                                    onSaved: (value) {
                                      userPassword = value!;
                                    },
                                    onChanged: (value) {
                                      userPassword = value;
                                    },
                                    validator: (value) {
                                      if(value!.isEmpty || value.length < 7) {
                                        return 'Password must be at least 7 characters long';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Password',
                                      hintStyle: TextStyle(
                                        color: Theme.of(context).colorScheme.outline,
                                        letterSpacing: 1.0,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      contentPadding: EdgeInsets.all(10),
                                      prefixIcon: Icon(
                                        Icons.lock,
                                        color: Theme.of(context).colorScheme.outlineVariant,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context).colorScheme.outlineVariant,
                                        ),
                                        borderRadius: BorderRadius.all(Radius.circular(30)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context).colorScheme.outlineVariant,
                                        ),
                                        borderRadius: BorderRadius.all(Radius.circular(30)),
                                      ),
                                    ),
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
            // 텍스트 폼필드
            AnimatedPositioned(
                duration: Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              top: isSignupScreen ? 430 : 390,
                right: 0,
                left: 0,
                child: Center(
                  child: Container (
//                    color: Theme.of(context).colorScheme.primary,
                    padding: EdgeInsets.all(15),
                    height: 90,
                    width: 90,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.shadow,
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: GestureDetector(
                      onTap: () async {
                        if(isSignupScreen) {
                          _tryVlidation();
                          try{
                            final newUser = await _authentication.createUserWithEmailAndPassword(
                                email: userEmail ,
                                password: userPassword
                            );

                            if(newUser != null) {
                              final dio = Dio();

                              final response = await dio.post(
                                  '$appServerURL/signup',
                                  data: {
                                    'email': userEmail,
                                    'uid': newUser.user!.uid,
                                    'name': userName,
                                  }
                              );
                              dio.close();

                              controller.userEmail(newUser.user!.email!);
                              controller.userId(newUser.user!.uid);
                              controller.userName(newUser.user!.displayName!);

                              Get.off(() => StartScreen());
                            }
                          } catch(e) {
                            print(e);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please check your email or password $e'),
                                backgroundColor: Theme.of(context).colorScheme.background,
                              ),
                            );
                          }
                        }
                        if(!isSignupScreen) {
                          _tryVlidation();
                          try{
                            final dio = Dio();
                            final newUser = await _authentication.signInWithEmailAndPassword(
                                email: userEmail ,
                                password: userPassword
                            );


                            if(newUser != null) {
                              controller.userEmail(newUser.user!.email);
                              controller.userId(newUser.user!.uid);
                              controller.userName(newUser.user!.displayName);

                              if(newUser.user!.displayName == null) {
                                final response = await dio.post(
                                    '$appServerURL/getusrname',
                                    data: {
                                      'uuid': newUser.user!.uid,
                                    }
                                );

                                controller.userName(response.data);
                              }

                            } else {
                                final response = await dio.post(
                                    '$appServerURL/getusrname',
                                    data: {
                                      'uuid': newUser.user!.uid,
                                    }
                                );


                                if(response.data == 'no') {
                                  final response = await dio.post(
                                      '$appServerURL/signup',
                                      data: {
                                        'email': newUser.user!.email!,
                                        'uid': newUser.user!.uid,
                                        'name': newUser.user!.displayName! ?? '',
                                      }
                                  );
                                }


                            }



                            dio.close();
                            Get.off (() => StartScreen());

                          } catch(e) {
                            print(e);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please check your email or password'),
                                backgroundColor: Colors.blue,
                              ),
                            );
                          }
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.secondary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.arrow_forward,
                            color: Theme.of(context).colorScheme.onPrimary ,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ),
            //전송버튼
            AnimatedPositioned(
                duration: Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              top: isSignupScreen ? MediaQuery.of(context).size.height - 175 :
                      MediaQuery.of(context).size.height - 200,
                right: 0,
                left: 0,
                child: Column (
                  children: [
                    Text(isSignupScreen ? 'Or Signup With' : 'Or Login With',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        primary: Colors.black,
                        minimumSize: Size(155, 40),
                        backgroundColor: Palette.googleColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      icon: Icon(Icons.add),
                      label: Text('Google'),
                    ),
                    SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: () async {
                        var key = await KakaoSdk.origin;
                        print(key);
                        try {
                          final dio = Dio();
                          await viewModel.login();

                          if(viewModel.isLogined = true) {
                            controller.userEmail(viewModel.user!.kakaoAccount!.email);
                            controller.userId(viewModel.user!.id.toString());
                            controller.userName(viewModel.user!.kakaoAccount!.profile!.nickname);

                            var response = await dio.post(
                                '$appServerURL/getusrname',
                                data: {
                                  'uuid': viewModel.user!.id.toString(),
                                }
                            );

                            print(response.data);

                            if(response.data == 'no') {
                              final response = await dio.post(
                                  '$appServerURL/signup',
                                  data: {
                                    'email': viewModel.user!.kakaoAccount!.email,
                                    'uid': viewModel.user!.id.toString(),
                                    'name': viewModel.user!.kakaoAccount!.profile!.nickname,
                                  }
                              );
                            }

                            dio.close();

                            Get.off(() => StartScreen());
                          }
                        } catch(e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Kakao Loin failed : $e'),
                              backgroundColor: Colors.blue,
                            ),
                          );
                          print(e);
//                          Get.off(() => StartScreen());
                        }
                      },
                      style: TextButton.styleFrom(
                        primary: Colors.black,
                        minimumSize: Size(155, 40),
                        backgroundColor: Palette.kakaoColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      icon: Icon(Icons.add),
                      label: Text('Kakao'),
                    ),
                  ],
                )
            ),
            //구글 로그인 버튼
          ],
        ),
      ),
    );
  }
}
