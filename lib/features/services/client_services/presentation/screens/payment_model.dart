class PaymentModel {
  final String taskId;
  final String timeSlot;
  final DateTime date;
  final String selectedCategory;
  final List<String> selectedSubCategories;
  final Map<String, int> serviceSizes;
  final double totalPrice;
  final String userId;
  final String userName;

  PaymentModel({
    required this.taskId,
    required this.timeSlot,
    required this.date,
    required this.selectedCategory,
    required this.selectedSubCategories,
    required this.serviceSizes,
    required this.totalPrice,
    required this.userId,
    required this.userName,
  });

  Map<String, dynamic> toJson() {
    return {
      'taskId': taskId,
      'timeSlot': timeSlot,
      'date': date.toIso8601String(),
      'selectedCategory': selectedCategory,
      'selectedSubCategories': selectedSubCategories,
      'serviceSizes': serviceSizes,
      'totalPrice': totalPrice,
      'userId': userId,
      'userName': userName,
    };
  }
}
