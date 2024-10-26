class Family{
  String? id;
  String? name;



Family({this.id, this.name});
  // Конструктор для создания объекта из JSON (данные из Firebase)
  Family.fromJson(Map<String, dynamic> data) {
    id = data['id'];
    name = data['name'];
  }

  // Метод для преобразования объекта в Map для хранения в Firebase
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

}