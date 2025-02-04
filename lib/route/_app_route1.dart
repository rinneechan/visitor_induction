import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:she_vi/screens/page/detailhistory.dart';
import '../screens/login/login_screen.dart';
import '../screens/chooseaccess_screen.dart';
import '../screens/createnewpass_screen.dart';
import '../screens/welcome_screen.dart';
import '../screens/home/mainmenu_screen.dart';
import '../screens/home/menusatu_screen.dart';
import '../screens/home/mainmenuExternal_screen.dart';
import '../screens/induction_test/welcome_testsatu_screen.dart';
import '../screens/induction_test/welcome_testdua_screen.dart';
import '../screens/induction_test/question_screen.dart';
import '../screens/induction_test/test_complated_screen.dart';
import '../screens/induction_test/approved_mail_screen.dart';
import '../screens/page/reqinductionysatu_screen.dart';
import '../screens/page/detaiinfo.dart';
import '../screens/induction_test/complated_screen.dart';
import 'package:she_vi/screens/setting/navigator_service.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: AppRouter.router,
    );
  }
}

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: globalNavigatorKey,
    initialLocation: '/welcome',
    routes: [
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
      ),

      GoRoute(
        path: '/main-menu',
        builder: (context, state) {
          final extra = state.extra as Map<String, String>?; // Ambil data dari `extra`
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
          return Detaiinfo(idrequest: idRequest);
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
        path: '/createnewpass',
        builder: (context, state) => CreateNewPass(employeeid: 'defaultID'),
      ),
      // GoRoute(
      //   path: '/detail-info',
      //   builder: (context, state) {
      //     final idRequest = state.uri.queryParameters['id'] ?? 'defaultID';
      //     return Detaiinfo(idrequest: idRequest);
      //   },
      // ),
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
      // GoRoute(
      //   path: '/question',
      //   builder: (context, state) {
      //     final args = state.extra as Map<String, dynamic>? ?? {};
      //     return QuestionScreen(
      //       idrequest: args['idrequest'] ?? '',
      //       plantId: args['plantId'] ?? '',
      //       plantName: args['plantName'] ?? '',
      //     );
      //   },
      // ),
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
      // GoRoute(
      //   path: '/question',
      //   builder: (context, state) {
      //     final args = state.extra as Map<String, String>?;
      //     return QuestionScreen(
      //       idrequest: args?['idrequest'] ?? 'defaultID',
      //       plantId: args?['plantId'] ?? 'defaultID',
      //       plantName: args?['plantName'] ?? 'defaultID',
      //     );
      //   },
      // ),

      GoRoute(
        path: '/main-menu-ext',
        builder: (context, state) => const MainmenuExternalScreen(),

      ),

      // GoRoute(
      //   path: '/approved-email',
      //   builder: (context, state) => ApprovedMailScreen(idrequest: 'defaultID'),
      // )
      GoRoute(
        path: '/approved-email',
        builder: (context, state) {
          final idrequest = state.uri.queryParameters['idrequest'] ?? '0'; // Gunakan default jika null
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
    ],
  );
}
