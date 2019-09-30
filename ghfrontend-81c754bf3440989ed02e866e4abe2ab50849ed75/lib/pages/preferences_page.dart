import 'package:flutter/material.dart';
import 'package:ghfrontend/models/guser.dart';
import 'package:ghfrontend/services/authentication.dart';

import 'package:flutter_auth_buttons/src/button.dart';
import 'package:ghfrontend/services/users.dart';

class PreferencesPage extends StatefulWidget {
  PreferencesPage(
      {this.currentUser, this.auth, this.users, this.onSetPreferences});

  final GUser currentUser;
  final BaseAuth auth;
  final Users users;
  final VoidCallback onSetPreferences;

  @override
  State<StatefulWidget> createState() => new _PreferencesPageState();
}

enum FormMode { LOGIN, SIGNUP }

class _PreferencesPageState extends State<PreferencesPage> {
  final _formKey = new GlobalKey<FormState>();

  String _nickname;
  String _errorMessage;

  bool _isIos;
  bool _isLoading;

  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void _validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });
    if (_validateAndSave()) {
      try {
        widget.users.updateNickname(widget.currentUser.id, _nickname);

        setState(() {
          _isLoading = false;
        });

        widget.onSetPreferences();
      } catch (e) {
        print('Error: $e');
        setState(() {
          _isLoading = false;
          if (_isIos) {
            _errorMessage = e.details;
          } else
            _errorMessage = e.message;
        });
      }
    }
  }

  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _signOut() async {
    try {
      await widget.auth.signOut();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    _isIos = Theme.of(context).platform == TargetPlatform.iOS;
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('GHaus - Update Preferences'),
          actions: <Widget>[
            new FlatButton(
                child: new Text('Logout',
                    style: new TextStyle(fontSize: 17.0, color: Colors.white)),
                onPressed: _signOut)
          ],
        ),
        body: Stack(
          children: <Widget>[
            _showBody(),
            _showCircularProgress(),
          ],
        ));
  }

  Widget _showCircularProgress() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }

  Widget _showBody() {
    return new Container(
        padding: EdgeInsets.all(16.0),
        child: new Form(
          key: _formKey,
          child: new ListView(
            shrinkWrap: true,
            children: <Widget>[
              _showNicknameInput(),
              _showPrimaryButton(),
              _showErrorMessage(),
            ],
          ),
        ));
  }

  Widget _showErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return new Text(
        _errorMessage,
        style: TextStyle(
            fontSize: 13.0,
            color: Colors.red,
            height: 1.0,
            fontWeight: FontWeight.w300),
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

  Widget _showNicknameInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Nickname',
            icon: new Icon(
              Icons.people,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty ? 'Nickname can\'t be empty' : null,
        onSaved: (value) => _nickname = value.trim(),
      ),
    );
  }

  Widget _showPrimaryButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new StretchableButton(
                buttonColor: Colors.white,
                buttonPadding: 0.0,
                borderRadius: 3.0,
                children: <Widget>[
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new Text('Update preferences',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontFamily: "Roboto",
                            fontWeight: FontWeight.w500,
                            color: Colors.black.withOpacity(0.54),
                          )))
                ],
                onPressed: () {
                  _validateAndSubmit();
                },
              ),
            ]));
  }
}
