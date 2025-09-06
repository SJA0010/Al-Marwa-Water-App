import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:loader_overlay/loader_overlay.dart';

import 'package:al_marwa_water_app/models/hive_issue_bottle_model.dart';
import 'package:al_marwa_water_app/models/issue_bottle_model.dart';
import 'package:al_marwa_water_app/repositories/issue_bottle_repository.dart';
import 'package:al_marwa_water_app/core/utils/custom_snackbar.dart';

class BottleController with ChangeNotifier {
  final BottleIssueRepository _repository = BottleIssueRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasSynced = false;
  BottleIssueModel? _bottleIssue;
  BottleIssueModel? get bottleIssue => _bottleIssue;

  // 🌐 Check internet
  Future<bool> hasInternet() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // 🚰 Issue bottle (online or offline)
  Future<void> issueBottle(
    BuildContext context, {
    required int customerId,
    required String quantity,
    required String buildingName,
    required String block,
    required String date,
    required String room,
    required String saleUserId,
  }) async {
    _isLoading = true;
    notifyListeners();
    context.loaderOverlay.show();

    final data = {
      "date": date,
      "customer_id": customerId,
      "quantity": quantity,
      "building_name": buildingName,
      "block": block,
      "room": room,
      "sale_user_id": saleUserId,
    };

    try {
      if (await hasInternet()) {
        _bottleIssue = await _repository.issueBottle(data);
        showSnackbar(
          message: "✅ ${_bottleIssue?.message ?? "Bottle issued successfully"}",
          isError: false,
        );
        log("🎉 Bottle issued online: ${_bottleIssue?.data}");
      } else {
        final box = Hive.box<HiveBottleIssue>('pending_bottle_orders');

        final isDuplicate = box.values.any((e) =>
            e.customerId == customerId &&
            e.quantity == quantity &&
            e.buildingName == buildingName &&
            e.block == block &&
            e.date == date &&
            e.room == room &&
            e.saleUserId == saleUserId);

        if (isDuplicate) {
          log("⚠️ Duplicate offline order blocked");
          showSnackbar(
              message: "⚠️ Order already saved offline", isError: true);
        } else {
          box.add(HiveBottleIssue(
            date: date,
            customerId: customerId,
            quantity: quantity,
            buildingName: buildingName,
            block: block,
            room: room,
            saleUserId: saleUserId,
          ));
          log("📦 Saved order offline");
          showSnackbar(
              message: "🕓 Offline: Order saved locally", isError: false);
        }
      }
    } catch (e) {
      log("❌ Error issuing bottle: $e");
      showSnackbar(message: "Error: $e", isError: true);
    } finally {
      _isLoading = false;
      notifyListeners();
      if (context.mounted) context.loaderOverlay.hide();
    }
  }

  // 🔁 Sync pending offline orders (called on home/splash)
  Future<void> syncPendingBottleOrders(BuildContext context) async {
    if (_hasSynced) return;
    _hasSynced = true;

    if (await hasInternet()) {
      final box = Hive.box<HiveBottleIssue>('pending_bottle_orders');

      if (box.isNotEmpty) {
        final orders = box.values.toList();
        log("🔄 Syncing ${orders.length} pending orders...");

        for (int i = 0; i < orders.length; i++) {
          final order = orders[i];
          try {
            log("➡️ Syncing order ${i + 1}/${orders.length}");
            await _repository.issueBottle(order.toJson());
          } catch (e) {
            log("❌ Failed to sync order ${i + 1}: $e");
          }
        }

        await box.clear();
        log("✅ All pending orders synced and cleared");
        showSnackbar(message: "✅ Synced pending orders");
      }
    }
  }
}
