import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:minerestoran/database/collection/medKit/model.dart';
import 'package:minerestoran/database/collection/medKit/service.dart';
import 'package:minerestoran/database/collection/user/model.dart';
import 'package:minerestoran/main.dart';
import 'package:minerestoran/pages/AddMedkit.dart';
import 'package:minerestoran/pages/MedKit.dart';

class MedkitListPage extends StatefulWidget {
  final Users? user;
  MedkitListPage({this.user});

  @override
  _MedkitListPageState createState() => _MedkitListPageState();
}

class _MedkitListPageState extends State<MedkitListPage> with RouteAware {
  final MedkitService medkitService = MedkitService();

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
    setState(() {}); // Обновляем данные при возврате на экран
  }

  @override
  Widget build(BuildContext context) {
    if (widget.user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Мои аптечки'),
        ),
        body: Center(child: Text('Пользователь не найден')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Мои аптечки'),
      ),
      body: FutureBuilder<List<Medkit>>(
        future: medkitService.getAllMedkits(widget.user!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Ошибка загрузки данных'));
          }

          final medkits = snapshot.data ?? [];

          if (medkits.isEmpty) {
            return Center(child: Text('Аптечек пока нет.'));
          }

          return ListView.builder(
            itemCount: medkits.length,
            itemBuilder: (context, index) {
              final medkit = medkits[index];
              return Dismissible(
                key: Key(medkit.id!), // уникальный ключ для каждого элемента
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) async {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.user!.id)
                      .collection('MedKit')
                      .doc(medkit.id)
                      .delete();

                  setState(() {
                    medkits.removeAt(index);
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("${medkit.name} удалена")),
                  );
                },
                child: MedkitItem(medkit: medkit, user: widget.user,),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: (Color(0xFFA1C292)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddFamilyAccessPage(user: widget.user), // Исправление здесь
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}


class MedkitItem extends StatelessWidget {
  final Medkit medkit;
  final Users? user;

  const MedkitItem({Key? key, required this.medkit, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.local_hospital, color: Colors.red), // Иконка аптечки
        title: Text(medkit.name ?? 'Без названия'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Описание: ${medkit.description ?? 'Описание отсутствует'}'),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MedkitPage(
                medkitId: medkit.id!, 
                user: user, // Передаем объект user
              ),
            ),
          );
        },
      ),
    );
  }
}
