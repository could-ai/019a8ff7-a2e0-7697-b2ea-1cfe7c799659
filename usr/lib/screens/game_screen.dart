import 'package:flutter/material.dart';
import 'dart:math';
import '../models/card.dart';
import '../models/player.dart';
import '../widgets/playing_card_widget.dart';
import '../widgets/player_widget.dart';
import '../services/poker_service.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final PokerService _pokerService = PokerService();
  List<PlayingCard> _communityCards = [];
  late Player _player;
  late Player _ai;
  int _pot = 0;
  String _gameMessage = '开始新游戏';
  bool _gameStarted = false;
  bool _showdown = false;

  @override
  void initState() {
    super.initState();
    _player = Player(name: '你', chips: 1000, isAI: false);
    _ai = Player(name: 'AI对手', chips: 1000, isAI: true);
  }

  void _startNewGame() {
    setState(() {
      _communityCards = [];
      _pot = 0;
      _gameMessage = '游戏开始！';
      _gameStarted = true;
      _showdown = false;
      
      // 发手牌
      final deck = _pokerService.createDeck();
      _pokerService.shuffle(deck);
      
      _player.hand = [deck.removeAt(0), deck.removeAt(0)];
      _ai.hand = [deck.removeAt(0), deck.removeAt(0)];
      
      // 小盲和大盲
      _player.bet(10);
      _ai.bet(20);
      _pot = 30;
      
      _gameMessage = '已发手牌，下注或跟注';
    });
  }

  void _dealFlop() {
    if (_communityCards.isEmpty) {
      setState(() {
        final deck = _pokerService.createDeck();
        _pokerService.shuffle(deck);
        
        // 移除已发的牌
        for (var card in _player.hand) {
          deck.removeWhere((c) => c.suit == card.suit && c.rank == card.rank);
        }
        for (var card in _ai.hand) {
          deck.removeWhere((c) => c.suit == card.suit && c.rank == card.rank);
        }
        
        // 翻牌（Flop） - 3张公共牌
        _communityCards.addAll([
          deck.removeAt(0),
          deck.removeAt(0),
          deck.removeAt(0),
        ]);
        _gameMessage = '翻牌圈：已发3张公共牌';
      });
    } else if (_communityCards.length == 3) {
      _dealTurn();
    } else if (_communityCards.length == 4) {
      _dealRiver();
    }
  }

  void _dealTurn() {
    setState(() {
      final deck = _pokerService.createDeck();
      _pokerService.shuffle(deck);
      
      for (var card in _player.hand) {
        deck.removeWhere((c) => c.suit == card.suit && c.rank == card.rank);
      }
      for (var card in _ai.hand) {
        deck.removeWhere((c) => c.suit == card.suit && c.rank == card.rank);
      }
      for (var card in _communityCards) {
        deck.removeWhere((c) => c.suit == card.suit && c.rank == card.rank);
      }
      
      // 转牌（Turn） - 第4张公共牌
      _communityCards.add(deck.removeAt(0));
      _gameMessage = '转牌圈：已发第4张公共牌';
    });
  }

  void _dealRiver() {
    setState(() {
      final deck = _pokerService.createDeck();
      _pokerService.shuffle(deck);
      
      for (var card in _player.hand) {
        deck.removeWhere((c) => c.suit == card.suit && c.rank == card.rank);
      }
      for (var card in _ai.hand) {
        deck.removeWhere((c) => c.suit == card.suit && c.rank == card.rank);
      }
      for (var card in _communityCards) {
        deck.removeWhere((c) => c.suit == card.suit && c.rank == card.rank);
      }
      
      // 河牌（River） - 第5张公共牌
      _communityCards.add(deck.removeAt(0));
      _gameMessage = '河牌圈：已发第5张公共牌，点击摊牌';
    });
  }

  void _showdown() {
    setState(() {
      _showdown = true;
      
      final playerHand = _pokerService.evaluateHand([..._player.hand, ..._communityCards]);
      final aiHand = _pokerService.evaluateHand([..._ai.hand, ..._communityCards]);
      
      final result = _pokerService.compareHands(playerHand, aiHand);
      
      if (result > 0) {
        _player.chips += _pot;
        _gameMessage = '你赢了！牌型: ${playerHand.handName}';
      } else if (result < 0) {
        _ai.chips += _pot;
        _gameMessage = 'AI赢了！AI牌型: ${aiHand.handName}，你的牌型: ${playerHand.handName}';
      } else {
        _player.chips += _pot ~/ 2;
        _ai.chips += _pot ~/ 2;
        _gameMessage = '平局！双方牌型: ${playerHand.handName}';
      }
      
      _pot = 0;
    });
  }

  void _playerBet(int amount) {
    if (_player.chips >= amount) {
      setState(() {
        _player.bet(amount);
        _pot += amount;
        
        // AI简单跟注
        final aiAmount = min(amount, _ai.chips);
        _ai.bet(aiAmount);
        _pot += aiAmount;
        
        _gameMessage = '你下注 $amount，AI跟注 $aiAmount';
      });
    }
  }

  void _fold() {
    setState(() {
      _ai.chips += _pot;
      _pot = 0;
      _gameMessage = '你弃牌了，AI获胜';
      _gameStarted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('德州扑克'),
        backgroundColor: const Color(0xFF1B5E20),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              Color(0xFF2E7D32),
              Color(0xFF1B5E20),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AI玩家区域
              Expanded(
                child: PlayerWidget(
                  player: _ai,
                  showCards: _showdown,
                ),
              ),
              
              // 公共牌区域
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    // 底池
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '底池: $_pot',
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    
                    // 公共牌
                    if (_communityCards.isNotEmpty)
                      SizedBox(
                        height: 100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _communityCards
                              .map((card) => Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: PlayingCardWidget(card: card),
                                  ))
                              .toList(),
                        ),
                      )
                    else
                      Container(
                        height: 100,
                        alignment: Alignment.center,
                        child: const Text(
                          '等待发牌...',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 15),
                    
                    // 游戏消息
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        _gameMessage,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              
              // 玩家区域
              Expanded(
                child: PlayerWidget(
                  player: _player,
                  showCards: true,
                ),
              ),
              
              // 操作按钮区域
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: !_gameStarted
                    ? SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _startNewGame,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            textStyle: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: const Text('开始新游戏'),
                        ),
                      )
                    : Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _communityCards.length < 5 ? _dealFlop : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  child: Text(
                                    _communityCards.isEmpty
                                        ? '翻牌'
                                        : _communityCards.length == 3
                                            ? '转牌'
                                            : _communityCards.length == 4
                                                ? '河牌'
                                                : '已完成',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _communityCards.length == 5 && !_showdown
                                      ? _showdown
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  child: const Text('摊牌'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _playerBet(20),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.amber,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  child: const Text('下注 20'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _playerBet(50),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.amber,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  child: const Text('下注 50'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _fold,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  child: const Text('弃牌'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}