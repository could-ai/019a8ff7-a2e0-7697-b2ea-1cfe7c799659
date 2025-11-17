import 'dart:math';
import '../models/card.dart';
import '../models/hand_rank.dart';

class PokerService {
  // 创建一副牌
  List<PlayingCard> createDeck() {
    final suits = ['hearts', 'diamonds', 'clubs', 'spades'];
    final ranks = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A'];
    
    final deck = <PlayingCard>[];
    for (var suit in suits) {
      for (var rank in ranks) {
        deck.add(PlayingCard(suit: suit, rank: rank));
      }
    }
    return deck;
  }
  
  // 洗牌
  void shuffle(List<PlayingCard> deck) {
    final random = Random();
    for (var i = deck.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final temp = deck[i];
      deck[i] = deck[j];
      deck[j] = temp;
    }
  }
  
  // 评估手牌（7张牌选最好的5张）
  HandRank evaluateHand(List<PlayingCard> cards) {
    if (cards.length < 5) {
      return HandRank(
        rank: HandRank.highCard,
        values: [0],
        handName: '手牌不足',
        cards: cards,
      );
    }
    
    // 生成所有5张牌的组合
    final allCombinations = _generateCombinations(cards, 5);
    HandRank? bestHand;
    
    for (var combination in allCombinations) {
      final handRank = _evaluateFiveCards(combination);
      if (bestHand == null || _compareHandRanks(handRank, bestHand) > 0) {
        bestHand = handRank;
      }
    }
    
    return bestHand!;
  }
  
  // 生成组合
  List<List<PlayingCard>> _generateCombinations(List<PlayingCard> cards, int r) {
    final combinations = <List<PlayingCard>>[];
    
    void combine(int start, List<PlayingCard> current) {
      if (current.length == r) {
        combinations.add(List.from(current));
        return;
      }
      
      for (var i = start; i < cards.length; i++) {
        current.add(cards[i]);
        combine(i + 1, current);
        current.removeLast();
      }
    }
    
    combine(0, []);
    return combinations;
  }
  
