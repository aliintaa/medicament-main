import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:minerestoran/database/collection/family/model.dart';
import 'package:minerestoran/database/collection/family/service.dart';
import 'package:minerestoran/database/collection/medKit/service.dart';
import 'package:minerestoran/database/collection/user/model.dart';

class AddFamilyAccessPage extends StatefulWidget {
  final Users? user;
  AddFamilyAccessPage({this.user});

  @override
  _AddFamilyAccessPageState createState() => _AddFamilyAccessPageState();
}

class _AddFamilyAccessPageState extends State<AddFamilyAccessPage> {
  List<Users> familyMembers = [];
  FamilyService familyService = FamilyService();
  final _formKey = GlobalKey<FormState>();

  // Поля для ввода
  String? medkitName;
  String? medkitDescription;
  String? medkitId; // Поле для ID аптечки
  bool hasFamily = false; // Флаг для наличия семьи у пользователя
  String _selectedOption = 'self'; // Выбранная опция, по умолчанию "Для себя"

  @override
  void initState() {
    super.initState();
    checkFamilyStatus(); // Проверяем, есть ли семья
  }

  // Проверка, есть ли у пользователя семья
  Future<void> checkFamilyStatus() async {
    if (widget.user != null && widget.user!.family_id != null) {
      final members = await familyService.getAllUserFamily(widget.user!, widget.user!.family_id!);
      if (members.isNotEmpty) {
        setState(() {
          familyMembers = members;
          hasFamily = true; // Устанавливаем, что у пользователя есть семья
        });
      }
    }
  }

  // Сохранение MedKit
  // Сохранение MedKit
Future<void> _saveMedkit() async {
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save();

    if (_selectedOption == 'import') {
      // Логика для импорта аптечки по ID
      final medkitDoc = await FirebaseFirestore.instance.collection('medkits').doc(medkitId).get();
      if (medkitDoc.exists) {
        await FirebaseFirestore.instance.collection('users').doc(widget.user!.id).collection('MedKit').doc(medkitId).set(medkitDoc.data()!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Аптечка успешно импортирована!')));
        }
        await Future.delayed(Duration(seconds: 2)); // Задержка перед закрытием страницы
        Navigator.pop(context); // Переход назад после отображения SnackBar
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Аптечка с таким ID не найдена!')));
      }
    } else {
      final id = DateTime.now().microsecondsSinceEpoch.toString();
      if (_selectedOption == 'family' && familyMembers.isNotEmpty) {
        for (var user in familyMembers) {
          await FirebaseFirestore.instance.collection('users').doc(user.id).collection('MedKit').add({
            'id': id,
          });
        }
        await MedkitService().addMedkit(id, medkitName, medkitDescription);
        await FirebaseFirestore.instance.collection('familys').doc(widget.user!.family_id!).collection('MedKit').doc(id).set({'id': id});
      } else {
        await FirebaseFirestore.instance.collection('users').doc(widget.user!.id).collection('MedKit').add({
          'id': id,
        });
        await MedkitService().addMedkit(id, medkitName, medkitDescription);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('MedKit успешно добавлен!')));
      }
      await Future.delayed(Duration(seconds: 2)); // Задержка перед закрытием страницы
      Navigator.pop(context); // Переход назад после отображения SnackBar
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Добавить MedKit'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_selectedOption != 'import')
                Column(
                  children: [
                    // Поле для ввода названия MedKit
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Название'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите название';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        medkitName = value;
                      },
                    ),
                    // Поле для ввода описания MedKit
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Описание'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите описание';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        medkitDescription = value;
                      },
                    ),
                  ],
                ),

              if (_selectedOption == 'import')
                // Поле для ввода ID аптечки при импорте
                TextFormField(
                  decoration: InputDecoration(labelText: 'ID Аптечки'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите ID аптечки';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    medkitId = value;
                  },
                ),

              SizedBox(height: 20),

              // Радиокнопки для выбора "Для себя", "Для семьи" или "Импортировать аптечку"
              if (hasFamily)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Кому предоставить доступ:'),
                    ListTile(
                      title: const Text('Для себя'),
                      leading: Radio<String>(
                        value: 'self',
                        groupValue: _selectedOption,
                        onChanged: (String? value) {
                          setState(() {
                            _selectedOption = value!;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text('Для семьи'),
                      leading: Radio<String>(
                        value: 'family',
                        groupValue: _selectedOption,
                        onChanged: (String? value) {
                          setState(() {
                            _selectedOption = value!;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text('Импортировать аптечку'),
                      leading: Radio<String>(
                        value: 'import',
                        groupValue: _selectedOption,
                        onChanged: (String? value) {
                          setState(() {
                            _selectedOption = value!;
                          });
                        },
                      ),
                    ),
                  ],
                )
              else
                ListTile(
                  title: const Text('Для себя'),
                  leading: Radio<String>(
                    value: 'self',
                    groupValue: _selectedOption,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedOption = 'self';
                      });
                    },
                  ),
                ),

              SizedBox(height: 20),

              // Кнопка сохранения
              ElevatedButton(
                onPressed:_saveMedkit,
                
                child: Text('Сохранить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
