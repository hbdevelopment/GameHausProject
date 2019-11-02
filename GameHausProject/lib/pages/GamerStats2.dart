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

    print("Greetings");

    // store all info from Json into a Map
    Map<String, dynamic> allInfo = jsonDecode(mUser.listOfJson['Overwatch']);

    return Stack(
      children: <Widget>[
        Opacity(
          opacity: 0.65,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: Colors.amber,
            ),
            width: MediaQuery.of(context).size.width,
            height: 300,
          ),
        ),

        // all info in the OverwatchStats block
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[

            // Overwatch logo
            Image.asset('assets/images/overwatch_icon.png',
                width: 30,
                height: 30
            ),

            // all stats
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget> [

                // User info
                Padding(
                  padding: EdgeInsets.only(right: 5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        alignment: AlignmentDirectional.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          color: Colors.black38,
                        ),
                        width: 120,
                        height: 25,
                        child: Text('User Info',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Stack(
                        alignment: AlignmentDirectional.center,
                        children: <Widget>[
                          Image.network(allInfo['icon'],
                            width: 45,
                            height: 45,
                          ),
                          Image.network(allInfo['levelIcon'],
                            width: 90,
                            height: 90,
                          ),
                          Image.network(allInfo['prestigeIcon'],
                            width: 90,
                            height: 90,
                          ),
                        ],
                      ),
                      Text(allInfo['name'],
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),

                      Text('LV: ' + allInfo['prestige'].toString() + allInfo['level'].toString(),
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text('Total Wins: ' + allInfo['gamesWon'].toString(),
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),

                    ],
                  ),
                ),

                // Separator line
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.white70,
                  ),
                  width: 5,
                  height: 240,
                ),


                // Competitive stats
                Padding(
                  padding: EdgeInsets.only(right: 5, left: 5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        alignment: AlignmentDirectional.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          color: Colors.black38,
                        ),
                        width: 120,
                        height: 25,
                        child: Text('Competitive',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text('Winrate: ' + (allInfo['competitiveStats']['games']['won']*100/allInfo['competitiveStats']['games']['played']).roundToDouble().toString(),
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text('Gold Medals: ' + allInfo['competitiveStats']['awards']['medalsGold'].toString(),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.orange,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text('Silver Medals: ' + allInfo['competitiveStats']['awards']['medalsSilver'].toString(),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black26,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text('Bronze Medals: ' + allInfo['competitiveStats']['awards']['medalsBronze'].toString(),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.brown,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text('Cards: ' + allInfo['competitiveStats']['awards']['cards'].toString(),
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.brown,
                        ),
                      ),
                    ],
                  ),
                ),

                // Separator line
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.white70,
                  ),
                  width: 5,
                  height: 240,
                ),


                // Quick Play stats
                Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,

                    children: <Widget>[
                      Container(
                        alignment: AlignmentDirectional.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          color: Colors.black38,
                        ),
                        width: 120,
                        height: 25,
                        child: Text('Quick Play',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text('Game Wins: ' + allInfo['quickPlayStats']['games']['won'].toString(),
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text('Gold Medals: ' + allInfo['quickPlayStats']['awards']['medalsGold'].toString(),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.orange,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text('Silver Medals: ' + allInfo['quickPlayStats']['awards']['medalsSilver'].toString(),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black26,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text('Bronze Medals: ' + allInfo['quickPlayStats']['awards']['medalsBronze'].toString(),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.brown,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text('Cards: ' + allInfo['quickPlayStats']['awards']['cards'].toString(),
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.brown,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
  }

  // TODO: add stats block create methods for other games

}
