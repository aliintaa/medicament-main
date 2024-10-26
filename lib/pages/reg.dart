import 'package:flutter/material.dart';
import 'package:minerestoran/database/auth/service.dart';
import 'package:minerestoran/database/collection/user/model.dart';
import 'package:minerestoran/pages/auth.dart';



class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  // Контроллеры для всех полей пользователя
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _patronymicController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = false;

  // Метод для регистрации
  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Создаем объект Users с использованием всех полей
      Users newUser = Users(
        email: _emailController.text,
        password: _passwordController.text, 
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        patronymic: _patronymicController.text,
        address: _addressController.text,
        phone: _phoneController.text,
        dateReg: DateTime.now(),  // Устанавливаем дату регистрации как текущую
      );

      // Вызываем метод createIn() для регистрации пользователя
      Users? registeredUser = await AuthService().createIn(newUser);

      setState(() {
        _isLoading = false;
      });

      if (registeredUser != null) {
        // Успешная регистрация, показываем сообщение и переходим на главную страницу
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Регистрация успешна!')),
        );
        Navigator.pushReplacementNamed(context, '/');
      } else {
        // Ошибка регистрации
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при регистрации')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Регистрация'),
      ),
      drawer: null,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите email';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(labelText: 'Пароль'),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите пароль';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _firstNameController,
                      decoration: InputDecoration(labelText: 'Имя'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите имя';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: InputDecoration(labelText: 'Фамилия'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите фамилию';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _patronymicController,
                      decoration: InputDecoration(labelText: 'Отчество'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите отчество';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(labelText: 'Адрес'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите адрес';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(labelText: 'Телефон'),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите телефон';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _registerUser,
                      child: Text('Зарегистрироваться'),
                    ),
                    ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AuthPage(), // Убедитесь, что AuthPage возвращает корректный виджет
      ),
    );
  },
  child: Text("Есть аккаунт?"),
)

                  ],
                ),
              ),
            ),
    );
  }
}
