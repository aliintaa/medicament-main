import 'package:flutter/material.dart';
import 'package:minerestoran/database/collection/user/model.dart';
import 'package:minerestoran/pages/BottomPages/MidKitListPage.dart';
import 'package:minerestoran/pages/BottomPages/Profile.dart';
import 'package:minerestoran/pages/BottomPages/medikomentsList.dart';
import 'package:minerestoran/pages/Info.dart';

class NavigationPage extends StatefulWidget {
  final Users user;  // Получаем объект пользователя
  final int? page_id;

  NavigationPage({required this.user, this.page_id});

  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  late int _currentIndex;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Устанавливаем начальный индекс на основе page_id или 0, если не передан
    _currentIndex = widget.page_id ?? 0;

    // Инициализация страниц с передачей объекта пользователя
    _pages = [
      MedkitListPage(user: widget.user),  // Передаем пользователя на страницу аптечек
      MedicationsPage(user: widget.user),
      UsefulInfoPage(),
      UserProfilePage(user: widget.user),
    ];
  }

  // Функция для изменения текущей вкладки
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],  // Показываем текущую страницу
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Текущий индекс выбранной вкладки
        onTap: _onTabTapped,         // Вызывается при выборе вкладки
        selectedItemColor: Color(0xFFA1C292), // Цвет активной вкладки
        unselectedItemColor: Colors.black,    // Цвет неактивных вкладок
        showUnselectedLabels: true,           // Показываем подписи для неактивных вкладок
        type: BottomNavigationBarType.fixed,  // Исправляем видимость при большом количестве элементов
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),   // Иконка для "Аптечки"
            label: 'Аптечки',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),  // Иконка для "Список таблеток"
            label: 'Таблеток',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),  // Иконка для "Полезная информация"
            label: 'Информация',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),   // Иконка для "Профиль"
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}
