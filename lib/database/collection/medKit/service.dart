import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:minerestoran/database/collection/medKit/model.dart';
import 'package:minerestoran/database/collection/user/model.dart';


class MedkitService {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  // Добавление нового medkit
  Future<void> addMedkit(String? id, String? name, String? description) async {
    
    await db.collection('medkits').doc(id).set({
      "id": id,
      "name": name,
      "description": description
    });
  }

  // Удаление medkit по ID
  Future<void> deleteMedkit(String id) async {
    await db.collection('medkits').doc(id).delete();
  }

  // Редактирование medkit по ID
  Future<void> editMedkit(String id, String? name, String? description) async {
    await db.collection('medkits').doc(id).update({
      "name": name,
      "description": description
    });
  }

  // Получение всех medkits
Future<List<Medkit>> getAllMedkits(Users user) async {
  List<Medkit> medkitList = [];

  // Получаем все документы пользователя
  final snapshot = await db.collection('users').doc(user.id).collection('MedKit').get();

  // Создаем список асинхронных задач для получения данных по каждой аптечке
  final futures = snapshot.docs.map((id) async {
    final data = await db.collection('medkits').doc(id.data()['id']).get();
    return Medkit.fromJson(data.data() as Map<String, dynamic>);
  }).toList();

  // Ждем выполнения всех запросов параллельно
  medkitList = await Future.wait(futures);

  return medkitList;
}

  
  Future<Medkit> getMedkit(String id) async {
    final snapshot = await db.collection('medkits').doc(id).get();
    if (snapshot.exists) {
      return Medkit.fromJson(snapshot.data() as Map<String, dynamic>);
    } else {
      throw Exception("Medkit с таким ID не найден");
    }
  }






}
