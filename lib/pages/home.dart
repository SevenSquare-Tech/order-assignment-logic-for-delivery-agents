import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';

import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ridderapp/blog/auth/authevent.dart';
import 'package:ridderapp/model/wallet.dart';
import 'package:ridderapp/transaction/acoount.dart';
import 'package:ridderapp/transaction/daily-commision.dart';
import 'package:ridderapp/transaction/transaction-list.dart';

import '../blog/auth/authbloc.dart';
import '../model/user.dart';
import '../base/customroute.dart';
import '../repository/transactionrepo.dart';
import 'loading_indicator.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Connectivity _connectivity = Connectivity();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TrxRepository repo = new TrxRepository();
  AuthenticationBloc authenticationBloc;
  StreamSubscription<ConnectivityResult> _connectionChangeStream;
  User _user;
  bool hasConnection = false;

  @override
  void initState() {
    super.initState();
    checkConnection();
    _connectionChangeStream =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        checkConnection().then((val) => setState(() {}));
      });
    });
    authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
    _user = this.authenticationBloc.userRepository.getAuthUserInfo();

  }

  Future<bool> checkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      print(result.toString());
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        hasConnection = true;
      } else {
        hasConnection = false;
      }
    } on SocketException catch (_) {
      hasConnection = false;
    }
    print('check connection....' + hasConnection.toString());
    setState(() {});
    return hasConnection;
  }


  @override
  void dispose() {
    _connectionChangeStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: GestureDetector(
        onTap: () {
          if (!_scaffoldKey.currentState.isDrawerOpen) {
            _scaffoldKey.currentState.openDrawer();
          }
        },
        child: new FutureBuilder(
            future: repo.getWallet(),
            builder: (BuildContext context, AsyncSnapshot<Wallet> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data != null) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        stops: [0.1, 0.5, 0.7, 0.9],
                        colors: [
                          Colors.indigo[800],
                          Colors.indigo[700],
                          Colors.indigo[600],
                          Colors.indigo[400],
                        ],
                      ),
                    ),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Column(children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(top: 25.0),
                        padding: EdgeInsets.only(right: 10.0),
                        alignment: Alignment.bottomRight,
                        child: Icon(
                            (!hasConnection)
                                ? Icons.signal_wifi_off
                                : Icons.wifi,
                            color: (!hasConnection)
                                ? Colors.redAccent
                                : Colors.white),
                      ),
                      Expanded(
                        child: Center(
                          child: Stack(alignment: Alignment.center, children: <
                              Widget>[
                            Container(
                              margin: EdgeInsets.fromLTRB(40, 80.0, 40, 20),
                              padding: EdgeInsets.all(20.0),
                              width: MediaQuery.of(context).size.width,
                              height: 200.0,
                              decoration: BoxDecoration(
                                  boxShadow: [
                                    new BoxShadow(
                                      color: Colors.black,
                                      blurRadius: 20.0,
                                    ),
                                  ],
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                   gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        stops: [0.1, 0.5, 0.7, 0.9],
                        colors: [
                          Colors.white60,
                          Colors.white,
                          Colors.white,
                          Colors.white70,
                        ],
                      ),),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    "RM " + snapshot.data.balance.toString(),
                                    style: TextStyle(
                                        color: Color(0xFF273746),
                                        fontSize: 48.0,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "OpenSans"),
                                  ),
                                  Text(
                                    "Your Balance",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "OpenSans"),
                                  )
                                ],
                              ),
                            ),
                            Positioned(
                              top: 25,
                              width: 250,
                              child: Container(
                                padding: EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                    boxShadow: [
                                      new BoxShadow(
                                        color: Colors.black,
                                        blurRadius: 20.0,
                                      ),
                                    ],
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                    color: Color(0xFF34495E)),
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      "Welcome",
                                      style: TextStyle(
                                          fontSize: 13.0,
                                          color: Theme.of(context)
                                              .primaryTextTheme
                                              .display1
                                              .color,
                                          fontStyle: FontStyle.italic,
                                          fontFamily: "OpenSans"),
                                    ),
                                    Text(
                                      snapshot.data.nickname,
                                      maxLines: 3,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 18.0,
                                          color: Theme.of(context)
                                              .primaryTextTheme
                                              .display1
                                              .color,
                                          fontFamily: "OpenSans"),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  new CustomRoute(
                                      builder: (context) =>
                                          new TransactionList()),
                                );
                              },
                              child: Container(
                                child: new CircleAvatar(
                                    child: Icon(Icons.motorcycle)),
                                width: 64.0,
                                height: 64.0,
                                margin: EdgeInsets.only(top: 260),
                                padding:
                                    const EdgeInsets.all(2.0),
                                decoration: new BoxDecoration(
                                  color:
                                      const Color(0xFFFFFFFF),
                                  shape: BoxShape.circle,
                                   gradient: LinearGradient(
                                  begin: Alignment.topRight,
                                  end: Alignment.bottomLeft,
                                  colors: [Color(0xFFFFFFFF), Colors.black]),
                                ),
                                
                              ),
                            )
                          ]),
                        ),
                      ),
                      Text("(c) by 2019 GalaEats all right reserved.",
                          style: TextStyle(
                              fontFamily: 'OpenSans',
                              fontWeight: FontWeight.normal,
                              fontSize: 15.0,
                              color: Colors.white)),
                      Divider(height: 10),
                    ]),
                  );
                } else {
                  return new LoadingIndicator();
                }
              } else {
                return new LoadingIndicator();
              }
            }),
      ),
      drawer: displayDrawer(context),
    );
  }

  Widget displayDrawer(BuildContext context) {
    return Drawer(
      elevation: 1,
      semanticLabel: "Rider App",
      child: Container(
        decoration: BoxDecoration(boxShadow: [
          new BoxShadow(
            color: Colors.black,
            blurRadius: 20.0,
          ),
        ], color: Colors.white),
        padding: EdgeInsets.only(left: 10),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            menuHeader(),
            Divider(
              height: 25,
            ),
            menuItem('Transactions', Color(0xFF34495E), () {
              Navigator.push(
                context,
                new CustomRoute(builder: (context) => new TransactionList()),
              );
            }),
            Divider(
              height: 20,
            ),
            menuItem('Account', Color(0xFF34495E), () {
              Navigator.push(
                context,
                new CustomRoute(builder: (context) => new RiderAccount()),
              );
            }),
            Divider(
              height: 20,
            ),
            menuItem('Daily Commission', Color(0xFF34495E), () {
              Navigator.push(
                context,
                new CustomRoute(builder: (context) => new DailyCommision()),
              );
            }),
            Divider(
              height: 20,
            ),
            menuItem('Log Out', Colors.redAccent, () {
              authenticationBloc.dispatch(LoggedOut());
              Navigator.pop(context);
            }),
            Divider(),
            
          ],
        ),
      ),
    );
  }

  Widget menuHeader() {
    return Container(
        decoration: BoxDecoration(color: Theme.of(context).primaryColor),
        padding: EdgeInsets.fromLTRB(20, 30, 20, 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            CircleAvatar(
              child: Icon(Icons.motorcycle),
            ),
            displayText(_user == null ? "" : _user.name, 18, FontWeight.w700,
                italy: true),
          ],
        ));
  }

  Widget menuItem(String actionText, Color color, Function action) {
    return InkWell(
      child: Container(
        decoration: BoxDecoration(
            boxShadow: [
              new BoxShadow(
                color: Colors.black,
                blurRadius: 10.0,
              ),
            ],
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            color: color), //Color(0xFF34495E)),
        height: 40.00,
        margin: EdgeInsets.fromLTRB(20, 1, 20, 1),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.arrow_right,
              size: 28,
              color: Colors.white,
            ),
            Text(
              actionText,
              style: TextStyle(fontSize: 20.0, color: Colors.white),
            ),
          ],
        ),
      ),
      onTap: () => action(),
    );
  }

  Widget displayText(String text, double fontSize, FontWeight fontWeight,
      {bool italy: false, bool startRight: true}) {
    return Text(
      text,
      textAlign: TextAlign.end,
      style: TextStyle(
          fontFamily: 'OpenSans',
          fontWeight: fontWeight,
          fontStyle: italy ? FontStyle.italic : FontStyle.normal,
          fontSize: fontSize,
          color: Colors.white),
    );
  }
}
