// lib/route/app_route.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// MODELS
import 'package:she_vi/models/mc_question.dart';

// -----------------------
// AUTH & GENERAL SCREENS
// -----------------------
import 'package:she_vi/screens/login/login_screen.dart';
import 'package:she_vi/screens/login/logout_screen.dart';
import 'package:she_vi/screens/login/createnewpass_screen.dart';
import 'package:she_vi/screens/welcome_screen.dart';
import 'package:she_vi/screens/chooseaccess_screen.dart';

// -----------------------
// HOME (INTERNAL)
// -----------------------
import 'package:she_vi/screens/home/mainmenu_screen.dart';
import 'package:she_vi/screens/home/menusatu_screen.dart';

// -----------------------
// HOME (EXTERNAL)
// -----------------------
import 'package:she_vi/screens/home/mainmenuExternal_screen.dart';
import 'package:she_vi/screens/home/external/register_screen.dart';
import 'package:she_vi/screens/home/external/request_induction_form_screen.dart'
    as form;
import 'package:she_vi/screens/home/external/request_induction_screen.dart'
    as screen;
import 'package:she_vi/screens/home/external/request_submitted_screen.dart';
import 'package:she_vi/screens/home/external/induction_landing_screen.dart';

// -----------------------
// PAGES
// -----------------------
import 'package:she_vi/screens/page/detailhistory.dart';
import 'package:she_vi/screens/page/requestsubmitted_screen.dart';
import 'package:she_vi/screens/page/reqinductionysatu_screen.dart';
import 'package:she_vi/screens/page/detaiinfo.dart';
import 'package:she_vi/screens/page/detailvisit.dart';
import 'package:she_vi/screens/page/visitorrequest_Screen.dart';

// -----------------------
// INDUCTION TEST SCREENS
// -----------------------
import 'package:she_vi/screens/induction_test/welcome_testsatu_screen.dart';
import 'package:she_vi/screens/induction_test/welcome_testdua_screen.dart';
import 'package:she_vi/screens/induction_test/question_screen.dart';
import 'package:she_vi/screens/induction_test/test_complated_screen.dart';
import 'package:she_vi/screens/induction_test/approved_mail_screen.dart';
import 'package:she_vi/screens/induction_test/completed_screen.dart';

// -----------------------
// CMS SCREENS
// -----------------------
import 'package:she_vi/screens/cms/cms_induction_screen.dart';
import 'package:she_vi/screens/cms/cms_question_screen.dart';
import 'package:she_vi/screens/cms/material_screen.dart';
import 'package:she_vi/screens/cms/cms_edit_question_screen.dart';
import 'package:she_vi/screens/cms/cms_duplicate_question_screen.dart';

// -----------------------
// UTILS / SERVICES
// -----------------------
import 'package:she_vi/screens/setting/navigator_service.dart';
// -----------------------
// Exsternal
// -----------------------
import 'package:she_vi/screens/home/external/approved_mail_exsternal_screen.dart';
import 'package:she_vi/screens/external/menu_exsternal_screen.dart';
import 'package:she_vi/screens/external/page/detaiinfoexternal.dart';
import 'package:she_vi/screens/external/page/welcome_testsatu_external.dart';
import 'package:she_vi/screens/external/page/welcome_testdua_external.dart';
import 'package:she_vi/screens/external/page/question_screen_external.dart';

