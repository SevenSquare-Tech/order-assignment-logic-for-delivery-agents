import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'pages/home.dart';
import 'pages/loading_indicator.dart';
import 'pages/login_page.dart';
import 'pages/splash.dart';
import 'repository/userreposity.dart';
import 'base/datahelper.dart';
import 'blog/auth/authbloc.dart';
import 'blog/auth/authevent.dart';
import 'blog/auth/authstate.dart';


void main() async {
  DataHelperSingleton datahlp = DataHelperSingleton.getInstance();
  await datahlp.iniSettingDB();
  runApp(App(userRepository: UserRepository()));
}

class App extends StatefulWidget {
  final UserRepository userRepository;

  App({Key key, @required this.userRepository}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  AuthenticationBloc authenticationBloc;
  UserRepository get userRepository => widget.userRepository;

  @override
  void initState() {
    authenticationBloc = AuthenticationBloc(userRepository: userRepository);
    super.initState();
  }

  @override
  void dispose() {
    authenticationBloc.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthenticationBloc>(
      bloc: authenticationBloc,
      child: MaterialApp(
        theme: ThemeData(
          fontFamily: 'OpenSans',
          brightness: Brightness.light,
          primaryColor: Color(0xff003c7e),
          accentColor: Color(0xff4487c7),          
        ),
        debugShowCheckedModeBanner: false,
        home: BlocBuilder<AuthenticationEvent, AuthenticationState>(
          bloc: authenticationBloc,
          builder: (BuildContext context, AuthenticationState state) {
            print("main loop ==> " + state.toString());
            if (state is AuthenticationUninitialized) {
              return SplashPage(); //authenticationBloc);
            }
            if (state is AuthenticationAuthenticated) {
              if (!userRepository.isAuthenticated())
                return LoginPage(userRepository: userRepository);
              return HomePage();
            }

            if (state is AuthenticationUnauthenticated) {
              return LoginPage(userRepository: userRepository);
            }
            if (state is AuthenticationLoading) {
              return LoadingIndicator();
            }
            return LoadingIndicator();
          },
        ),
      ),
    );
  }
}
