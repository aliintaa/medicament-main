import 'package:cloud_firestore/cloud_firestore.dart';

class MedicomentMotion {
  String? id;
  String? idUser;
  String? idMedicoment;
  String? motion;
  int? count; // Используем int вместо String для количества
  DateTime? timestamp;

  MedicomentMotion({
    this.id,
    this.idUser,
    this.idMedicoment,
    this.motion,
    this.count,
    this.timestamp,
  });

  // Преобразование данных из JSON (для получения данных из Firestore)
  MedicomentMotion.fromJson(Map<String, dynamic> data) {
    id = data['id'];
    idUser = data['id_user'];
    idMedicoment = data['id_medicoment'];
    motion = data['motion'];
    count = data['count'];
    timestamp = (data['timestamp'] as Timestamp).toDate(); // Преобразование Timestamp в DateTime
  }

  // Преобразование в Map (для записи в Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_user': idUser,
      'id_medicoment': idMedicoment,
      'motion': motion,
      'count': count,
      'timestamp': timestamp,
    };
  }
}

class MedicomentMotionWithName {
  final MedicomentMotion motion;
  final String medicomentName;

  MedicomentMotionWithName({required this.motion, required this.medicomentName});
}
