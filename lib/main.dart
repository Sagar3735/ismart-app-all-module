import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'navigation/app_router.dart';
import 'theme/app_theme.dart';
import 'providers/employee_provider.dart';
import 'providers/attendance_provider.dart';
import 'providers/leave_provider.dart';

void main() {
  runApp(const ISFPortalApp());
}

class ISFPortalApp extends StatelessWidget {
  const ISFPortalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EmployeeProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => LeaveProvider()),
      ],
      child: MaterialApp.router(
        title: 'ISF Portal',
        theme: AppTheme.light,
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
