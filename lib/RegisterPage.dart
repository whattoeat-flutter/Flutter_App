import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'SuccessRegister.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
      ),
      body: const RegisterForm(),
    );
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({Key? key}) : super(key: key);

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _authentication = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String userName = '';
  bool showSpinner = false;

  //잘못된 형식의 이메일이나 비밀번호를 입력했을때
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
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 50.0),
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height/5,
                ),
                Form(
                    key: _formKey,
                    child: Column(
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
                          height: 20,
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
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'User Name',
                          ),
                          onChanged: (value) {
                            userName = value;
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(40),
                            ),

                            onPressed: () async {
                              try {
                                setState(() {
                                  showSpinner = true;
                                });

                                //firebase와 연동
                                final newUser =
                                await _authentication.createUserWithEmailAndPassword(
                                    email: email, password: password);
                                await FirebaseFirestore.instance
                                    .collection('user')
                                    .doc(newUser.user!.uid)
                                    .set({
                                  'userName': userName,
                                  'email': email,
                                });

                                if (newUser.user != null) {
                                  _formKey.currentState!.reset();
                                  if (!mounted) return;
                                  setState(() {
                                    showSpinner = false;
                                  });

                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                          const SuccessRegisterPage()));
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
                            child: const Text('회원가입')),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text('이미 계정이 있다면, '),
                            TextButton(
                              child: const Text('로그인하세요.'),
                              onPressed: () {
                                Navigator.pop(context);
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
