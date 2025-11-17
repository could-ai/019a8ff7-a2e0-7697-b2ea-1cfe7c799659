class PlayingCard {
  final String suit; // 花色: hearts, diamonds, clubs, spades
  final String rank; // 点数: 2-10, J, Q, K, A
  
  PlayingCard({required this.suit, required this.rank});
  
  // 获取牌的数值（用于比较大小）
  int get value {
    switch (rank) {
      case 'A':
        return 14;
      case 'K':
        return 13;
      case 'Q':
        return 12;
      case 'J':
        return 11;
      default:
        return int.parse(rank);
    }
  }
  
  // 获取花色符号
  String get suitSymbol {
    switch (suit) {
      case 'hearts':
        return '♥';
      case 'diamonds':
        return '♦';
      case 'clubs':
        return '♣';
      case 'spades':
        return '♠';
      default:
        return '';
    }
  }
  
  // 获取花色颜色
  bool get isRed {
    return suit == 'hearts' || suit == 'diamonds';
  }
  
  @override
  String toString() => '$rank$suitSymbol';
}