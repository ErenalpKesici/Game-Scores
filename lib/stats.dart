import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'main.dart';

class StatsPageSend extends StatefulWidget {
  StatsPageSend();
  @override
  State<StatefulWidget> createState() {
    return StatsPage();
  }
}
class StatsPage extends State<StatsPageSend>{
  String? selectedPlayer;
  int selectedWins=0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('Stats'),),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<String>(
              alignment: AlignmentDirectional.center,
              value: selectedPlayer,
              onChanged: (String? newValue) {
                selectedWins = 0;
                setState(() {     
                  selectedPlayer = newValue;          
                  for(int i=0;i<allItems.length;i++){
                    if(allItems[i].players[allItems[i].winnerIdx].name == selectedPlayer){
                      selectedWins++;
                    }
                  }
                });
              },
              items: players.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  alignment: AlignmentDirectional.center,
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            Text("Win%: " + (selectedWins/allItems.length * 100).toString()),
          ],
        ),
      ),
    );
  }

}