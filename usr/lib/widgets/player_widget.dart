import 'package:flutter/material.dart';
import '../models/player.dart';
import 'playing_card_widget.dart';

class PlayerWidget extends StatelessWidget {
  final Player player;
  final bool showCards;
  
  const PlayerWidget({
    super.key,
    required this.player,
    this.showCards = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 玩家信息
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: player.isAI ? Colors.red.withOpacity(0.3) : Colors.blue.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: player.isAI ? Colors.red : Colors.blue,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  player.isAI ? Icons.smart_toy : Icons.person,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '筹码: ${player.chips}',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // 手牌
          if (player.hand.isNotEmpty)
            SizedBox(
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: player.hand
                    .map((card) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: PlayingCardWidget(
                            card: card,
                            faceDown: !showCards && player.isAI,
                          ),
                        ))
                    .toList(),
              ),
            )
          else
            Container(
              height: 100,
              alignment: Alignment.center,
              child: Text(
                '等待发牌',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }
}