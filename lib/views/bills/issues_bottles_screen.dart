import 'dart:developer';

import 'package:al_marwa_water_app/core/constants/global_variable.dart';
import 'package:al_marwa_water_app/core/utils/custom_snackbar.dart';
import 'package:al_marwa_water_app/core/utils/validation.dart';
import 'package:al_marwa_water_app/models/customers_model.dart';
import 'package:al_marwa_water_app/routes/app_routes.dart';
import 'package:al_marwa_water_app/viewmodels/auth_controller.dart';
import 'package:al_marwa_water_app/viewmodels/customer_controller.dart';
import 'package:al_marwa_water_app/viewmodels/issue_bottle_controller.dart';
import 'package:al_marwa_water_app/widgets/custom_elevated_button.dart';
import 'package:al_marwa_water_app/widgets/custom_textform_field.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';

class IssuesBottlesScreen extends StatefulWidget {
  const IssuesBottlesScreen({super.key});

  @override
  State<IssuesBottlesScreen> createState() => _IssuesBottlesScreenState();
}

class _IssuesBottlesScreenState extends State<IssuesBottlesScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController newdateController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _buildingNameController = TextEditingController();
  final TextEditingController _blockController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();

  CustomerController? customerController;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (customerController == null) {
      customerController = Provider.of<CustomerController>(context);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        customerController!.fetchCustomers(context);
      });
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _buildingNameController.dispose();
    _blockController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  CustomerData? selectedCustomer;
  String? selectedCustomerName;
  int? selectedCustomerId;

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: false,
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
          'Issue Bottles',
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
          customerController = Provider.of<CustomerController>(context);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            customerController!.fetchCustomers(context);
          });
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height - 100,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/back.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 30,
                  ),
                  child: Container(
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
                        children: [
                          SizedBox(height: 50),
                          _buildDateField(context),
                          const SizedBox(height: 16),
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
                                  // Hide customerCode in the selected item display
                                  if (selectedCustomer != null &&
                                      customer.id == selectedCustomer!.id) {
                                    // Only show name, building, room, block (no code)
                                    return customer.personName == "N/A"
                                        ? ''
                                        : '${customer.buildingName} - ${customer.personName} ${customer.roomNo}- ${customer.blockNo}';
                                  }
                                  // For dropdown search, show code for clarity
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
                                      _buildingNameController.text =
                                          newCustomer.buildingName == "N/A"
                                              ? ""
                                              : newCustomer.buildingName;
                                      _blockController.text =
                                          newCustomer.blockNo == "N/A"
                                              ? ""
                                              : newCustomer.blockNo;
                                      _roomController.text =
                                          newCustomer.roomNo == "N/A"
                                              ? ""
                                              : newCustomer.roomNo;

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
                                    // Always show code in dropdown list
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
                          const SizedBox(height: 16),
                          CustomTextFormField(
                            controller: _quantityController,
                            hint: 'Quantity',
                            keyboardType: TextInputType.number,
                            filled: true,
                            validator: (value) =>
                                Validation.fieldValidation(value, "Quantity"),
                          ),
                          const SizedBox(height: 16),
                          CustomTextFormField(
                            controller: _buildingNameController,
                            hint: 'Building Name',
                            keyboardType: TextInputType.text,
                            filled: true,
                            validator: (value) => Validation.fieldValidation(
                              value,
                              "Building Name",
                            ),
                          ),
                          const SizedBox(height: 16),
                          CustomTextFormField(
                            controller: _blockController,
                            hint: 'Block',
                            keyboardType: TextInputType.text,
                            filled: true,
                            validator: (value) =>
                                Validation.fieldValidation(value, "Block"),
                          ),
                          const SizedBox(height: 16),
                          CustomTextFormField(
                            controller: _roomController,
                            hint: 'Room',
                            keyboardType: TextInputType.text,
                            filled: true,
                            validator: (value) =>
                                Validation.fieldValidation(value, "Room"),
                          ),
                          const SizedBox(height: 32),
                          CustomElevatedButton(
                            text: "Submit",
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                context.loaderOverlay.show();

                                if (selectedCustomerId != null) {
                                  DateTime selectedDate = DateFormat(
                                    'dd/MM/yyyy',
                                  ).parse(dateController.text);

                                  // Convert to ISO string and split
                                  newdateController.text = selectedDate
                                      .toIso8601String()
                                      .split('T')
                                      .first;

                                  Provider.of<BottleController>(
                                    context,
                                    listen: false,
                                  ).issueBottle(
                                    context,
                                    date: newdateController.text,
                                    customerId: selectedCustomerId!,
                                    quantity: _quantityController.text,
                                    buildingName: _buildingNameController.text,
                                    block: _blockController.text,
                                    room: _roomController.text,
                                    saleUserId: "${authController.userId}",
                                  );

                                  _quantityController.clear();
                                  _buildingNameController.clear();
                                  _blockController.clear();
                                  _roomController.clear();
                                  selectedCustomer = null;
                                } else {
                                  showSnackbar(
                                    message: "Please select a customer.",
                                    isError: true,
                                  );
                                }

                                context.loaderOverlay.hide();
                              } else {
                                showSnackbar(
                                  message: "Please fill in all fields.",
                                  isError: true,
                                );
                              }
                            },
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CustomElevatedButton(
                    text: "Bottle History",
                    onPressed: () {
                      Navigator.pushNamed(
                          context, AppRoutes.bottleHistoryScreen);
                    },
                  ),
                ),
                SizedBox(height: 50),
              ],
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
}
