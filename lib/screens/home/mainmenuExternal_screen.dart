import 'package:flutter/material.dart';
import 'custom_drawer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:go_router/go_router.dart';

class MainmenuExternalScreen extends StatefulWidget {
  const MainmenuExternalScreen({super.key});

  @override
  _MainmenuExternalScreenScreenState createState() =>
      _MainmenuExternalScreenScreenState();
}

class _MainmenuExternalScreenScreenState
    extends State<MainmenuExternalScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late Box box;
  String? username;
  String? visitorid;
  String? email;

  @override
  void initState() {
    super.initState();
  }

  Future<bool> _onWillPop() async {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
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
              height: 1.0,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        drawer: CustomDrawer(username: username ?? "Guest"),

        body: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.shortestSide,
            child: Stack(
              children: [
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
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Welcome Back, Visitor!',
                              style: TextStyle(
                                color: Color(0xFF757575),
                                fontFamily: 'Hanken Grotesk',
                                fontSize: 16.0,
                                fontWeight: FontWeight.w400,
                                height: 1.0,
                              ),
                            ),
                          ),

                          SizedBox(height: 16),

                          InkWell(
                            onTap: () {
                              context.go(
                                '/request-form',
                                extra: {
                                  'username': username,
                                },
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey, width: 1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 12.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
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
                                    height: 40,
                                    width: 40,
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
