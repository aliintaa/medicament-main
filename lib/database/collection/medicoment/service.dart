
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:minerestoran/database/collection/medicoment/model.dart';
import 'package:minerestoran/database/collection/medicoment/model_user.dart';

class mdeicomentsClass {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<void> addMedicoment(mdeicoments medicoment) async{
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    await db.collection('medicoments').doc(id).set(
     medicoment.toMap()
    );
  }

   Future<void> deleteMedicoment(String id_medkit , String id) async {
    db.collection('medkits').doc(id_medkit).collection('medicoments').doc(id).delete();
  }

  Future<void> editMedicoment(String id, String? _image, String? _name, String? _description, DateTime? _dateStop, DateTime? _dateStart) async{

    await db.collection('medicoments').doc(id).update(
      { "id": id,
      "image": _image,
      "name": _name,
      "description": _description,
      "dateStop": _dateStop,
      "dateStart": _dateStart}
    );
  }


  Future<List<mdeicoments>> getAllmedicoment() async {
  List<mdeicoments> medicoments = [];

  try {
    final snapshot = await db.collection('medicoments').get();

    if (snapshot.docs.isEmpty) {
      print('Коллекция пустая');
      return medicoments;
    }

    for (var doc in snapshot.docs) {
      try {
        final data = doc.data() as Map<String, dynamic>;
        final mdeicoment = mdeicoments.fromJson(data);
        medicoments.add(mdeicoment);
      } catch (e) {
        print('Ошибка при парсинге документа: ${doc.id}, ошибка: $e');
      }
    }

    return medicoments;
  } catch (e) {
    print('Ошибка при получении данных из Firestore: $e');
    return medicoments;
  }



  }
  Future<mdeicoments> getMedicoment(String id ) async{
    final snapshot = await db.collection('medicoments').doc(id).get();
    return mdeicoments.fromJson(snapshot.data() as Map<String, dynamic>); 
  }

  Future<List<mdeicomentsUser>?> getAllmedicomentForMedkit(String id) async{
    final  snapshot = await db.collection('medkits').doc(id).collection('medicoments').get();
    List<mdeicomentsUser> medicoments = [];
    for(var doc in snapshot.docs){
       medicoments.add(mdeicomentsUser.fromJson(doc.data()));
    }
    return medicoments;
  }


  Future<void> addInMedKidForMedikament(String id_Aptechka, mdeicomentsUser medicomentUser ) async{
    
    await db.collection('medkits').doc(id_Aptechka).collection('medicoments').doc(medicomentUser.id!).set(medicomentUser.toMap());
  }


  // Проверка, существует ли медикамент в аптечке
  Future<mdeicomentsUser?> checkIfMedicationExistsInMedkit(String medkitId, String medicamentId) async {
    final snapshot = await db
        .collection('medkits')
        .doc(medkitId)
        .collection('medicoments')
        .doc(medicamentId)
        .get();

    if (snapshot.exists) {
      return mdeicomentsUser.fromJson(snapshot.data() as Map<String, dynamic>);
    } else {
      return null;  // Медикамент не найден
    }
  }

  // Добавление медикамента в аптечку
  Future<void> addInMedKidForMedikaments(String medkitId, mdeicomentsUser medicomentUser) async {
    await db
        .collection('medkits')
        .doc(medkitId)
        .collection('medicoments')
        .doc(medicomentUser.id)
        .set(medicomentUser.toMap());
  }

}
