import 'package:al_marwa_water_app/core/constants/global_variable.dart';
import 'package:al_marwa_water_app/core/theme/app_theme.dart';
import 'package:al_marwa_water_app/routes/app_routes.dart';
import 'package:al_marwa_water_app/viewmodels/auth_controller.dart';
import 'package:al_marwa_water_app/viewmodels/bills_controller.dart';
import 'package:al_marwa_water_app/viewmodels/bottle_history_controller.dart';
import 'package:al_marwa_water_app/viewmodels/bottom_nav_provider.dart';
import 'package:al_marwa_water_app/viewmodels/credit_bills_controller.dart';
import 'package:al_marwa_water_app/viewmodels/customer_controller.dart';
import 'package:al_marwa_water_app/viewmodels/customer_type_controller.dart';
import 'package:al_marwa_water_app/viewmodels/image_controller.dart';
import 'package:al_marwa_water_app/viewmodels/issue_bottle_controller.dart';
import 'package:al_marwa_water_app/viewmodels/password_visibility_provider.dart';
import 'package:al_marwa_water_app/viewmodels/pay_type_controller.dart';
import 'package:al_marwa_water_app/viewmodels/products_controller.dart';
import 'package:al_marwa_water_app/viewmodels/vat_controller.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PasswordVisibilityProvider()),
        ChangeNotifierProvider(create: (_) => BottomNavProvider()),
        ChangeNotifierProvider(create: (_) => CustomerController()),
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => BottleController()),
        ChangeNotifierProvider(create: (_) => BillController()),
        ChangeNotifierProvider(create: (_) => PayTypeController()),
        ChangeNotifierProvider(create: (_) => CustomersTypeController()),
        ChangeNotifierProvider(create: (_) => ProductsTypeController()),
        ChangeNotifierProvider(create: (_) => CreditBillController()),
        ChangeNotifierProvider(create: (_) => SaleController()),
        ChangeNotifierProvider(create: (_) => VatProvider()),
        ChangeNotifierProvider(create: (_) => CustomerImageController()),
      ],
      child: GlobalLoaderOverlay(
        child: MaterialApp(
          title: 'Al Marwa Water',
          debugShowCheckedModeBanner: false,
          scaffoldMessengerKey: scaffoldMessengerKey,
          theme: AppTheme.instance.lightTheme,
          initialRoute: AppRoutes.splahScreen,
          onGenerateRoute: AppRoutes.generateRoute,
        ),
      ),
    );
  }
}
