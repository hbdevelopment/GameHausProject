import 'dart:convert';
import 'package:ghfrontend/style/theme_style.dart' as Style;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ghfrontend/models/guser.dart';
import 'package:ghfrontend/services/authentication.dart';

// class ChatPage extends StatefulWidget {
//   ChatPage(
//       {Key key,
//       this.title,
//       this.roomId,
//       this.auth,
//       this.currentUser,
//       this.onSignedOut})
//       : super(key: key);
//
//   final String roomId;
//   final String title;
//   final BaseAuth auth;
//   final VoidCallback onSignedOut;
//   final GUser currentUser;
//
//   @override
//   State<StatefulWidget> createState() => new _ChatPageState();
// }
//
// class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
//   final GlobalKey<FormState> formKey = GlobalKey<FormState>();
//
//   bool _isEmailVerified = false;
//
//   final TextEditingController _textController = new TextEditingController();
//   final List<GChatMessage> _messages = <GChatMessage>[];
//
//   bool _isLoading = false;
//   bool _isComposing = false;
//
//   String _userNickname;
//
//   final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
//   final FlutterLocalNotificationsPlugin _notifsPlugin =
//       new FlutterLocalNotificationsPlugin();
//
//   void _checkEmailVerification() async {
//     _isEmailVerified = await widget.auth.isEmailVerified();
//     if (!_isEmailVerified) {
//       _showVerifyEmailDialog();
//     }
//   }
//
//   void _resentVerifyEmail() {
//     widget.auth.sendEmailVerification();
//     _showVerifyEmailSentDialog();
//   }
//
//   void _showVerifyEmailDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         // return object of type Dialog
//         return AlertDialog(
//           title: new Text("Verify your account"),
//           content: new Text("Please verify account in the link sent to email"),
//           actions: <Widget>[
//             new FlatButton(
//               child: new Text("Resent link"),
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 _resentVerifyEmail();
//               },
//             ),
//             new FlatButton(
//               child: new Text("Dismiss"),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _showVerifyEmailSentDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         // return object of type Dialog
//         return AlertDialog(
//           title: new Text("Verify your account"),
//           content:
//               new Text("Link to verify account has been sent to your email"),
//           actions: <Widget>[
//             new FlatButton(
//               child: new Text("Dismiss"),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   void dispose() {
//     for (GChatMessage message in _messages) {
//       message.aController.dispose();
//     }
//     super.dispose();
//   }
//
//   _signOut() async {
//     try {
//       await widget.auth.signOut();
//       widget.onSignedOut();
//     } catch (e) {
//       print(e);
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//
//     _checkEmailVerification();
//
//     _registerNotifications();
//     _configureLocalNotifications();
//
//     _userNickname = widget.currentUser.nickname;
//   }
//
//   void _registerNotifications() {
//     _firebaseMessaging.requestNotificationPermissions();
//
//     _firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
//       print('onMessage: $message');
//       _showNotification(message['notification']);
//       return;
//     }, onResume: (Map<String, dynamic> message) {
//       print('onResume: $message');
//       return;
//     }, onLaunch: (Map<String, dynamic> message) {
//       print('onLaunch: $message');
//       return;
//     });
//
//     _firebaseMessaging.getToken().then((token) {
//       print('token: $token');
//       Firestore.instance
//           .collection('users')
//           .document(widget.currentUser.id)
//           .updateData({'pushToken': token}).catchError((err) {
//         Fluttertoast.showToast(msg: err.toString());
//       });
//     });
//   }
//
//   void _configureLocalNotifications() {
//     _notifsPlugin.initialize(new InitializationSettings(
//         new AndroidInitializationSettings('app_icon'),
//         new IOSInitializationSettings()));
//   }
//
//   void _showNotification(message) async {
//     var platformChannelSpecifics = new NotificationDetails(
//         new AndroidNotificationDetails(
//             'com.example.ghfrontend', 'GChat - Prototype', 'Just a prototype',
//             playSound: true,
//             enableVibration: true,
//             importance: Importance.Max,
//             priority: Priority.High),
//         new IOSNotificationDetails());
//
//     await _notifsPlugin.show(0, message['title'].toString(),
//         message['body'].toString(), platformChannelSpecifics,
//         payload: json.encode(message));
//   }
//
//   void _handleSubmitted(String text) {
//     _textController.clear();
//     setState(() {
//       _isComposing = false;
//     });
//     var documentRef = Firestore.instance
//         .collection('messages')
//         .document(widget.roomId)
//         .collection(widget.roomId)
//         .document(DateTime.now().millisecondsSinceEpoch.toString());
//     Firestore.instance.runTransaction((transaction) async {
//       await transaction.set(documentRef, {
//         'fromId': widget.currentUser.id,
//         'fromNickname': widget.currentUser.nickname,
//         'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
//         'content': text,
//         'type': 0
//       });
//     });
//   }
//
//   Widget _buildMessage(dynamic message) {
//     GChatMessage gmessage = new GChatMessage(
//       text: message['content'],
//       nickname: message['fromNickname'],
//       aController: new AnimationController(
//           duration: new Duration(milliseconds: 600), vsync: this),
//     );
//     // gmessage.aController.forward();
//     return gmessage;
//   }
//
//   Widget _wrapWithCardColorBox(Widget toWrap) {
//     return new Container(
//       decoration: new BoxDecoration(
//         color: Theme.of(context).cardColor,
//       ),
//       child: toWrap,
//     );
//   }
//
//   Widget _wrapWithIconTheme(Widget toWrap) {
//     return new IconTheme(
//         data: new IconThemeData(color: Theme.of(context).accentColor),
//         child: toWrap);
//   }
//
//   Widget _buildTextComposer() {
//     return _wrapWithCardColorBox(_wrapWithIconTheme(new Container(
//         margin: const EdgeInsets.symmetric(horizontal: 6.0),
//         child: new Row(children: <Widget>[
//           new Flexible(
//               child: new TextField(
//             controller: _textController,
//             onChanged: (String text) {
//               setState(() {
//                 _isComposing = text.length > 0;
//               });
//             },
//             onSubmitted: _handleSubmitted,
//             decoration:
//                 new InputDecoration.collapsed(hintText: "Send a message"),
//           )),
//           new Container(
//               margin: new EdgeInsets.symmetric(horizontal: 4.0),
//               child: new IconButton(
//                 icon: new Icon(Icons.send),
//                 onPressed: _isComposing
//                     ? () => _handleSubmitted(_textController.text)
//                     : null,
//               ))
//         ]))));
//   }
//
//   Widget _buildMessageList() {
//     return new Flexible(
//       child: new StreamBuilder(
//           stream: Firestore.instance
//               .collection('messages')
//               .document(widget.roomId)
//               .collection(widget.roomId)
//               .orderBy('timestamp', descending: true)
//               .limit(30)
//               .snapshots(),
//           builder: (context, snapshot) {
//             if (!snapshot.hasData) {
//               return Center(
//                 child: CircularProgressIndicator(
//                   valueColor: AlwaysStoppedAnimation<Color>(
//                       Theme.of(context).primaryColor),
//                 ),
//               );
//             } else {
//               return ListView.builder(
//                 padding: new EdgeInsets.all(6.0),
//                 reverse: true,
//                 itemBuilder: (_, int index) =>
//                     _buildMessage(snapshot.data.documents[index]),
//                 itemCount: snapshot.data.documents.length,
//               );
//             }
//           }),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return new Scaffold(
//         appBar: new AppBar(
//           title: new Text(widget.title),
//           actions: <Widget>[
//             new FlatButton(
//                 child: new Text('Logout',
//                     style: new TextStyle(fontSize: 17.0, color: Colors.white)),
//                 onPressed: _signOut)
//           ],
//         ),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: <Widget>[
//               _buildMessageList(),
//               new Divider(height: 1.0),
//               _buildTextComposer()
//             ],
//           ),
//         ));
//   }
// }

class GChatMessage extends StatelessWidget {
  GChatMessage({this.text, this.aController, this.nickname});

  final String text;
  final String nickname;
  final AnimationController aController;

  Widget _wrapWithEaseOutAnimation(Widget toWrap) {
    return new SizeTransition(
      sizeFactor:
          new CurvedAnimation(parent: aController, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: toWrap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Container(
              margin: const EdgeInsets.only(right: 12.0),
              child: new CircleAvatar(
                backgroundImage: NetworkImage('https://robohash.org/'+(nickname ?? "")),
                //child: new Text(nickname[0],style: Style.TextTemplate.button_signup,)
              )
              ),
          new Expanded(
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Text(nickname, style: Style.TextTemplate.chat_title),
                new Container(
                  margin: const EdgeInsets.only(top: 4.0),
                  child: new Text(text, style: Style.TextTemplate.chat_description,),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
