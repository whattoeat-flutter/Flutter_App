import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pj/SuccessLogin.dart';
import 'RegisterPage.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인'),
      ),
      body: const LoginForm(),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {

  bool showSpinner = false;
  final _authentication = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';

  //이메일, 비밀번호 입력 후 일치하는 유저를 찾을 수 없을때
  //확인바라는 문구 출력
  void _plzCheckInput(){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)
            ),
            content: Text('잘못된 이메일 혹은 비밀번호입니다.'),
            actions: <Widget>[
              TextButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text('확인'))
            ],
            actionsAlignment: MainAxisAlignment.end,
          );

        });
  }


  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: GestureDetector(
        onTap: (){
          //외부영역 터치 시 키보드 닫기 이벤트
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 70.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height/6,
                ),

                SizedBox(
                  height: MediaQuery.of(context).size.width/3,
                  width: MediaQuery.of(context).size.width/3,
                  child: Image.asset('assets/title.png'),
                ),
                const SizedBox(
                  height: 20,
                ),
                Form(
                    key: _formKey,
                    child: ListView(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Email',
                          ),
                          onChanged: (value) {
                            email = value;
                          },
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                          ),
                          onChanged: (value) {
                            password = value;
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                            onPressed: () async {
                              try {
                                setState(() {
                                  showSpinner = true;
                                });
                                final currentUser =
                                await _authentication.signInWithEmailAndPassword(
                                    email: email, password: password);
                                if (currentUser.user != null) {
                                  //닉네임 띄우는 팝업창
                                  //이후 필터페이지로 넘어가기

                                  showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context){
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8.0)
                                          ),
                                          content: Builder(
                                            builder: (context){
                                              var height = MediaQuery.of(context).size.height;
                                              var width = MediaQuery.of(context).size.width;

                                              return Container(
                                                height: 160,
                                                width: width - 120,
                                                child: const SuccessLoginPage(),
                                              );
                                            },
                                          ),
                                          insetPadding: const EdgeInsets.all(5),
                                          contentPadding: const EdgeInsets.all(0),
                                        );
                                      }
                                  );

                                  if (!mounted) return;
                                  setState(() {
                                    showSpinner = false;
                                  });
                                }
                              } catch (e) {
                                if (!mounted) return;
                                setState(() {
                                  showSpinner = false;
                                });
                                _plzCheckInput();

                                print(e);
                              }
                            },
                            child: const Text('로그인')),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text(
                              '만일 계정이 없다면,',
                              style: TextStyle(
                                fontSize: 13,
                              ),
                            ),
                            TextButton(
                              child: const Text(
                                '계정을 생성하세요.',
                                style: TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const RegisterPage()));
                              },
                            )
                          ],
                        )
                      ],
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
