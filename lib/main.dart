import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:game_scores/person.dart';
import 'package:game_scores/stats.dart';
import 'package:path_provider_windows/path_provider_windows.dart';
import 'game_played_item.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:intl/intl.dart';
final PathProviderWindows provider = PathProviderWindows();

List<GamePlayedItem> allItems = List.empty(growable: true);
List<GamePlayedItem> shownItems = List.empty(growable: true);
List<String> games = List.filled(1, '', growable: true);
List<String> players = List.filled(1, '', growable: true);
void fillUniqueLists(){
  for(GamePlayedItem itm in allItems){
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
  final externalDir = await provider.getApplicationSupportPath();
  // await File(externalDir!.path +'/Save.json').delete();
  // await File(externalDir!.path +'/Save.json').create();
  if(await File(externalDir! +'/Save.json').exists() && await File(externalDir+"/Save.json").readAsString() != ""){
    List<dynamic> itmList = jsonDecode(await File(externalDir+"/Save.json").readAsString());
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
          case("winnerIdx"):
            tmp.winnerIdx=int.parse(value);
            break;
        }
      });
      allItems.add(tmp);
    } 
    shownItems = allItems;
    fillUniqueLists();
  }
  else{
    await File(externalDir+'/Save.json').create();
  }
  runApp(const MyApp());
}

PageRouteBuilder _transition(var page){
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.ease;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme:ThemeData(brightness: SchedulerBinding.instance!.window.platformBrightness, primarySwatch: Colors.deepPurple,
        appBarTheme: const AppBarTheme(
          foregroundColor: Colors.white,
          backgroundColor: Colors.deepPurple)),
      home: const MyHomePage(),
    );
  }
}

List<GamePlayedItem> _queryGame(String searched){
  if(searched == '')return allItems;
  List<GamePlayedItem> retList = List.empty(growable: true);
  for(GamePlayedItem item in allItems){
    bool match = true;
    if(item.game.length < searched.length) continue;
    for(int i=0;i<searched.length;i++){
      if(item.game[i] != searched[i]) {
        match = false;
      }
    }
    if(match){
      retList.add(item);
    }
  }
  return retList;
}

