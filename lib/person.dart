class Person{
  late String name;
  late int score;
  Person(this.name, this.score);
  Person.empty(){name ="";score =0;}
  @override
  String toString() {
    return name+":" + score.toString();
  }
}