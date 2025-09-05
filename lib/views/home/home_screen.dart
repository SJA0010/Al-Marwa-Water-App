import 'package:al_marwa_water_app/core/constants/app_colors.dart';
import 'package:al_marwa_water_app/core/constants/global_variable.dart';
import 'package:al_marwa_water_app/routes/app_routes.dart';
import 'package:al_marwa_water_app/viewmodels/auth_controller.dart';
import 'package:al_marwa_water_app/viewmodels/bills_controller.dart';
import 'package:al_marwa_water_app/viewmodels/credit_bills_controller.dart';
import 'package:al_marwa_water_app/viewmodels/customer_controller.dart';
import 'package:al_marwa_water_app/viewmodels/issue_bottle_controller.dart';
import 'package:al_marwa_water_app/views/bills/bills_screen.dart';
import 'package:al_marwa_water_app/views/bills/credit_bills_screen.dart';
import 'package:al_marwa_water_app/views/bills/issues_bottles_screen.dart';
import 'package:al_marwa_water_app/views/coming_soon_screen.dart';
import 'package:al_marwa_water_app/views/customers/customers_screen.dart';
import 'package:al_marwa_water_app/views/customers/new_customer_screen.dart';
import 'package:al_marwa_water_app/views/home/widgets/logout_dailogue.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> menuItems = [
    {
      'icon': Icons.receipt_long,
      'label': 'Bill',
      'color': Colors.teal,
      'screen': BillsScreen(),
    },
    {
      'icon': Icons.receipt_outlined,
      'label': 'Credit Bills',
      'color': Colors.red,
      'screen': CreditBillsScreen(),
    },
    {
      'icon': Icons.confirmation_number,
      'label': 'Coupon',
      'color': Colors.purple,
      'screen': ComingSoonPage(),
    },
    {
      'icon': Icons.people_outline,
      'label': 'Customers',
      'color': Colors.cyan,
      'screen': CustomersScreen(),
    },
    {
      'icon': Icons.person_add_alt,
      'label': 'New Customers',
      'color': Colors.green,
      'screen': NewCustomerScreen(),
    },
    {
      'icon': Icons.local_drink_outlined,
      'label': 'Issue Bottle',
      'color': Colors.deepPurple,
      'screen': IssuesBottlesScreen(),
    },
    {
      'icon': Icons.local_shipping,
      'label': 'Add Extra Bottle',
      'color': Colors.indigo,
      'screen': ComingSoonPage(),
    },
    {
      'icon': Icons.widgets_outlined,
      'label': 'More Options',
      'color': Colors.amber,
      'screen': ComingSoonPage(),
    },
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor:
          Colors.blue[900], // Set the navigation bar color
      systemNavigationBarIconBrightness: Brightness.light, // Or Brightness.dark
    ));
    _checkAndSyncOfflineOrders();
  }

  void _checkAndSyncOfflineOrders() async {
    final controller = Provider.of<BottleController>(context, listen: false);
    final billController = Provider.of<BillController>(context, listen: false);
    final createController =
        Provider.of<CustomerController>(context, listen: false);
    final billCreditController =
        Provider.of<CreditBillController>(context, listen: false);

    if (await controller.hasInternet()) {
      if (mounted) await controller.syncPendingBottleOrders(context);
      if (mounted) await billController.syncPendingBills(context);
      if (mounted) await billCreditController.syncPendingCreditBills(context);
      if (mounted) await createController.syncPendingCustomers(context);
      print("🔁 Calling sync from Home");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        // title: Text(
        //   'Home',
        //   style: textTheme(context).titleLarge?.copyWith(
        //         color: colorScheme(context).onSurface,
        //         fontWeight: FontWeight.bold,
        //       ),
        // ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => LogoutConfirmationDialog(
                  onConfirm: () {
                    Navigator.pushReplacementNamed(
                        context, AppRoutes.loginScreen);
                    final authController =
                        Provider.of<AuthController>(context, listen: false);
                    authController.logout(context);
                  },
                ),
              );
            },
            icon: Icon(
              Icons.logout_rounded,
              color: colorScheme(context).onSurface,
            ),
          ),
        ],
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _checkAndSyncOfflineOrders();
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/back.jpg"),
                  fit: BoxFit.cover),
            ),
            child: Container(
              child: Column(
                children: [
                  SizedBox(height: 130),
                  // _controller.value.isInitialized
                  //     ? AspectRatio(
                  //         aspectRatio: _controller.value.aspectRatio,
                  //         child: ClipRRect(
                  //           borderRadius: BorderRadius.circular(16),
                  //           child: VideoPlayer(_controller),
                  //         ),
                  //       )
                  //     : const Center(child: CircularProgressIndicator()),
                  Text(
                    textAlign: TextAlign.center,
                    'Welcome to\nAl Marwa',
                    style: GoogleFonts.medievalSharp(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkblue),
                  ),
                  SizedBox(height: 30),
                  // Text(
                  //   textAlign: TextAlign.center,
                  //   "Welcome To\nAl Marwa Water",
                  //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  // ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.all(0),
                    itemCount: menuItems.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) {
                      final item = menuItems[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          boxShadow: [
                            BoxShadow(
                              color: item['color'].withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            // _controller.pause();
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => item['screen']),
                            );
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(item['icon'],
                                  size: 40, color: item['color']),
                              const SizedBox(height: 8),
                              Text(
                                item['label'],
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
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
}
