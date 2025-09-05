import 'dart:developer';

import 'package:al_marwa_water_app/core/constants/constants.dart';
import 'package:al_marwa_water_app/core/utils/validation.dart';
import 'package:al_marwa_water_app/models/customers_model.dart';
import 'package:al_marwa_water_app/models/products_model.dart';
import 'package:al_marwa_water_app/viewmodels/auth_controller.dart';
import 'package:al_marwa_water_app/viewmodels/credit_bills_controller.dart';
import 'package:al_marwa_water_app/viewmodels/customer_controller.dart';
import 'package:al_marwa_water_app/viewmodels/products_controller.dart';
import 'package:al_marwa_water_app/viewmodels/vat_controller.dart';
import 'package:al_marwa_water_app/views/bills/widgets/amount_field_widget.dart';
import 'package:al_marwa_water_app/views/bills/widgets/quantity_rate.dart';
import 'package:al_marwa_water_app/widgets/custom_textform_field.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:al_marwa_water_app/core/constants/global_variable.dart';
import 'package:al_marwa_water_app/core/utils/custom_snackbar.dart';
import 'package:al_marwa_water_app/models/bills_model.dart';
import 'package:al_marwa_water_app/routes/app_routes.dart';
import 'package:al_marwa_water_app/widgets/custom_elevated_button.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CreditBillsScreen extends StatefulWidget {
  const CreditBillsScreen({super.key});
  @override
  State<CreditBillsScreen> createState() => _CreditBillsScreenState();
}

class _CreditBillsScreenState extends State<CreditBillsScreen> {
  late String salesCode;
  CustomerData? selectedCustomer;
  late String siNumber;
  String selectedProduct = '';
  final TextEditingController dateController = TextEditingController();
  final TextEditingController newdateController = TextEditingController();
  final TextEditingController trnController = TextEditingController();
  final TextEditingController tradeNameController = TextEditingController();
  final TextEditingController AuthNameController = TextEditingController();
  final TextEditingController buildingController = TextEditingController();
  final TextEditingController blockController = TextEditingController();
  final TextEditingController roomController = TextEditingController();
  final TextEditingController productController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController vatController = TextEditingController();

