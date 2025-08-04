import 'package:flutter/material.dart';
import 'custom_drawer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:go_router/go_router.dart';

class MainmenuExsternalScreen extends StatefulWidget {
  final String employeeid;
  const MainmenuExsternalScreen({Key? key, required this.employeeid})
      : super(key: key);

  @override
  _MainmenuScreenState createState() => _MainmenuScreenState();
}

class _MainmenuScreenState extends State<MainmenuExsternalScreen> {
  late Box box;
  String? username;
  String? visitorid;
  String? email;
  DateTime? lastPressed;

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    box = await Hive.openBox('userBox');
    if (!mounted) return;
    setState(() {
      username = box.get('username');
      visitorid = box.get('visitorid');
      email = box.get('email');
      String? token = box.get('token');
      if (token == null || token.isEmpty) {
        Navigator.pushReplacementNamed(context, '/');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final now = DateTime.now();
        if (lastPressed == null ||
            now.difference(lastPressed!) > Duration(seconds: 2)) {
          lastPressed = now;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Tekan sekali lagi untuk keluar"),
                duration: Duration(seconds: 2)),
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Sedia',
            style: TextStyle(
              color: Color(0xFF07840B),
              fontFamily: 'Hanken Grotesk',
              fontSize: 32.323,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.normal,
              height: 1.0,
            ),
          ),
          backgroundColor: const Color(0xFFFFFFFF),
          elevation: 0,
        ),
        drawer: CustomDrawer(username: username),
        body: Center(
          child: Container(
            width: MediaQuery.of(context).size.shortestSide,
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: Container(color: Color(0xFFF0F0F0)),
                ),
                Positioned(
                  top: 90,
                  left: 0,
                  right: 0,
                  child: Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          username == null
                              ? Center(child: CircularProgressIndicator())
                              : Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    'Welcome Back, $username',
                                    style: TextStyle(
                                      color: Color(0xFF757575),
                                      fontFamily: 'Hanken Grotesk',
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                          SizedBox(height: 16),
                          InkWell(
                            onTap: () {
                              //context.push('/request-induction', extra: {'username': username ?? 'defaultID'});
                              GoRouter.of(context).go('/request-induction',
                                  extra: {'username': username ?? 'defaultID'});
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.grey, width: 1.0),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Visitor Induction',
                                        style: TextStyle(
                                          fontFamily: 'Hanken Grotesk',
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF343434),
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                    ],
                                  ),
                                  SvgPicture.asset(
                                    'assets/images/Right-Scroll.svg',
                                    height: 40.0,
                                    width: 40.0,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
