import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:minerestoran/database/collection/user/model.dart';
import 'package:minerestoran/database/collection/user/service.dart';


class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<Users?> signIn(String email, String password) async {
  try {
    UserCredential userCredential = await _firebaseAuth
        .signInWithEmailAndPassword(email: email, password: password);
    User? user = userCredential.user;

    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (snapshot.exists) {
        Users users = Users.fromJson(snapshot.data() as Map<String, dynamic>);
        return users;
      } else {
        // Handle case where user document does not exist
        return null;
      }
    } else {
      // Handle case where userCredential.user is null
      return null;
    }
  } catch (e) {
    // Optionally, log or handle the error
    print('Error signing in: $e');
    return null;
  }
}

Future<Users?> createIn(Users user) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: user.email!, password: user.password!);
          user.id = userCredential.user!.uid;
          final users =  await UsersService().addUsers(userCredential.user!.uid, user);

        return users;
      
      
      
    } catch (e) {
      return null;
    }
}
  

  Future<void> logOut() async{
    return await _firebaseAuth.signOut();
  }
  Stream<Users?> get currentUser {
  return _firebaseAuth.authStateChanges().asyncMap((User? user) async {
    if (user != null) {
      print('Пользователь найден: ${user.uid}');
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (snapshot.exists) {
        print('Документ пользователя существует');
        try {
          return Users.fromJson(snapshot.data() as Map<String, dynamic>);
        } catch (e) {
          print('Ошибка десериализации данных пользователя: $e');
          return null;
        }
      } else {
        print('Документ пользователя не найден в Firestore');
        return null;
      }
    } else {
      print('Пользователь не залогинен');
      return null;
    }
  }).handleError((error) {
    print("Ошибка в потоке пользователя: $error");
    return null;
  });
}

}

