import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'pages/login/login_page.dart';
import 'pages/dashboard.dart';
import 'pages/labours/labor_page.dart';
import 'pages/labours/add_labor_page.dart';
import 'pages/project/project_list_page.dart';
import 'pages/vendors/vendors_entry_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Add an artificial delay of 3 seconds
  await Future.delayed(Duration(seconds: 3));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Labor Management App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.grey,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: FadeIn(
        duration: const Duration(milliseconds: 1000),
        child: DashboardPage(),
        //   child: const VendorSelectionPage(projectId: 1,),
      ),
      routes: {
        '/login': (context) => HomePage(),
        '/dashboard': (context) => const DashboardPage(),
        '/labor_management': (context) => const LaborPage(),
        '/add_labor': (context) => const AddLaborPage(),
        '/projects': (context) => const ProjectPage(), // Ensure ProjectPage is defined
      },
    );
  }
}
