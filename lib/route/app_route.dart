import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// -----------------------
// SCREENS
// -----------------------

// Auth & General
import 'package:she_vi/screens/login/login_screen.dart';
import 'package:she_vi/screens/login/logout_screen.dart';
import 'package:she_vi/screens/login/createnewpass_screen.dart';
import 'package:she_vi/screens/welcome_screen.dart';
import 'package:she_vi/screens/chooseaccess_screen.dart';

// Home - Internal
import 'package:she_vi/screens/home/mainmenu_screen.dart';
import 'package:she_vi/screens/home/menusatu_screen.dart';

// Home - External
import 'package:she_vi/screens/home/mainmenuExternal_screen.dart';
import 'package:she_vi/screens/home/external/register_screen.dart';
import 'package:she_vi/screens/home/external/mainmenu_employee_screen.dart';
import 'package:she_vi/screens/home/external/request_induction_form_screen.dart';

// Pages
import 'package:she_vi/screens/page/detailhistory.dart';
import 'package:she_vi/screens/page/requestsubmitted_screen.dart';
import 'package:she_vi/screens/page/reqinductionysatu_screen.dart';
import 'package:she_vi/screens/page/detaiinfo.dart';
import 'package:she_vi/screens/page/detailvisit.dart';
import 'package:she_vi/screens/page/visitorrequest_Screen.dart';

// Induction Test
import 'package:she_vi/screens/induction_test/welcome_testsatu_screen.dart';
import 'package:she_vi/screens/induction_test/welcome_testdua_screen.dart';
import 'package:she_vi/screens/induction_test/question_screen.dart';
import 'package:she_vi/screens/induction_test/test_complated_screen.dart';
import 'package:she_vi/screens/induction_test/approved_mail_screen.dart';
import 'package:she_vi/screens/induction_test/complated_screen.dart';

// Utils / Services
import 'package:she_vi/screens/setting/navigator_service.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
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

      /// -----------------------
      /// AUTH & GENERAL ROUTES
      /// -----------------------
      GoRoute(path: '/', builder: (context, state) => const WelcomeScreen()),
      GoRoute(path: '/welcome', builder: (context, state) => const WelcomeScreen()),
      GoRoute(path: '/choose-access', builder: (context, state) => ChooseAccess()),
      GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/logout', builder: (context, state) => LogoutScreen()),

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

      /// -----------------------
      /// EMPLOYEE ROUTES (Internal)
      /// -----------------------
      GoRoute(
        path: '/employee/main-menu',
        builder: (context, state) {
          final extra = state.extra as Map<String, String>?;
          return MainmenuScreen(
            employeeid: extra?['username'] ?? 'defaultID',
          );
        },
      ),
      GoRoute(
        path: '/employee/request-induction',
        builder: (context, state) => MenusatuScreen(username: 'defaultID'),
      ),
      GoRoute(
        path: '/employee/detail-info',
        builder: (context, state) {
          final idRequest = state.uri.queryParameters['id'] ?? 'defaultID';
          return Detaiinfo(idrequest: idRequest);
        },
      ),
      GoRoute(
        path: '/employee/detail-history',
        builder: (context, state) {
          final idRequest = state.uri.queryParameters['id'] ?? 'defaultID';
          return DetailHistory(idrequest: idRequest);
        },
      ),
      GoRoute(
        path: '/employee/request-new-induction',
        builder: (context, state) => ReqInductionySatu(),
      ),
      GoRoute(
        path: '/employee/request-submitted',
        builder: (context, state) => RequestSubmitted(username: 'defaultID'),
      ),

      /// -----------------------
      /// VISITOR ROUTES (External)
      /// -----------------------
      GoRoute(
        path: '/visitor/main-menu',
        builder: (context, state) => const MainmenuExternalScreen(),
      ),
      GoRoute(
        path: '/visitor/request',
        builder: (context, state) {
          final idRequest = state.uri.queryParameters['id'] ?? 'defaultID';
          return VisitorRequest(idrequest: idRequest);
        },
      ),
      GoRoute(
        path: '/visitor/request-form',
        builder: (context, state) => const RequestInductionScreen(),
      ),
      GoRoute(
        path: '/visitor/detail-scan',
        builder: (context, state) {
          final idRequest = state.uri.queryParameters['id'] ?? 'defaultID';
          return DetailVisit(idrequest: idRequest);
        },
      ),

      /// -----------------------
      /// INDUCTION TEST ROUTES
      /// -----------------------
      GoRoute(
        path: '/induction/welcome-test',
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
        path: '/induction/welcome-test-instructions',
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
        path: '/induction/question',
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
        path: '/induction/test-completed',
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
        path: '/induction/approved-email',
        builder: (context, state) {
          final idrequest = state.uri.queryParameters['idrequest'] ?? '0';
          return ApprovedMailScreen(idrequest: idrequest);
        },
      ),
      GoRoute(
        path: '/induction/active-info',
        builder: (context, state) {
          final idRequest = state.uri.queryParameters['id'] ?? 'defaultID';
          return ComplatedScreen(idrequest: idRequest);
        },
      ),
    ],
  );
}
