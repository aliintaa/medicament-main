import 'package:cloud_firestore/cloud_firestore.dart';

class mdeicoments{

  String? id;
  String? image;
  String? name;
  String? description;



  mdeicoments({this.id, this.name, this.description, this.image} );
  
 
  

  mdeicoments.fromJson(Map<String, dynamic> data) {
    id = data["id"];
    image = data["image"];
    name = data["name"];
    description = data["description"];

  }

  Map<String, Object?> toMap() {
    return {
      "id": id,
      "image": image,
      "name": name,
      "description": description,
    };
  }
}