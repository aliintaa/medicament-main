import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:minerestoran/database/collection/family/service.dart';
import 'package:minerestoran/database/collection/user/model.dart';
import 'package:minerestoran/database/collection/family/model.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfilePage extends StatefulWidget {
  final Users user;

  UserProfilePage({required this.user});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final FamilyService familyService = FamilyService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Профиль'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _logout(context);
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileRow('Email:', widget.user.email ?? 'Не указано'),
            _buildProfileRow('Имя:', widget.user.firstName ?? 'Не указано'),
            _buildProfileRow('Фамилия:', widget.user.lastName ?? 'Не указано'),
            _buildProfileRow('Отчество:', widget.user.patronymic ?? 'Не указано'),
            _buildProfileRow('Адрес:', widget.user.address ?? 'Не указано'),
            _buildProfileRow('Телефон:', widget.user.phone ?? 'Не указано'),
            _buildProfileRow(
                'Дата регистрации:', 
                widget.user.dateReg != null 
                    ? widget.user.dateReg!.toLocal().toString() 
                    : 'Не указано'),
            _buildProfileRow('ID семьи:', widget.user.family_id ?? 'Не указано'),
            SizedBox(height: 16),
            _buildFamilyActions(context),
          ],
        ),
      ),
    );
  }

  // Построение строки с данными профиля
  Widget _buildProfileRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  // Блок действий для работы с семьей
  Widget _buildFamilyActions(BuildContext context) {
    if (widget.user.family_id != null) {
      // Если пользователь уже состоит в семье, показываем только кнопку "Пригласить"
      return Column(
        children: [
          ElevatedButton(
              style: ButtonStyle(backgroundColor:MaterialStateProperty.all<Color>(Color(0xFFA1C292)),foregroundColor: MaterialStateProperty.all<Color>(Colors.white)),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: widget.user.family_id!));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ID семьи скопирован: ${widget.user.family_id}')));
            },
            child: Text('Пригласить в семью (ID скопирован)'),
          ),
        ],
      );
    } else {
      // Если пользователь не состоит в семье, показываем кнопки "Создать семью" и "Войти в семью"
      return Column(
        children: [
          ElevatedButton(
              style: ButtonStyle(backgroundColor:MaterialStateProperty.all<Color>(Color(0xFFA1C292)),foregroundColor: MaterialStateProperty.all<Color>(Colors.white)),
            onPressed: () {
              _showCreateFamilyDialog(context);
            },
            child: Text('Добавить семью'),
          ),
          SizedBox(height: 8),
          ElevatedButton(
              style: ButtonStyle(backgroundColor:MaterialStateProperty.all<Color>(Color(0xFFA1C292)),foregroundColor: MaterialStateProperty.all<Color>(Colors.white)),
            onPressed: () {
              _enterFamily(context);
            },
            child: Text('Войти в семью'),
          ),
        ],
      );
    }
  }

  // Логика выхода из аккаунта
  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/'); // Переход на экран логина
  }

  // Окно для создания семьи
  void _showCreateFamilyDialog(BuildContext context) {
    final TextEditingController familyNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Создание семьи'),
          content: TextField(
            controller: familyNameController,
            decoration: InputDecoration(hintText: 'Название семьи'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Отмена'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Создать'),
              onPressed: () async {
                final newFamily = Family(id: null, name: familyNameController.text);
                await familyService.addfamily(newFamily, widget.user);
                
                setState(() {
                  widget.user.family_id = newFamily.id; // Обновляем состояние
                });

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Семья создана')));
              },
            ),
          ],
        );
      },
    );
  }

  // Логика входа в семью
  void _enterFamily(BuildContext context) async {
    final TextEditingController familyIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Войти в семью'),
          content: TextField(
            controller: familyIdController,
            decoration: InputDecoration(hintText: 'ID семьи'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Отмена'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Войти'),
              onPressed: () async {
                final familyId = familyIdController.text.trim();

                // Проверяем, существует ли семья с таким ID
                final familySnapshot = await familyService.db.collection('familys').doc(familyId).get();

                if (!familySnapshot.exists) {
                  // Если семья не найдена
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Нет такой семьи')));
                  Navigator.of(context).pop(); // Закрываем диалог
                } else {
                  // Добавляем пользователя в семью
                  await familyService.db
                      .collection('familys')
                      .doc(familyId)
                      .collection('users')
                      .doc(widget.user.id)
                      .set({'id': widget.user.id});

                  // Обновляем ID семьи у пользователя
                  await familyService.db.collection('users').doc(widget.user.id).update({'familys': familyId});
                  final  idsMedKit = await FirebaseFirestore.instance.collection('familys').doc(familyId).collection('MedKit').get();

                  idsMedKit.docs.forEach((element) {
                    FirebaseFirestore.instance.collection('users').doc(widget.user.id).collection('MedKit').doc(element.data()['id']).set({'id': element.data()['id'] });
                  },);
                  
                  setState(() {
                    widget.user.family_id = familyId; // Обновляем состояние
                  });

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Вы вошли в семью')));
                }
              },
            ),
          ],
        );
      },
    );
  }
}
