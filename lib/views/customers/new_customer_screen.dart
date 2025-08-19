import 'package:al_marwa_water_app/core/utils/custom_snackbar.dart';
import 'package:al_marwa_water_app/models/customer_type_model.dart';
import 'package:al_marwa_water_app/models/pay_type.dart';
import 'package:al_marwa_water_app/routes/app_routes.dart';
import 'package:al_marwa_water_app/viewmodels/auth_controller.dart';
import 'package:al_marwa_water_app/viewmodels/customer_controller.dart';
import 'package:al_marwa_water_app/viewmodels/customer_type_controller.dart';
import 'package:al_marwa_water_app/viewmodels/image_controller.dart';
import 'package:al_marwa_water_app/viewmodels/pay_type_controller.dart';
import 'package:al_marwa_water_app/viewmodels/save_number_controller.dart';
import 'package:al_marwa_water_app/widgets/custom_elevated_button.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';

class NewCustomerScreen extends StatefulWidget {
  const NewCustomerScreen({super.key});

  @override
  State<NewCustomerScreen> createState() => _NewCustomerScreenState();
}

class _NewCustomerScreenState extends State<NewCustomerScreen> {
  final GlobalKey<FormState> _formKey1 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey2 = GlobalKey<FormState>();

  final TextEditingController customerCodeController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController newdateController = TextEditingController();
  final TextEditingController createCustomerController =
      TextEditingController();
  final TextEditingController buildingController = TextEditingController();
  final TextEditingController blockController = TextEditingController();
  final TextEditingController roomController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController mobile1Controller = TextEditingController();
  final TextEditingController mobile2Controller = TextEditingController();
  final TextEditingController bottleController = TextEditingController();
  final TextEditingController depositAmountController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController mobile3Controller = TextEditingController();
  final TextEditingController mobile4Controller = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController tradeNameController = TextEditingController();
  final TextEditingController trnNumberController = TextEditingController();
  final TextEditingController authPersonNameController =
      TextEditingController();
  String _depositPaid = 'No';
  String? selectedCustomerType;
  int? selectedCustomerId;
  PayType? selectedPayType;
  int? selectedPayTypeId;
  CustomerTypeModel? selectedCustomerTypeModel;
  String? selectedDeliveryDay;
  String? paymentType;
  String customerCode = '';
  final List<String> customerTypes = [];
  final List<String> deliveryDays = ['Daily', 'Alternate', 'Weekly'];

  PayTypeController? payTypeController;
  CustomersTypeController? customerTypeController;

  bool? isCoupon; // Change to false to disable the button
  final TextEditingController _remarksController = TextEditingController();

  final BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  Future<void> printReceipt({
    required int salesCode,
    required String tradeName,
    required String buildingName,
    required String blockName,
    required String roomName,
    required String bottleGiven,
    required String paidDeposit,
    required String amount,
    required String customerTRN,
  }) async {
    try {
      List<BluetoothDevice> devices = await bluetooth.getBondedDevices();
      if (devices.isEmpty) {
        print("No paired devices.");
        showSnackbar(
          message: "No paired devices found.",
          isError: true,
        );
        return;
      }

      BluetoothDevice printer = devices.first;
      await bluetooth.connect(printer);

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
      bluetooth.disconnect();
    } catch (e) {}
  }

