class foodModel {
  final String uid;
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final DateTime date;
  final double Fiber;

  foodModel({
    required this.uid,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.Fiber,
    required this.date,
  });
}

List<foodModel> foodList = [];
double totalWater = 0;
