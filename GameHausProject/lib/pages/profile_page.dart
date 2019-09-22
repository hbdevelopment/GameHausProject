
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/generated/i18n.dart';
import 'package:ghfrontend/models/guser.dart';
import 'package:ghfrontend/services/authentication.dart';
import 'package:ghfrontend/services/date_helper.dart';
import 'package:ghfrontend/services/users.dart';
import 'package:ghfrontend/style/theme_style.dart' as Style;
import 'package:google_sign_in/google_sign_in.dart';


class ProfilePage extends StatefulWidget {

  ProfilePage({Key key,this.onSignedOut, this.users, this.currentUser, this.isMe, this.userId}) : super(key: key);
  final VoidCallback onSignedOut;
  final Users users;
  final GUser currentUser;

  final bool isMe;
  final String userId;

  @override
  State<StatefulWidget> createState() {
    return _ProfilePageState();
  }
}

class _ProfilePageState extends State<ProfilePage> {

  BaseAuth auth;
  Users users;
  GUser mUser = GUser("","","","","",[""]);
  VoidCallback onSignedOut;

  @override
  void initState() {
    // TODO: implement initState
    _getUserDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    Widget logOutButton;
    if (widget.isMe){
      logOutButton = FlatButton(
        child: Text("LOG OUT" ,style: Style.TextTemplate.app_bar_button,),
        onPressed: _signOut,
      );
    }else{
      logOutButton = Center();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Style.Colors.darkGrey,
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        //leading: Icon(Icons.keyboard_backspace, color: Colors.white,),
        title: Text(
          "PROFILE",
          style: Style.TextTemplate.app_bar,
        ),
        actions: <Widget>[
          logOutButton
        ],
      ),
      body: ListView(
        children: <Widget>[
          _createColorsRow(),
          _createProfilePicture(),
          Container(
            height: 300,
            padding: EdgeInsets.only(left: 17,right: 17),
            child: _createAttendingEvents(),
          )
        ],
      ),
    );
  }

  Widget _createColorsRow() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            height: 3,
            color: Style.Colors.blue,
          ),
        ),
        Expanded(
          child: Container(
            height: 3,
            color: Style.Colors.red,
          ),
        ),
        Expanded(
          child: Container(
            height: 3,
            color: Style.Colors.yellow,
          ),
        ),
        Expanded(
          child: Container(
            height: 3,
            color: Style.Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _createProfilePicture(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Center(
          child: Container(
            height: 170,
            width: 170,
            padding: EdgeInsets.only(bottom: 20),
            margin: EdgeInsets.only(top: 25,bottom: 15),
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: NetworkImage('https://robohash.org/'+(mUser.nickname ?? "")),
                  fit: BoxFit.cover
              ),
              borderRadius: new BorderRadius.all(new Radius.circular(100.0)),
              border: Border.all(
                  color: Colors.white,
                  width: 3
              ),

            ),
          ),
        ),

        Text(mUser.nickname, style: Style.TextTemplate.profile_name, textAlign: TextAlign.center,),
        Padding(
          padding: EdgeInsets.only(left: 17, top: 25, bottom: 10),
          child: Text("ATTENDING THESE EVENTS", style: Style.TextTemplate.heading, textAlign: TextAlign.start,),
        )
      ],
    );
  }

  void _getUserDetails() async{

    if (widget.isMe){
      try {
        var user = await FirebaseAuth.instance.currentUser();
        Firestore.instance.collection("users").document(user.uid).get().then((snapshot){
          GUser userData = GUser.fromSnapshot(snapshot);
          setState(() {
            mUser = userData;
          });
        });
      }catch (e) {
        print(e);
      }
    }else{
      try {
        Firestore.instance.collection("users").document(widget.userId).get().then((snapshot){
          GUser userData = GUser.fromSnapshot(snapshot);
          setState(() {
            mUser = userData;
          });
        });
      }catch (e) {
        print(e);
      }
    }


  }

  Widget _createAttendingEvents(){
    if (mUser.id.isNotEmpty){
      return new StreamBuilder(
          stream: Firestore.instance.collection("users").document(mUser.id).collection("attending_events").snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor),
                ),
              );
            } else {
              if (snapshot.data.documents.length == 0){
                return Center(
                  child: Text("No Events", style: Style.TextTemplate.tf_hint,),
                );
              }else{
                return ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, int index) =>
                      _buildEventView(snapshot.data.documents[index]),
                  itemCount: snapshot.data.documents.length,
                );
              }
            }
          });
    }else{
      return null;
    }
  }

  Widget _buildEventView(eventData){

    Widget eventImage;
    if (eventData["image_url"] == null){
      eventImage = Center(
        child: Text("No Image", style: Style.TextTemplate.heading,),
      );
    }else{
      eventImage = Image(
        image: NetworkImage(eventData["image_url"]),
        fit: BoxFit.fitHeight,
      );
    }

    return Container(
      width: 200,
      padding: EdgeInsets.only(bottom: 10),
      margin: EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Style.Colors.darkGrey
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 200,
            height: 150,
            color: Style.Colors.grey,
            child: eventImage
          ),
          Container(
            padding: EdgeInsets.only(left:10, top: 12,right: 10),
            child: Text(eventData["title"] ?? "", style: Style.TextTemplate.event_title,),
          ),
          Padding(
            padding: EdgeInsets.only(left: 8, top: 5),
            child: Row(
              children: <Widget>[
                Icon(Icons.access_time, color: Style.Colors.lightGrey,),
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.only(left: 5, right: 5),
                    child: RichText(
                        text: new TextSpan(
                            children: [
                              TextSpan(text: DateHelper().dayFormat(eventData['dateTime'].toDate()), style: Style.TextTemplate.attend_description,),
                              TextSpan(text: DateHelper().dateFormat(eventData['dateTime'].toDate()), style: Style.TextTemplate.attend_description,)
                            ]
                        )
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 8, top: 5),
            child: Row(
              children: <Widget>[
                Icon(Icons.location_on, color: Style.Colors.lightGrey,),
                Flexible(
                  child: Text(eventData["location"], style: Style.TextTemplate.attend_description),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  _signOut() async {
    GoogleSignIn googleSignIn = new GoogleSignIn();
    try {
      await FirebaseAuth.instance.signOut();
      await googleSignIn.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }
}