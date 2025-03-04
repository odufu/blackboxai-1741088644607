import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/stand_list_screen.dart';
import 'screens/stand_details_screen.dart';
import 'screens/ar_navigation_screen.dart';
import 'screens/admin/admin_login_screen.dart';
import 'screens/admin/admin_home_screen.dart';
import 'screens/admin/stand_allocation_screen.dart';

void main() {
  runApp(const AfricanHousingShow());
}

class AfricanHousingShow extends StatelessWidget {
  const AfricanHousingShow({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'African Housing Show',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/stands': (context) => const StandListScreen(),
        '/stand-details': (context) => const StandDetailsScreen(),
        '/ar-navigation': (context) => const ARNavigationScreen(),
        '/admin-login': (context) => const AdminLoginScreen(),
        '/admin-home': (context) => const AdminHomeScreen(),
        '/stand-allocation': (context) => const StandAllocationScreen(),
      },
    );
  }
}
