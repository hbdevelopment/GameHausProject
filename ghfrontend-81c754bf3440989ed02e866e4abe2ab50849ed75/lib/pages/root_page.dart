import 'package:flutter/material.dart';
import 'package:ghfrontend/models/guser.dart';
import 'package:ghfrontend/pages/login_signup_page.dart';
import 'package:ghfrontend/pages/preferences_page.dart';
import 'package:ghfrontend/services/authentication.dart';
import 'package:ghfrontend/pages/home_page.dart';
import 'package:ghfrontend/services/users.dart';

class RootPage extends StatefulWidget {
  RootPage({this.auth, this.users});

  final BaseAuth auth;
  final Users users;

  @override
  State<StatefulWidget> createState() => new _RootPageState();
}

enum AppStatus {
  NOT_DETERMINED,
  STARTUP,
  DO_LOGIN,
  DO_SIGN_UP,
  LOGGED_IN,
}

class _RootPageState extends State<RootPage> {
  AppStatus appStatus = AppStatus.NOT_DETERMINED;
  GUser _currentUser;

  @override
  void initState() {
    super.initState();
    widget.auth.getCurrentUser().then((user) {
      if (user != null) {
        widget.users.ensureUserCreated(user).then((currentUser) {
          setState(() {
            _currentUser = currentUser;
            appStatus = AppStatus.LOGGED_IN;
          });
        });
      } else {
        setState(() {
          appStatus = AppStatus.STARTUP;
        });
      }
    });
  }

  void _onLoggedIn() {
    widget.auth.getCurrentUser().then((user) {
      widget.users.ensureUserCreated(user).then((currentUser) {
        setState(() {
          _currentUser = currentUser;
          appStatus = AppStatus.LOGGED_IN;
        });
      });
    });
  }

  void _onSignedOut() {
    setState(() {
      appStatus = AppStatus.STARTUP;
      _currentUser = null;
    });
  }


  void _onSetPreferences() {
    widget.users.getCurrentUser(_currentUser.id).then((currentUser) {
      setState(() {
        _currentUser = currentUser;
      });
    });
  }

  Widget _buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildOpeningChoice() {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
                margin: EdgeInsets.all(6.0),
                child: Center(
                  child: FlatButton(
                      onPressed: () {
                        setState(() {
                          appStatus = AppStatus.DO_LOGIN;
                        });
                      },
                      child: Text(
                        'Log In',
                        style: TextStyle(fontSize: 16.0),
                      ),
                      color: Color(0xffdd4b39),
                      highlightColor: Color(0xffff7f7f),
                      splashColor: Colors.transparent,
                      textColor: Colors.white,
                      padding: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0)),
                )),
            Container(
                margin: EdgeInsets.all(6.0),
                child: Center(
                  child: FlatButton(
                      onPressed: () {
                        setState(() {
                          appStatus = AppStatus.DO_SIGN_UP;
                        });
                      },
                      child: Text(
                        'Sign Up',
                        style: TextStyle(fontSize: 16.0),
                      ),
                      color: Color(0xffdd4b39),
                      highlightColor: Color(0xffff7f7f),
                      splashColor: Colors.transparent,
                      textColor: Colors.white,
                      padding: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0)),
                )),
          ],
        ),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    switch (appStatus) {
      case AppStatus.NOT_DETERMINED:
        return _buildWaitingScreen();
        break;
      case AppStatus.STARTUP:
        return _buildOpeningChoice();
        break;
      case AppStatus.DO_LOGIN:
        return new LoginSignUpPage(
            auth: widget.auth, onSignedIn: _onLoggedIn, onSignedOut:_onSignedOut, isLogin: true);
        break;
      case AppStatus.DO_SIGN_UP:
        return new LoginSignUpPage(
            auth: widget.auth, onSignedIn: _onLoggedIn, onSignedOut:_onSignedOut, isLogin: false);
        break;
      case AppStatus.LOGGED_IN:
        if (_currentUser != null) {
          if (_currentUser.incompletePreferences()) {
            return new PreferencesPage(
              currentUser: _currentUser,
              users: widget.users,
              auth: widget.auth,
              onSetPreferences: _onSetPreferences,
            );
          } else {
            return new HomePage(
              currentUser: _currentUser,
              auth: widget.auth,
              onSignedOut: _onSignedOut,
            );
          }
        } else {
          return _buildWaitingScreen();
        }
        break;
      default:
        return _buildWaitingScreen();
    }
  }
}
