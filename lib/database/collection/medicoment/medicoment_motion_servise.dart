import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:minerestoran/database/collection/medicoment/model.dart';
import 'package:minerestoran/database/collection/medicoment/model_medicoment_motion.dart';
import 'package:minerestoran/database/collection/medicoment/model_user.dart';


class MedicomentsMotionService {
  final FirebaseFirestore db = FirebaseFirestore.instance;



  // Добавление медикамента и отслеживание его движения
  Future<void> addMedicomentMotion(String medkitId, mdeicomentsUser? medicomentUser, String userId, int count, String? motion) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();

    // Создаем запись о движении медикамента в коллекции medicomentmotion
    await db
        .collection('medkits')
        .doc(medkitId)
        .collection('medicoments')
        .doc(medicomentUser!.id)
        .collection('medicomentmotion')
        .doc(id)
        .set({
      'id': id,
      'id_user': userId,
      'id_medicoment': medkitId,
      'motion': motion,
      'count': count,
      'timestamp': DateTime.now(),
    });

    // Обновляем количество медикамента в зависимости от действия (добавление или удаление)
    if (motion == 'add') {
      await db.collection('medkits').doc(medkitId).collection('medicoments').doc(medicomentUser.id).update({
        'count': (medicomentUser.count! + count),
      });
    } else if (motion == 'remove') {
      await db.collection('medkits').doc(medkitId).collection('medicoments').doc(medicomentUser.id).update({
        'count': (medicomentUser.count! - count),
      });
    }
  }



  // Метод для получения истории употребления медикаментов с их именами по id аптечки
  Future<List<MedicomentMotionWithName>> getMedicomentHistory(String medkitId) async {
    List<MedicomentMotionWithName> historyWithNames = [];

    try {
      // Получаем все медикаменты в аптечке
      final medicomentsSnapshot = await db
          .collection('medkits')
          .doc(medkitId)
          .collection('medicoments')
          .get();

      for (var medicomentDoc in medicomentsSnapshot.docs) {
        String medicomentName = medicomentDoc.data()['name'] ?? 'Без названия';

        // Для каждого медикамента получаем историю движений
        final motionSnapshot = await db
            .collection('medkits')
            .doc(medkitId)
            .collection('medicoments')
            .doc(medicomentDoc.id)
            .collection('medicomentmotion')
            .get();

        for (var motionDoc in motionSnapshot.docs) {
          MedicomentMotion motion = MedicomentMotion.fromJson(motionDoc.data());
          historyWithNames.add(MedicomentMotionWithName(
            motion: motion,
            medicomentName: medicomentName,
          ));
        }
      }

      return historyWithNames;
    } catch (e) {
      print('Ошибка при получении истории: $e');
      return [];
    }
  }
}

