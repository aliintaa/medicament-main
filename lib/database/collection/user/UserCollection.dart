import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserCollection {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  Future<void> addUserCollection(String email, String last_name,String first_name,String? patronymic,
      String phone, String password) async {
        final id = DateTime.now().microsecondsSinceEpoch.toString();
    try {
      await _firebaseFirestore.collection('users').doc(id).set({
        'uid': id,
        'email': email,
        'last_name': last_name,
        'first_name': first_name,
        'patronymic': patronymic,
        'phone': phone,
        'password': password
      });
     
    } catch (e) {
      return;
    }
  }

  Future<void> editUserCollection(
    String name,
    String phone,
  ) async {
    final String user = FirebaseAuth.instance.currentUser!.uid.toString();
    try {
      await _firebaseFirestore.collection('users').doc(user).update({
        'name': name,
        'phone': phone,
      });
    } catch (e) {
      return;
    }
  }

  Future<void> deleteUserCollection(dynamic docs) async {
    try {
      await _firebaseFirestore.collection('users').doc(docs.id).delete();
    } catch (e) {
      return;
    }
  }
}