  final TextEditingController quantityController = TextEditingController(
    text: '0',
  );
  final TextEditingController rateController = TextEditingController(text: '0');
  bool isVATChecked = true;
  double totalAmount = 0.0;
  int? selectedProductId;
  ProductsTypeController? productsTypeController;
  CustomerController? customerController;
  String? selectedCustomerName;
  int? selectedCustomerId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // This will only run once
    if (productsTypeController == null) {
      productsTypeController = Provider.of<ProductsTypeController>(context);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        productsTypeController!.fetchProductTypes();
      });
    }
    if (customerController == null) {
      customerController = Provider.of<CustomerController>(context);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        customerController!.fetchCustomers(context);
      });
    }
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    isVATChecked = true;
    quantityController.addListener(_calculateAmount);
    rateController.addListener(_calculateAmount);
    vatController.addListener(_calculateAmount);
  }

  bool isPreview = false;
  Bill? savedBill;

  void _calculateAmount() {
    final quantity = double.tryParse(quantityController.text) ?? 0.0;
    final rate = double.tryParse(rateController.text) ?? 0.0;

    final vat = Provider.of<VatProvider>(context, listen: false).vatPercentage;

    double amount = quantity * rate;

    setState(() {
      if (isVATChecked == true) {
        amount += amount * (vat / 100); // Apply VAT as a percentage
      }
      totalAmount = amount;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context, listen: false);
    final productsTypeController = Provider.of<ProductsTypeController>(context);
    final vatProvider = Provider.of<VatProvider>(context, listen: false);
    print("${productsTypeController.ProductTypeNames}");
    Theme.of(context);

    final controller = Provider.of<CreditBillController>(
      context,
    );
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
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: colorScheme(context).onPrimary),
        ),
        title: Text(
          'New Credit Bill',
          style: textTheme(context).titleLarge?.copyWith(
                color: colorScheme(context).onPrimary,
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
        backgroundColor: colorScheme(context).primary,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // This will only run once

          productsTypeController.fetchProductTypes();

          customerController = Provider.of<CustomerController>(
            context,
            listen: false,
          );

          customerController!.fetchCustomers(context);
          vatProvider.fetchVatPercentage();
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height - 50,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/back.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 2,
                        color: colorScheme(context).primary,
                      ),
                      color: colorScheme(context).primary.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          _buildDateField(context),
                          const SizedBox(height: 12),
                          Consumer<CustomerController>(
                            builder: (context, customerController, _) {
                              final allCustomers = customerController.customers;

                              return DropdownSearch<CustomerData>(
                                validator: (CustomerData? customer) {
                                  if (customer == null) {
                                    return 'Please select a customer';
                                  }
                                  return null;
                                },
                                key: ValueKey(allCustomers.length),
                                selectedItem: selectedCustomer,
                                itemAsString: (CustomerData? customer) {
                                  if (customer == null) return '';
                                  return customer.personName == "N/A"
                                      ? customer.customerCode
                                      : '${customer.customerCode}. ${customer.buildingName} - ${customer.personName} ${customer.roomNo}- ${customer.blockNo}';
                                },
                                asyncItems: (String filter) async {
                                  // ✅ Perform live filtering on all 5 fields
                                  return allCustomers.where((customer) {
                                    final lowerFilter = filter.toLowerCase();

                                    return customer.customerCode
                                            .toLowerCase()
                                            .contains(lowerFilter) ||
                                        customer.personName
                                            .toLowerCase()
                                            .contains(lowerFilter) ||
                                        customer.buildingName
                                            .toLowerCase()
                                            .contains(lowerFilter) ||
                                        customer.roomNo
                                            .toLowerCase()
                                            .contains(lowerFilter) ||
                                        customer.blockNo
                                            .toLowerCase()
                                            .contains(lowerFilter);
                                  }).toList();
                                },
                                onChanged: (CustomerData? newCustomer) {
                                  if (newCustomer != null) {
                                    setState(() {
                                      selectedCustomer = newCustomer;
                                      selectedCustomerId = newCustomer.id;
                                      rateController.text =
                                          newCustomer.price == 'N/A'
                                              ? ''
                                              : newCustomer.price;
                                      trnController.text =
                                          newCustomer.trnNumber == 'N/A'
                                              ? ''
                                              : newCustomer.trnNumber;
                                      buildingController.text =
                                          newCustomer.buildingName == 'N/A'
                                              ? ''
                                              : newCustomer.buildingName;
                                      blockController.text =
                                          newCustomer.blockNo == 'N/A'
                                              ? ''
                                              : newCustomer.blockNo;
                                      roomController.text =
                                          newCustomer.roomNo == 'N/A'
                                              ? ''
                                              : newCustomer.roomNo;
                                      tradeNameController.text =
                                          newCustomer.tradeName == 'N/A'
                                              ? ''
                                              : newCustomer.tradeName;
                                      AuthNameController.text =
                                          newCustomer.authPersonName == 'N/A'
                                              ? ''
                                              : newCustomer.authPersonName;

                                      log(
                                        "✅ Selected: ${newCustomer.id} | ${newCustomer.personName} | ${newCustomer.price}| ${newCustomer.trnNumber} | ${newCustomer.buildingName} | ${newCustomer.authPersonName}| ${newCustomer.tradeName} | ${newCustomer.roomNo} | ${newCustomer.blockNo}",
                                      );
                                    });
                                  }
                                },
                                dropdownDecoratorProps: DropDownDecoratorProps(
                                  dropdownSearchDecoration: InputDecoration(
                                    hintText: "Select Customer",
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.all(12),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        width: 2,
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                ),
                                popupProps: PopupProps.menu(
                                  constraints: BoxConstraints(
                                    maxHeight: allCustomers.length == 1
                                        ? 200
                                        : allCustomers.length <= 5
                                            ? allCustomers.length *
                                                60.0 // ≈ height per item
                                            : 500, // max height
                                  ),
                                  showSearchBox: true,
                                  searchFieldProps: TextFieldProps(
                                    decoration: InputDecoration(
                                      hintText: "Type to search...",
                                      contentPadding: const EdgeInsets.all(12),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                  itemBuilder: (context, item, isSelected) {
                                    final displayText = item.personName == "N/A"
                                        ? item.customerCode
                                        : '${item.customerCode}. ${item.personName}';
                                    return ListTile(
                                      title: Text(displayText),
                                      selected: isSelected,
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildDropdown(
                            hint: 'Select Product',
                            value: productsTypeController.ProductTypeNames
                                    .contains(selectedProduct)
                                ? selectedProduct
                                : null,
                            items:
                                productsTypeController.ProductTypeNames.toSet()
                                    .toList(), // ✅ ensures unique items
                            onChanged: (value) {
                              setState(() {
                                selectedProduct = value!;

                                final selected = productsTypeController
                                    .ProductTypes.firstWhere(
                                  (e) => e.name == selectedProduct,
                                  orElse: () => ProductsModel(price: '0'),
                                );
                                // rateController.text = selected.price ?? '0';
                                selectedProductId = selected.id ?? 0;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          CustomTextFormField(
                            controller: trnController,
                            fillColor: Colors.white,
                            hint: 'TRN',
                            filled: true,
                            validator: (value) =>
                                Validation.fieldValidation(value, "TRN"),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: isVATChecked,
                                onChanged: (val) {
                                  final vatProvider = Provider.of<VatProvider>(
                                    context,
                                    listen: false,
                                  );

                                  setState(() {
                                    isVATChecked = val!;
                                    _calculateAmount();

                                    if (isVATChecked) {
                                      vatController.text =
                                          "${vatProvider.vatPercentage}";
                                    } else {
                                      vatController
                                          .clear(); // Optional: clear VAT when unchecked
                                    }
                                  });
                                },
                              ),

                              const Text(
                                'VAT',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              SizedBox(width: 10),
                              // if (isVATChecked)
                              //   Expanded(
                              //     child: CustomTextFormField(
                              //       controller: vatController,
                              //       borderColor: colorScheme(context).primary,
                              //       hint: 'Vat',
                              //       keyboardType: TextInputType.number,
                              //       filled: true,
                              //       validator: (value) =>
                              //           Validation.fieldValidation(value, "VAT"),
                              //     ),
                              //   ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          QuantityRateRow(
                            quantityController: quantityController,
                            rateController: rateController,
                          ),
                          const SizedBox(height: 16),
                          AmountFieldWidget(amount: totalAmount),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: CustomElevatedButton(
                          text: "Save",
                          buttonColor: colorScheme(context).secondary,
                          onPressed: () async {
                            if (_formKey.currentState!.validate() &&
                                selectedProductId != null) {
                              DateTime selectedDate = DateFormat(
                                'dd/MM/yyyy',
                              ).parse(dateController.text);

                              // Convert to ISO string and split
                              newdateController.text = selectedDate
                                  .toIso8601String()
                                  .split('T')
                                  .first;

                              print(
                                "✅ Final ISO Date: ${newdateController.text}",
                              );
                              final billData = {
                                'date': newdateController.text,
                                'customer_id': selectedCustomerId,
                                'product_id': selectedProductId,
                                'trn': trnController.text,
                                'vat': isVATChecked == true
                                    ? "${vatProvider.vatPercentage}%"
                                    : "0%",
                                'quantity': quantityController.text,
                                'rate': rateController.text,
                                'amount': "$totalAmount",
                                'sale_user_id': "${authController.userId}",
                              };

                              await controller.createCreditBill(
                                context,
                                billData,
                              );

                              StaticData().currentBill = Bill(
                                id: controller.id,
                                customerName:
                                    selectedCustomer?.personName ?? "",
                                productName: selectedProduct,
                                trn: trnController.text,
                                vatValue: isVATChecked
                                    ? "${vatProvider.vatPercentage}"
                                    : "0",
                                quantity: quantityController.text,
                                salesCode: controller.salesCode ?? '',
                                siNumber: controller.salesCode ?? '',
                                date: dateController.text,
                                customer: selectedCustomer?.personName ?? '',
                                product: "$selectedProductId",
                                isCreditBill: true,
                                rate: rateController.text,
                                isVAT: isVATChecked,
                                total: "$totalAmount",
                              );
                              // Clear form fields
                              dateController.clear();
                              trnController.clear();
                              quantityController.clear();
                              rateController.clear();
                              vatController.clear();
                              selectedCustomer = null;
                              selectedProductId = null;
                              selectedProduct = '';
                              setState(() {
                                isPreview = true;
                              });
                            } else {
                              showSnackbar(
                                message: "Please fill all fields correctly!",
                                isError: true,
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomElevatedButton(
                          text: "Preview",
                          buttonColor: isPreview
                              ? colorScheme(context).surface
                              : Colors.grey.shade300,
                          borderColor: isPreview
                              ? colorScheme(context).secondary
                              : Colors.grey.shade400,
                          textStyle: TextStyle(
                            color: isPreview
                                ? colorScheme(context).secondary
                                : Colors.grey[700],
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                          onPressed: isPreview
                              ? () {
                                  final current = StaticData().currentBill;
                                  if (current != null) {
                                    savedBill = Bill(
                                      id: controller.id,
                                      salesCode: controller.salesCode ?? '',
                                      siNumber: controller.salesCode ?? '',
                                      date: current.date,
                                      customer: current.customer,
                                      product: current.product,
                                      customerName: current.customerName,
                                      productName: current.productName,
                                      trn: current.trn,
                                      isCreditBill: current.isCreditBill,
                                      vatValue: current.vatValue,
                                      quantity: current.quantity,
                                      rate: current.rate,
                                      isVAT: current.isVAT,
                                      total: current.total,
                                    );
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.previewScreen,
                                      arguments: savedBill,
                                    );
                                    print("-----------------$savedBill}");
                                  } else {
                                    showSnackbar(
                                      message: "No bill data found!",
                                      isError: true,
                                    );
                                  }
                                }
                              : () {
                                  showSnackbar(
                                    message: "Please save the bill first!",
                                    isError: true,
                                  );
                                },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  CustomElevatedButton(
                    text: "Show history",
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.creditBillsHistoryScreen,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    if (dateController.text.isEmpty) {
      dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    }
    return SizedBox(
      child: TextFormField(
        controller: dateController,
        readOnly: true,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          suffixIcon: Icon(
            Icons.calendar_today,
            color: Theme.of(context).colorScheme.primary,
          ),
          fillColor: Colors.white,
          filled: true,
          hintText: 'Select Date',
          hintStyle: TextStyle(
            color: Colors.grey[700],
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          contentPadding: const EdgeInsets.all(12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 1,
            ),
          ),
        ),
        onTap: () async {
          final pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2100),
          );
          if (pickedDate != null) {
            dateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a date';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'Please select a product';
        }
        return null;
      },
      style: TextStyle(
        color: Colors.black, // selected item text color
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        contentPadding: const EdgeInsets.all(12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 1,
          ),
        ),
      ),
      hint: Text(
        hint,
        style: TextStyle(
          color: Colors.grey[700],
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
      value: value,
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
    );
  }
}
