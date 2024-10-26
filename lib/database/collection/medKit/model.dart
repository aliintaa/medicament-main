class Medkit {
  String? id;
  String? name;
  String? description;

  Medkit({this.id, this.name, this.description});

  // Метод для конвертации объекта в Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  // Фабричный метод для создания объекта из JSON (Map)
  factory Medkit.fromJson(Map<String, dynamic> data) {
    return Medkit(
      id: data['id'],
      name: data['name'],
      description: data['description'],
    );
  }
}
