import 'package:hive/hive.dart';
part 'hive_issue_bottle_model.g.dart';

@HiveType(typeId: 6)
class HiveBottleIssue {
  @HiveField(0)
  final int customerId;

  @HiveField(1)
  final String quantity;

  @HiveField(2)
  final String buildingName;

  @HiveField(3)
  final String block;

  @HiveField(4)
  final String room;

  @HiveField(5)
  final String saleUserId;

  @HiveField(6)
  final String date;

  HiveBottleIssue({
    required this.customerId,
    required this.quantity,
    required this.buildingName,
    required this.block,
    required this.room,
    required this.saleUserId,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      "customer_id": customerId,
      "quantity": quantity,
      "building_name": buildingName,
      "block": block,
      "room": room,
      "sale_user_id": saleUserId,
      "date": date,
    };
  }
}
