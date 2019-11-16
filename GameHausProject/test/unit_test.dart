import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ghfrontend/pages/sign_in_page.dart';
import 'package:ghfrontend/services/authentication.dart';
import 'package:mockito/mockito.dart';

class FirebaseAuthMock extends Mock implements Auth{}

void main(){

  //somewhat static test data
  //Username: TestAccount
  //email(fake,nonexistant): testghaus@gmail.com
  //password: 1234567890
  //userid: tSOy9V73AhfBjbBWL0Ais3SmdzI2
  //url: https://ow-api.com/v1/stats/pc/us/cats-11481/profile
    SignInPageState auth; //create object
  setUp((){
    auth = new SignInPageState();
  });

  test('Test sign in right password', (){
    //test
    auth.testSignIn("testghaus.gmail.com", "1234567890");
    bool result = auth.isSignedIn(); //get result

    expect(result, true); //verify
  });

  test('Test sign in wrong password', (){
    //test
    auth.testSignIn("testghaus.gmail.com", "1234567891");
    bool result = auth.isSignedIn(); //get result

    expect(result, true); //verify
  });
}