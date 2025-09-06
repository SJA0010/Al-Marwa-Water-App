class BottleIssueModel {
  final bool status;
  final String message;
  final BottleIssueData data;

  BottleIssueModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory BottleIssueModel.fromJson(Map<String, dynamic> json) {
    return BottleIssueModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: BottleIssueData.fromJson(json['data']),
    );
  }
}

class BottleIssueData {
  final int id;
  final int customerId;
  final String quantity;
  final String buildingName;
  final String block;
  final String room;
  final String saleUserId;
  final String date;
  final String createdAt;
  final String updatedAt;

  BottleIssueData({
    required this.id,
    required this.customerId,
    required this.quantity,
    required this.buildingName,
    required this.block,
    required this.room,
    required this.saleUserId,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BottleIssueData.fromJson(Map<String, dynamic> json) {
    return BottleIssueData(
      id: json['id'],
      customerId: json['customer_id'],
      quantity: json['quantity'],
      buildingName: json['building_name'],
      block: json['block'],
      room: json['room'],
      saleUserId: json['sale_user_id'],
      date: json['date'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
