import 'package:flutter/material.dart';
import 'package:demo/main.dart';

class CreateNoteLayout extends StatefulWidget {
  @override
  CreateNoteLayoutState createState() => CreateNoteLayoutState();
}

class CreateNoteLayoutState extends State<CreateNoteLayout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("Create Note"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyHomePage(title: 'Flutter Demo Home Page')),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
          child: Column(children: [
            Text("Test")
          ],)
      )// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}