  // 评估5张牌
  HandRank _evaluateFiveCards(List<PlayingCard> cards) {
    final sortedCards = List<PlayingCard>.from(cards)
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final isFlush = _isFlush(sortedCards);
    final isStraight = _isStraight(sortedCards);
    final valueCounts = _getValueCounts(sortedCards);
    
    // 皇家同花顺
    if (isFlush && isStraight && sortedCards.first.rank == 'A') {
      return HandRank(
        rank: HandRank.royalFlush,
        values: [14],
        handName: HandRank.getRankName(HandRank.royalFlush),
        cards: sortedCards,
      );
    }
    
    // 同花顺
    if (isFlush && isStraight) {
      return HandRank(
        rank: HandRank.straightFlush,
        values: [sortedCards.first.value],
        handName: HandRank.getRankName(HandRank.straightFlush),
        cards: sortedCards,
      );
    }
    
    // 四条
    if (valueCounts.containsValue(4)) {
      final fourValue = valueCounts.entries.firstWhere((e) => e.value == 4).key;
      final kicker = valueCounts.entries.firstWhere((e) => e.value == 1).key;
      return HandRank(
        rank: HandRank.fourOfAKind,
        values: [fourValue, kicker],
        handName: HandRank.getRankName(HandRank.fourOfAKind),
        cards: sortedCards,
      );
    }
    
    // 葫芦
    if (valueCounts.containsValue(3) && valueCounts.containsValue(2)) {
      final threeValue = valueCounts.entries.firstWhere((e) => e.value == 3).key;
      final pairValue = valueCounts.entries.firstWhere((e) => e.value == 2).key;
      return HandRank(
        rank: HandRank.fullHouse,
        values: [threeValue, pairValue],
        handName: HandRank.getRankName(HandRank.fullHouse),
        cards: sortedCards,
      );
    }
    
    // 同花
    if (isFlush) {
      return HandRank(
        rank: HandRank.flush,
        values: sortedCards.map((c) => c.value).toList(),
        handName: HandRank.getRankName(HandRank.flush),
        cards: sortedCards,
      );
    }
    
    // 顺子
    if (isStraight) {
      return HandRank(
        rank: HandRank.straight,
        values: [sortedCards.first.value],
        handName: HandRank.getRankName(HandRank.straight),
        cards: sortedCards,
      );
    }
    
    // 三条
    if (valueCounts.containsValue(3)) {
      final threeValue = valueCounts.entries.firstWhere((e) => e.value == 3).key;
      final kickers = valueCounts.entries
          .where((e) => e.value == 1)
          .map((e) => e.key)
          .toList()
        ..sort((a, b) => b.compareTo(a));
      return HandRank(
        rank: HandRank.threeOfAKind,
        values: [threeValue, ...kickers],
        handName: HandRank.getRankName(HandRank.threeOfAKind),
        cards: sortedCards,
      );
    }
    
    // 两对
    final pairs = valueCounts.entries.where((e) => e.value == 2).toList();
    if (pairs.length == 2) {
      final pairValues = pairs.map((e) => e.key).toList()..sort((a, b) => b.compareTo(a));
      final kicker = valueCounts.entries.firstWhere((e) => e.value == 1).key;
      return HandRank(
        rank: HandRank.twoPair,
        values: [...pairValues, kicker],
        handName: HandRank.getRankName(HandRank.twoPair),
        cards: sortedCards,
      );
    }
    
    // 一对
    if (pairs.length == 1) {
      final pairValue = pairs.first.key;
      final kickers = valueCounts.entries
          .where((e) => e.value == 1)
          .map((e) => e.key)
          .toList()
        ..sort((a, b) => b.compareTo(a));
      return HandRank(
        rank: HandRank.onePair,
        values: [pairValue, ...kickers],
        handName: HandRank.getRankName(HandRank.onePair),
        cards: sortedCards,
      );
    }
    
    // 高牌
    return HandRank(
      rank: HandRank.highCard,
      values: sortedCards.map((c) => c.value).toList(),
      handName: HandRank.getRankName(HandRank.highCard),
      cards: sortedCards,
    );
  }
  
  // 判断是否同花
  bool _isFlush(List<PlayingCard> cards) {
    final suit = cards.first.suit;
    return cards.every((card) => card.suit == suit);
  }
  
  // 判断是否顺子
  bool _isStraight(List<PlayingCard> cards) {
    final values = cards.map((c) => c.value).toList()..sort();
    
    // 检查普通顺子
    for (var i = 0; i < values.length - 1; i++) {
      if (values[i + 1] - values[i] != 1) {
        // 检查A-2-3-4-5的特殊顺子
        if (values[0] == 2 && values[values.length - 1] == 14) {
          final specialStraight = [2, 3, 4, 5, 14];
          return values.toString() == specialStraight.toString();
        }
        return false;
      }
    }
    return true;
  }
  
  // 获取牌值计数
  Map<int, int> _getValueCounts(List<PlayingCard> cards) {
    final counts = <int, int>{};
    for (var card in cards) {
      counts[card.value] = (counts[card.value] ?? 0) + 1;
    }
    return counts;
  }
  
  // 比较两个手牌
  int compareHands(HandRank hand1, HandRank hand2) {
    return _compareHandRanks(hand1, hand2);
  }
  
  // 比较手牌等级
  int _compareHandRanks(HandRank hand1, HandRank hand2) {
    if (hand1.rank != hand2.rank) {
      return hand1.rank.compareTo(hand2.rank);
    }
    
    // 相同牌型，比较牌值
    for (var i = 0; i < hand1.values.length && i < hand2.values.length; i++) {
      if (hand1.values[i] != hand2.values[i]) {
        return hand1.values[i].compareTo(hand2.values[i]);
      }
    }
    
    return 0; // 完全相同
  }
}