import 'package:minerestoran/pages/Prograss.dart';
import 'package:minerestoran/pages/auth.dart';
import 'package:minerestoran/pages/landing.dart';
import 'package:minerestoran/pages/reg.dart';

final routes = {
  "/": (context) =>  const LadingPage(),
  "/auth": (context) => const AuthPage(),
  '/registration': (context) => RegistrationPage(),
"/progress" : (context)=> const Proggres()};
