
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:minerestoran/database/collection/user/model.dart';




class UsersService {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<Users> addUsers(String id , Users Users) async {
    final snapshot = await db.collection('users').doc(id).set(Users.toMap());

    return Users;
  }

  Future<void> deleteUsers(String id) async {
    await db.collection('users').doc(id).delete();
  }

  Future<void> editUsers(String id, Users Users) async {
    await db.collection('users').doc(id).update(Users.toMap());
  }

  Future<Users> getUsers(String id) async {
    final snapshot = await db.collection('users').doc(id).get();
    return Users.fromJson(snapshot.data() as Map<String, dynamic>);
  }

  Future<List<Users>> getAllUserss() async {
    List<Users> userss = [];
    final snapshot = await db.collection('users').get();
    snapshot.docs.forEach((doc) {
      final Usersq = Users.fromJson(doc.data() as Map<String, dynamic>);
      userss.add(Usersq);
    });
    return userss;
  }
}