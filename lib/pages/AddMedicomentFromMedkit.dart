import 'package:flutter/material.dart';
import 'package:minerestoran/database/collection/medKit/model.dart';
import 'package:minerestoran/database/collection/medicoment/model.dart';
import 'package:minerestoran/database/collection/medicoment/service.dart';
import 'package:minerestoran/database/collection/medicoment/model_user.dart';
import 'package:minerestoran/database/collection/user/model.dart';
import 'package:intl/intl.dart'; // Для форматирования даты

class AddMedicationMedkitPage extends StatefulWidget {
  final String? medkit;

  AddMedicationMedkitPage(this.medkit);

  @override
  _AddMedicationMedkitPageState createState() => _AddMedicationMedkitPageState();
}

class _AddMedicationMedkitPageState extends State<AddMedicationMedkitPage> {
  final mdeicomentsClass medicationService = mdeicomentsClass();
  List<mdeicoments>? medications;
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    try {
      final meds = await medicationService.getAllmedicoment();
      setState(() {
        medications = meds;
      });
    } catch (e) {
      print('Ошибка при загрузке медикаментов: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при загрузке медикаментов')),
      );
    }
  }

  // Функция для проверки и вывода сообщения
  Future<void> _onMedicationTap(mdeicoments medication) async {
    // Проверяем, существует ли медикамент в аптечке
    final existingMedication = await medicationService.checkIfMedicationExistsInMedkit(widget.medkit!, medication.id!);

    if (existingMedication != null) {
      // Если медикамент уже есть, выводим сообщение
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Медикамент уже существует в аптечке!')),
      );
    } else {
      // Если медикамента нет, сразу открываем диалог для добавления
      _showAddMedicationDialog(medication);
    }
  }

  // Функция для ввода данных и добавления медикамента
  Future<void> _showAddMedicationDialog(mdeicoments medication) async {
    final _countController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Добавить медикамент: ${medication.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ввод количества
              TextField(
                controller: _countController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Количество'),
              ),
              // Ввод даты начала
              ListTile(
                title: Text(startDate == null
                    ? 'Выбрать дату начала'
                    : 'Дата начала: ${DateFormat('dd-MM-yyyy').format(startDate!)}'), // Форматирование даты
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000), // Дата начала может быть с 2000 года
                    lastDate: DateTime.now(), // Дата начала не может быть больше текущего дня
                  );
                  if (date != null) {
                    setState(() {
                      startDate = date;
                    });
                  }
                },
              ),
              // Ввод даты окончания
              ListTile(
                title: Text(endDate == null
                    ? 'Выбрать дату окончания'
                    : 'Дата окончания: ${DateFormat('dd-MM-yyyy').format(endDate!)}'), // Форматирование даты
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(), // Дата окончания должна быть больше или равна текущему дню
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    setState(() {
                      endDate = date;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                // Проверка данных перед добавлением
                if (_countController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Введите количество таблеток')),
                  );
                } else if (startDate == null || endDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Выберите обе даты')),
                  );
                } else if (startDate!.isAfter(endDate!)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Дата начала не может быть позже даты окончания')),
                  );
                } else {
                  _addMedicationToMedkit(medication, int.parse(_countController.text), startDate!, endDate!);
                  Navigator.pop(context);
                }
              },
              child: Text('Добавить'),
            ),
          ],
        );
      },
    );
  }

  // Добавление медикамента в аптечку
  Future<void> _addMedicationToMedkit(mdeicoments medication, int count, DateTime startDate, DateTime endDate) async {
    final medUser = mdeicomentsUser(
      medication.id,
      medication.image,
      medication.name,
      medication.description,
      endDate,
      startDate,
      count,
    );

    await medicationService.addInMedKidForMedikament(widget.medkit!, medUser);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Медикамент успешно добавлен!')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Добавить медикамент в аптечку'),
      ),
      body: medications == null
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: medications!.length,
              itemBuilder: (context, index) {
                final medication = medications![index];
                return GestureDetector(
                  onTap: () {
                    _onMedicationTap(medication);  // Проверка и сообщение сразу при нажатии
                  },
                  child: Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: medication.image != null
                          ? Image.network(medication.image!)
                          : Icon(Icons.medical_services),
                      title: Text(medication.name ?? 'Без названия'),
                      subtitle: Text(medication.description ?? 'Нет описания'),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
