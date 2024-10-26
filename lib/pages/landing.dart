import 'package:flutter/material.dart';
import 'package:minerestoran/database/auth/service.dart';
import 'package:minerestoran/database/collection/user/model.dart';
import 'package:minerestoran/pages/NavigationPage.dart';
import 'package:minerestoran/pages/auth.dart';
import 'package:provider/provider.dart';


class LadingPage extends StatelessWidget {
  const LadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Users?>(
      stream: AuthService().currentUser,  // Подключаем поток текущего пользователя
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Показываем индикатор загрузки, пока данные загружаются
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          // Показываем сообщение об ошибке
          return Scaffold(
            body: Center(
              child: Text('Ошибка загрузки данных пользователя'),
            ),
          );
        } else if (snapshot.hasData) {
          // Если данные пользователя получены, переходим на страницу навигации
          Users? userModel = snapshot.data;
          return userModel != null ? NavigationPage(user: userModel) : AuthPage();
        } else {
          // Если данных нет, показываем страницу входа
          return AuthPage();
        }
      },
    );
  }


  
}
