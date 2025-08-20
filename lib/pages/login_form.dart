import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../base/customroute.dart';
import '../blog/login/loginbloc.dart';
import '../blog/login/login_event.dart';
import '../blog/login/login_state.dart';

import 'Settings/setting.dart';
import 'loading_indicator.dart';

class LoginForm extends StatefulWidget {
  final LoginBloc loginBloc;

  LoginForm({
    Key key,
    @required this.loginBloc,
  }) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  LoginBloc get _loginBloc => widget.loginBloc;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginEvent, LoginState>(
      bloc: _loginBloc,
      builder: (
        BuildContext context,
        LoginState state,
      ) {
        if (state is LoginFailure) {
          _onWidgetDidBuild(() {
            Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text('${state.error}'),
                backgroundColor: Colors.red,
              ),
            );
          });
        }

        return Form(
          child: Container(
            margin: EdgeInsets.fromLTRB(40, 20, 30, 40),
            padding: EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Stack(
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 80,
                        width: 60,
                        transform: Matrix4.translationValues(-10.0, -10.0, 0.0),
                        child: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColorLight,
                          child: Icon(
                            Icons.motorcycle,
                            size:40.0,
                            color: Colors.pinkAccent,
                          ),
                        ),
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                            labelText: 'User ID',
                            prefix: Icon(Icons.person_pin),
                            filled: true,
                            fillColor: Colors.white),
                        controller: _usernameController,
                      ),
                      Divider(),
                      TextFormField(
                        decoration: InputDecoration(
                            labelText: 'Password',
                            prefix: Icon(Icons.lock),
                            filled: true,
                            fillColor: Colors.white),
                        controller: _passwordController,
                        obscureText: true,
                      ),
                      RaisedButton(
                        padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
                        color: Colors.pinkAccent,
                        splashColor: Colors.amberAccent,
                        onPressed: state is! LoginLoading
                            ? _onLoginButtonPressed
                            : null,
                        child: Text(
                          'Please Sign In',                          
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      Container(
                        child: state is LoginLoading
                            ? CircularProgressIndicator()
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _onWidgetDidBuild(Function callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      callback();
    });
  }

  _onLoginButtonPressed() {
    _loginBloc.dispatch(LoginButtonPressed(
      username: _usernameController.text,
      password: _passwordController.text,
    ));
  }
}
