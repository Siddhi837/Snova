import 'package:flutter/material.dart';
import 'package:snova/screens/authentication/forgot_password_screen.dart';
import 'package:snova/screens/authentication/login_screen.dart';
import 'package:snova/screens/cart/add_to_cart_screen.dart';
import 'package:snova/screens/order/order_screen.dart';
import 'package:snova/screens/home/profile_screen.dart';
import 'package:snova/screens/utils/my_preference.dart';

import 'home_screen.dart';

class HomePageActivity extends StatefulWidget {
  const HomePageActivity({super.key});

  @override
  State<HomePageActivity> createState() => _HomePageActivityState();
}

class _HomePageActivityState extends State<HomePageActivity> {

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: _bottomNavBar(),
        body:_getBody()
    );
  }

  Widget _getBody() {
    switch (selectedIndex) {
      case 0:
        return HomeScreen();
      case 1:
        return AddToCartScreen();
      case 2:
        return OrderScreen();
      case 3:
        return ProfileScreen();
      default:
        return HomeScreen();
    }
  }

  //BOTTOM NAV
  Widget _bottomNavBar() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(27),
        child: Container(
          padding: EdgeInsets.fromLTRB(0,3,0,0),
          decoration: BoxDecoration(
            color: Colors.black,
          ),
          child:  BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            currentIndex: selectedIndex,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey.shade500,
            onTap: (index) async {
              if (index == 4) {
                await MyPreference.clearLogin();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                      (route) => false,
                );
              } else {
                setState(() {
                  selectedIndex = index;
                });
              }
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "My Cart"),
              BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: "Orders"),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
              BottomNavigationBarItem(icon: Icon(Icons.logout), label: "Logout"),
            ],
          ),
        ),
      ),
    );
  }
}