List<GamePlayedItem> _filterItems(String filterPlayer, String filterGame){
  if(filterPlayer == '' && filterGame == '') {
    return allItems;
  }
  List<GamePlayedItem> retItms = List.empty(growable: true);
  if(filterPlayer != ''){
    for(int i=0;i<allItems.length;i++){
      int maxIdx = 0;
      for(int j=0;j<allItems[i].players.length;j++){
        if(allItems[i].players[maxIdx].score < allItems[i].players[j].score) {
          maxIdx = j;
        }
      }
      if(allItems[i].players[maxIdx].name == filterPlayer){
        retItms.add(allItems[i]);
      }
    } 
  }
  if(filterGame != ''){
    List<GamePlayedItem> tmp = List.empty(growable: true);
    for(GamePlayedItem item in (filterPlayer != ''?retItms:allItems)){
      if(item.game == filterGame){
        tmp.add(item);
      }
    }
    retItms = tmp;
  }
  retItms = retItms.toSet().toList();
  return retItms;
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController tecSearch = TextEditingController(text: '');
  String filterPlayer = '', filterGame = '';
  List<bool> selectedTile = List.filled(shownItems.length, false);
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        return false;
      },
      child: Scaffold(
        drawer:  Drawer(
    child: Container(
      child: ListView(
        children: [
          DrawerHeader(
            child: Container(height: 100,)
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: Text("Ana Sayfa", textAlign: TextAlign.center,),
            onTap: (){
              if(context.widget.toString() != "MyHomePage"){
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute(builder: (context) =>MyHomePage()));
              }
              else
                Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: const Icon(Icons.query_stats),
            title: const Text("Stats", textAlign: TextAlign.center,),
            onTap: (){
              if(context.widget.toString() != "StatsPageSend"){
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute(builder: (context) =>StatsPageSend()));
              }
              else {
                Navigator.of(context).pop();
              }
            },
          ),       
        ],
      ),
    ),
  ),
        appBar: AppBar(
          title: AutoSizeText('Games (' + shownItems.length.toString() +')', maxLines: 1,),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 100, 
                child: 
                PopupMenuButton(icon: const Icon(Icons.manage_search_rounded), itemBuilder: (context)=>[
                  PopupMenuItem(
                    onTap: (){
                      setState(() {
                        filterGame='';
                        filterPlayer='';
                        shownItems = _filterItems(filterPlayer, filterGame);   
                      });
                    },
                    child: StatefulBuilder(
                      builder: (BuildContext context, void Function(void Function()) setInnerState) { 
                        return 
                        Column(children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("Filter by:"),
                          ),
                          Row(
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Text("Winner: "),
                              ),
                              DropdownButton<String>(
                                alignment: AlignmentDirectional.center,
                                value: filterPlayer,
                                onChanged: (String? newValue) {
                                  setInnerState(() {
                                    filterPlayer = newValue!;
                                  });
                                  setState(() {
                                    shownItems = _filterItems(filterPlayer, filterGame);                                    
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
                              const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Text("Game: "),
                              ),
                              DropdownButton<String>(
                                alignment: AlignmentDirectional.center,
                                value: filterGame,
                                onChanged: (String? newValue) {
                                  setInnerState(() {
                                    filterGame = newValue!;
                                  });
                                  setState(() {
                                    shownItems = _filterItems(filterPlayer, filterGame);                                    
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
                            ]
                          )
                        ]);
                      },
                    ) ,
                  ),
              ]
              )
              ),
            ),
            if(selectedTile.contains(true) && !selectedTile.every((element) => element))
              IconButton(
                onPressed: (){
                  setState(() {
                    selectedTile = List.filled(shownItems.length, true);
                  });
              }, icon: const Icon(Icons.select_all)),
            if(selectedTile.contains(true))
              IconButton(
                onPressed: (){
                  List<GamePlayedItem> newAllItems = List.empty(growable: true);
                  for(int i=0;i<allItems.length;i++){
                    if(!selectedTile[i]){
                      newAllItems.add(allItems[_findIdxRelativeToAll(i)]);
                    }
                  }
                  setState(() {
                    allItems=newAllItems;
                    shownItems = allItems;
                  });
                  _saveAll(context);
                }, icon: const Icon(Icons.delete)),
            if(selectedTile.isNotEmpty && selectedTile.every((element) => element))
              IconButton(
                onPressed: (){
                  setState(() {
                    selectedTile = List.filled(shownItems.length, false);
                  });
              }, icon: const Icon(Icons.cancel)),
            IconButton(
              onPressed: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => GamePlayedPageSend(idx: allItems.length,)));
            }, icon: const Icon(Icons.add))
          ],
        ),
        body: Scrollbar(
          isAlwaysShown: true,
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: shownItems.length,
            itemBuilder: ((BuildContext context, int index) {
              return Dismissible(
                direction: DismissDirection.startToEnd,
                confirmDismiss: (DismissDirection direction) async {
                  return await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Confirm"),
                        content: const Text("Are you sure you wish to delete this item?"),
                        actions: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text("No"),
                              ),
                              const SizedBox(width: 5,),
                              ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text("Yes")
                              ),
                            ],
                          )
                        ],
                      );
                    },
                  );
                },
                key: UniqueKey(),
                background: Container(
                  color: Colors.red,
                  child: const Icon(Icons.delete),
                ),
                onDismissed: (DismissDirection direction){
                  setState(() {
                    shownItems.removeAt(index);
                    _saveAll(context);
                  });
                },
                child: Card(
                  child: ListTile(
                    onLongPress: (){
                      setState(() {
                        selectedTile = List.filled(shownItems.length, false);
                        selectedTile[index] = true;
                      });
                    },
                    selected: selectedTile[index],
                    leading: SizedBox(
                      width: MediaQuery.of(context).size.width / 2,
                      child: Row(
                        children: [
                          const Icon(Icons.access_time_sharp),
                          const SizedBox(width: 10,),
                          Text(DateFormat('dd/MMM/yy hh:mm').format(shownItems[index].date)),
                        ],
                      ),
                    ),
                    title: Text(shownItems[index].game, textAlign: TextAlign.end,),
                    subtitle: Text(shownItems[index].players.toString(), textAlign: TextAlign.end,),
                    trailing: const Icon(Icons.games),
                    onTap: (){
                      if(selectedTile.contains(true)){
                        setState(() {
                          if(selectedTile[index]) {
                            selectedTile[index] = false;
                          }
                          else {
                            selectedTile[index] = true;
                          }
                        });
                      }
                      else {
                        
                        Navigator.of(context).push(_transition(GamePlayedPageSend(idx: index,)));
                      }
                    },
                  ),
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
    return GamePlayedPage(idx);
  }
}
class GamePlayedPage extends State<GamePlayedPageSend>{
  int? idx;
  late List<Person> ppl; 
  late GamePlayedItem item;
  List<TextEditingController> tecScores = List.empty(growable: true);
  AppBar appbar = AppBar();
  GamePlayedPage(this.idx);
  @override
  void initState() {
    if(allItems.length == idx){
      item = GamePlayedItem(games.first, List.empty(growable: true), DateTime.now(), 0);
    }
    else{
      item = GamePlayedItem(shownItems[idx!].game, shownItems[idx!].players, shownItems[idx!].date, 0);
      for(int i=0;i<item.players.length;i++){
        tecScores.add(TextEditingController(text: item.players[i].score.toString()));
      }
    }
    tecScores.add(TextEditingController(text: '0'));
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
   return Scaffold(
     appBar: appbar = AppBar(
       title: const FittedBox(child: Text('Add Game Played')),
       actions: [
         Column(
           children: [
              SizedBox(
                height: appbar.preferredSize.height/2,
                child: ElevatedButton.icon(onPressed: (){
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
                            games.add(tecGame.text);
                            item.game = tecGame.text;
                          });
                        }, child: const Text("Confirm"))
                      ],
                    );
                  });
          }, icon: const Icon(Icons.add), label: const Text("Game")),
        ),
        SizedBox(
          height: appbar.preferredSize.height/2,
          child: 
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
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("OR"),
                        ),
                        TextField(decoration: InputDecoration(labelText: 'Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),  controller: tecPlayerName,
                          onTap: (){
                            setState(() {
                              previousSelectedName = "";  
                            });
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
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
                        tecScores.elementAt(tecScores.length - 1).text = score.toString();
                        tecScores.add(TextEditingController(text: '0'));
                      });
                    }, child: const Text("Confirm"))
                  ],
                ),
              );
            });
            });
            }, icon: const Icon(Icons.add), label: const Text("Player")),
          ),
        ],
        ),
        if(idx! < shownItems.length)
          PopupMenuButton(
            itemBuilder: (context)=>
              [
                PopupMenuItem(
                  onTap: () async{
                    List<GamePlayedItem> deletedList = List.empty(growable: true);
                    for(int i=0;i<allItems.length;i++){
                      if(i != _findIdxRelativeToAll(idx!)) {
                        deletedList.add(allItems[i]);
                      }
                    }
                    allItems = deletedList;
                    _saveAll(context);
                  },
                  child: Row(children: const [Icon(Icons.delete), Text('Delete')]) ,
                ),
              ]
            )
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
             Card(
               child: SizedBox(
                 width: MediaQuery.of(context).size.width/2,
                 height: MediaQuery.of(context).size.height/2,
                 child: ListView.builder(
                  itemCount: item.players.length,
                  itemBuilder: ((BuildContext context, int index) {
                    return ListTile(
                      leading: Text(item.players[index].name),
                      trailing: SizedBox(
                        width: 50,
                        child: TextField(
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          controller: tecScores[index],
                          onChanged: (String n){
                            if(n != '' && n != ' ') {
                              if(n[0] == '0') {
                                n = n.substring(1, n.length);
                                setState(() {
                                  tecScores[index] = TextEditingController(text: n);
                                });
                              }
                              item.players[index].score = int.parse(n);
                            }
                          },
                        ),
                      ),
                    );
                  }),
                ),
               ),
             ),
            ElevatedButton.icon(onPressed: () async{
              if(item.game == '' || item.players.isEmpty){
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Make sure to select a game and atleast one player.', textAlign: TextAlign.center))); 
                return;
              }
              int maxIdx = 0;
              for(int i=0;i<item.players.length;i++){
                if(maxIdx < item.players[i].score){
                  maxIdx = i;
                }
              }
              item.winnerIdx = maxIdx;
              setState(() {
                if(idx == allItems.length) {
                  allItems.insert(0, item);
                } 
                else {
                  idx = _findIdxRelativeToAll(idx!);
                  allItems[idx!] = item;
                }
                fillUniqueLists();
              });
              _saveAll(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved.', textAlign: TextAlign.center))); 
            }, icon: const Icon(Icons.save), label: const Text('Save'))
           ],
         ),
       ),
     ),
   ); 
  }
}
void _saveAll(BuildContext context)async{
  final externalDir = await provider.getApplicationSupportPath();
  await File(externalDir! + "/Save.json").writeAsString(jsonEncode(allItems));
  shownItems = _queryGame('');
  Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const MyHomePage()));
}
int _findIdxRelativeToAll(int shownIdx){
  for(int i=0;i<allItems.length;i++){
    if(allItems[i] == shownItems[shownIdx]){
      return i;
    }
  }
  return allItems.length;
}
