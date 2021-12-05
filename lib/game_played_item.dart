import 'package:game_scores/person.dart';

class GamePlayedItem{
  late String game;
  late List<Person> players;
  late DateTime date;
GamePlayedItem.clear(){game = '';players = List.empty(growable: true); date= DateTime.now();}
 GamePlayedItem.fromJson(Map<String, dynamic> json)
      : game = json['game'],
        players = json['players'],
        date = json['date'];

  Map<String, dynamic> toJson() {
    return {
      'game': game,
      'players': players.toString(),
      'date': date.toString(),
    };
  }
  GamePlayedItem(this.game, this.players, this.date);
  @override
  String toString() {
    return game+", " + players.toString() +", " + date.toString();
  }
}