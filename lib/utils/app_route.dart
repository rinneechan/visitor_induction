import 'package:flutter/material.dart';
//import '../screens/welcome_screen.dart';
import '../screens/chooseaccess_screen.dart';
import '../screens/login/login_screen.dart';
//import '../screens/login2_screen.dart';
import '../screens/createnewpass_screen.dart';
import '../screens/home/mainmenu_screen.dart';
import '../screens/home/menusatu_screen.dart';
import '../screens/page/submissionhistory.dart';
import '../screens/induction_test/welcome_testsatu_screen.dart';
import '../screens/induction_test/welcome_testdua_screen.dart';
import '../screens/induction_test/question_screen.dart';
import '../screens/page/reqinductionysatu_screen.dart';

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
        return WelcomeTestSatuScreen(idrequest: idrequest,plantId: plantId, plantName: plantName);
      },

      '/welcome-test-intructions': (context) {
        // Mengambil data dari arguments
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>;
        final idrequest = args['idrequest'] ?? 'defaultID'; // Ambil 'idrequest'
        final plantId = args['plantId'] ?? 'defaultID'; // Ambil 'plantId'
        final plantName = args['plantName'] ?? 'defaultID'; // Ambil 'plantName'

        return WelcomeTestDuaScreen(
          idrequest: idrequest,
          plantId: plantId,
          plantName: plantName,
        );
      },

      //'/question': (context) =>QuestionScreen(idrequest: 'defaultID', plantName: 'defaultID'),
      // '/question': (context) => QuestionScreen(
      //   idrequest: 'defaultID',
      //   plantName: 'defaultPlantName',
      //   plantId: 'defaultPlantID',
      // ),
      '/question': (context) {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>;
        final idrequest = args['idrequest'] ?? 'defaultID';
        final plantId = args['plantId'] ?? 'defaultID'; // Harus sesuai key di arguments
        final plantName = args['plantName'] ?? 'defaultID';

        return QuestionScreen(
          idrequest: idrequest,
          plantId: plantId,
          plantName: plantName,
        );
      },
      //'/login2': (context) => Login2Screen(employeeid: 'defaultID'),

      // '/submssionhistory': (context) =>
      //     SubMissionHistory(idrequest: 'defaultID'),
      // '/detailinfo': (context) =>
      //     SubMissionHistory(idrequest: 'defaultID'),
      // '/welcometestdua': (context) =>
      //     WelcomeTestDuaScreen(idrequest: 'defaultID', plantName: 'defaultID'),

    };
  }
}
