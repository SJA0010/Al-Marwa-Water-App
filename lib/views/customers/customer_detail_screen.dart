import 'dart:async';
import 'dart:developer';

import 'package:al_marwa_water_app/core/utils/custom_snackbar.dart';
import 'package:al_marwa_water_app/models/customers_model.dart';
import 'package:al_marwa_water_app/routes/app_routes.dart';
import 'package:al_marwa_water_app/viewmodels/bottle_history_controller.dart';
import 'package:al_marwa_water_app/widgets/custom_elevated_button.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomerDetailScreen extends StatefulWidget {
  final CustomerData customer;
  const CustomerDetailScreen({super.key, required this.customer});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  SaleController? saleController;
  int totalBottles = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (saleController == null) {
      saleController = Provider.of<SaleController>(context);
      saleController!.getSalesByCustomerId(widget.customer.id);
    }
  }

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
    required String salesCode,
    required String tradeName,
    required String buildingName,
    required String blockName,
    required String roomName,
    required String bottleGiven,
    required String paidDeposit,
    required String amount,
    required String customerTRN,
  }) async {
    if (!await _connectToPrinter()) {
      setState(() {
        _isPrinting = false;
      });
      return;
    }

    try {
      if (!await _connectToPrinter()) {
        setState(() {
          _isPrinting = false;
        });
        return;
      }

      try {
        // Header
        bluetooth.printNewLine();

        // Header
        bluetooth.printCustom("Al Marwa Water", 4, 1);
        bluetooth.printNewLine();
        bluetooth.printCustom("TRN: $customerTRN", 1, 1);
        bluetooth.printCustom("Phone: +971-12-1234567", 1, 1);
        bluetooth.printNewLine();
        bluetooth.printCustom("--------------------------------", 1, 1);
        bluetooth.printNewLine();

        bluetooth.printCustom("Sales Code #: $salesCode", 1, 0);
        bluetooth.printCustom("Building #    : $buildingName", 1, 0);
        bluetooth.printCustom("Trade Name        : $tradeName", 1, 0);
        bluetooth.printCustom("block #        : $blockName", 1, 0);
        bluetooth.printCustom("room #        : $roomName", 1, 0);
        bluetooth.printCustom("bottle given        : $bottleGiven", 1, 0);
        bluetooth.printCustom("paid deposit        : $paidDeposit ", 1, 0);

        bluetooth.printCustom("amount        : $amount", 1, 0);

        bluetooth.printNewLine();
        // Footer
        bluetooth.printCustom("--------------------------------", 1, 1);
        bluetooth.printNewLine();

        bluetooth.printCustom("Thank you for your purchase!", 1, 1);
        bluetooth.printCustom("AL-MARWA", 2, 1);
        bluetooth.printCustom("Downtown Dubai, UAE", 1, 1);

        bluetooth.printNewLine();
        bluetooth.paperCut();

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
    final color = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    saleController = Provider.of<SaleController>(context);
    final sales = saleController?.allSales ?? [];

    // Compute total bottles safely
    totalBottles = sales.fold(0, (sum, item) {
      final qty = int.tryParse(item.quantity.trim()) ?? 0;
      return sum + qty;
    });

    String extractName(String input) {
      final regex = RegExp(r'name:\s*([^\}]+)');
      final match = regex.firstMatch(input);
      return match != null ? match.group(1)?.trim() ?? '' : '';
    }

    print(widget.customer.paidDeposit);
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.homeScreen,
                (route) => false,
              );
            },
            icon: Icon(Icons.home, color: Colors.white),
          ),
        ],
        backgroundColor: color.primary,
        title: Text(
          'Customer',
          style: textTheme.titleLarge?.copyWith(color: color.onPrimary),
        ),
        centerTitle: true,
        leading: BackButton(color: color.onPrimary),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/back.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sectionTitle("Basic Details", color, textTheme),
                  infoRow(
                    "Customer Code",
                    widget.customer.customerCode,
                    textTheme,
                  ),
                  infoRow(
                    "Type",
                    extractName(widget.customer.customerType),
                    textTheme,
                  ),
                  infoRow(
                    "Customer Pay",
                    extractName(widget.customer.customerPayId),
                    textTheme,
                  ),
                  infoRow("TRN Number", widget.customer.trnNumber, textTheme),
                  const Divider(height: 32),
                  sectionTitle("Personal Details", color, textTheme),
                  infoRow("Person Name", widget.customer.personName, textTheme),
                  infoRow(
                    "Building Name",
                    widget.customer.buildingName,
                    textTheme,
                  ),
                  infoRow("Block No", widget.customer.blockNo, textTheme),
                  infoRow("Room No", widget.customer.roomNo, textTheme),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: contactCard(
                          Icons.call,
                          widget.customer.phone1,
                          color,
                          textTheme,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: contactCard(
                          Icons.call,
                          widget.customer.phone2,
                          color,
                          textTheme,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: contactCard(
                          Icons.call,
                          widget.customer.phone3,
                          color,
                          textTheme,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: contactCard(
                          Icons.call,
                          widget.customer.phone4,
                          color,
                          textTheme,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  sectionTitle("Added Date", color, textTheme),
                  dateCard(widget.customer.date, color, textTheme),
                  const Divider(height: 32),
                  sectionTitle("Delivery Info", color, textTheme),
                  infoRow(
                    "Bottle Delivery Days",
                    widget.customer.deliveryDays,
                    textTheme,
                  ),
                  infoRow(
                    "Paid Deposit",
                    widget.customer.paidDeposit,
                    textTheme,
                  ),
                  infoRow(
                    "Bottle Given",
                    widget.customer.bottleGiven,
                    textTheme,
                  ),
                  infoRow("Price", widget.customer.price, textTheme),
                  infoRow("Total Amount", widget.customer.amount, textTheme),
                  const Divider(height: 32),
                  sectionTitle("More Details", color, textTheme),
                  infoRow("Phone Number", widget.customer.phone3, textTheme),
                  infoRow("Email", widget.customer.email, textTheme),
                  infoRow("Trade Name", widget.customer.tradeName, textTheme),
                  infoRow(
                    "Authorized Person",
                    widget.customer.authPersonName,
                    textTheme,
                  ),
                  const Divider(height: 32),
                  sectionTitle("Order Details", color, textTheme),
                  (saleController?.allSales.isEmpty ?? true)
                      ? Text(
                          "No sales data available",
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.red,
                          ),
                        )
                      : Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Date",
                                  style: textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Bottle Given",
                                  style: textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(
                                top: 10,
                                bottom: 0,
                              ),
                              itemBuilder: (context, index) {
                                final bottleData =
                                    saleController?.allSales[index];

                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${bottleData?.createdAt.toLocal().toIso8601String().split('T').first}",
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: color.primary,
                                      ),
                                    ),
                                    Text(
                                      (bottleData?.quantity != null &&
                                              int.tryParse(
                                                    bottleData!.quantity
                                                        .toString(),
                                                  ) !=
                                                  null &&
                                              int.tryParse(
                                                    bottleData.quantity
                                                        .toString(),
                                                  )! >
                                                  0)
                                          ? "${bottleData.quantity} Bottles"
                                          : "No bottles",
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: color.primary,
                                      ),
                                    ),
                                  ],
                                );
                              },
                              separatorBuilder: (context, index) =>
                                  const Divider(),
                              itemCount: saleController?.allSales.length ?? 0,
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Total",
                                  style: textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "$totalBottles",
                                  style: textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ],
                        ),
                  const SizedBox(height: 35),
                  Row(
                    children: [
                      Flexible(
                        flex: 2,
                        child: CustomElevatedButton(
                          onPressed: _selectPrinter,
                          text: 'Select Printer',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Flexible(
                        flex: 2,
                        child: CustomElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.editCustomersScreen,
                              arguments: widget.customer,
                            );
                          },
                          text: "Edit Details",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  CustomElevatedButton(
                    text: _isPrinting ? 'Printing...' : 'Print',
                    onPressed: _isPrinting
                        ? () {}
                        : () async {
                            print("working");
                            await printReceipt(
                              amount: widget.customer.amount.isNotEmpty
                                  ? widget.customer.amount
                                  : "0",
                              blockName: widget.customer.blockNo.isNotEmpty
                                  ? widget.customer.blockNo
                                  : "N/A",
                              buildingName:
                                  widget.customer.buildingName.isNotEmpty
                                      ? widget.customer.buildingName
                                      : "N/A",
                              bottleGiven:
                                  widget.customer.bottleGiven.isNotEmpty
                                      ? widget.customer.bottleGiven
                                      : "0",
                              customerTRN: widget.customer.trnNumber.isNotEmpty
                                  ? widget.customer.trnNumber
                                  : "N/A",
                              paidDeposit:
                                  widget.customer.paidDeposit.isNotEmpty
                                      ? widget.customer.paidDeposit
                                      : "0",
                              roomName: widget.customer.roomNo.isNotEmpty
                                  ? widget.customer.roomNo
                                  : "N/A",
                              tradeName: widget.customer.tradeName.isNotEmpty
                                  ? widget.customer.tradeName
                                  : "N/A",
                              salesCode: widget.customer.customerCode,
                            );
                          },
                  ),
                  const SizedBox(height: 35),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget sectionTitle(String title, ColorScheme color, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: textTheme.titleMedium?.copyWith(
          color: color.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget infoRow(String label, String value, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 5,
            child: Text(
              overflow: TextOverflow.ellipsis,
              label,
              style: textTheme.bodyMedium?.copyWith(color: Colors.black54),
            ),
          ),
          Spacer(),
          Flexible(
            flex: 6,
            child: Text(
              overflow: TextOverflow.ellipsis,
              value,
              style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget contactCard(
    IconData icon,
    String phone,
    ColorScheme color,
    TextTheme textTheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color.primary),
          const SizedBox(height: 6),
          Text(
            phone,
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget dateCard(String date, ColorScheme color, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: color.primary, size: 20),
          const SizedBox(width: 10),
          Text(
            date,
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
