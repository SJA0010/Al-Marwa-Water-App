import 'package:al_marwa_water_app/core/constants/global_variable.dart';
import 'package:al_marwa_water_app/models/bills_model.dart';
import 'package:al_marwa_water_app/models/customers_model.dart';
import 'package:al_marwa_water_app/models/products_model.dart';
import 'package:al_marwa_water_app/routes/app_routes.dart';
import 'package:al_marwa_water_app/viewmodels/auth_controller.dart';
import 'package:al_marwa_water_app/viewmodels/bills_controller.dart';
import 'package:al_marwa_water_app/viewmodels/customer_controller.dart';
import 'package:al_marwa_water_app/viewmodels/products_controller.dart';
import 'package:al_marwa_water_app/viewmodels/vat_controller.dart';
import 'package:al_marwa_water_app/views/bills/widgets/amount_field_widget.dart';
import 'package:al_marwa_water_app/views/bills/widgets/quantity_rate.dart';
import 'package:al_marwa_water_app/widgets/custom_elevated_button.dart';
import 'package:al_marwa_water_app/widgets/custom_textform_field.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EditBillScreen extends StatefulWidget {
  final Bill bill;
  const EditBillScreen({super.key, required this.bill});

  @override
  State<EditBillScreen> createState() => _EditBillScreenState();
}

