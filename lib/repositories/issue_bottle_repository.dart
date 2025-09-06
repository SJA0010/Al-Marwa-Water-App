import 'dart:developer';
import 'package:al_marwa_water_app/core/utils/custom_snackbar.dart';
import 'package:al_marwa_water_app/models/issue_bottle_model.dart';
import 'package:al_marwa_water_app/services/api_helper.dart';

class BottleIssueRepository {
  final ApiHelper _apiHelper = ApiHelper();

  Future<BottleIssueModel> issueBottle(Map<String, dynamic> body) async {
    try {
      final response = await _apiHelper.post('issue-bottles', body);
      log("✅ Bottle Issue API response: $response");

      return BottleIssueModel.fromJson(response);
    } catch (e) {
      log("❌ Bottle issue error: $e");
      showSnackbar(message: "Failed to issue bottle", isError: true);
      rethrow;
    }
  }
}
