import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  String id;
  String title;
  String description;
  DateTime dateTime;
  String game;
  String image_url;
  String location;
  int capacity;
  String type;
  String user_id;
  String user_nickname;

  Event(this.title, this.description, this.game, this.image_url, this.dateTime, this.capacity, this.location, this.type, this.user_id, this.user_nickname);

  Event.fromSnapshot(DocumentSnapshot snapshot) :
    id = snapshot["id"],
    title = snapshot["title"],
    description = snapshot["description"],
    dateTime = snapshot["dateTime"].toDate(),
    game = snapshot["game"],
    image_url = snapshot["image_url"],
    location = snapshot["location"],
    capacity = snapshot["capacity"],
    type = snapshot["type"],
    user_id = snapshot["user_id"],
    user_nickname = snapshot["user_nickname"];

  toJson() {
    return {
      "id": id,
      "title": title,
      "description": description,
      "dateTime": dateTime,
      "game": game,
      "location": location,
      "capacity": capacity,
      "type": type,
      "user_nickname": user_nickname,
      "user_id": user_id,
      "image_url":image_url
    };
  }
}
