
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ghfrontend/models/event.dart';
import 'package:ghfrontend/models/guser.dart';
import 'package:ghfrontend/services/authentication.dart';
import 'package:ghfrontend/services/date_helper.dart';
import 'package:ghfrontend/services/users.dart';
import 'package:ghfrontend/style/theme_style.dart' as Style;



class AttendancePage extends StatefulWidget {

  AttendancePage({Key key,this.eventData, this.currentUser, this.boolAttend}) : super(key: key);
  final DocumentSnapshot eventData;
  final GUser currentUser;
  final bool boolAttend;
  @override
  State<StatefulWidget> createState() {
    return _AttendancePageState();
  }
}

class _AttendancePageState extends State<AttendancePage> {

  BaseAuth auth;
  Users users;
  GUser mUser = GUser("","","","","",[""]);
  VoidCallback onSignedOut;

  @override
  void initState() {
    // TODO: implement initState
    //_getUserDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Style.Colors.darkGrey,
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        //leading: Icon(Icons.keyboard_backspace, color: Colors.white,),
        title: Text(
          widget.eventData["game"],
          style: Style.TextTemplate.app_bar,
        ),
      ),
      body: ListView(
        children: <Widget>[
          _createColorsRow(),
          _returnTitle(),
          _returnDetailView(),
          _returnButtons()
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

  Widget _returnTitle(){
    if (widget.boolAttend){
      return Center(
        child: Container(
          margin: EdgeInsets.only(top: 30),
          child: Text("Do you want to attend this event?", style: Style.TextTemplate.button_signin,)
        ),
      );
    }else{
      return Center(
        child: Container(
            margin: EdgeInsets.only(top: 30),
            child: Text("Do you want to unattend this event?", style: Style.TextTemplate.button_signin,)
        ),
      );
    }
  }

  Widget _returnDetailView(){
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 15, top: 20),
            child: Text("Title:", style: Style.TextTemplate.heading,),
          ),
          Padding(
            padding: EdgeInsets.only(left: 15, bottom: 5),
            child: Text(widget.eventData["title"], style: Style.TextTemplate.description,),
          ),
          Padding(
            padding: EdgeInsets.only(left: 15, top: 20),
            child: Text("Description:", style: Style.TextTemplate.heading,),
          ),
          Padding(
            padding: EdgeInsets.only(left: 15, bottom: 5),
            child: Text(widget.eventData["description"], style: Style.TextTemplate.description,),
          ),
          Padding(
            padding: EdgeInsets.only(left: 15,top: 20),
            child: Text("Location:", style: Style.TextTemplate.heading,),
          ),
          Padding(
            padding: EdgeInsets.only(left: 15),
            child: Text(widget.eventData["location"], style: Style.TextTemplate.description,),
          ),
          Padding(
            padding: EdgeInsets.only(left: 15, top: 20),
            child: Text("Date:", style: Style.TextTemplate.heading,),
          ),
          Padding(
            padding: EdgeInsets.only(left: 15),
            child: Text(DateHelper().dayDateFormat(widget.eventData["dateTime"].toDate()), style: Style.TextTemplate.description,),
          ),
        ],
      ),
    );
  }

  Widget _returnButtons(){
    return Container(
      margin: EdgeInsets.only(top: 60),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 150,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(50)
            ),
            child: FlatButton(
              child: Text("NO", style: Style.TextTemplate.button_signin,),
              onPressed: _noButton,
            ),
          ),
          Container(
            width: 150,
            child: FlatButton(
              child: Text("YES", style: Style.TextTemplate.button_signup,),
              onPressed: _yesButton,
            ),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50)
            ),
          )
        ],
      ),
    );
  }

  void _yesButton() async{
    Fluttertoast.showToast(msg: "Loading...");
    Event eventObj = Event.fromSnapshot(widget.eventData);
    Map<String, dynamic> data = eventObj.toJson();

    if (widget.boolAttend == true){
          print("ATTEND");
          await Firestore.instance.collection("events").document(widget.eventData.documentID)
              .collection("attendance_uid").document(widget.currentUser.id)
              .setData({"user_id": widget.currentUser.id});
          await Firestore.instance.collection("users").document(widget.currentUser.id)
              .collection("attending_events").document(widget.eventData.documentID)
              .setData(data).then((value){
            _showDialog(context, "Success", "Successfully attend event");
          });
    }else{
        print("UNATTEND");
        await Firestore.instance.collection("events").document(widget.eventData.documentID)
            .collection("attendance_uid").document(widget.currentUser.id)
            .delete();
        await Firestore.instance.collection("users").document(widget.currentUser.id)
            .collection("attending_events").document(widget.eventData.documentID)
            .delete().then((value){
          _showDialog(context, "Success", "Successfully unattend event");
        });
    }
  }

  void _noButton(){
    Navigator.of(context).pop();
  }

  void _showDialog(context, title, description) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Style.Colors.darkGrey,
            title: new Text(
              title,
              style: Style.TextTemplate.alert_title,
            ),
            content: new Text(
              description,
              style: Style.TextTemplate.alert_description,
            ),
            actions: <Widget>[
              new FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "OK",
                    style: Style.TextTemplate.heading,
                  ))
            ],
          );
        });
  }
}
