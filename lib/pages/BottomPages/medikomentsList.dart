import 'package:flutter/material.dart';
import 'package:minerestoran/database/collection/medicoment/model.dart';
import 'package:minerestoran/database/collection/medicoment/service.dart';
import 'package:minerestoran/database/collection/user/model.dart';
import 'package:minerestoran/main.dart';
import 'package:minerestoran/pages/addMedicoment.dart';


class MedicationsPage extends StatefulWidget {
  final Users? user;
  MedicationsPage({this.user});

  @override
  _MedicationsPageState createState() => _MedicationsPageState();
}

class _MedicationsPageState extends State<MedicationsPage> with RouteAware {
  final mdeicomentsClass medicationService = mdeicomentsClass();
  List<mdeicoments>? medications;

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    try {
      final meds = await medicationService.getAllmedicoment();
      print(meds); // Отладочный вывод
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Подписываем страницу на RouteObserver
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    // Отписываемся от RouteObserver
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Этот метод вызывается, когда возвращаемся на страницу
    _loadMedications(); // Обновляем данные
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Медикаменты'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddMedicationPage(widget.user)),
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: medications == null
          ? Center(child: Text('Таблетки еще не добавили!'))
          : ListView.builder(
              itemCount: medications!.length,
              itemBuilder: (context, index) {
                final medication = medications![index];
                return _buildMedicationCard(medication);
              },
            ),
    );
  }

  Widget _buildMedicationCard(mdeicoments medication) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            _buildImage(medication.image),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medication.name ?? 'Без названия',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    medication.description ?? 'Нет описания',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String? imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Image.network(
        imageUrl ?? 'https://example.com/default-image.jpg',
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image, size: 80);
        },
      ),
    );
  }
}
