import 'package:al_marwa_water_app/core/constants/app_images.dart';
import 'package:al_marwa_water_app/models/bills_model.dart';
import 'package:al_marwa_water_app/models/get_credit_bill_model.dart';
import 'package:al_marwa_water_app/routes/app_routes.dart';
import 'package:al_marwa_water_app/viewmodels/credit_bills_controller.dart';
import 'package:al_marwa_water_app/widgets/custom_textform_field.dart';
import 'package:flutter/material.dart';
import 'package:al_marwa_water_app/core/constants/global_variable.dart';
import 'package:provider/provider.dart';

class CreditBillsHistoryScreen extends StatefulWidget {
  const CreditBillsHistoryScreen({super.key});

  @override
  State<CreditBillsHistoryScreen> createState() =>
      _CreditBillsHistoryScreenState();
}

class _CreditBillsHistoryScreenState extends State<CreditBillsHistoryScreen> {
  int? currentPage;
  int? lastPage;
  List<int> pages = [];
  bool isLoading = false;
  bool isFirstLoad = true;

  late List<GetCreditBillItem> _filterBills;
  late CreditBillController billsProvider;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    billsProvider = Provider.of<CreditBillController>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await billsProvider.fetchBillsPage(context);

      setState(() {
        _filterBills = billsProvider.billsPage;
        currentPage = billsProvider.currentPage;
        lastPage = billsProvider.lastPage;
        pages = List.generate(lastPage ?? 1, (index) => index + 1);
        isFirstLoad = false;
      });
    });

    // Optional: filter on typing
    searchController.addListener(() {
      _filterBillsFun(searchController.text);
    });
  }

  void _filterBillsFun(String query) {
    final allBills = billsProvider.billsPage;

    if (query.isEmpty) {
      setState(() {
        _filterBills = allBills;
      });
    } else {
      setState(() {
        _filterBills = allBills
            .where(
              (bill) =>
                  bill.customerName.toLowerCase().contains(
                        query.toLowerCase(),
                      ) ||
                  bill.amount.toString().contains(query.toLowerCase()),
            )
            .toList();
      });
    }
  }

  void _goToPage(int page) async {
    if (page == billsProvider.currentPage || isLoading) return;

    setState(() {
      isLoading = true;
    });

    await billsProvider.fetchBillsPage(context, page: page);

    setState(() {
      _filterBills = billsProvider.billsPage;
      currentPage = billsProvider.currentPage;
      isLoading = false;
    });
  }

  List<int> getVisiblePages(int currentPage, int lastPage) {
    int start = (currentPage - 3).clamp(1, lastPage);
    int end = (currentPage + 3).clamp(1, lastPage);
    return List.generate(end - start + 1, (index) => start + index);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isFirstLoad) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
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
          'Credit Bills History',
          style: textTheme(context).titleLarge?.copyWith(
                color: colorScheme(context).onPrimary,
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
        backgroundColor: colorScheme(context).primary,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.blue[900]))
          : Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/back.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: CustomTextFormField(
                      onChanged: _filterBillsFun,
                      controller: searchController,
                      hint: 'Search by name, email, TRN...',
                      prefixIcon: Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  Expanded(
                    child: _filterBills.isEmpty
                        ? RefreshIndicator(
                            onRefresh: () async {
                              billsProvider = Provider.of<CreditBillController>(
                                context,
                                listen: false,
                              );
                              await billsProvider.fetchBillsPage(context);

                              setState(() {
                                _filterBills = billsProvider.billsPage;
                                currentPage = billsProvider.currentPage;
                                lastPage = billsProvider.lastPage;
                                pages = List.generate(
                                  lastPage ?? 1,
                                  (index) => index + 1,
                                );
                                isFirstLoad = false;
                              });

                              // Optional: filter on typing
                              searchController.addListener(() {
                                _filterBillsFun(searchController.text);
                              });
                            },
                            child: Center(
                              child: ListView(
                                children: [
                                  SizedBox(height: 200),
                                  Icon(
                                    Icons.search_off,
                                    size: 80,
                                    color: colorScheme(context).primary,
                                  ),
                                  const SizedBox(height: 16),
                                  Center(
                                    child: Text(
                                      'No results found',
                                      style: textTheme(context)
                                          .titleMedium
                                          ?.copyWith(
                                            color: colorScheme(context).primary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              billsProvider = Provider.of<CreditBillController>(
                                context,
                                listen: false,
                              );
                              await billsProvider.fetchBillsPage(context);

                              setState(() {
                                _filterBills = billsProvider.billsPage;
                                currentPage = billsProvider.currentPage;
                                lastPage = billsProvider.lastPage;
                                pages = List.generate(
                                  lastPage ?? 1,
                                  (index) => index + 1,
                                );
                                isFirstLoad = false;
                              });

                              // Optional: filter on typing
                              searchController.addListener(() {
                                _filterBillsFun(searchController.text);
                              });
                            },
                            child: ListView.builder(
                              itemCount: _filterBills.length,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              itemBuilder: (context, index) {
                                final bill = _filterBills[index];
                                return InkWell(
                                  onTap: () {
                                    final previewBill = Bill(
                                      customerName: bill.customerName,
                                      productName: bill.productName,
                                      id: bill.id,
                                      salesCode: bill.salesCode,
                                      siNumber: bill.srNo,
                                      date: bill.date,
                                      customer: bill.customerName,
                                      product: bill.productName,
                                      vatValue: bill.vat,
                                      trn: bill.trn,
                                      quantity: bill.quantity,
                                      rate: bill.rate,
                                      isVAT: (bill.vat == "0" ||
                                              bill.vat == "0%" ||
                                              bill.vat.isEmpty)
                                          ? false
                                          : true,
                                      total: bill.amount,
                                      isCreditBill: true,
                                    );

                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.previewScreen,
                                      arguments: previewBill,
                                    );
                                  },
                                  child: Card(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    elevation: 6,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 28,
                                                backgroundColor:
                                                    Colors.grey[300],
                                                child: Image.asset(
                                                  AppImages.appLogo,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  bill.productName,
                                                  style: textTheme(context)
                                                      .bodyLarge
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black87,
                                                      ),
                                                ),
                                              ),
                                              Text(
                                                'AED ${bill.amount}',
                                                style: textTheme(context)
                                                    .titleMedium
                                                    ?.copyWith(
                                                      color: colorScheme(
                                                        context,
                                                      ).primary,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 14),
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF1F5F9),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  bill.id.toString(),
                                                  style: textTheme(context)
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        color: Colors.black87,
                                                      ),
                                                ),
                                                Text(
                                                  bill.trn,
                                                  style: textTheme(context)
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        color: Colors.black87,
                                                      ),
                                                ),
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.date_range,
                                                      size: 18,
                                                      color:
                                                          Colors.purpleAccent,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      bill.date,
                                                      style: textTheme(context)
                                                          .bodyMedium
                                                          ?.copyWith(
                                                            color:
                                                                Colors.black87,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                  _filterBills.isEmpty
                      ? SizedBox.shrink()
                      : Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[900],
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Previous button
                              // currentPage! > 1
                              IconButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                    Colors.white,
                                  ),
                                ),
                                onPressed: currentPage! > 1
                                    ? () => _goToPage(currentPage! - 1)
                                    : null,
                                icon: Icon(
                                  Icons.arrow_back,
                                  color: currentPage! > 1
                                      ? Colors.blue[900]
                                      : Colors.grey[400],
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Page numbers container
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: getVisiblePages(
                                    currentPage!,
                                    lastPage!,
                                  ).map((page) {
                                    final bool isCurrent = page == currentPage;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                          if (!isCurrent) _goToPage(page);
                                        },
                                        child: isCurrent
                                            ? CircleAvatar(
                                                backgroundColor:
                                                    Colors.blue[900],
                                                radius: 12,
                                                child: Text(
                                                  '$page',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              )
                                            : Text(
                                                '$page',
                                                style: TextStyle(
                                                  color: Colors.blue[900],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Next button
                              // currentPage! < lastPage!
                              IconButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                    Colors.white,
                                  ),
                                ),
                                onPressed: currentPage! < lastPage!
                                    ? () => _goToPage(currentPage! + 1)
                                    : null,
                                icon: Icon(
                                  Icons.arrow_forward,
                                  color: currentPage! < lastPage!
                                      ? Colors.blue[900]
                                      : Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ),
                  SizedBox(height: 80),
                ],
              ),
            ),
    );
  }
}
