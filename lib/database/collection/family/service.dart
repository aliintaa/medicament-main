import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:minerestoran/database/collection/user/model.dart';
import 'model.dart';

class FamilyService {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  // Метод для добавления Семьи
  Future<void> addfamily(Family family, Users user) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    family.id = id;
    await db.collection('familys').doc(id).set(family.toMap());
    await db.collection('users').doc(user.id).update({'familys': id });
    await db.collection('familys').doc(id).collection('users').doc(user.id).set({'id': user.id});
  }

  // Метод для удаления Семьи по id
  Future<void> deletefamily(String id) async {
    await db.collection('familys').doc(id).delete();
  }

  // Метод для редактирования Семьи
  Future<void> editfamily(String id, Family family) async {
    await db.collection('familys').doc(id).update(family.toMap());
  }

  // Метод для получения Семьи по id
  Future<Family> getfamily(String id) async {
    final snapshot = await db.collection('familys').doc(id).get();
    return Family.fromJson(snapshot.data() as Map<String, dynamic>);
  }

  // Метод для получения всех пользователей  семьи
  Future<List<Users>> getAllfamilys(String id) async {
    List<Users> familys = [];
    final snapshot = await db.collection('familys').doc(id).collection('users').get();
    snapshot.docs.forEach((doc) async {
      final snapshot = await db.collection('users').doc(doc.data()['id']).get();
      familys.add(Users.fromJson(snapshot.data() as Map<String, dynamic>));
    });
    return familys;
  }
  Future<List<Users>> getAllUserFamily(Users user, String id) async{
    final snapshot =  await db.collection('familys').doc(id).collection('users').get();
    List<Users> users = [];
    for(var doc in snapshot.docs ){
      final user = await db.collection('users').doc(doc.data()['id']).get();
      users.add(Users.fromJson(user.data() as Map<String , dynamic>));
    }
    return users;
  }



}
