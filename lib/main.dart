import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:game_scores/person.dart';
import 'package:path_provider/path_provider.dart';
import 'game_played_item.dart';
import 'package:intl/intl.dart';

List<GamePlayedItem> itms = List.empty(growable: true);
List<String> games = List.filled(1, '', growable: true);
List<String> players = List.filled(1, '', growable: true);
void fillUniqueLists(){
  for(GamePlayedItem itm in itms){
    bool unique = true;
    for(String game in games){
      if(game == itm.game) {
        unique = false;
        break;
      }
    }
    if(unique) {
      games.add(itm.game);
    }
    else{
      unique=true;
    }
    for(int i=0;i<itm.players.length;i++){
      for(String player in players){
        if(player == itm.players[i].name) {
          unique = false;
          break;
        }
      }
      if(unique) {
        players.add(itm.players[i].name);
      }
    }
  }
}
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final externalDir = await getExternalStorageDirectory();
  // await File(externalDir!.path +'/Save.json').delete();
  // await File(externalDir!.path +'/Save.json').create();
  if(await File(externalDir!.path +'/Save.json').exists() && await File(externalDir.path+"/Save.json").readAsString() != ""){
    print(await File(externalDir.path+"/Save.json").readAsString());
    List<dynamic> itmList = jsonDecode(await File(externalDir.path+"/Save.json").readAsString());
    print(":: " + itmList.toString());
    // List readItems = jsonDecode(File(externalDir.path+"/Save.json").readAsStringSync());
    for(var itm in itmList){
      GamePlayedItem tmp  = GamePlayedItem.clear();
      Map<String, dynamic> readSave = Map<String, dynamic>.from(itm);
      readSave.forEach((key, value) {
        switch(key){
          case("game"):
            tmp.game=value;        
            break;
          case("players"):
            String pplDecoded = value.toString().substring(1, value.toString().length - 1);
            List<String> ppl = pplDecoded.split(', ');
            for(String prsn in ppl){
              tmp.players.add(Person(prsn.split(':')[0], int.parse(prsn.split(':')[1])));
            }
            break;
          case("date"):
            tmp.date=DateTime.parse(value);
            break;
        }
      });
      itms.add(tmp);
    } 
    print(itms.toString());
    fillUniqueLists();
  }
  else{
    await File(externalDir.path +'/Save.json').create();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme:ThemeData(brightness: SchedulerBinding.instance!.window.platformBrightness, primarySwatch: Colors.deepPurple,
        appBarTheme: const AppBarTheme(
          foregroundColor: Colors.white,
          backgroundColor: Colors.deepPurple)),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: Container(),
          title: const Text('Games'),
          actions: [
            ElevatedButton.icon(
              onPressed: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => GamePlayedPageSend(idx: itms.length,)));
            }, icon: Icon(Icons.add), label: const Text("Add"), style: ElevatedButton.styleFrom(primary: Colors.green))
          ],
        ),
        body: Scrollbar(
          isAlwaysShown: true,
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: itms.length,
            reverse: true,
            itemBuilder: ((BuildContext context, int index) {
              return Card(
                child: ListTile(
                  leading: SizedBox(
                    width: MediaQuery.of(context).size.width / 3,
                    child: Row(
                      children: [
                        const Icon(Icons.access_time_sharp),
                        const SizedBox(width: 10,),
                        Text(DateFormat('dd/MMM/yy').format(itms[index].date)),
                      ],
                    ),
                  ),
                  title: Text(itms[index].game, textAlign: TextAlign.end,),
                  subtitle: Text(itms[index].players.toString(), textAlign: TextAlign.end,),
                  trailing: const Icon(Icons.games),
                  onTap: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=> GamePlayedPageSend(idx: index,)));
                  },
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
class GamePlayedPageSend extends StatefulWidget{
  final int? idx;
  const GamePlayedPageSend({Key? key, @required this.idx}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    print(idx);
    return GamePlayedPage(idx);
  }
}
class GamePlayedPage extends State<GamePlayedPageSend>{
  int? idx;
  late List<Person> ppl; 
  late GamePlayedItem item;
  List<TextEditingController> tecScores = List.empty(growable: true);
  GamePlayedPage(this.idx);
   @override
  void initState() {
    if(itms.length == idx){
      item = GamePlayedItem(games.first, List.empty(growable: true), DateTime.now());
    }
    else{
      item = GamePlayedItem(itms[idx!].game, itms[idx!].players, itms[idx!].date);
      for(int i=0;i<item.players.length;i++){
        tecScores.add(TextEditingController(text: item.players[i].score.toString()));
      }
    }
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: const FittedBox(child: Text('Add Game Played')),
       actions: [
        ElevatedButton.icon(onPressed: (){
          TextEditingController tecGame = TextEditingController();
          showDialog(context: context, builder: (BuildContext context) {
            return AlertDialog(
              title: const Center(child: Text("Add a Game")),
              content: 
                TextField(
                  controller: tecGame,
                ),
              actions: [
                ElevatedButton(onPressed: (){
                  Navigator.pop(context);
                  setState(() {
                    if(games.first == ''){
                      games[0] = tecGame.text;
                    }
                    else{
                      games.add(tecGame.text);
                    }
                    item.game = tecGame.text;
                  });
                }, child: const Text("Confirm"))
              ],
            );
        });
      }, icon: const Icon(Icons.add), label: const Text("Game")),
      ElevatedButton.icon(onPressed: (){
        TextEditingController tecPlayerName = TextEditingController();
        TextEditingController tecPlayerScore = TextEditingController();
        String previousSelectedName = players.first;
        showDialog(context: context, builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setInnerState) {
            return SingleChildScrollView(
            child: AlertDialog(
              title: const Center(child: Text("Add a Player")),
              content: 
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 200,
                      child: DropdownButton<String>(
                        alignment: AlignmentDirectional.center,
                        value: previousSelectedName,
                        onChanged: (String? newValue) {
                          setInnerState(() {
                            tecPlayerName.clear();
                            previousSelectedName = newValue!;
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
                    ),
                    const Text("OR"),
                    TextField(decoration: InputDecoration(labelText: 'Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),  controller: tecPlayerName,
                      onTap: (){
                        setState(() {
                          previousSelectedName = "";  
                        });
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(decoration: InputDecoration(labelText: 'Score', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),  controller: tecPlayerScore, keyboardType: TextInputType.number,),
                    ),
                  ],
                ),
              actions: [
                ElevatedButton(onPressed: (){
                  Navigator.pop(context);
                  if(previousSelectedName == '' && tecPlayerName.text == '')return;
                  int score = tecPlayerScore.text==''?0:int.parse(tecPlayerScore.text);
                  Person? p;
                  if(previousSelectedName == ''){
                    p = Person(tecPlayerName.text, score);
                  }
                  else{
                    p = Person(previousSelectedName, score);
                  }
                  setState(() {
                    item.players.add(p!);
                    tecScores.add(TextEditingController(text: score.toString()));
                  });
                }, child: const Text("Confirm"))
              ],
            ),
          );
        });
        });
        }, icon: const Icon(Icons.add), label: const Text("Player")),
      ],
     ),
     body: SingleChildScrollView(
       child: Center(
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             Row(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 const Text('Game: '),
                 Padding(
                   padding: const EdgeInsets.all(8.0),
                   child: DropdownButton<String>(
                      alignment: AlignmentDirectional.center,
                      value: item.game,
                      onChanged: (String? newValue) {
                        setState(() {
                          item.game = newValue!;
                        });
                      },
                      items: games.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          alignment: AlignmentDirectional.center,
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                 ),
               ],
             ),
             SizedBox(
               height: 300,
               child: ListView.builder(
                itemCount: item.players.length,
                itemBuilder: ((BuildContext context, int index) {
                  return ListTile(
                    leading: Text(item.players[index].name),
                    trailing: SizedBox(
                      width: 100,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: tecScores[index],
                        onChanged: (String n){
                          if(n != '')
                            item.players[index].score = int.parse(n);
                        },
                      ),
                    ),
                  );
                }),
              ),
             ),
            ElevatedButton.icon(onPressed: () async{
              if(item.game == '' || item.players.isEmpty){
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Make sure to select a game and atleast one player.', textAlign: TextAlign.center))); 
                return;
              }
              setState(() {
                if(idx == itms.length) {
                  itms.add(item);
                } 
                else {
                  itms[idx!] = item;
                }
                fillUniqueLists();
              });
              final externalDir = await getExternalStorageDirectory();
              await File(externalDir!.path + "/Save.json").writeAsString(jsonEncode(itms));
              Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const MyHomePage()));
            }, icon: const Icon(Icons.save), label: const Text('Save'))
           ],
         ),
       ),
     ),
   ); 
  }
}
