import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class APICall{
  Future<Map<String, dynamic>> callOverwatchAPI(String userID, String platform, String region, String battleNetID) async{
    String url = 'https://ow-api.com/v1/stats/${platform}/${region}/${battleNetID}/profile';
    print(url);
    Response response = await get(url);
    int statusCode = response.statusCode;
    Map<String, String> headers = response.headers;
    String contentType = headers['content-type'];
    String json = response.body;
    if (statusCode!=200){
      return null;
    }
    print(statusCode);
    Map<String, dynamic> parsedJson = jsonDecode(json);
    try{
    await Firestore.instance.collection('users').document(userID).updateData({"Game JSON.Overwatch": json});

    return parsedJson;
  }catch (e){

    return null;
  }
  }

   Future<bool> AddPlayerAPIInfo(String userID, String platform, String region, String battleNetID) async{
     Map<String, String> info = {"userID": userID, "platform": platform, "region": region, "battleNetID": battleNetID};
     String jsonString=jsonEncode(info);
     print(jsonString);
     try{
       await Firestore.instance.collection('users').document(userID).updateData({"Game API.Overwatch": jsonString});
       return true;
     }catch (e){
       return false;
     }
   }


}
