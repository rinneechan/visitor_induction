import 'package:flutter/material.dart';
import '../screens/chooseaccess_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/createnewpass_screen.dart';
import '../screens/home/mainmenu_screen.dart';
import '../screens/home/menusatu_screen.dart';
import '../screens/page/_submissionhistory.dart';
import '../screens/induction_test/welcome_testsatu_screen.dart';
import '../screens/induction_test/welcome_testdua_screen.dart';
import '../screens/induction_test/question_screen.dart';
import '../screens/page/reqinductionysatu_screen.dart';

// Dalam MaterialApp, tambahkan initialRoute
void main() {
  runApp(
    MaterialApp(
      initialRoute: '/choose-access',  // Menambahkan initialRoute
      routes: AppRoutes.getRoutes(),
    ),
  );
}


class AppRoutes {
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      '/choose-access': (context) => ChooseAccess(),
      '/login': (context) => LoginScreen(),
      '/main-menu': (context) => MainmenuScreen(employeeid: 'defaultID'),
      '/request-induction': (context) => MenusatuScreen(username: 'defaultID'),
      '/request-new-induction': (context) => ReqInductionySatu(),
      '/createnewpass': (context) => CreateNewPass(employeeid: 'defaultID'),
      '/detail-info': (context) => SubMissionHistory(idrequest: ModalRoute.of(context)?.settings.arguments as String),
      '/welcome-test': (context) {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>;
        final idrequest = args?['idrequest'] ?? 'defaultID';
        final plantId = args?['plantId'] ?? 'defaultID';
        final plantName = args?['plantName'] ?? 'defaultID';
        return WelcomeTestSatuScreen(idrequest: idrequest, plantId: plantId, plantName: plantName);
      },

      '/welcome-test-intructions': (context) {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>;
        final idrequest = args['idrequest'] ?? 'defaultID';
        final plantId = args['plantId'] ?? 'defaultID';
        final plantName = args['plantName'] ?? 'defaultID';

        return WelcomeTestDuaScreen(
          idrequest: idrequest,
          plantId: plantId,
          plantName: plantName,
        );
      },
      '/question': (context) {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>;
        final idrequest = args['idrequest'] ?? 'defaultID';
        final plantId = args['plantId'] ?? 'defaultID';
        final plantName = args['plantName'] ?? 'defaultID';

        return QuestionScreen(
          idrequest: idrequest,
          plantId: plantId,
          plantName: plantName,
        );
      },
    };
  }
}

