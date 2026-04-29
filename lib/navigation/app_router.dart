import 'package:go_router/go_router.dart';
import '../screens/home/all_module_screen.dart';
import '../screens/personal/employee_details_screen.dart';
import '../screens/personal/my_profile_screen.dart';
import '../screens/personal/documents_screen.dart';
import '../screens/personal/contact_hr_screen.dart';
import '../screens/attendance/monthly_report_screen.dart';
import '../screens/attendance/reliever_screen.dart';
import '../screens/attendance/leave_apply_screen.dart';
import '../screens/attendance/leave_balance_screen.dart';
import '../screens/attendance/overtime_screen.dart';
import '../screens/attendance/tour_request_screen.dart';
import '../screens/attendance/holiday_list_screen.dart';
import '../screens/attendance/regularize_screen.dart';
import '../screens/payroll/payslip_screen.dart';
import '../screens/payroll/esic_screen.dart';
import '../screens/payroll/pf_details_screen.dart';
import '../screens/payroll/benefits_screen.dart';
import '../screens/payroll/advance_screen.dart';
import '../screens/payroll/tax_screen.dart';
import '../screens/self_service/tickets_screen.dart';
import '../screens/self_service/uniform_screen.dart';
import '../screens/self_service/conveyance_screen.dart';
import '../screens/self_service/voice_messages_screen.dart';
import '../screens/learning/lms_screen.dart';
import '../screens/learning/grooming_screen.dart';
import '../screens/learning/career_path_screen.dart';
import '../screens/learning/certificates_screen.dart';
import '../screens/learning/feedback_screen.dart';
import '../screens/learning/goals_screen.dart';
import '../screens/learning/language_screen.dart';
import '../screens/learning/my_reports_screen.dart';
import '../screens/settings/notifications_screen.dart';
import '../screens/settings/notices_screen.dart';
import '../screens/settings/help_screen.dart';
import '../screens/settings/news_screen.dart';
import '../screens/settings/settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const AllModuleScreen()),
    GoRoute(path: '/employee_details', builder: (c, s) => const EmployeeDetailsScreen()),
    GoRoute(path: '/my_profile', builder: (c, s) => const MyProfileScreen()),
    GoRoute(path: '/documents', builder: (c, s) => const DocumentsScreen()),
    GoRoute(path: '/contact_hr', builder: (c, s) => const ContactHRScreen()),
    GoRoute(path: '/monthly_report', builder: (c, s) => const MonthlyReportScreen()),
    GoRoute(path: '/reliever', builder: (c, s) => const RelieverScreen()),
    GoRoute(path: '/leave_apply', builder: (c, s) => const LeaveApplyScreen()),
    GoRoute(path: '/leave_balance', builder: (c, s) => const LeaveBalanceScreen()),
    GoRoute(path: '/overtime', builder: (c, s) => const OvertimeScreen()),
    GoRoute(path: '/tour_request', builder: (c, s) => const TourRequestScreen()),
    GoRoute(path: '/holiday_list', builder: (c, s) => const HolidayListScreen()),
    GoRoute(path: '/regularize', builder: (c, s) => const RegularizeScreen()),
    GoRoute(path: '/payslip', builder: (c, s) => const PayslipScreen()),
    GoRoute(path: '/esic', builder: (c, s) => const ESICScreen()),
    GoRoute(path: '/pf_details', builder: (c, s) => const PFDetailsScreen()),
    GoRoute(path: '/benefits', builder: (c, s) => const BenefitsScreen()),
    GoRoute(path: '/advance', builder: (c, s) => const AdvanceScreen()),
    GoRoute(path: '/tax', builder: (c, s) => const TaxScreen()),
    GoRoute(path: '/tickets', builder: (c, s) => const TicketsScreen()),
    GoRoute(path: '/uniform', builder: (c, s) => const UniformScreen()),
    GoRoute(path: '/conveyance', builder: (c, s) => const ConveyanceScreen()),
    GoRoute(path: '/voice_messages', builder: (c, s) => const VoiceMessagesScreen()),
    GoRoute(path: '/lms', builder: (c, s) => const LMSScreen()),
    GoRoute(path: '/grooming', builder: (c, s) => const GroomingScreen()),
    GoRoute(path: '/career_path', builder: (c, s) => const CareerPathScreen()),
    GoRoute(path: '/certificates', builder: (c, s) => const CertificatesScreen()),
    GoRoute(path: '/feedback', builder: (c, s) => const FeedbackScreen()),
    GoRoute(path: '/goals', builder: (c, s) => const GoalsScreen()),
    GoRoute(path: '/language', builder: (c, s) => const LanguageScreen()),
    GoRoute(path: '/my_reports', builder: (c, s) => const MyReportsScreen()),
    GoRoute(path: '/notifications', builder: (c, s) => const NotificationsScreen()),
    GoRoute(path: '/notices', builder: (c, s) => const NoticesScreen()),
    GoRoute(path: '/help', builder: (c, s) => const HelpScreen()),
    GoRoute(path: '/news', builder: (c, s) => const NewsScreen()),
    GoRoute(path: '/settings', builder: (c, s) => const SettingsScreen()),
  ],
);