/// ======================================================
/// ✅ AppRouter: Kelas tunggal untuk mengatur semua route
/// ======================================================
class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: globalNavigatorKey, // 🔑 Gunakan global navigator
    initialLocation: '/',
    routes: [
      /// ======================================================
      /// 🔐 AUTH & GENERAL ROUTES
      /// ======================================================
      GoRoute(path: '/', builder: (context, state) => const WelcomeScreen()),
      GoRoute(
          path: '/welcome', builder: (context, state) => const WelcomeScreen()),
      GoRoute(
          path: '/choose-access', builder: (context, state) => ChooseAccess()),
      GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
      GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/logout', builder: (context, state) => LogoutScreen()),

      // 🔑 Reset password (dengan 3 parameter path)
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

      /// ======================================================
      /// 🧑‍💼 EMPLOYEE ROUTES (INTERNAL)
      /// ======================================================
      GoRoute(
        path: '/employee/main-menu',
        builder: (context, state) {
          final extra = state.extra as Map<String, String>? ?? {};
          return MainmenuScreen(employeeid: extra['username'] ?? 'defaultID');
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
        path: '/request-new-induction',
        builder: (context, state) => ReqInductionySatu(),
      ),
      GoRoute(
        path: '/employee/request-submitted',
        builder: (context, state) => RequestSubmitted(username: 'defaultID'),
      ),

      /// ======================================================
      /// 🧍‍♂️ VISITOR ROUTES (EXTERNAL)
      /// ======================================================
      GoRoute(
        path: '/main-menu-ext',
        builder: (context, state) => const MainmenuExternalScreen(),
      ),
      GoRoute(
        path: '/visitor/aktif-info',
        builder: (context, state) {
          final idRequest = state.uri.queryParameters['id'] ?? 'defaultID';
          return CompletedScreen(idrequest: idRequest);
        },
      ),
      GoRoute(
        path: '/visitor/request',
        builder: (context, state) {
          final idRequest = state.uri.queryParameters['id'] ?? 'defaultID';
          return VisitorRequest(idrequest: idRequest);
        },
      ),

      GoRoute(
        path: '/request-form',
        builder: (context, state) => const form.RequestInductionFormScreen(),
      ),
      GoRoute(
        path: '/request-submitted',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? "guest@email.com";
          return RequestSubmittedScreen(email: email);
        },
      ),
      GoRoute(
        path: '/visitor/detail-scan',
        builder: (context, state) {
          final idRequest = state.uri.queryParameters['id'] ?? 'defaultID';
          return DetailVisit(idrequest: idRequest);
        },
      ),
      GoRoute(
        path: '/landing-test',
        builder: (context, state) => const InductionLandingScreen(),
      ),

      /// ======================================================
      /// 🧠 INDUCTION TEST ROUTES
      /// ======================================================
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
          return CompletedScreen(idrequest: idRequest);
        },
      ),

      /// ======================================================
      /// 🧩 CMS ROUTES
      /// ======================================================
      GoRoute(
        path: '/cms',
        builder: (context, state) {
          final plantId = state.extra as String? ?? '';
          return CmsInductionScreen(plantId: plantId);
        },
      ),
      GoRoute(
        path: '/cms/questions',
        builder: (context, state) {
          print("EXTRA VALUE TYPE: ${state.extra.runtimeType}");
          String plantId = '';
          if (state.extra is Map<String, String>) {
            plantId = (state.extra as Map<String, String>)['plantId'] ?? '';
          } else if (state.extra is String) {
            plantId = state.extra as String;
          }
          return CmsQuestionScreen(plantId: plantId);
        },
      ),
      GoRoute(
        path: '/cms/material/add',
        builder: (context, state) {
          print("EXTRA VALUE TYPE: ${state.extra.runtimeType}");
          String plantId = '';
          if (state.extra is Map<String, String>) {
            plantId = (state.extra as Map<String, String>)['plantId'] ?? '';
          } else if (state.extra is String) {
            plantId = state.extra as String;
          }
          return AddMaterialScreen(plantId: plantId);
        },
      ),
      GoRoute(
        path: '/cms/question/edit',
        builder: (context, state) {
          final question = state.extra as MCQuestion?;
          return CmsEditQuestionScreen(question: question!);
        },
      ),

      GoRoute(
        path: '/cms/question/duplicate',
        builder: (context, state) {
          final question = state.extra as MCQuestion?;
          return CmsDuplicateQuestionScreen(question: question!);
        },
      ),

      /// ======================================================
      /// 🧠 exsternal
      /// ======================================================

      GoRoute(
        path: '/request-induction',
        builder: (context, state) => const screen.RequestInductionScreen(),
      ),

      GoRoute(
        path: '/exsternal/approved-email',
        builder: (context, state) {
          final idRequest = state.uri.queryParameters['idrequest'];

          if (idRequest == null) {
            // Jika parameter tidak ada, bisa arahkan ke halaman error / not found
            return const Scaffold(
              body: Center(
                child: Text('Invalid or missing request ID'),
              ),
            );
          }

          return ApprovedMailExsternalScreen(idrequest: idRequest);
        },
      ),

      GoRoute(
        path: '/exsternal/request-induction',
        builder: (context, state) {
          final idRequest = state.uri.queryParameters['idrequest'];
          if (idRequest == null) {
            return const Scaffold(
              body: Center(
                child: Text('Invalid or missing request ID'),
              ),
            );
          }
          return MenuExternalScreen(idrequest: idRequest);
        },
      ),

      // GoRoute(
      //   path: '/exsternal/detail-info',
      //   builder: (context, state) {
      //     final idRequest = state.uri.queryParameters['id'] ?? 'defaultID';
      //     return Detaiinfoexternal(idrequest: idRequest);
      //   },
      // ),
      GoRoute(
        path: '/exsternal/detail-info',
        builder: (context, state) {
          final idprogress = state.uri.queryParameters['id'] ?? 'defaultID';
          final idrequest = state.uri.queryParameters['idrequest'] ?? '';

          // Sekarang kirim semua data sebagai parameter konstruktor
          return Detaiinfoexternal(
            idprogress: idprogress,
            idrequest: idrequest,
          );
        },
      ),
      GoRoute(
      path: '/external/welcome-test-satu',
      builder: (context, state) {
        final extras = state.extra as Map<String, dynamic>?;

        return WelcomeTestSatuExternalScreen(
          idrequest: extras?['idrequest'] ?? '',
          plantId: extras?['plantId'] ?? '',
          plantName: extras?['plantName'] ?? '',
        );
      },
    ),
      GoRoute(
      path: '/external/welcome-test-dua',
      builder: (context, state) {
        final extras = state.extra as Map<String, dynamic>?;

        return WelcomeTestDuaExternalScreen(
          idrequest: extras?['idrequest'] ?? '',
          plantId: extras?['plantId'] ?? '',
          plantName: extras?['plantName'] ?? '',
        );
      },
    ),
    GoRoute(
      path: '/external/induction/question',
      name: 'external-question',
      builder: (context, state) {
        final idrequest = state.uri.queryParameters['idrequest'] ?? '';
        final plantId = state.uri.queryParameters['plantId'] ?? '';
        final plantName = state.uri.queryParameters['plantName'] ?? '';

        return QuestionScreenExternal(
          idrequest: idrequest,
          plantName: plantName,
        );
      },
    ),
    ],
  );
}