class _EditBillScreenState extends State<EditBillScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController trnController = TextEditingController();
  final TextEditingController productController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController vatController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController rateController = TextEditingController();

  bool? isVATChecked;
  double totalAmount = 0.0;
  int? selectedProductId;
  String selectedProduct = '';
  CustomerController? customerController;
  String? selectedCustomerName;
  int? selectedCustomerId;
  ProductsTypeController? productsTypeController;
  CustomerData? selectedCustomer;
  bool _isDataInitialized = false;

  @override
  void initState() {
    super.initState();

    totalAmount = double.tryParse(widget.bill.total) ?? 0.0;

    dateController.text = widget.bill.date;
    dateController.text = widget.bill.date;
    trnController.text = widget.bill.trn;
    selectedCustomerName = widget.bill.customer;
    vatController.text = widget.bill.vatValue;
    selectedProduct = widget.bill.product;
    quantityController.text = widget.bill.quantity;
    rateController.text = widget.bill.rate;
    // isVATChecked = widget.bill.isVAT;
    print(vatController.text);
    if (vatController.text == "0" ||
        vatController.text.isEmpty ||
        vatController.text == "0%") {
      isVATChecked = false;
    } else {
      isVATChecked = true;
    }
    quantityController.addListener(_calculateAmount);
    rateController.addListener(_calculateAmount);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  // ---------- Added Helper Function for Date Parsing ----------
  DateTime parseDate(String dateStr) {
    try {
      return DateFormat('yyyy-MM-dd').parse(dateStr);
    } catch (_) {
      return DateFormat('dd/MM/yyyy').parse(dateStr);
    }
  }
  // -----------------------------------------------------------

  void _initializeData() async {
    customerController =
        Provider.of<CustomerController>(context, listen: false);
    productsTypeController =
        Provider.of<ProductsTypeController>(context, listen: false);

    if (customerController!.customers.isEmpty) {
      await customerController!.fetchCustomers(context);
    }

    if (productsTypeController!.ProductTypes.isEmpty) {
      await productsTypeController!.fetchProductTypes();
    }

    print("Bill customer: ${widget.bill.customer}");
    print("Bill product: ${widget.bill.product}");
    print("Available customers: ${customerController!.customers.length}");
    print("Available products: ${productsTypeController!.ProductTypes.length}");

    final customers = customerController!.customers;
    CustomerData? customerMatch;

    int? customerId = int.tryParse(widget.bill.customer);
    if (customerId != null) {
      customerMatch = customers.firstWhere(
        (c) => c.id == customerId,
        orElse: () => CustomerData(
          id: -1,
          customerCode: '',
          personName: 'N/A',
          date: '',
          customerType: '',
          buildingName: '',
          blockNo: '',
          roomNo: '',
          phone1: '',
          phone2: '',
          deliveryDays: '',
          customerPayId: '',
          bottleGiven: '',
          price: '',
          paidDeposit: '',
          amount: '',
          phone3: '',
          phone4: '',
          email: '',
          tradeName: '',
          trnNumber: '',
          authPersonName: '',
          salePersonId: 0,
          createdAt: '',
          updatedAt: '',
        ),
      );
    }

    if (customerMatch == null || customerMatch.id == -1) {
      for (var customer in customers) {
        if (customer.personName == selectedCustomerName ||
            '${customer.customerCode}. ${customer.personName}' ==
                selectedCustomerName ||
            customer.customerCode == selectedCustomerName ||
            (selectedCustomerName != null &&
                customer.personName.contains(selectedCustomerName!)) ||
            (selectedCustomerName != null &&
                selectedCustomerName!.contains(customer.personName))) {
          customerMatch = customer;
          break;
        }
      }
    }

    if (customerMatch == null || customerMatch.id == -1) {
      customerMatch = customers.firstWhere(
        (c) =>
            selectedCustomerName != null &&
            (c.personName
                    .toLowerCase()
                    .contains(selectedCustomerName!.toLowerCase()) ||
                selectedCustomerName!
                    .toLowerCase()
                    .contains(c.personName.toLowerCase())),
        orElse: () => CustomerData(
          id: -1,
          customerCode: '',
          personName: 'N/A',
          date: '',
          customerType: '',
          buildingName: '',
          blockNo: '',
          roomNo: '',
          phone1: '',
          phone2: '',
          deliveryDays: '',
          customerPayId: '',
          bottleGiven: '',
          price: '',
          paidDeposit: '',
          amount: '',
          phone3: '',
          phone4: '',
          email: '',
          tradeName: '',
          trnNumber: '',
          authPersonName: '',
          salePersonId: 0,
          createdAt: '',
          updatedAt: '',
        ),
      );
    }

    if (customerMatch.id != -1) {
      setState(() {
        selectedCustomer = customerMatch;
        selectedCustomerId = customerMatch!.id;
        selectedCustomerName = customerMatch.personName;
      });

      print(
          "Selected customer: ${selectedCustomer!.personName}, ID: ${selectedCustomer!.id}");
    } else {
      print("Customer not found: $selectedCustomerName");
      if (customers.isNotEmpty) {
        setState(() {
          selectedCustomer = customers.first;
          selectedCustomerId = customers.first.id;
          selectedCustomerName = customers.first.personName;
        });
      }
    }

    final products = productsTypeController!.ProductTypes;
    ProductsModel? productMatch;

    int? productId = int.tryParse(widget.bill.product);
    if (productId != null) {
      productMatch = products.firstWhere(
        (p) => p.id == productId,
        orElse: () => ProductsModel(id: 0, name: '', price: '0'),
      );
    }

    if (productMatch == null || productMatch.id == 0) {
      for (var product in products) {
        if (product.name == selectedProduct) {
          productMatch = product;
          break;
        }
      }
    }

    if (productMatch == null || productMatch.id == 0) {
      productMatch = products.firstWhere(
        (p) =>
            p.name != null &&
            p.name!.toLowerCase().contains(selectedProduct.toLowerCase()),
        orElse: () => ProductsModel(id: 0, name: '', price: '0'),
      );
    }

    if (productMatch.id != null && productMatch.id! > 0) {
      setState(() {
        selectedProductId = productMatch!.id;
        selectedProduct = productMatch.name!;
      });

      print("Selected product: $selectedProduct, ID: $selectedProductId");
    } else {
      print("Product not found: $selectedProduct");
      if (products.isNotEmpty) {
        setState(() {
          selectedProductId = products.first.id;
          selectedProduct = products.first.name!;
        });
      }
    }

    await Provider.of<VatProvider>(context, listen: false).fetchVatPercentage();
    _calculateAmount();

    setState(() {
      _isDataInitialized = true;
    });
  }

  void _calculateAmount() {
    final quantity = double.tryParse(quantityController.text) ?? 0.0;
    final rate = double.tryParse(rateController.text) ?? 0.0;

    final vat = Provider.of<VatProvider>(context, listen: false).vatPercentage;

    double amount = quantity * rate;

    setState(() {
      if (isVATChecked == true) {
        amount += amount * (vat / 100);
      }
      totalAmount = amount;
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final productsTypeController = Provider.of<ProductsTypeController>(context);
    final customerController = Provider.of<CustomerController>(context);
    print(widget.bill);
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
          widget.bill.isCreditBill ? 'Edit credit Bill' : 'Edit Bill',
          style: textTheme(context).titleLarge?.copyWith(
                color: colorScheme(context).onPrimary,
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
        backgroundColor: colorScheme(context).primary,
      ),
      body: !_isDataInitialized
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Container(
                height: height,
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
                              Text(
                                "id : ${widget.bill.id}",
                                style: textTheme(context).titleMedium?.copyWith(
                                      color: colorScheme(context).onPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 12),
                              _buildDateField(context),
                              const SizedBox(height: 12),
                              _buildCustomerDropdown(customerController),
                              const SizedBox(height: 12),
                              _buildProductDropdown(productsTypeController),
                              const SizedBox(height: 12),
                              CustomTextFormField(
                                controller: trnController,
                                fillColor: Colors.white,
                                hint: 'TRN',
                                filled: true,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Checkbox(
                                    value: isVATChecked,
                                    onChanged: (val) {
                                      final vatProvider =
                                          Provider.of<VatProvider>(
                                        context,
                                        listen: false,
                                      );

                                      setState(() {
                                        isVATChecked = val!;
                                        _calculateAmount();

                                        if (isVATChecked!) {
                                          vatController.text =
                                              "${vatProvider.vatPercentage}";
                                        } else {
                                          vatController.clear();
                                        }
                                      });
                                    },
                                  ),
                                  const Text(
                                    'VAT',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(width: 10),
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
                      CustomElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final controller = Provider.of<BillController>(
                              context,
                              listen: false,
                            );
                            final provider = Provider.of<AuthController>(
                              context,
                              listen: false,
                            );

                            DateTime selectedDate =
                                parseDate(dateController.text);

                            dateController.text =
                                selectedDate.toIso8601String().split('T').first;
                            final updatedData = {
                              "date": dateController.text,
                              "customer_id": "${selectedCustomerId ?? 0}",
                              "product_id": "${selectedProductId ?? 1}",
                              "sale_user_id": provider.userId.toString(),
                              "trn": trnController.text,
                              "vat": isVATChecked == true
                                  ? "${Provider.of<VatProvider>(context, listen: false).vatPercentage}"
                                  : "0",
                              "quantity": quantityController.text,
                              "rate": rateController.text,
                              "amount": totalAmount.toStringAsFixed(2),
                            };

                            await controller.updateBill(
                              isCredit: widget.bill.isCreditBill,
                              billId: widget.bill.id ?? 0,
                              updatedData: updatedData,
                              token: "${provider.userId}",
                              context: context,
                            );
                          }
                        },
                        text: 'Update Bill',
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildCustomerDropdown(CustomerController customerController) {
    final allCustomers = customerController.customers;

    return DropdownSearch<CustomerData>(
      validator: (CustomerData? customer) {
        if (customer == null) {
          return 'Please select a customer';
        }
        return null;
      },
      selectedItem: selectedCustomer,
      itemAsString: (CustomerData? customer) {
        if (customer == null) return '';
        return customer.personName == "N/A"
            ? customer.customerCode
            : '${customer.customerCode}. ${customer.buildingName} - ${customer.personName} ${customer.roomNo}- ${customer.blockNo}';
      },
      asyncItems: (String filter) async {
        return allCustomers.where((customer) {
          final lowerFilter = filter.toLowerCase();
          return customer.customerCode.toLowerCase().contains(lowerFilter) ||
              customer.personName.toLowerCase().contains(lowerFilter) ||
              customer.buildingName.toLowerCase().contains(lowerFilter) ||
              customer.roomNo.toLowerCase().contains(lowerFilter) ||
              customer.blockNo.toLowerCase().contains(lowerFilter);
        }).toList();
      },
      onChanged: (CustomerData? newCustomer) {
        if (newCustomer != null) {
          setState(() {
            print("object   ${newCustomer}");
            selectedCustomer = newCustomer;
            selectedCustomerId = newCustomer.id;
            selectedCustomerName = newCustomer.personName;
            rateController.text = newCustomer.price;
            trnController.text = newCustomer.trnNumber;
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
      ),
      popupProps: PopupProps.menu(
        constraints: BoxConstraints(
          maxHeight: allCustomers.length == 1
              ? 200
              : allCustomers.length <= 5
                  ? allCustomers.length * 60.0
                  : 500,
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
  }

  Widget _buildProductDropdown(ProductsTypeController productsTypeController) {
    final productNames =
        productsTypeController.ProductTypeNames.toSet().toList();

    return DropdownButtonFormField<String>(
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'Please select a product';
        }
        return null;
      },
      value:
          selectedProduct.isNotEmpty && productNames.contains(selectedProduct)
              ? selectedProduct
              : null,
      style: TextStyle(
        color: Colors.black,
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
        'Select Product',
        style: TextStyle(
          color: Colors.grey[700],
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
      items: productNames
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: (String? value) {
        if (value != null) {
          setState(() {
            selectedProduct = value;
            final selected = productsTypeController.ProductTypes.firstWhere(
              (e) => e.name == selectedProduct,
              orElse: () => ProductsModel(price: '0'),
            );
            selectedProductId = selected.id ?? 0;
          });
        }
      },
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
