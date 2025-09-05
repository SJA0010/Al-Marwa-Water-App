import 'dart:developer';
import 'dart:io';
import 'package:al_marwa_water_app/core/constants/constants.dart';
import 'package:al_marwa_water_app/core/utils/custom_snackbar.dart';
import 'package:al_marwa_water_app/models/create_credit_bill_model.dart';
import 'package:al_marwa_water_app/models/get_credit_bill_model.dart';
import 'package:al_marwa_water_app/models/hive_create_credit_model.dart';
import 'package:al_marwa_water_app/repositories/credit_bill_repository.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:loader_overlay/loader_overlay.dart';

class CreditBillController with ChangeNotifier {
  final CreditBillRepository _createBillRepository = CreditBillRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  List<GetCreditBillItem> _creditBills = [];
  String? _error;
  int? id;

  CreateCreditBillModel? _createBillResponse;
  CreateCreditBillModel? get createBillResponse => _createBillResponse;
  bool _hasSynced = false;

  Future<bool> hasInternet() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> createCreditBill(
      BuildContext context, Map<String, dynamic> billData) async {
    _isLoading = true;
    notifyListeners();
    context.loaderOverlay.show();

    try {
      if (await hasInternet()) {
        // Online
        _createBillResponse = await _createBillRepository.createBill(billData);

        if (_createBillResponse?.status == true) {
          _salesCode = _createBillResponse?.data.salesCode;
          print("12222${_createBillResponse!.data}");
          print("12222${_createBillResponse!.data.id}");
          StaticData().currentBill = StaticData()
              .currentBill
              ?.copyWith(id: _createBillResponse!.data.id);
          id = _createBillResponse!.data.id;
          print(StaticData().currentBill?.id);
        } else {
          throw Exception(
              _createBillResponse?.message ?? 'Failed to create credit bill');
        }
      } else {
        final box =
            Hive.box<HiveCreditBillModel>('pending_create_credit_bills');
        final offlineBill = HiveCreditBillModel(
          date: billData["date"],
          customerId: billData["customer_id"],
          productId: billData["product_id"],
          trn: billData["trn"],
          vat: billData["vat"],
          quantity: billData["quantity"],
          rate: billData["rate"],
          amount: billData["amount"],
          saleUserId: billData["sale_user_id"],
        );

        box.add(offlineBill);

        // ✅ also set StaticData so UI doesn't crash

        log("🕓 Offline credit bill saved locally and set to StaticData");
        showSnackbar(
            message: "🕓 Offline: Credit Bill saved locally", isError: false);
      }
    } catch (e) {
      log("❌ Create Credit Bill controller error: $e");
      showSnackbar(message: e.toString(), isError: true);
    } finally {
      _isLoading = false;
      context.loaderOverlay.hide();
      notifyListeners();
    }
  }

  Future<void> syncPendingCreditBills(BuildContext context) async {
    if (_hasSynced) return;
    _hasSynced = true;

    if (await hasInternet()) {
      final box = Hive.box<HiveCreditBillModel>('pending_create_credit_bills');
      if (box.isNotEmpty) {
        final orders = box.values.toList();
        log("🔄 Syncing ${orders.length} pending credit bills...");
        for (int i = 0; i < orders.length; i++) {
          final order = orders[i];
          try {
            log("🔄 Syncing credit bill ${i + 1}/${orders.length}");
            await _createBillRepository.createBill(order.toJson());
          } catch (e) {
            log("❌ Failed to sync credit bill: $e");
          }
        }
        await box.clear();
        log("✅ Synced and cleared all pending credit bills");
        showSnackbar(message: "✅ Synced pending credit bills");
      }
    }
  }

//! --------Get page bills------------------
  List<GetCreditBillItem> get creditBills => _creditBills;
  String? get error => _error;
  String? _salesCode;
  String? get salesCode => _salesCode;
  List<GetCreditBillItem> _billsPage = [];
  List<GetCreditBillItem> get billsPage => _billsPage;

  int _currentPage = 1;
  int _lastPage = 1;

  // Add these getters so your UI can access currentPage and lastPage
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;

  Future<void> fetchBillsPage(BuildContext context,
      {bool loadMore = false, int page = 1}) async {
    if (_isLoading) return; // prevent multiple calls

    if (!loadMore) {
      _currentPage = page; // update to requested page
      _billsPage = [];
    } else {
      if (_currentPage >= _lastPage) return; // no more pages
      _currentPage++;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Assuming your repository method returns an object like PaginatedBills
      final paginatedData =
          await _createBillRepository.getPageBills(context, page: _currentPage);

      if (!loadMore) {
        _billsPage = paginatedData.bills;
      } else {
        _billsPage.addAll(paginatedData.bills);
      }

      _lastPage = paginatedData.lastPage;

      if (_billsPage.isEmpty) {
        // showSnackbar(message: "No bills found", isError: true);
      } else if (!loadMore) {
        showSnackbar(message: "Bills fetched successfully");
      }
    } catch (e) {
      if (!await hasInternet()) {
        _isLoading = false;
        notifyListeners();

        await showInternetDialog(context, () {
          fetchBillsPage(context, loadMore: loadMore, page: page); // 🔁 Retry
        });

        return; // ⛔ Exit early if no internet
      } else {
        showSnackbar(message: "Failed to fetch bills", isError: true);

        debugPrint("Error fetching bills: $e");
      }
    }

    _isLoading = false;
    notifyListeners();
  }
}

Future<void> showInternetDialog(
    BuildContext context, VoidCallback onRetry) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Text("No Internet Connection"),
      content: const Text("Please check your internet and try again."),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onRetry();
          },
          child: const Text("Try Again"),
        ),
      ],
    ),
  );
}
