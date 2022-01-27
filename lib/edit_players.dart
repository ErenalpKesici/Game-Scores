import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'main.dart';

class EditPlayersPageSend extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return EditPlayersPage();
  }
}
class EditPlayersPage extends State<EditPlayersPageSend>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Players"),),
      body: ListView.builder(itemCount: players.length, itemBuilder: (BuildContext context, int idx){
        return ListTile(title: Text(players[idx]));
      }),
    );
  }
}