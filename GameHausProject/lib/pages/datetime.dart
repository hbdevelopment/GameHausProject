import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

// THIS PAGE IS NOT BEING USED ANYMORE
class EventFormPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => new EventFormPageState();
}

class EventFormPageState extends State<EventFormPage> {
  final _eventNameController = TextEditingController();
  final _eventDescriptionController = TextEditingController();
  DateTime date=new DateTime.now();
  DateTime currentdate=new DateTime.now();
  TimeOfDay time=new TimeOfDay.now();
  TimeOfDay currenttime=new TimeOfDay.now();

  Future<Null> selectDate(BuildContext context) async {
    final DateTime picked=await showDatePicker(context: context,
      initialDate: currentdate,
      firstDate: currentdate,
      lastDate: new DateTime(2100));
    if (picked!=null && picked!=date){
      setState((){
        date=picked;
      });
      print(date.toString());
    }
  }

  Future<Null> selectTime(BuildContext context) async{
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: currenttime
    );
    if (picked!=null && picked!=time){
      setState((){
        time=picked;
      });
    }
  }

  void _handleSubmitted(String name, String content, String date, String time) {
    print(name);
    print(content);
    var documentRef = Firestore.instance
        .collection('events')
        .document();
    Firestore.instance.runTransaction((transaction) async {
      await transaction.set(documentRef, {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': name,
        'content': content,
        'date': date,
        'time': time
      });
    });
  }

  @override
   void initState(){
     super.initState();
   }

  Widget showEventInput() {
    String eventName='';
    String eventDescription='';

    // Build a Form widget using the _formKey created above


        return new Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Name your Event'),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _eventNameController,
                    maxLines: 1,
                    keyboardType: TextInputType.emailAddress,
                    autofocus: false,
                    decoration: new InputDecoration(
                        hintText: 'Event Name',
                        ),
                    validator: (value) => value.isEmpty ? 'Event Name can\'t be empty' : null,
                    onFieldSubmitted: (value) => eventName = value.trim(),
                  ),
                ),
                Text('Description')
                ,
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _eventDescriptionController,
                    maxLines: 8,
                    keyboardType: TextInputType.emailAddress,
                    autofocus: false,
                    decoration: new InputDecoration(
                        hintText: 'Event Description',
                    ),
                    validator: (value) => value.isEmpty ? 'Event Description can\'t be empty' : null,
                    onFieldSubmitted: (value) => eventDescription = value,
                  ),
                ),
                Text(date.toString()),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RaisedButton(
                    child: Text("Select Date"),
                    onPressed: () {
                      selectDate(context);
                    }
                  )
                )
                ,  Text(time.toString()),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RaisedButton(
                      child: Text('Select Time'),
                      onPressed: (){
                        selectTime(context);
                      }
                    )
                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RaisedButton(
                    child: Text("Submit"),
                    onPressed: () {

                      _handleSubmitted(_eventNameController.text,
                         _eventDescriptionController.text,
                         date.toString(),
                         time.toString());
                    },
                  ),
                ),



              ],
            ),
          );
    }


    @override
    Widget build(BuildContext context) {
      return showEventInput();


    }


}
