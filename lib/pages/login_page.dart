import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blog/auth/authbloc.dart';
import '../blog/login/loginbloc.dart';
import '../repository/userreposity.dart';
import 'login_form.dart';


class LoginPage extends StatefulWidget {
  final UserRepository userRepository;

  LoginPage({Key key, @required this.userRepository})
      : assert(userRepository != null),
        super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with TickerProviderStateMixin {
  LoginBloc _loginBloc;
  AuthenticationBloc _authenticationBloc;

  UserRepository get _userRepository => widget.userRepository;

  AnimationController controller;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();
    _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
    _loginBloc = LoginBloc(
      userRepository: _userRepository,
      authenticationBloc: _authenticationBloc,
    );
    controller = AnimationController(
        duration: const Duration(milliseconds: 3000), vsync: this);
    animation = CurvedAnimation(parent: controller, curve: Curves.easeIn);

    controller.forward();
   
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
       CustomPaint( 
          painter: CurvePainter(context),
          child: Container(
        child: FadeTransition(
          opacity: animation,
          child: Center(
            child: LoginForm(
              loginBloc: _loginBloc,
            ),
          ),
        ),
      ),
    )
    );
  }

  @override
  void dispose() {
    _loginBloc.dispose();
    super.dispose();
  }
}

class CurvePainter extends CustomPainter{
  final BuildContext context;
  
  CurvePainter(this.context);

  @override
  void paint(Canvas canvas, Size size) {
      Path path = Path();
    Paint paint = Paint();

    path.lineTo(0, size.height *0.55);
    path.quadraticBezierTo(size.width* 0.50, size.height*0.65,   size.width* 1.0, size.height*1.0);
    path.close();
    paint.color = Theme.of(context).primaryColor;
    canvas.drawPath(path, paint);
  }

   @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
