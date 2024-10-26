import 'package:flutter/material.dart';
import 'package:minerestoran/database/auth/service.dart';
import "dart:async";

import 'package:toast/toast.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool visibility = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passCotroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "images/logo.png",
                height: MediaQuery.of(context).size.height * 0.4,
                width: MediaQuery.of(context).size.width * 0.6,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextField(
                  controller: emailController,
                  
                
                  decoration: const InputDecoration(
                      labelText: "Email",
                      hintText: "Email",
                    
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.elliptical(10, 10)),
                          borderSide: BorderSide(color: Colors.black)),
                      prefixIcon: Icon(
                        Icons.email,
                      
                      )),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextField(
                 
                  obscureText: !visibility,
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                      labelText: "Password",
                      hintText: "Password",
                   
                      border: const OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(Radius.elliptical(10, 10)),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      prefixIcon: const Icon(
                        Icons.password,
                  
                      ),
                      suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              visibility = !visibility;
                            });
                          },
                          icon: const Icon(
                            Icons.visibility,
                            
                          ))),
                  controller: passCotroller,
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.55,
                height: MediaQuery.of(context).size.height * 0.06,
                child: ElevatedButton(
                  style: ButtonStyle(backgroundColor:MaterialStateProperty.all<Color>(Color(0xFFA1C292)),foregroundColor: MaterialStateProperty.all<Color>(Colors.white)),
                  onPressed: () async {
                    if (emailController.text.isEmpty ||
                        passCotroller.text.isEmpty) {
                      Toast.show("Заполните поля");
                    } else {
                      showDialog(
                          context: context,
                          builder: (context) =>
                              const Center(child: CircularProgressIndicator()));
                      Future.delayed(const Duration(seconds: 5), () {});
                      var user = await AuthService()
                          .signIn(emailController.text, passCotroller.text);
                      if (user != null) {
                        Toast.show("Вы успешно вошли");
                        Navigator.pushNamed(context, "/");
                      } else {
                        Navigator.pop(context);
                        Toast.show("Такого пользователя нет");
                      }
                    }
                  },
                  child: const Text("Войти"),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              InkWell(
                child: const Text(
                  "Нет аккаунта? Регистрация",
                 
                ),
                onTap: () {
                  Navigator.popAndPushNamed(context, "/registration");
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
