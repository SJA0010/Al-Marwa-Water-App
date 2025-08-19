import 'dart:async';
import 'dart:developer';

import 'package:al_marwa_water_app/core/constants/app_images.dart';
import 'package:al_marwa_water_app/core/utils/custom_snackbar.dart';
import 'package:al_marwa_water_app/models/bills_model.dart';
import 'package:al_marwa_water_app/routes/app_routes.dart';
import 'package:al_marwa_water_app/viewmodels/vat_controller.dart';
import 'package:al_marwa_water_app/widgets/custom_elevated_button.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  final BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  bool _isPrinting = false;
  BluetoothDevice? _selectedPrinter;

  Future<void> _selectPrinter() async {
    try {
      List<BluetoothDevice> devices = await bluetooth.getBondedDevices();

      if (devices.isEmpty) {
        showSnackbar(
          message: "No paired devices found.",
          isError: true,
        );
        return;
      }

      // Filter for likely printer devices (often contain "Printer" in name)
      List<BluetoothDevice> printers = devices.where((device) {
        return device.name?.toLowerCase().contains('printer') == true ||
            device.name?.toLowerCase().contains('bt') == true ||
            device.name?.toLowerCase().contains('pos') == true;
      }).toList();

      if (printers.isEmpty) {
        // If no obvious printers, show all devices
        printers = devices;
      }

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Select Printer'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: printers.length,
              itemBuilder: (context, index) {
                final device = printers[index];
                return ListTile(
                  title: Text(device.name ?? 'Unknown Device'),
                  subtitle: Text(device.address!),
                  onTap: () {
                    Navigator.pop(context);
                    _selectedPrinter = device;
                    showSnackbar(
                      message: "Selected printer: ${device.name}",
                      isError: false,
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ],
        ),
      );
    } catch (e) {
      log('Error selecting printer: $e');
      showSnackbar(
        message: "Error selecting printer: $e",
        isError: true,
      );
    }
  }

  Future<bool> _connectToPrinter() async {
    if (_selectedPrinter == null) {
      showSnackbar(
        message: "Please select a printer first.",
        isError: true,
      );
      return false;
    }

    try {
      setState(() {
        _isPrinting = true;
      });

      // Check if already connected
      bool? isConnected = await bluetooth.isConnected;
      if (isConnected == true) {
        await bluetooth.disconnect();
        await Future.delayed(Duration(milliseconds: 500));
      }

      // Connect with timeout
      final Completer<bool> connectionCompleter = Completer<bool>();

      // Set a timeout for connection
      Future.delayed(Duration(seconds: 10), () {
        if (!connectionCompleter.isCompleted) {
          connectionCompleter.complete(false);
        }
      });

      try {
        await bluetooth.connect(_selectedPrinter!);
        if (!connectionCompleter.isCompleted) {
          connectionCompleter.complete(true);
        }
      } catch (error) {
        if (!connectionCompleter.isCompleted) {
          connectionCompleter.complete(false);
        }
      }

      bool connected = await connectionCompleter.future;

      if (!connected) {
        showSnackbar(
          message: "Connection timeout. Please try again.",
          isError: true,
        );
        return false;
      }

      return true;
    } catch (e) {
      log('Connection error: $e');
      showSnackbar(
        message: "Failed to connect to printer: $e",
        isError: true,
      );
      return false;
    }
  }

  Future<void> printReceipt({
    required String receiptNo,
    required String date,
    required String customerTRN,
    required String customerName,
    required String product,
    required String tax,
    required String vat,
    required String totalAmount,
  }) async {
    if (!await _connectToPrinter()) {
      setState(() {
        _isPrinting = false;
      });
      return;
    }

    try {
      // Header
      bluetooth.printNewLine();
      bluetooth.printCustom("Al Marwa Water", 4, 1);
      bluetooth.printCustom("TRN: $customerTRN", 1, 1);
      bluetooth.printCustom("Phone: +971-12-1234567", 1, 1);
      bluetooth.printNewLine();
      bluetooth.printCustom("--------------------------------", 1, 1);
      bluetooth.printNewLine();

      // Receipt Info
      bluetooth.printCustom("Invoice #: $receiptNo", 1, 0);
      bluetooth.printCustom("Date     : $date", 1, 0);
      bluetooth.printNewLine();

      // Customer Info
      bluetooth.printCustom("Name        : $customerName", 1, 0);
      bluetooth.printCustom("Customer TRN: $customerTRN", 1, 0);
      bluetooth.printNewLine();

      // Product Info
      bluetooth.printCustom("Product : $product", 1, 0);
      bluetooth.printCustom("Tax     : $tax%", 1, 0);
      bluetooth.printCustom("VAT     : $vat%", 1, 0);
      bluetooth.printNewLine();

      bluetooth.printCustom("Total: AED $totalAmount", 2, 1);
      bluetooth.printNewLine();

      // Footer
      bluetooth.printCustom("--------------------------------", 1, 1);
      bluetooth.printNewLine();
      bluetooth.printCustom("Thank you for your purchase!", 1, 1);
      bluetooth.printCustom("AL-MARWA", 2, 1);
      bluetooth.printCustom("Downtown Dubai, UAE", 1, 1);
      bluetooth.printNewLine();
      bluetooth.printNewLine();

      // Add some delay before cutting
      await Future.delayed(Duration(milliseconds: 500));
      bluetooth.paperCut();

      // Add delay before disconnecting
      await Future.delayed(Duration(milliseconds: 500));
      await bluetooth.disconnect();

      showSnackbar(
        message: "Receipt printed successfully!",
        isError: false,
      );
    } catch (e) {
      log('Print Error: $e');
      showSnackbar(
        message: "Printing failed: $e",
        isError: true,
      );

      // Try to disconnect if there was an error
      try {
        await bluetooth.disconnect();
      } catch (disconnectError) {
        log('Disconnect error: $disconnectError');
      }
    } finally {
      setState(() {
        _isPrinting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final arguments = ModalRoute.of(context)?.settings.arguments;

    if (arguments == null || arguments is! Bill) {
      return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, AppRoutes.homeScreen, (route) => false);
              },
              icon: Icon(Icons.home, color: Colors.white),
            ),
          ],
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back, color: colorScheme.onPrimary),
          ),
          title: Text(
            'Invoice Preview',
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: colorScheme.primary,
        ),
        body: const Center(child: Text('No invoice data provided')),
      );
    }

    final Bill bill = arguments;
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, AppRoutes.homeScreen, (route) => false);
            },
            icon: Icon(Icons.home, color: Colors.white),
          ),
        ],
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: colorScheme.onPrimary),
        ),
        title: Text(
          'Invoice Preview',
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/back.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(AppImages.appLogo, height: 80),
                    Text(
                      bill.date,
                      style: textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _infoRow('SI NO.', bill.siNumber, textTheme),
                _infoRow('CUSTOMER NAME.', bill.customer, textTheme),
                _infoRow('SALES CODE', bill.salesCode, textTheme),
                _infoRow('PRODUCT', bill.product, textTheme),
                _infoRow('QUANTITY', bill.quantity.toString(), textTheme),
                _infoRow(
                  'RATE',
                  'AED ${bill.rate.toStringAsFixed(2)}',
                  textTheme,
                ),
                if (bill.isVAT)
                  _infoRow(
                    'VAT',
                    bill.isCreditBill
                        ? '${bill.vatValue}%'
                        : Provider.of<VatProvider>(context, listen: false)
                            .vatPercentage
                            .toString(),
                    textTheme,
                  ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'GRAND TOTAL: AED ${bill.total.toStringAsFixed(2)}',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Thank you for your purchase',
                  style: textTheme.bodyLarge?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: colorScheme.onSurface.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _infoRow('TRN', bill.trn, textTheme),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'AL-MARWA',
                    style: textTheme.headlineSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    'Downtown Dubai, Dubai UAE',
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                ),

                // Printer selection section
                const SizedBox(height: 24),
                if (_selectedPrinter != null)
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.print, color: Colors.green),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Selected: ${_selectedPrinter!.name}',
                            style: TextStyle(color: Colors.green[800]),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: CustomElevatedButton(
                        onPressed: _selectPrinter,
                        text: 'Select Printer',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomElevatedButton(
                        onPressed: _isPrinting
                            ? () {}
                            : () async {
                                await printReceipt(
                                  customerName: bill.customer,
                                  customerTRN: bill.trn,
                                  receiptNo: bill.siNumber,
                                  date: bill.date,
                                  totalAmount: bill.total.toStringAsFixed(2),
                                  product: bill.product,
                                  tax: bill.vatValue,
                                  vat: bill.vatValue,
                                );
                              },
                        text: _isPrinting ? 'Printing...' : 'Print',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.editBillScreen,
                      arguments: bill,
                    );
                  },
                  text: 'Edit Bill',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
