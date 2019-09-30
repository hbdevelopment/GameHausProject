import 'package:cloud_firestore/cloud_firestore.dart';

class GUser {
  String id;
  String nickname;
  String photoUrl;
  String createdAt;
  String displayName;
  List memberOfEvents;

  GUser(this.id, this.nickname, this.photoUrl, this.createdAt, this.displayName, this.memberOfEvents);

  GUser.fromSnapshot(DocumentSnapshot snapshot) :
    id = snapshot["id"],
    nickname = snapshot["nickname"],
    photoUrl = snapshot["photoUrl"],
    createdAt = snapshot["createdAt"],
    displayName = snapshot["displayName"],
    memberOfEvents = snapshot['memberOfEvents'];

  bool incompletePreferences() {
    return nickname == null;
  }

  toJson() {
    return {
      "id": id,
      "nickname": nickname,
      "photoUrl": photoUrl,
      "createdAt": createdAt,
      "displayName": displayName,
      "memberOfEvents": memberOfEvents
    };
  }
}
