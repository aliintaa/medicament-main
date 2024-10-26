

import 'package:cloud_firestore/cloud_firestore.dart';

class Users {
  String? id;
  String? email;
  String? firstName;
  String? lastName;
  String? patronymic;
  String? address;
  String? phone;
  DateTime? dateReg;
  String? family_id;
  bool? is_active;
  String? password;

  Users({this.id, this.email, this.firstName, this.lastName, this.patronymic, this.address, this.phone, this.dateReg, this.family_id, this.is_active, this.password});

  Users.fromJson(Map<String, dynamic> data) {
    id = data['id'];
    email = data['email'];
    firstName = data['first_name'];
    lastName = data['last_name'];
    patronymic = data['patronymic'];
    address = data['address'];
    phone = data['phone'];
  
   
        family_id = data['familys'];
   

    if( data['is_active'] == null){
       is_active = true;
    }
    is_active = data['is_active'];
    password = data['password'];
     // Проверка на null перед преобразованием Timestamp в DateTime
    if (data['date_reg'] != null) {
      dateReg = (data['date_reg'] as Timestamp).toDate();
    } else {
      dateReg = null;
    }
  
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'patronymic': patronymic,
      'address': address,
      'phone': phone,
      'date_reg': dateReg,
      'familys': family_id,
      'is_active' : true,
      'password': password
    };
  }
}