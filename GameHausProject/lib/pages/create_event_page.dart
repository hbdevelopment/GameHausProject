import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ghfrontend/models/event.dart';
import 'package:ghfrontend/models/guser.dart';
import 'package:ghfrontend/pages/choose_gif_page.dart';
import 'package:ghfrontend/style/theme_style.dart' as Style;
import 'package:giphy_client/giphy_client.dart';
import 'package:intl/intl.dart';

class CreateEventPage extends StatefulWidget {

//  CreateEventPage({this.roomId});
//  final String roomId;

  @override
  State<StatefulWidget> createState() {
    return _CreateEventPageState();
  }
}

class _CreateEventPageState extends State<CreateEventPage> {
  final dateController = TextEditingController();
  final locationController = TextEditingController();
  final timeController = TextEditingController();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final capacityController = TextEditingController();

  var radioValue = 0;
  var groupValue=0;

  /// FORM ELECTIONS
  String title = "";
  String selectedGame = "";
  DateTime selectedDate;
  TimeOfDay selectedTime;
  String selectedLocation = "";
  int capacity = 0;
  String type = "Casual";
  String group="LFG";
  String description = "";

  String selectedRoomId = "";

  GiphyGif selectedGif;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat("yyyy-MM-dd");
    final timeFormat = DateFormat("h:mm a");

