import 'package:flutter/material.dart';
import 'package:minerestoran/database/collection/medicoment/medicoment_motion_servise.dart';
import 'package:minerestoran/database/collection/medicoment/model_medicoment_motion.dart';

class MedicomentHistoryPage extends StatefulWidget {
  final String medkitId;

  MedicomentHistoryPage({required this.medkitId});

  @override
  _MedicomentHistoryPageState createState() => _MedicomentHistoryPageState();
}

class _MedicomentHistoryPageState extends State<MedicomentHistoryPage> {
  late MedicomentsMotionService medicomentService;
  List<MedicomentMotionWithName> historyList = [];
  bool isLoading = true;  // Переменная состояния для индикации загрузки

  @override
  void initState() {
    super.initState();
    medicomentService = MedicomentsMotionService();
    loadHistory();
  }

  Future<void> loadHistory() async {
    try {
      final history = await medicomentService.getMedicomentHistory(widget.medkitId);
      setState(() {
        historyList = history;
        isLoading = false;  // Отключаем индикатор загрузки после загрузки данных
      });
    } catch (e) {
      setState(() {
        isLoading = false;  // Отключаем индикатор загрузки даже в случае ошибки
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка загрузки истории: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('История употребления медикаментов'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())  // Показать индикатор загрузки
          : historyList.isEmpty
              ? Center(child: Text('История не найдена'))  // Если нет данных, показываем сообщение
              : ListView.builder(
                  itemCount: historyList.length,
                  itemBuilder: (context, index) {
                    final motionWithName = historyList[index];
                    return Card(
                      child: ListTile(
                        leading: Icon(
                          motionWithName.motion.motion == 'add' ? Icons.add_circle : Icons.remove_circle,
                          color: motionWithName.motion.motion == 'add' ? Colors.green : Colors.red,
                        ),
                        title: Text('Медикамент: ${motionWithName.medicomentName}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Действие: ${motionWithName.motion.motion == 'add' ? 'Добавлено' : 'Употреблено'}'),
                            Text('Количество: ${motionWithName.motion.count}'),
                            Text('Дата: ${motionWithName.motion.timestamp}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