  void _showRemarksDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter Remarks'),
        content: TextField(
          controller: _remarksController,
          decoration: InputDecoration(hintText: 'Type your remarks here...'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              print("Remarks: ${_remarksController.text}");
              _remarksController.clear(); // Optionally clear after submit
            },
            child: Text('Submit'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    createCustomerController.text = DateFormat(
      'dd/MM/yyyy',
    ).format(
      DateTime.now(),
    );

    dateController.text = DateFormat('dd/MM/yyyy').format(
      DateTime.now(),
    );
    // customerCode = generateCustomerCode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // This will only run once
    if (payTypeController == null) {
      payTypeController = Provider.of<PayTypeController>(context);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        payTypeController!.fetchPayTypes();
      });
    }
    if (customerTypeController == null) {
      customerTypeController = Provider.of<CustomersTypeController>(context);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        customerTypeController!.fetchcustomersTypes();
      });
    }
  }

  int _currentIndex = 0;
  String? contactName;
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final customerController = Provider.of<CustomerController>(
      context,
      listen: false,
    );
    final authController = Provider.of<AuthController>(context, listen: false);
    final payTypeController = Provider.of<PayTypeController>(context);
    final contactController = Provider.of<GoogleContactProvider>(context);
    final imageController = Provider.of<CustomerImageController>(context);

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
          'New Customer',
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
      ),
      body: SingleChildScrollView(
        child: Container(
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
                _currentIndex == 0
                    ? Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 2,
                            color: colorScheme.primary,
                          ),
                          color: colorScheme.primary.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Form(
                          key: _formKey1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    flex: 2,
                                    child: Text(
                                      "Date :",
                                      style: textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Flexible(
                                    flex: 3,
                                    child: _buildDateField(context),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),
                              _buildLabel('Customer Type', textTheme),
                              SizedBox(height: 5),
                              // _buildDropdown(
                              //   hint: 'Select ',
                              //   value: selectedCustomerType,
                              //   items:
                              //       customerTypeController.customersTypeNames,
                              //   onChanged: (value) {
                              //     setState(() => selectedCustomerType = value);
                              //   },
                              // ),
                              Consumer<CustomersTypeController>(
                                builder: (context, CustomersTypeController, _) {
                                  final customers =
                                      CustomersTypeController.customersTypes;

                                  return DropdownButtonFormField<
                                      CustomerTypeModel>(
                                    style: TextStyle(
                                      color: Colors
                                          .black, // selected item text color
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
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          width: 2,
                                        ),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    hint: Text(
                                      "Select Customer Type",
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    isExpanded: true,
                                    value: selectedCustomerTypeModel != null &&
                                            customers.contains(
                                                selectedCustomerTypeModel)
                                        ? selectedCustomerTypeModel
                                        : null,
                                    items: customers.map((customer) {
                                      return DropdownMenuItem<
                                          CustomerTypeModel>(
                                        value: customer,
                                        child: Text(customer.name ?? 'Unknown'),
                                      );
                                    }).toList(),
                                    onChanged: (CustomerTypeModel? newValue) {
                                      setState(() {
                                        selectedCustomerTypeModel = newValue;
                                        selectedCustomerId = newValue?.id;

                                        print(
                                            "✅ Selected Customer ID: $selectedCustomerId");
                                      });
                                    },
                                  );
                                },
                              ),

                              const SizedBox(height: 16),
                              _buildLabel('Building Name', textTheme),
                              SizedBox(height: 5),
                              _buildTextField(
                                'Enter Customer building Name',
                                controller: buildingController,
                                labelText: 'Building Name',
                                keyboardType: TextInputType.text,
                              ),
                              SizedBox(height: 10),
                              _buildLabelRow('Block No', 'Room No', textTheme),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: _buildTextField(
                                      nullable: true,
                                      'Enter block no.',
                                      controller: blockController,
                                      labelText: 'Block Number',
                                      keyboardType: TextInputType.text,
                                    ),
                                  ),
                                  SizedBox(width: 20),
                                  Expanded(
                                    flex: 2,
                                    child: _buildTextField(
                                      'Enter room no.',
                                      controller: roomController,
                                      labelText: 'Room Number',
                                      keyboardType: TextInputType.text,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 10),
                              _buildLabel('Mobile No', textTheme),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: _buildTextField(
                                      'Enter number',
                                      controller: mobile1Controller,
                                      keyboardType: TextInputType.phone,
                                      labelText: 'Phone Number',
                                    ),
                                  ),
                                  SizedBox(width: 20),
                                  Expanded(
                                    flex: 2,
                                    child: _buildTextField(
                                      nullable: true,
                                      'Enter number',
                                      controller: mobile2Controller,
                                      keyboardType: TextInputType.phone,
                                      labelText: 'Phone Number',
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    flex: 2,
                                    child: _buildLabel(
                                      'Delivery Days :',
                                      textTheme,
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Flexible(
                                    flex: 3,
                                    child: _buildDropdown(
                                      hint: 'Select',
                                      value: selectedDeliveryDay,
                                      items: deliveryDays,
                                      onChanged: (value) {
                                        setState(
                                          () => selectedDeliveryDay = value,
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              payTypeController.payTypeNames.isNotEmpty
                                  ? _buildLabel('Customer Pay', textTheme)
                                  : SizedBox(),
                              SizedBox(height: 10),
                              payTypeController.payTypeNames.isNotEmpty
                                  ? Row(
                                      children: [
                                        Flexible(
                                          flex: 2,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: payTypeController.payTypes
                                                .map((payType) {
                                              return Expanded(
                                                child: GestureDetector(
                                                  onTap: () => setState(() {
                                                    selectedPayType = payType;
                                                    selectedPayTypeId =
                                                        payType.id;
                                                    if (selectedPayType ==
                                                        "Coupon") {
                                                      isCoupon = true;
                                                    } else {
                                                      isCoupon = false;
                                                    }
                                                    print(
                                                        "✅ Selected Payment Type ID: $selectedPayTypeId");
                                                  }),
                                                  child: Wrap(
                                                    crossAxisAlignment:
                                                        WrapCrossAlignment
                                                            .center,
                                                    children: [
                                                      Radio<PayType>(
                                                        value: payType,
                                                        groupValue:
                                                            selectedPayType,
                                                        onChanged:
                                                            (PayType? value) {
                                                          setState(() {
                                                            selectedPayType =
                                                                value!;
                                                            selectedPayTypeId =
                                                                value.id;
                                                            if (value.name ==
                                                                "Coupon") {
                                                              isCoupon = true;
                                                            } else {
                                                              isCoupon = false;
                                                            }
                                                            print(
                                                                "✅ Selected Payment Type ID: $selectedPayTypeId");
                                                            print(
                                                                "✅ Selected Payment Type Name: ${selectedPayType!.name}");
                                                          });
                                                        },
                                                        materialTapTargetSize:
                                                            MaterialTapTargetSize
                                                                .shrinkWrap,
                                                        visualDensity:
                                                            VisualDensity
                                                                .compact,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        payType.name ??
                                                            'Unknown',
                                                        style: textTheme
                                                            .bodyMedium,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                        Flexible(
                                            flex: 1,
                                            child: CustomElevatedButton(
                                              text: "Btn",
                                              buttonColor: isCoupon == true
                                                  ? colorScheme.primary
                                                  : Colors.grey.shade300,
                                              borderColor: isCoupon == true
                                                  ? colorScheme.primary
                                                  : Colors.grey.shade400,
                                              textStyle: TextStyle(
                                                color: isCoupon == true
                                                    ? Colors.white
                                                    : Colors.grey[700],
                                                fontSize: 14,
                                                fontWeight: FontWeight.w800,
                                              ),
                                              onPressed: isCoupon == true
                                                  ? () {
                                                      _showRemarksDialog();
                                                      // Implement your coupon logic here
                                                      print(
                                                          "Coupon button pressed");
                                                    }
                                                  : () {},
                                            ))
                                      ],
                                    )
                                  : const CircularProgressIndicator(),
                              const SizedBox(height: 16),
                              _buildLabelRow(
                                  'Bottle Given', 'Price', textTheme),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: _buildTextField(
                                      'Enter',
                                      controller: bottleController,
                                      keyboardType: TextInputType.number,
                                      labelText: 'Bottle Given',
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    flex: 1,
                                    child: _buildTextField(
                                      '0.0 AED',
                                      controller: priceController,
                                      keyboardType: TextInputType.number,
                                      labelText: 'Price',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Paid Deposit',
                                      style: textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 20),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      'Amount',
                                      style: textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),

                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Row(
                                      children: [
                                        Radio<String>(
                                          value: 'Yes',
                                          groupValue: _depositPaid,
                                          onChanged: (value) {
                                            setState(() {
                                              _depositPaid = value!;
                                            });
                                          },
                                        ),
                                        const Text('Yes'),
                                        Radio<String>(
                                          value: 'No',
                                          groupValue: _depositPaid,
                                          onChanged: (value) {
                                            setState(() {
                                              _depositPaid = value!;
                                              amountController.clear();
                                            });
                                          },
                                        ),
                                        const Text('No'),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    flex: 1,
                                    child: _buildTextField(
                                      'AED',
                                      controller: amountController,
                                      labelText: 'Amount',
                                      keyboardType: TextInputType.number,
                                      enabled: _depositPaid == 'Yes',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildLabel('Location', textTheme),
                              SizedBox(height: 5),
                              _buildTextField(
                                'Location',
                                controller: locationController,
                                labelText: 'Location',
                                keyboardType: TextInputType.text,
                              ),
                              const SizedBox(height: 16),
                              CustomElevatedButton(
                                buttonColor: colorScheme.surface,
                                borderColor: colorScheme.secondary,
                                textStyle: TextStyle(
                                  color: colorScheme.secondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                                text: imageController.selectedImage != null
                                    ? "Image Selected"
                                    : "Pick Image",
                                onPressed: () async {
                                  // Just pick the image and store it in provider
                                  final file =
                                      await ImagePickerHelper.pickImage(
                                          context);
                                  if (file != null) {
                                    imageController.setSelectedImage(
                                        file); // Store for later upload
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 2,
                            color: colorScheme.primary,
                          ),
                          color: colorScheme.primary.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Form(
                          key: _formKey2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 40),
                              Text(
                                "Authorized Person Name",
                                style: textTheme.titleSmall?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              _buildTextField(
                                nullable: false,
                                'Enter Authorized Person Name',
                                labelText: 'Authorized Person Name',
                                controller: authPersonNameController,
                                keyboardType: TextInputType.text,
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Phone Number 3",
                                          style: textTheme.titleSmall?.copyWith(
                                            color: colorScheme.onSurface,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        _buildTextField(
                                          nullable: true,
                                          'Enter Phone Number 3',
                                          labelText: 'Phone Number 3',
                                          controller: mobile3Controller,
                                          keyboardType: TextInputType.phone,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Phone Number 4",
                                          style: textTheme.titleSmall?.copyWith(
                                            color: colorScheme.onSurface,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        _buildTextField(
                                          nullable: true,
                                          'Enter Phone Number 4',
                                          labelText: 'Phone Number 4',
                                          controller: mobile4Controller,
                                          keyboardType: TextInputType.phone,
                                        ),
                                        // const SizedBox(height: 16),
                                        // CustomElevatedButton(
                                        //   buttonColor: colorScheme.surface,
                                        //   borderColor: colorScheme.secondary,
                                        //   textStyle: TextStyle(
                                        //     color: colorScheme.secondary,
                                        //     fontSize: 14,
                                        //     fontWeight: FontWeight.w800,
                                        //   ),
                                        //   text: imageController.selectedImage !=
                                        //           null
                                        //       ? "Pick Image"
                                        //       : "Pick Image",
                                        //   onPressed: () async {
                                        //     // Just pick the image and store it in provider
                                        //     final file = await ImagePickerHelper
                                        //         .pickImage(context);
                                        //     if (file != null) {
                                        //       imageController.setSelectedImage(
                                        //           file); // Store for later upload
                                        //     }
                                        //   },
                                        // ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Email",
                                style: textTheme.titleSmall?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              _buildTextField(
                                nullable: true,
                                'Enter Email',
                                labelText: 'Email',
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "TRN Number",
                                style: textTheme.titleSmall?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              _buildTextField(
                                nullable: true,
                                'Enter TRN Number',
                                labelText: 'TRN Number',
                                controller: trnNumberController,
                                keyboardType: TextInputType.text,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Trade Name",
                                style: textTheme.titleSmall?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              _buildTextField(
                                nullable: true,
                                'Enter Trade Name',
                                labelText: 'Trade Name',
                                controller: tradeNameController,
                                keyboardType: TextInputType.text,
                              ),
                              const SizedBox(height: 15),
                            ],
                          ),
                        ),
                      ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _currentIndex == 1
                        ? Expanded(
                            child: CustomElevatedButton(
                              text: "Save ",
                              onPressed: () async {
                                context.loaderOverlay.show();
                                if (_formKey2.currentState!.validate()) {
                                  DateTime selectedDate = DateFormat(
                                    'dd/MM/yyyy',
                                  ).parse(dateController.text);

                                  // Convert to ISO string and split
                                  newdateController.text = selectedDate
                                      .toIso8601String()
                                      .split('T')
                                      .first;

                                  print(
                                      "✅ Final ISO Date: ${newdateController.text}");

                                  final customerData = {
                                    "date": newdateController.text,
                                    "customer_type": "$selectedCustomerId",
                                    "building_name": buildingController.text,
                                    "block_no": blockController.text,
                                    "room_no": roomController.text,
                                    "phone1": mobile1Controller.text,
                                    "phone2": mobile2Controller.text,
                                    "delivery_days": selectedDeliveryDay,
                                    "customer_pay_id": "$selectedPayTypeId",
                                    "bottle_given": bottleController.text,
                                    "price": priceController.text,
                                    "paid_deposit": _depositPaid,
                                    "amount": amountController.text.isNotEmpty
                                        ? amountController.text
                                        : "0",
                                    "person_name":
                                        authPersonNameController.text,
                                    "phone3": mobile3Controller.text,
                                    "phone4": mobile4Controller.text,
                                    "email": emailController.text,
                                    "trade_name": tradeNameController.text,
                                    "trn_number": trnNumberController.text,
                                    "auth_person_name":
                                        authPersonNameController.text,
                                    "sale_person_id": authController.userId,
                                  };
                                  await customerController.createCustomer(
                                    customerData,
                                    context,
                                  );
                                  if (imageController.selectedImage != null &&
                                      customerController.customerCreateID !=
                                          null) {
                                    await imageController.uploadImage(
                                      customerId:
                                          customerController.customerCreateID!,
                                      imageFile: imageController.selectedImage!,
                                      context: context,
                                    );
                                  } else {
                                    showSnackbar(
                                        message: "No image selected",
                                        isError: true);
                                  }
                                  contactName =
                                      "${buildingController.text} ${blockController.text} ${roomController.text}";

                                  // Save Google contact

                                  contactController.createGoogleContact(
                                    name: contactName ?? "conatact",
                                    phoneNumber: mobile1Controller.text,
                                    context: context,
                                  );
                                  customerCodeController.clear();

                                  buildingController.clear();
                                  blockController.clear();
                                  roomController.clear();
                                  amountController.clear();
                                  priceController.clear();
                                  mobile1Controller.clear();
                                  mobile2Controller.clear();
                                  bottleController.clear();
                                  depositAmountController.clear();
                                  locationController.clear();
                                  mobile3Controller.clear();
                                  mobile4Controller.clear();

                                  emailController.clear();
                                  tradeNameController.clear();
                                  trnNumberController.clear();
                                  authPersonNameController.clear();
                                } else {
                                  showSnackbar(
                                    message: "Please fill all required fields",
                                    isError: true,
                                  );
                                }
                                // saveContact();
                                context.loaderOverlay.hide();
                              },
                            ),
                          )
                        : Expanded(
                            child: CustomElevatedButton(
                              text: "Save",
                              onPressed: () async {
                                context.loaderOverlay.show();
                                if (_formKey1.currentState!.validate()) {
                                  DateTime selectedDate = DateFormat(
                                    'dd/MM/yyyy',
                                  ).parse(dateController.text);

                                  // Convert to ISO string and split
                                  newdateController.text = selectedDate
                                      .toIso8601String()
                                      .split('T')
                                      .first;

                                  print(
                                      "✅ Final ISO Date: ${newdateController.text}");
                                  final customerData = {
                                    "date": newdateController.text,
                                    "customer_type": "$selectedCustomerId",

                                    // "$selectedCustomerId" ?? "",
                                    "building_name":
                                        buildingController.text.isNotEmpty
                                            ? buildingController.text
                                            : "N/A",
                                    "block_no": blockController.text.isNotEmpty
                                        ? blockController.text
                                        : "N/A",
                                    "room_no": roomController.text.isNotEmpty
                                        ? roomController.text
                                        : "N/A",
                                    "phone1": mobile1Controller.text.isNotEmpty
                                        ? mobile1Controller.text
                                        : "N/A",
                                    "phone2": mobile2Controller.text.isNotEmpty
                                        ? mobile2Controller.text
                                        : "N/A",
                                    "delivery_days":
                                        selectedDeliveryDay?.isNotEmpty == true
                                            ? selectedDeliveryDay
                                            : "N/A",
                                    "customer_pay_id": "$selectedPayTypeId",
                                    "bottle_given":
                                        bottleController.text.isNotEmpty
                                            ? bottleController.text
                                            : "0",
                                    "price": priceController.text.isNotEmpty
                                        ? priceController.text
                                        : "0",
                                    "paid_deposit": _depositPaid,
                                    "amount": amountController.text.isNotEmpty
                                        ? amountController.text
                                        : "0",
                                    "person_name":
                                        authPersonNameController.text.isNotEmpty
                                            ? authPersonNameController.text
                                            : "N/A",
                                    "phone3": mobile3Controller.text.isNotEmpty
                                        ? mobile3Controller.text
                                        : "N/A",
                                    "phone4": mobile4Controller.text.isNotEmpty
                                        ? mobile4Controller.text
                                        : "N/A",
                                    "email": emailController.text.isNotEmpty
                                        ? emailController.text
                                        : "N/A",
                                    "trade_name":
                                        tradeNameController.text.isNotEmpty
                                            ? tradeNameController.text
                                            : "N/A",
                                    "trn_number":
                                        trnNumberController.text.isNotEmpty
                                            ? trnNumberController.text
                                            : "N/A",
                                    "auth_person_name":
                                        authPersonNameController.text.isNotEmpty
                                            ? authPersonNameController.text
                                            : "N/A",
                                    "sale_person_id":
                                        authController.userId ?? "",
                                  };
                                  await customerController.createCustomer(
                                    customerData,
                                    context,
                                  );
                                  if (imageController.selectedImage != null &&
                                      customerController.customerCreateID !=
                                          null) {
                                    await imageController.uploadImage(
                                      customerId:
                                          customerController.customerCreateID!,
                                      imageFile: imageController.selectedImage!,
                                      context: context,
                                    );
                                  } else {
                                    showSnackbar(
                                        message: "No image selected",
                                        isError: true);
                                  }
                                  contactName =
                                      "${buildingController.text} ${blockController.text} ${roomController.text}";

                                  // Save Google contact

                                  contactController.createGoogleContact(
                                    name: contactName ?? "conatact",
                                    phoneNumber: mobile1Controller.text,
                                    context: context,
                                  );

                                  customerCodeController.clear();

                                  buildingController.clear();
                                  blockController.clear();
                                  roomController.clear();
                                  amountController.clear();
                                  priceController.clear();
                                  mobile1Controller.clear();
                                  mobile2Controller.clear();
                                  bottleController.clear();
                                  depositAmountController.clear();
                                  locationController.clear();
                                  mobile3Controller.clear();
                                  mobile4Controller.clear();
                                  emailController.clear();
                                  tradeNameController.clear();
                                  trnNumberController.clear();
                                  authPersonNameController.clear();
                                } else {
                                  showSnackbar(
                                    message: "Please fill all required fields",
                                    isError: true,
                                  );
                                }

                                context.loaderOverlay.hide();
                              },
                            ),
                          ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomElevatedButton(
                        buttonColor: colorScheme.error,
                        text: "Cancel",
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomElevatedButton(
                        text: "Print",
                        onPressed: () async {
                          print("working");
                          await printReceipt(
                            amount: amountController.text.isNotEmpty
                                ? amountController.text
                                : "0",
                            blockName: blockController.text.isNotEmpty
                                ? blockController.text
                                : "N/A",
                            buildingName: buildingController.text.isNotEmpty
                                ? buildingController.text
                                : "N/A",
                            bottleGiven: bottleController.text.isNotEmpty
                                ? bottleController.text
                                : "0",
                            customerTRN: trnNumberController.text.isNotEmpty
                                ? trnNumberController.text
                                : "N/A",
                            paidDeposit: _depositPaid,
                            roomName: roomController.text.isNotEmpty
                                ? roomController.text
                                : "N/A",
                            tradeName: tradeNameController.text.isNotEmpty
                                ? tradeNameController.text
                                : "N/A",
                            salesCode: authController.userId ?? 0,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    _currentIndex == 0
                        ? Expanded(
                            child: CustomElevatedButton(
                              text: "Next",
                              onPressed: () {
                                if (_formKey1.currentState!.validate()) {
                                  if (selectedPayTypeId == null) {
                                    showSnackbar(
                                      message: "Please select a payment type",
                                      isError: true,
                                    );
                                  } else {
                                    setState(() {
                                      _currentIndex++;
                                    });
                                  }
                                } else {
                                  showSnackbar(
                                    message: "Please fill all required fields",
                                    isError: true,
                                  );
                                }
                              },
                            ),
                          )
                        : Expanded(
                            child: CustomElevatedButton(
                              text: "Previous",
                              onPressed: () {
                                setState(() {
                                  _currentIndex--;
                                });
                              },
                            ),
                          ),
                  ],
                ),
                const SizedBox(height: 10),

                // CustomElevatedButton(
                //   text: "save",
                //   onPressed: () {
                //     contactController.createGoogleContact(
                //       name: "new contacvts 11",
                //       phoneNumber: "+92331736433 ",
                //       context: context,
                //     );
                //   },
                // ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, TextTheme textTheme) {
    return Text(
      text,
      style: textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 13,
      ),
    );
  }

  Widget _buildLabelRow(String left, String right, TextTheme textTheme) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            left,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
        SizedBox(width: 20),
        Expanded(
          flex: 2,
          child: Text(
            right,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String hint, {
    TextEditingController? controller,
    bool enabled = true,
    bool nullable = false,
    String? labelText,
    required TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      autovalidateMode: AutovalidateMode.disabled,
      keyboardType: keyboardType,
      validator: enabled && nullable == false
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }

              // Email validation only if keyboardType is email
              if (keyboardType == TextInputType.emailAddress) {
                final emailRegex = RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                );
                if (!emailRegex.hasMatch(value)) {
                  return 'Please enter a valid email';
                }
              }

              return null;
            }
          : null,
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        hintText: labelText ?? hint,
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
    );
  }

  Widget _buildDateField(BuildContext context) {
    if (createCustomerController.text.isEmpty) {
      createCustomerController.text = DateFormat(
        'dd/MM/yyyy',
      ).format(
        DateTime.now(),
      );
    }

    return SizedBox(
      child: TextFormField(
        controller: createCustomerController,
        readOnly: true,
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
            createCustomerController.text = DateFormat(
              'dd/MM/yyyy',
            ).format(pickedDate);
          }
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
      style: TextStyle(
        color: Colors.black, // selected item text color
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
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
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(item),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: (val) {
        if (val == null || val.isEmpty) {
          return 'Please select $hint';
        }
        return null;
      },
    );
  }
}
