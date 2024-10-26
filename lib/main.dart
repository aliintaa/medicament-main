// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:minerestoran/database/auth/service.dart';
import 'package:minerestoran/firebase_options.dart';
import 'package:minerestoran/routes/routes.dart';
import 'package:minerestoran/themes/themeDark.dart';
import 'package:provider/provider.dart';
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings =
      const Settings(persistenceEnabled: true);
  runApp(const ThemeAppMenu());
}

class ThemeAppMenu extends StatelessWidget {
  const ThemeAppMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamProvider.value(
      
      initialData: null,
      value: AuthService().currentUser,
      child: MaterialApp(
        initialRoute: '/',
        routes: routes,
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        navigatorObservers: [routeObserver], // Добавляем наблюдателя маршрутов
      ),
    );
  }
}
