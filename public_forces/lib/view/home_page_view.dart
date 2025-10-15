import 'package:flutter/material.dart';
import 'package:public_forces/config/responsive_layout.dart';
import 'package:public_forces/pages/mobile_home_page.dart';
import 'package:public_forces/pages/web_home_page.dart';

class HomePageView extends StatelessWidget {
  const HomePageView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(mobile: MobileHomePage(), web: WebHomePage());
  }
}