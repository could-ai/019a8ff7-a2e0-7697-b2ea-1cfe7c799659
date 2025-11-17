import 'card.dart';

class HandRank {
  final int rank; // 牌型等级：10-皇家同花顺, 9-同花顺, 8-四条, 等等
  final List<int> values; // 用于比较的牌值
  final String handName; // 牌型名称
  final List<PlayingCard> cards; // 组成这个牌型的5张牌
  
  HandRank({
    required this.rank,
    required this.values,
    required this.handName,
    required this.cards,
  });
  
  // 牌型等级常量
  static const int royalFlush = 10;
  static const int straightFlush = 9;
  static const int fourOfAKind = 8;
  static const int fullHouse = 7;
  static const int flush = 6;
  static const int straight = 5;
  static const int threeOfAKind = 4;
  static const int twoPair = 3;
  static const int onePair = 2;
  static const int highCard = 1;
  
  // 获取牌型名称
  static String getRankName(int rank) {
    switch (rank) {
      case royalFlush:
        return '皇家同花顺';
      case straightFlush:
        return '同花顺';
      case fourOfAKind:
        return '四条';
      case fullHouse:
        return '葫芦';
      case flush:
        return '同花';
      case straight:
        return '顺子';
      case threeOfAKind:
        return '三条';
      case twoPair:
        return '两对';
      case onePair:
        return '一对';
      case highCard:
        return '高牌';
      default:
        return '未知';
    }
  }
}