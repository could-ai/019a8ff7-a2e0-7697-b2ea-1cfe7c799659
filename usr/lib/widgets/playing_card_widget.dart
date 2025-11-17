import 'package:flutter/material.dart';
import '../models/card.dart';

class PlayingCardWidget extends StatelessWidget {
  final PlayingCard card;
  final bool faceDown;
  final double width;
  final double height;
  
  const PlayingCardWidget({
    super.key,
    required this.card,
    this.faceDown = false,
    this.width = 60,
    this.height = 90,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: faceDown ? const Color(0xFF1565C0) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black26, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: faceDown
          ? Center(
              child: Icon(
                Icons.casino,
                color: Colors.white.withOpacity(0.3),
                size: 40,
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          card.rank,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: card.isRed ? Colors.red : Colors.black,
                          ),
                        ),
                        Text(
                          card.suitSymbol,
                          style: TextStyle(
                            fontSize: 14,
                            color: card.isRed ? Colors.red : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Text(
                  card.suitSymbol,
                  style: TextStyle(
                    fontSize: 24,
                    color: card.isRed ? Colors.red : Colors.black,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          card.suitSymbol,
                          style: TextStyle(
                            fontSize: 14,
                            color: card.isRed ? Colors.red : Colors.black,
                          ),
                        ),
                        Text(
                          card.rank,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: card.isRed ? Colors.red : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}