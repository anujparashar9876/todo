class Task {
  int? id;
  String title;
  bool isCompleted;

  Task({this.id, required this.title, this.isCompleted = false});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }
}
