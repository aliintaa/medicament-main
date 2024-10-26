import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';  // Для инициализации локали
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:minerestoran/database/auth/service.dart';
import 'package:minerestoran/database/collection/medicoment/medicoment_motion_servise.dart';
import 'package:minerestoran/database/collection/medicoment/model_user.dart';
import 'package:minerestoran/database/collection/medicoment/service.dart';
import 'package:minerestoran/database/collection/user/model.dart';
import 'package:minerestoran/pages/AddMedicomentFromMedkit.dart';
import 'package:minerestoran/pages/Historymedicoment.dart';

// Функция для форматирования даты
String formatDate(DateTime date) {
  final formatter = DateFormat('d MMMM y', 'ru'); // Форматируем дату как "24 октября 2024"
  return formatter.format(date);
}

class MedkitPage extends StatefulWidget {
  final String medkitId;
  final Users? user;

  MedkitPage({required this.medkitId, this.user});

  @override
  _MedkitPageState createState() => _MedkitPageState();
}

class _MedkitPageState extends State<MedkitPage> {
  late mdeicomentsClass medicomentService;
  List<mdeicomentsUser> medicomentsList = [];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ru'); // Инициализация форматирования для русского языка
    medicomentService = mdeicomentsClass();
    loadMedicoments();
  }

  // Метод загрузки медикаментов для аптечки
  Future<void> loadMedicoments() async {
    try {
      final medicoments = await medicomentService.getAllmedicomentForMedkit(widget.medkitId);
      setState(() {
        medicomentsList = medicoments ?? [];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка загрузки медикаментов: $e')));
    }
  }

  // Проверка срока годности медикаментов
  bool isExpired(DateTime? expiryDate) {
    if (expiryDate == null) return false;
    final now = DateTime.now();
    return expiryDate.isBefore(now) || expiryDate.isAtSameMomentAs(now);  // Истек или сегодня
  }

  // Удаление медикамента
  Future<void> deleteMedicoment(String id) async {
    try {
      await medicomentService.deleteMedicoment(widget.medkitId, id);
      setState(() {
        medicomentsList.removeWhere((item) => item.id == id);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка удаления медикамента: $e')));
    }
  }

  // Подтверждение удаления медикамента
  void confirmDelete(BuildContext context, mdeicomentsUser medicoment, int index) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Удалить медикамент'),
        content: Text('Вы уверены, что хотите удалить этот медикамент?'),
        actions: [
          TextButton(
            child: Text('Отмена'),
            onPressed: () {
              Navigator.of(context).pop();
              // Восстанавливаем медикамент, если отменено
              setState(() {
                medicomentsList.insert(index, medicoment);
              });
            },
          ),
          TextButton(
            child: Text('Удалить'),
            onPressed: () {
              deleteMedicoment(medicoment.id!);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

  // Открытие диалога для употребления медикамента
  void showTakePillDialog(BuildContext context, mdeicomentsUser medicoment) {
    if (isExpired(medicoment.dateStop)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Медикамент с истекшим сроком годности нельзя употребить!')));
      return;
    }

    final TextEditingController countController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Сколько таблеток вы хотите взять?'),
          content: TextField(
            controller: countController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Количество'),
          ),
          actions: [
            TextButton(
              child: Text('Отмена'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Принять'),
              onPressed: () async {
                final count = int.tryParse(countController.text);
                if (count != null && count > 0 && count <= medicoment.count!) {
                  await takePill(medicoment, count); // Употребляем таблетку
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Неверное количество')));
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Употребление таблетки
  Future<void> takePill(mdeicomentsUser medicoment, int count) async {
    if (widget.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: пользователь не найден')));
      return;
    }

    try {
      await MedicomentsMotionService().addMedicomentMotion(
        widget.medkitId,
        medicoment,
        widget.user!.id!,
        count,
        'remove', // Действие "употребить"
      );

      setState(() {
        medicoment.count = medicoment.count! - count;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Вы приняли $count таблеток')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка при обновлении: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Медикаменты аптечки'),
        actions: [ IconButton(
      icon: Icon(Icons.copy),
      onPressed: () {
        Clipboard.setData(ClipboardData(text: widget.medkitId)); // Копируем ID аптечки
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ID аптечки скопирован: ${widget.medkitId}')));
      },
    ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MedicomentHistoryPage(medkitId: widget.medkitId),
                ),
              );
            },
            icon: Icon(Icons.history),
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddMedicationMedkitPage(widget.medkitId)),
              ).then((_) {
                loadMedicoments(); // Обновляем медикаменты после возврата
              });
            },
          ),
        ],
      ),
      body: medicomentsList.isEmpty
          ? Center(child: Text('Медикаменты не найдены'))
          : ListView.builder(
              itemCount: medicomentsList.length,
              itemBuilder: (context, index) {
                final medicoment = medicomentsList[index];
                final bool isExpiredNow = isExpired(medicoment.dateStop);

                return Dismissible(
                  key: Key(medicoment.id!),
                  background: Container(color: Colors.red),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
  setState(() {
    medicomentsList.removeAt(index); // Убираем временно из списка
  });
  confirmDelete(context, medicoment, index); // Показываем диалог подтверждения
},
                  child: Card(
                    child: ListTile(
                      leading: medicoment.image != null
                          ? Image.network(medicoment.image!, width: 50, height: 50, fit: BoxFit.cover)
                          : Icon(Icons.medical_services),
                      title: Text(
                        medicoment.name ?? 'Без названия',
                        style: TextStyle(
                          color: isExpiredNow ? Colors.red : Colors.black, // Красный цвет, если срок годности истек
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Описание: ${medicoment.description ?? 'Нет описания'}'),
                          Text('Количество: ${medicoment.count ?? 0}'),
                          if (medicoment.dateStop != null)
                            Text(
                              'Срок годности: ${formatDate(medicoment.dateStop!)}', // Используем форматированную дату
                              style: TextStyle(color: isExpiredNow ? Colors.red : Colors.black),
                            ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.remove_circle_outline),
                        onPressed: isExpiredNow
                            ? null // Блокировка кнопки, если срок годности истек
                            : () {
                                showTakePillDialog(context, medicoment); // Открываем диалог для ввода количества
                              },
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
