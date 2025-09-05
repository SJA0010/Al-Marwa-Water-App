import 'dart:developer';
import 'dart:io';

import 'package:al_marwa_water_app/core/constants/constants.dart';
import 'package:al_marwa_water_app/core/utils/custom_snackbar.dart';
import 'package:al_marwa_water_app/models/create_bill_model.dart';
import 'package:al_marwa_water_app/models/get_bill_model.dart';
import 'package:al_marwa_water_app/models/hive_create_bill_model.dart';
import 'package:al_marwa_water_app/repositories/bill_repository.dart';
import 'package:al_marwa_water_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:loader_overlay/loader_overlay.dart';

class BillController with ChangeNotifier {
  final BillRepository _createBillRepository = BillRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _salesCode;
  String? get salesCode => _salesCode;
  int? id;

  CreateBillResponseModel? _createBillResponse;
  CreateBillResponseModel? get createBillResponse => _createBillResponse;

  Future<bool> hasInternet() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> createBill(
    BuildContext context,
    Map<String, dynamic> billData,
  ) async {
    _isLoading = true;
    notifyListeners();
    context.loaderOverlay.show();

    try {
      if (await hasInternet()) {
        _createBillResponse = await _createBillRepository.createBill(billData);

        if (_createBillResponse?.status == true) {
          showSnackbar(
            message:
                _createBillResponse?.message ?? 'Bill created successfully',
            isError: false,
          );
          _salesCode = _createBillResponse?.data.salesCode;
          log("✅ Bill creation success: $_createBillResponse");
          // _createBillResponse =
          //     await _createBillRepository.createBill(billData);

          if (_createBillResponse?.status == true) {
            print("12222${_createBillResponse!.data}");
            print("12222${_createBillResponse!.data.id}");
            StaticData().currentBill = StaticData()
                .currentBill
                ?.copyWith(id: _createBillResponse!.data.id);
            id = _createBillResponse!.data.id;
            print(StaticData().currentBill?.id);
          }
        } else {
          throw Exception(
            _createBillResponse?.message ?? 'Failed to create bill',
          );
        }
      } else {
        // 🕓 Save to Hive if offline
        final box = Hive.box<HiveCreateBillModel>('pending_create_bills');
        final bill = HiveCreateBillModel(
          date: billData['date'],
          customerId: billData['customer_id'],
          productId: billData['product_id'],
          trn: billData['trn'],
          vat: billData['vat'],
          quantity: billData['quantity'],
          rate: billData['rate'],
          amount: billData['amount'],
          saleUserId: billData['sale_user_id'],
        );

        box.add(bill);
        log("📦 Bill saved offline: ${bill.toJson()}");
        showSnackbar(message: "🕓 Offline: Bill saved locally", isError: false);
      }
    } catch (e) {
      log("❌ Create Bill controller error: $e");
      showSnackbar(message: e.toString(), isError: true);
    } finally {
      _isLoading = false;
      context.loaderOverlay.hide();
      notifyListeners();
    }
  }

  bool _hasSynced = false;

  Future<void> syncPendingBills(BuildContext context) async {
    if (_hasSynced) return;
    _hasSynced = true;

    if (await hasInternet()) {
      final box = Hive.box<HiveCreateBillModel>('pending_create_bills');
      if (box.isNotEmpty) {
        final pending = box.values.toList();
        log("🔄 Syncing ${pending.length} pending bills...");

        for (int i = 0; i < pending.length; i++) {
          final bill = pending[i];
          try {
            log("🔄 Syncing bill ${i + 1}/${pending.length}");
            await _createBillRepository.createBill(bill.toJson());
          } catch (e) {
            log("❌ Failed to sync bill: $e");
          }
        }

        await box.clear();
        log("✅ Synced and cleared all pending bills");
        showSnackbar(message: "✅ Synced pending bills");
      }
    }
  }

  //! --------update bill controller------------------

  String? successMessage;
  String? errorMessage;

  Future<void> updateBill({
    required int billId,
    required Map<String, dynamic> updatedData,
    required String token,
    required bool isCredit,
    required BuildContext context,
  }) async {
    _isLoading = true;
    successMessage = null;
    errorMessage = null;
    notifyListeners();

    try {
      final result;
      print("Updating bill with ID: $billId $isCredit");
      if (isCredit == true) {
        result = await _createBillRepository.updateCreditBill(
          billId: billId,
          body: updatedData,
          token: token,
        );
      } else {
        result = await _createBillRepository.updateBill(
          billId: billId,
          body: updatedData,
          token: token,
        );
      }

      if (result['success']) {
        successMessage = result['message'];
        Navigator.pop(context);
        isCredit == false
            ? Navigator.popAndPushNamed(context, AppRoutes.BillsHistoryScreen)
            : Navigator.popAndPushNamed(
                context,
                AppRoutes.creditBillsHistoryScreen,
              );
        log('✅ Bill updated: ${result['data']}');
      } else {
        errorMessage = result['message'];
      }

      print("Update result: $result");
    } catch (e) {
      errorMessage = 'Something went wronghhhh: $e';
      log('❌ Error updating bill: $e');
      showSnackbar(message: errorMessage!, isError: true);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //! --------Get page bills------------------
  List<GetBillItem> _billsPage = [];
  List<GetBillItem> get billsPage => _billsPage;

  int _currentPage = 1;
  int _lastPage = 1;

  // Add these getters so your UI can access currentPage and lastPage
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;

  Future<void> fetchBillsPage(
    BuildContext context, {
    bool loadMore = false,
    int page = 1,
  }) async {
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
      final paginatedData = await _createBillRepository.getPageBills(
        context,
        page: _currentPage,
      );

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
  BuildContext context,
  VoidCallback onRetry,
) async {
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