    return new Scaffold(
      backgroundColor: Style.Colors.primaryColor,
      appBar: AppBar(
        backgroundColor: Style.Colors.darkGrey,
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        //leading: Icon(Icons.keyboard_backspace, color: Colors.white,),
        title: Text(
          "NEW EVENT",
          style: Style.TextTemplate.app_bar,
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(
              "Create",
              style: Style.TextTemplate.app_bar_button,
            ),
            onPressed: _createEventButtonPressed,
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          _createColorsRow(),
          new Container(
            margin: EdgeInsets.only(top: 20),
            padding: EdgeInsets.only(left: 17, bottom: 10, top: 10),
            color: Style.Colors.darkGrey,
            child:
                _createTFF("EVENT TITLE", titleController, TextInputType.text),
          ),
          Padding(
            padding: EdgeInsets.only(left: 17, top: 18, bottom: 13),
            child: Text(
              "CHOOSE GAME",
              style: Style.TextTemplate.heading,
              textAlign: TextAlign.start,
            ),
          ),
          new Container(
            color: Style.Colors.darkGrey,
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  width: 50,
                  height: 50,
                  decoration: _borderSelection1(),
                  child: IconButton(
                    icon: Image.asset('assets/images/fortnite_icon.png'),
                    onPressed: () => chooseGame("FORTNITE"),
                  ),
                ),
                Container(
                  width: 50,
                  height: 50,
                  decoration: _borderSelection(),
                child: IconButton(
                  icon: Image.asset('assets/images/madisonesports_icon.png'),
                  onPressed: ()=> chooseGame("Madison eSports Club")
                )
              ),

                Container(
                  width: 50,
                  height: 50,
                  decoration: _borderSelection2(),
                  child: IconButton(
                    icon: Image.asset('assets/images/dota_icon.png'),
                    onPressed: () => chooseGame("DOTA 2"),
                  ),
                ),
                Container(
                  width: 50,
                  height: 50,
                  decoration: _borderSelection3(),
                  child: IconButton(
                    icon: Image.asset('assets/images/lol_icon.png'),
                    onPressed: () => chooseGame("LOL"),
                  ),
                ),
                Container(
                  width: 50,
                  height: 50,
                  decoration: _borderSelection4(),
                  child: IconButton(
                    icon: Image.asset('assets/images/overwatch_icon.png'),
                    onPressed: () => chooseGame("OVERWATCH"),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 17, top: 18, bottom: 13),
            child: Text(
              "WHEN, WHERE & GIF",
              style: Style.TextTemplate.heading,
              textAlign: TextAlign.start,
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 15),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                      padding: EdgeInsets.only(left: 17, bottom: 10, top: 10),
                      margin: EdgeInsets.only(right: 15),
                      color: Style.Colors.darkGrey,
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                  child: Container(
                                margin: EdgeInsets.only(right: 16),
                                child: DateTimeField(
                                  style: new TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.normal),
                                  cursorColor: Colors.white,
                                  showCursor: true,
                                  decoration: InputDecoration(
                                      hintText: "Date",
                                      hintStyle: Style.TextTemplate.tf_hint),
                                  format: dateFormat,
                                  onShowPicker: (context, currentValue) {
                                    return showDatePicker(
                                        context: context,
                                        firstDate: DateTime(1900),
                                        initialDate:
                                            currentValue ?? DateTime.now(),
                                        lastDate: DateTime(2100));
                                  },
                                  onChanged: (dt) =>
                                      setState(() => selectedDate = dt),
                                ),
                              )),
                              Expanded(
                                  child: Container(
                                margin: EdgeInsets.only(left: 5, right: 0),
                                child: DateTimeField(
                                  style: new TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.normal),
                                  decoration: InputDecoration(
                                      hintText: "Time",
                                      hintStyle: Style.TextTemplate.tf_hint),
                                  format: timeFormat,
                                  onShowPicker: (context, currentValue) async {
                                    final time = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.fromDateTime(
                                          currentValue ?? DateTime.now()),
                                    );
                                    return DateTimeField.convert(time);
                                  },
                                  onChanged: (t) => setState(() =>
                                      selectedTime = TimeOfDay.fromDateTime(t)),
                                ),
                              ))
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(right: 10),
                                  height: 1,
                                  color: Colors.white,
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(left: 5, right: 18),
                                  height: 1,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          _createTFF("Location", locationController,
                              TextInputType.text)
                        ],
                      )),
                ),
                Container(
                  width: 2,
                  height: 40,
                  color: Colors.white,
                ),
                Container(
                    width: 120,
                    height: 115,
                    margin: EdgeInsets.only(left: 15),
                    //padding: EdgeInsets.only(top: 10, bottom: 10),
                    color: Style.Colors.darkGrey,
                    child: _showGif()),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 17, top: 18, bottom: 13),
            child: Text(
              "HOW MANY PEOPLE & WHAT KIND",
              style: Style.TextTemplate.heading,
              textAlign: TextAlign.start,
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 3, bottom: 3, left: 18, right: 18),
            color: Style.Colors.darkGrey,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: _createTFF(
                      "How Many?", capacityController, TextInputType.number),
                ),
                Container(
                  width: 2,
                  height: 20,
                  color: Colors.white,
                ),
                new Radio(
                  value: 0,
                  groupValue: radioValue,
                  activeColor: Colors.white,
                  onChanged: _handleRadioValueChange,
                ),
                new Text(
                  'Casual',
                  style: Style.TextTemplate.tf_hint,
                ),
                new Radio(
                  value: 1,
                  groupValue: radioValue,
                  onChanged: _handleRadioValueChange,
                  activeColor: Colors.white,
                ),
                new Text(
                  'Competitive',
                  style: Style.TextTemplate.tf_hint,
                ),
              ],
            ),
          ), Container(
        padding: EdgeInsets.only(top: 3, bottom: 3, left: 18, right: 18),
                      color: Style.Colors.darkGrey,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Text("What Type?", style: Style.TextTemplate.tf_hint),
                          ),
                          Container(
                            width: 2,
                            height: 20,
                            color: Colors.white,
                          ),
                          new Radio(
                            value: 0,
                            groupValue: groupValue,
                            activeColor: Colors.white,
                            onChanged: handleGroupTypeChange,
                          ),
                          new Text(
                            'LFG',
                            style: Style.TextTemplate.tf_hint,
                          ),
                          new Radio(
                            value: 1,
                            groupValue: groupValue,
                            onChanged: handleGroupTypeChange,
                            activeColor: Colors.white,
                          ),
                          new Text(
                            'Tournament',
                            style: Style.TextTemplate.tf_hint,
                          ),
                        ],
                      ),
                    ),
          Padding(
            padding: EdgeInsets.only(left: 17, top: 36, bottom: 13),
            child: Text(
              "TELL US MORE",
              style: Style.TextTemplate.heading,
              textAlign: TextAlign.start,
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 30),
            child: _createDescriptionTFF("Format, prizes, the works..."),
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

  Widget _createTFF(hint, controller, keyboard) {
    return Container(
      child: TextFormField(
        style:
            new TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
        controller: controller,
        keyboardType: keyboard,
        autofocus: false,
        decoration: InputDecoration(
          enabled: true,
          hintText: hint,
          hintStyle: Style.TextTemplate.tf_hint,
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
          ),
        ),
//        validator: (value) => value.isEmpty ? 'Password can\'t be empty' : null,
//        onSaved: (value) => _email = value.trim(),
      ),
    );
  }

  Widget _createDescriptionTFF(hint) {
    return Container(
      height: 300,
      margin: EdgeInsets.only(left: 30, right: 30, top: 5),
      padding: EdgeInsets.only(left: 15, right: 15),
      color: Style.Colors.darkGrey,
      child: TextFormField(
        style:
            new TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
        controller: descriptionController,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        autofocus: false,
        decoration: InputDecoration(
          enabled: true,
          hintText: hint,
          hintStyle: Style.TextTemplate.tf_hint,
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
          ),
        ),
      ),
    );
  }

  void _handleRadioValueChange(int value) {
    setState(() {
      radioValue = value;

      switch (radioValue) {
        case 0:
        print("Casual");
          type = "Casual";
          break;
        case 1:
        print("Competitive");
          type = "Competitive";
          break;
        default:
          break;
      }
    });
  }
  void handleGroupTypeChange(int value){
    setState(() {
      groupValue=value;
    });
    switch (groupValue) {
      case 0:

        group = "LFG";
        print(group);
        break;
      case 1:

        group= "Tournament";
        print(group);
        break;
      default:
        break;
    }
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
                  },
                  child: Text(
                    "OK",
                    style: Style.TextTemplate.heading,
                  ))
            ],
          );
        });
  }

  BoxDecoration _borderSelection1() {
    if (selectedGame == "FORTNITE") {
      return BoxDecoration(border: Border.all(color: Colors.white, width: 2));
    } else {
      return null;
    }
  }

  BoxDecoration _borderSelection2() {
    if (selectedGame == "DOTA 2") {
      return BoxDecoration(border: Border.all(color: Colors.white, width: 2));
    } else {
      return null;
    }
  }

  BoxDecoration _borderSelection3() {
    if (selectedGame == "LOL") {
      return BoxDecoration(border: Border.all(color: Colors.white, width: 2));
    } else {
      return null;
    }
  }

  BoxDecoration _borderSelection4() {
    if (selectedGame == "OVERWATCH") {
      return BoxDecoration(border: Border.all(color: Colors.white, width: 2));
    } else {
      return null;
    }
  }
