import 'package:al_marwa_water_app/models/bills_model.dart';
import 'package:al_marwa_water_app/models/customers_model.dart';
import 'package:al_marwa_water_app/routes/fade_page_transition.dart';
import 'package:al_marwa_water_app/views/auth/login_screen.dart';
import 'package:al_marwa_water_app/views/bills/bill_history.dart';
import 'package:al_marwa_water_app/views/bills/bottle_history_screen.dart';
import 'package:al_marwa_water_app/views/bills/credit_bills_history_screen.dart';
import 'package:al_marwa_water_app/views/bills/bills_screen.dart';
import 'package:al_marwa_water_app/views/bills/credit_bills_screen.dart';
import 'package:al_marwa_water_app/views/bills/edit_bill_screen.dart';
import 'package:al_marwa_water_app/views/bills/preview_screen.dart';
import 'package:al_marwa_water_app/views/customers/customer_detail_screen.dart';
import 'package:al_marwa_water_app/views/customers/customers_screen.dart';
import 'package:al_marwa_water_app/views/customers/edit_customer_screen.dart';
import 'package:al_marwa_water_app/views/home/home_screen.dart';
import 'package:al_marwa_water_app/views/splash/splash_screen.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String splahScreen = '/splash-screen';
  static const String test = '/test-screen';
  static const String loginScreen = '/login-screen';
  static const String homeScreen = '/home-screen';
  static const String billsScreen = '/bills-screen';
  static const String creditBillsScreen = '/credit-bills-screen';
  static const String creditBillsHistoryScreen = '/credit-bills-history-screen';
  static const String BillsHistoryScreen = '/bills-history-screen';
  static const String customersScreen = '/customers-screen';
  static const String customerDetailScreen = '/customer-detail-screen';
  static const String bottomNavScreen = '/bottom-nav-screen';
  static const String previewScreen = '/preview-screen';
  static const String editBillScreen = '/edit-bill-screen';
  static const String editCustomersScreen = '/edit-customers-screen';
  static const String bottleHistoryScreen = '/bottle-history-screen';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splahScreen:
        return FadePageRoute(page: SplashScreen(), settings: settings);

      case loginScreen:
        return FadePageRoute(page: LoginScreen(), settings: settings);

      case homeScreen:
        return FadePageRoute(page: HomeScreen(), settings: settings);

      case billsScreen:
        return FadePageRoute(page: BillsScreen(), settings: settings);

      case creditBillsScreen:
        return FadePageRoute(page: CreditBillsScreen(), settings: settings);

      case creditBillsHistoryScreen:
        return FadePageRoute(
          page: CreditBillsHistoryScreen(),
          settings: settings,
        );

      // case test:
      //   return FadePageRoute(
      //     page: Example(),
      //     settings: settings,
      //   );

      case BillsHistoryScreen:
        return FadePageRoute(page: BillHistoryScreen(), settings: settings);

      case previewScreen:
        return FadePageRoute(page: PreviewScreen(), settings: settings);

      case customerDetailScreen:
        final customer = settings.arguments as CustomerData;
        return FadePageRoute(
          page: CustomerDetailScreen(customer: customer),
          settings: settings,
        );

      case customersScreen:
        return FadePageRoute(page: CustomersScreen(), settings: settings);

      case bottleHistoryScreen:
        return FadePageRoute(page: BottleHistoryScreen(), settings: settings);

      case editCustomersScreen:
        final customer = settings.arguments as CustomerData;
        return FadePageRoute(
          page: EditCustomerScreen(customer: customer),
          settings: settings,
        );

      case editBillScreen:
        final bill = settings.arguments as Bill;
        print("dataaalihassan037${bill}");
        return FadePageRoute(
          page: EditBillScreen(bill: bill),
          settings: settings,
        );

      default:
        return FadePageRoute(page: SplashScreen(), settings: settings);
    }
  }
}
