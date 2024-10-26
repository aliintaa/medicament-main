import 'package:cloud_firestore/cloud_firestore.dart';  
class mdeicomentsUser{

  String? id;
  String? image;
  String? name;
  String? description;
  int? count;
  DateTime? dateStop;
  DateTime? dateStart;


  mdeicomentsUser(String? _id, String? _image, String? _name, String? _description, DateTime? _dateStop, DateTime? _dateStart, int? _count, ){
    id = _id;
    name = _name;
    image = _image;
    count = _count;
    description = _description;
    dateStart = _dateStart;
    dateStop = _dateStop;
  }

  mdeicomentsUser.fromJson(Map<String, dynamic> data) {
    id = data["id"];
    image = data["image"];
    name = data["name"];
    description = data["description"];
    count = data['count'];
  dateStop = (data["dateStop"] as Timestamp).toDate(); // Преобразуем Timestamp в DateTime
  dateStart = (data["dateStart"] as Timestamp).toDate(); // Преобразуем Timestamp в DateTime
}

  Map<String, Object?> toMap() {
    return {
      "id": id,
      "image": image,
      "name": name,
      "description": description,
      'count': count,
      "dateStop": dateStop,
      "dateStart": dateStart
    };
  }
}