BoxDecoration _borderSelection(){
  if (selectedGame=="Madison eSports Club"){
  return BoxDecoration(border: Border.all(color: Colors.white, width: 2));
}else{
  return null;
}
}

  void _navigateToChooseGif() async{
    selectedGif = await Navigator.push(context, MaterialPageRoute(builder: (context) => ChooseGifPage()));
//    setState(() async{
//      selectedGif = await GiphyPicker.pickGif(context: context, apiKey: 'RbR2vCHAXm4IOfn06Ap0UDm5SVzTkyNm');
//    });
  }

  Widget _showGif() {
    if (selectedGif != null) {
      return GestureDetector(
      onLongPress: _navigateToChooseGif,
      child: Container(
        color: Style.Colors.darkGrey,
        child: Image(
          image: NetworkImage(selectedGif.images.downsized.url),
          fit: BoxFit.fitHeight,
        ),
      )
    );
    } else {
      return FlatButton(
        child: Text(
          "Choose\nGIF",
          style: Style.TextTemplate.button_signin,
          textAlign: TextAlign.center,
        ),
        onPressed: _navigateToChooseGif,
      );
    }
  }

  void chooseGame(game) {
    setState(() {
      selectedGame = game;
      switch (game){
        case "FORTNITE":
          selectedRoomId = "nYQT0NBBAQGRYI3TSVQ0";
          break;
        case "DOTA 2":
          selectedRoomId = "m6p76gE4hnigPW4Bi6hJ";
          break;
        case "LOL":
          selectedRoomId = "eGKPNy54lvyQoatYE5Mx";
          break;
        case "OVERWATCH":
          selectedRoomId = "5crWuxFMuNY7E9G9xdz9";
          break;
        case "Madison eSports Club":
          selectedRoomId="6CkGuBewHOuPOKmhl2NI";
        break;
      }

    });
  }

  Future _createEventButtonPressed() async {

    title = titleController.text;
    selectedLocation = locationController.text;
    if (capacityController.text.isNotEmpty) {
      capacity = int.parse(capacityController.text);
    }
    description = descriptionController.text;

    if (title.isEmpty){
      _showDialog(context, "Opps", "Event title cannot be empty.");
    }else if (selectedGame.isEmpty){
      _showDialog(context, "Opps", "Please select a game.");
    }else if (selectedDate == null){
      _showDialog(context, "Opps", "Date cannot be empty.");
    }else if (selectedTime == null){
      _showDialog(context, "Opps", "Time cannot be empty.");
    }else if (selectedLocation.isEmpty){
      _showDialog(context, "Opps", "Location cannot be empty.");
    }else if (selectedGif == null){
      _showDialog(context, "Opps", "Please Choose a GIF.");
    }else if (capacity == null || capacity <= 0){
      _showDialog(context, "Opps", "Capacity cannot be empty.");
    }else if (type.isEmpty){
      _showDialog(context, "Opps", "Invalid Event Type");
    }else if (type.isEmpty){
      _showDialog(context, "Opps", "Invalid Group Type");
    }else if (description.isEmpty){
      _showDialog(context, "Opps", "Description cannot be empty.");
    }else {

      try {
        var user = await FirebaseAuth.instance.currentUser();
        Firestore.instance.collection("users").document(user.uid).get().then((snapshot){
          GUser userData = GUser.fromSnapshot(snapshot);
          DateTime date = DateTimeField.combine(selectedDate, selectedTime);
          Event event = Event(
              "",
              selectedRoomId,
              title,
              description,
              selectedGame,
              selectedGif.images.downsized.url,
              date,
              capacity,
              selectedLocation,
              type, group, user.uid,userData.nickname);

          Map<String, dynamic> eventData = event.toJson();
          _createEventInFirestore(eventData);
        });
      }catch (e) {
        _showDialog(context, "Fail To Create Event", e.message);
      }
    }
  }


  void _createEventInFirestore(eventData){
    Firestore.instance
        .collection('events')
        .add(eventData).then((snapshot) {
        snapshot.updateData({'documentID': snapshot.documentID});
      Fluttertoast.showToast(msg: "Successfully Created Event");
      Navigator.of(context).pop();
    }).catchError((err) {
      Fluttertoast.showToast(msg: err.toString());
    });
  }
}
