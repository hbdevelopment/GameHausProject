import 'package:flutter/material.dart';
import 'package:ghfrontend/models/guser.dart';
import 'package:ghfrontend/services/API_call.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ghfrontend/style/theme_style.dart' as Style;
import 'package:cloud_firestore/cloud_firestore.dart';

class GamerStats extends StatefulWidget {
  GamerStats({Key key, this.currentUser, this.userId}) : super(key: key);
  final GUser currentUser;
  final String userId;
  @override
  _GamerStatsState createState() => _GamerStatsState();
}

class _GamerStatsState extends State<GamerStats> {
  GUser mUser = GUser("","","","","",[""], {"":""}, {"":""});
  void initState() {
    // TODO: implement initState
    _getUserDetails();
    super.initState();
    print("USERID: ");
    print(widget.userId);

  }
  void _getUserDetails() async{


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



  //  }



  /*
   * the list holding all possible stats for all games from the API and a refresh button
   * Game Index:
   * 0, Overwatch
   * 1, Dota2
   * 2, Fortnite
   * 3, LOL
   * 4, refresh button
   */
  List<Widget> _gameStatsHolder = new List(5);
  bool hasOverwatchAPI=false;
  @override
  Widget build(BuildContext context) {

    // initialize the holder, initially, they all empty 0 size SizedBox

    return ListView(
      children: <Widget>[
        _createRefresh(),
        _createOverwatchGameStats(),

      ],
    );
  }


  /*
   * every time the users successfully linked their game account (one per attempt),
   * and after the all the API Json file successfully parsed into firebase
   * call this method, and this method will add one game info block into the holder list
   *
   * That's it: After user click "balabala(a random game) game connect" in Ted's page and after
   * the auth succeed, call this method
   */

   addAPIInfo(String platform, String region, String battleNetID) async{
     var returnedval=await APICall().AddPlayerAPIInfo(widget.currentUser.id, platform, region, battleNetID);
     _getUserDetails();

     print("Data: "+returnedval.toString());
   }

   addJsonInfo(String platform, String region, String battleNetID) async{

     var result=await APICall().callOverwatchAPI(mUser.id, platform, region, battleNetID);
     _getUserDetails();
   }

   updatePlayerOverwatchInfo() async{
     if (mUser.listOfAPI==null || mUser.listOfAPI["Overwatch"]==null){
       return;
     }
     Map<String, dynamic> data=jsonDecode(mUser.listOfAPI['Overwatch']);
     addJsonInfo(data['platform'], data['region'], data['battleNetID']);
     _getUserDetails();
   }



  /*
   * every time the users successfully disconnect their game account (one per attempt),
   * call this method, and this method will delete the corresponding stats block
   */




  /*
   * this method is to create the refresh button
   */
  Widget _createRefresh () {
    return FlatButton(
      child: Text("Refresh", style: Style.TextTemplate.drawer_listTitle),
      onPressed: updatePlayerOverwatchInfo
        // TODO: refresh the data in firebase from Game API (the Json file)

    );
  }



  /*
   * this method is to create Overwatch Stats block
   */
  Widget _createOverwatchGameStats(){


    if(mUser.listOfJson==null || mUser.listOfJson['Overwatch']==null){

      return SizedBox(
        width: 0,
        height: 0,
      );
    }else{
    /*
     * TODO: all data of this list should be from firebase after successfully authed.
     * For eg: Battle tag, level, KDA ratio, damage per 10 min, etc...
     */

    List allOverwatchStats = new List();
    print("Greetings");

    return Stack(
      children: <Widget>[

        // background theme color for Overwatch
        Opacity(
          opacity: 1.0,
          child: Container(
            color: Colors.amber,
          ),
        ),

        // the Game stats, derived from list allOverwatchStats(firebase) ... holding in multiple rows in a column
        Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Text("Name"+jsonDecode(mUser.listOfJson['Overwatch'])['name'] ?? "",style: Style.TextTemplate.drawer_listTitle)
              ]
            ),
            Row(),
            Row(),

          ],
        )

      ],
    );
  }
  }

  // TODO: add stats block create methods for other games

}
