import 'card.dart';

class Player {
  final String name;
  int chips;
  List<PlayingCard> hand;
  final bool isAI;
  
  Player({
    required this.name,
    required this.chips,
    this.hand = const [],
    this.isAI = false,
  });
  
  void bet(int amount) {
    if (chips >= amount) {
      chips -= amount;
    }
  }
  
  void clearHand() {
    hand = [];
  }
}