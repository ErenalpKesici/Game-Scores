import 'package:game_scores/person.dart';

class GamePlayedItem{
  late String game;
  late List<Person> players;
  late DateTime date;
  late int winnerIdx;
  GamePlayedItem.clear(){game = '';players = List.empty(growable: true); date= DateTime.now(); winnerIdx = 0;}
  GamePlayedItem.fromJson(Map<String, dynamic> json)
      : game = json['game'],
        players = json['players'],
        date = json['date'],
        winnerIdx = json['winnerIdx'];

  Map<String, dynamic> toJson() {
    return {
      'game': game,
      'players': players.toString(),
      'date': date.toString(),
      'winnerIdx': winnerIdx.toString()
    };
  }
  GamePlayedItem(this.game, this.players, this.date, this.winnerIdx);
  @override
  String toString() {
    return game+", " + players.toString() +", " + date.toString();
  }
}