import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:she_vi/screens/page/detailhistory.dart';
import 'package:she_vi/screens/page/requestsubmitted_screen.dart';
import 'package:she_vi/screens/login/login_screen.dart';
import 'package:she_vi/screens/chooseaccess_screen.dart';
import 'package:she_vi/screens/login/createnewpass_screen.dart';
import 'package:she_vi/screens/welcome_screen.dart';
import 'package:she_vi/screens/home/mainmenu_screen.dart';
import 'package:she_vi/screens/home/menusatu_screen.dart'; //Home Menu Satu
import 'package:she_vi/screens/home/mainmenuExternal_screen.dart';
import 'package:she_vi/screens/induction_test/welcome_testsatu_screen.dart';
import 'package:she_vi/screens/induction_test/welcome_testdua_screen.dart';
import 'package:she_vi/screens/induction_test/question_screen.dart';
import 'package:she_vi/screens/induction_test/test_complated_screen.dart';
import 'package:she_vi/screens/induction_test/approved_mail_screen.dart';
import 'package:she_vi/screens/page/reqinductionysatu_screen.dart';
import 'package:she_vi/screens/page/detaiinfo.dart';
import 'package:she_vi/screens/page/detailvisit.dart';
import 'package:she_vi/screens/induction_test/complated_screen.dart';
import 'package:she_vi/screens/setting/navigator_service.dart';
import 'package:she_vi/screens/page/visitorrequest_Screen.dart';
import 'package:she_vi/screens/login/logout_screen.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor:
            Colors.white, // Pastikan background tidak hitam
      ),
      routerConfig: AppRouter.router,
    );
  }
}

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: globalNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/choose-access',
        builder: (context, state) => ChooseAccess(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(),
      ),// ✅ Tambahkan di sini route logout
      GoRoute(
        path: '/logout',
        builder: (context, state) => LogoutScreen(),
      ),
      GoRoute(
        path: '/create-new-pass/:employeeid/:fullName/:email',
        builder: (context, state) {
          final employeeid = state.pathParameters['employeeid'] ?? '';
          final fullName = state.pathParameters['fullName'] ?? '';
          final email = state.pathParameters['email'] ?? '';

          return CreateNewPass(
            employeeid: employeeid,
            fullName: fullName,
            email: email,
          );
        },
      ),
      GoRoute(
        path: '/choose-access',
        builder: (context, state) => ChooseAccess(),
      ),
      GoRoute(
        path: '/main-menu',
        builder: (context, state) {
          final extra =
              state.extra as Map<String, String>?; // Ambil data dari `extra`
          return MainmenuScreen(
            employeeid: extra?['username'] ?? 'defaultID',
          );
        },
      ),
      GoRoute(
        path: '/request-induction',
        builder: (context, state) => MenusatuScreen(username: 'defaultID'),
      ),
      GoRoute(
        path: '/detail-info',
        builder: (context, state) {
          final idRequest = state.uri.queryParameters['id'] ?? 'defaultID';
          print('Navigating to /detail-info with id: $idRequest');
          return Detaiinfo(
              idrequest: idRequest); // Menampilkan halaman DetailInfo
        },
      ),
      GoRoute(
        path: '/detail-history',
        builder: (context, state) {
          final idRequest = state.uri.queryParameters['id'] ?? 'defaultID';
          return DetailHistory(idrequest: idRequest);
        },
      ),
      GoRoute(
        path: '/request-new-induction',
        builder: (context, state) => ReqInductionySatu(),
      ),
      GoRoute(
        path: '/request-submitted',
        builder: (context, state) => RequestSubmitted(username: 'defaultID'),
      ),
      GoRoute(
        path: '/welcome-test',
        builder: (context, state) {
          final queryParams = state.uri.queryParameters;
          return WelcomeTestSatuScreen(
            idrequest: queryParams['idrequest'] ?? 'defaultID',
            plantId: queryParams['plantId'] ?? 'defaultID',
            plantName: queryParams['plantName'] ?? 'defaultID',
          );
        },
      ),
      GoRoute(
        path: '/welcome-test-intructions',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>? ?? {};
          return WelcomeTestDuaScreen(
            idrequest: args['idrequest'] ?? '',
            plantId: args['plantId'] ?? '',
            plantName: args['plantName'] ?? '',
          );
        },
      ),
      GoRoute(
        path: '/question',
        builder: (context, state) {
          final queryParams = state.uri.queryParameters;
          return QuestionScreen(
            idrequest: queryParams['idrequest'] ?? 'defaultID',
            plantId: queryParams['plantId'] ?? 'defaultID',
            plantName: queryParams['plantName'] ?? 'defaultID',
          );
        },
      ),
      GoRoute(
        path: '/test-complated',
        builder: (context, state) {
          final queryParams = state.uri.queryParameters;
          return TestComplatedScreen(
            idrequest: queryParams['idrequest'] ?? 'defaultID',
            plantId: queryParams['plantId'] ?? 'defaultID',
            plantName: queryParams['plantName'] ?? 'defaultID',
          );
        },
      ),
      GoRoute(
        path: '/main-menu-ext',
        builder: (context, state) => const MainmenuExternalScreen(),
      ),
      GoRoute(
        path: '/approved-email',
        builder: (context, state) {
          final idrequest = state.uri.queryParameters['idrequest'] ??
              '0'; // Gunakan default jika null
          return ApprovedMailScreen(idrequest: idrequest);
        },
      ),
      GoRoute(
        path: '/aktif-info',
        builder: (context, state) {
          final idRequest = state.uri.queryParameters['id'] ?? 'defaultID';
          return ComplatedScreen(idrequest: idRequest);
        },
      ),
      GoRoute(
        path: '/visitor-request',
        builder: (context, state) {
          final idRequest = state.uri.queryParameters['id'] ?? 'defaultID';
          return VisitorRequest(idrequest: idRequest);
        },
      ),
      GoRoute(
        path: '/detail-scan',
        builder: (context, state) {
          final idRequest = state.uri.queryParameters['id'] ?? 'defaultID';
          return DetailVisit(idrequest: idRequest);
        },
      ),
    ],
  );
}
