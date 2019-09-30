import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ghfrontend/models/guser.dart';
import 'package:ghfrontend/pages/game_page.dart';
import 'package:ghfrontend/services/authentication.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.auth, this.currentUser, this.onSignedOut})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final GUser currentUser;

  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool _isEmailVerified = false;

  @override
  void initState() {
    super.initState();

    _checkEmailVerification();
  }

  void _checkEmailVerification() async {
    _isEmailVerified = await widget.auth.isEmailVerified();
    if (!_isEmailVerified) {
      _showVerifyEmailDialog();
    }
  }

  void _resentVerifyEmail() {
    widget.auth.sendEmailVerification();
    _showVerifyEmailSentDialog();
  }

  void _showVerifyEmailDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Verify your account"),
          content: new Text("Please verify account in the link sent to email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Resent link"),
              onPressed: () {
                Navigator.of(context).pop();
                _resentVerifyEmail();
              },
            ),
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showVerifyEmailSentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Verify your account"),
          content:
              new Text("Link to verify account has been sent to your email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  void _navigateToChat(String roomId, String roomName, String documentID) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => GamePage(
                documentID: documentID,
                title: '$roomName',
                currentUser: widget.currentUser,
                auth: widget.auth)));
  }



  // TODO: rename these so they make sense? These aren't rooms anymore they are games
  Widget _buildRoomsList() {
    // TODO: update this to work through a service
    return new StreamBuilder(
        stream: Firestore.instance.collection('rooms').limit(30).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor),
              ),
            );
          } else {
            return ListView.builder(
              itemBuilder: (_, int index) =>
                  _buildRoomBox(snapshot.data.documents[index]),
              itemCount: snapshot.data.documents.length,
            );
          }
        });
  }

  Widget _buildRoomBox(dynamic roomData) {
    return Center(
        child: Container(
            margin: const EdgeInsets.all(16.0),
            child: Card(
              child: InkWell(
                splashColor: Colors.blue.withAlpha(30),
                onTap: () {
                  print('Card tapped.');
                },
                child:
                    Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.home),
                    title: Text(roomData['name']),
                  //  subtitle: Text('ID: ' + roomData['id']),
                  ),
                  ButtonTheme.bar(
                    // make buttons use the appropriate styles for cards
                    child: ButtonBar(
                      children: <Widget>[
                        FlatButton(
                          child: const Text('JOIN'),
                          onPressed: () {
                            _navigateToChat(roomData['id'], roomData['name'], roomData.documentID);
                          },
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            )));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          //changed to GAME HAUS
          title: new Text('ROOMS'),
          actions: <Widget>[
            new FlatButton(
                child: new Text('Logout',
                    style: new TextStyle(fontSize: 17.0, color: Colors.white)),
                onPressed: _signOut)
          ],
        ),
        body: Container(child: Center(child: _buildRoomsList())));
  }
}
