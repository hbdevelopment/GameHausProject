import 'package:flutter/material.dart';
import 'package:ghfrontend/services/authentication.dart';
import 'package:ghfrontend/pages/root_page.dart';
import 'package:ghfrontend/services/users.dart';

void main() {
  runApp(new GHausApp());
}

class GHausApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'GHaus',
        debugShowCheckedModeBanner: false,
        theme: new ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: new RootPage(auth: new Auth(), users: new Users()));
  }
}
