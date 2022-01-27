import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:game_scores/game_played_item.dart';

import 'main.dart';

class EditPlayersGamesPageSend extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return EditPlayersGamesPage();
  }
}
class EditPlayersGamesPage extends State<EditPlayersGamesPageSend>{
  List<TextEditingController> tecPlayers = List.empty(growable: true);
  List<TextEditingController> tecGames = List.empty(growable: true);
  @override
  void initState() {
    for(String player in players){
      tecPlayers.add(TextEditingController(text: player));
    }
    for(String player in games){
      tecGames.add(TextEditingController(text: player));
    }
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Players and Games"),),
      body: Column(
        children: [
          DefaultTabController(
            length: 2,
            child: Flexible(
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(icon: Icon(Icons.people), child: FittedBox(child: Text("Players"))),
                      Tab(icon: Icon(Icons.games), child: FittedBox(child: Text("Games"))),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: tecPlayers.length, 
                                itemBuilder: (BuildContext context, int idx){
                                  if(tecPlayers[idx].text != ""){
                                    return ListTile(
                                      title: TextField(controller: tecPlayers[idx]),
                                      trailing: IconButton(onPressed: (){
                                        for(GamePlayedItem item in allItems){
                                          int playerIdx = item.players.indexWhere((element) => element.name == players[idx]);
                                          if(playerIdx != -1) {
                                            item.players[playerIdx].name = tecPlayers[idx].text;
                                          }
                                        }            
                                        players[idx] = tecPlayers[idx].text;
                                        saveAll(context);
                                      }, icon: Icon(Icons.task_alt_sharp))
                                    );
                                }
                                return Container();
                              }),
                              ),
                            ],
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: tecGames.length, 
                          itemBuilder: (BuildContext context, int idx){
                            if(tecGames[idx].text != ""){
                              return ListTile(
                                title: TextField(controller: tecGames[idx]),
                                trailing: IconButton(onPressed: (){
                                  for(int i=0;i<allItems.length;i++){
                                    if(allItems[i].game == games[idx]){
                                      allItems[i].game = tecGames[idx].text;
                                    }
                                  }
                                  games[idx] = tecGames[idx].text;
                                  saveAll(context);
                                }, icon: Icon(Icons.task_alt_sharp))
                              );
                          }
                          return Container();
                        }),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}