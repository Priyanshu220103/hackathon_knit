import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:public_forces/pages/feedback_page.dart';
import 'dashboard_page.dart';
import 'anomaly_page.dart';
import 'prediction_page.dart';
import 'report_page.dart';
import 'cost_overrun_page.dart';

class WebHomePage extends StatefulWidget {
  const WebHomePage({super.key});

  @override
  State<WebHomePage> createState() => _WebHomePageState();
}

class _WebHomePageState extends State<WebHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        toolbarHeight: 50,
        title: const Text(
          'Public Forces Analytics',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          indicatorColor: Theme.of(context).colorScheme.primary,
          labelColor: Colors.white,
          unselectedLabelColor: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
          tabAlignment: TabAlignment.fill,
          labelStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          tabs: [
            Tab(
              icon: Icon(
                Icons.dashboard, 
                size: 18,
                color: _selectedIndex == 0 ? Colors.white : Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
              ),
              text: 'Dashboard',
            ),
            Tab(
              icon: Icon(
                Icons.warning, 
                size: 18,
                color: _selectedIndex == 1 ? Colors.white : Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
              ),
              text: 'Anomaly',
            ),
            Tab(
              icon: Icon(
                Icons.trending_up, 
                size: 18,
                color: _selectedIndex == 2 ? Colors.white : Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
              ),
              text: 'Cost Over run',
            ),
            Tab(
              icon: Icon(
                Icons.analytics, 
                size: 18,
                color: _selectedIndex == 3 ? Colors.white : Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
              ),
              text: 'Prediction',
            ),
            Tab(
              icon: Icon(
                Icons.feedback, 
                size: 18,
                color: _selectedIndex == 4 ? Colors.white : Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
              ),
              text: 'FeedBack',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          const DashboardPage(),
          const AnomalyPage(),
          const CostOverRunPage(),
          const PredictionPage(),
          const FeedbackPage(),
        ],
      ),
    );
  }

  Widget _buildComingSoonPage(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '$title - Coming Soon',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This feature is under development',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
