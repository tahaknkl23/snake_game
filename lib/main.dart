import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

enum Direction { up, down, left, right }

class SnakeGame extends StatefulWidget {
  const SnakeGame({super.key});

  @override
  _SnakeGameState createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> {
  final List<Offset> _snakePositions = [
    const Offset(0, 0),
    const Offset(1, 0),
    const Offset(2, 0),
  ];

  Offset _foodPosition = const Offset(5, 5);
  Direction _direction = Direction.right;

  @override
  void initState() {
    super.initState();
    _placeFood();
    Timer.periodic(const Duration(milliseconds: 200), _moveSnake);
  }

  void _placeFood() {
    final random = Random();
    int x = random.nextInt(20);
    int y = random.nextInt(20);
    setState(() {
      _foodPosition = Offset(x.toDouble(), y.toDouble());
    });
  }

  void _moveSnake(Timer timer) {
    setState(() {
      Offset head = _snakePositions.last;
      Offset newHead;

      switch (_direction) {
        case Direction.up:
          newHead = Offset(head.dx, head.dy - 1);
          break;
        case Direction.down:
          newHead = Offset(head.dx, head.dy + 1);
          break;
        case Direction.left:
          newHead = Offset(head.dx - 1, head.dy);
          break;
        case Direction.right:
          newHead = Offset(head.dx + 1, head.dy);
          break;
      }

      _snakePositions.add(newHead);

      // Check if snake eats the food
      if (newHead == _foodPosition) {
        _placeFood();
      } else {
        _snakePositions.removeAt(0); // Remove tail
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Snake Game'),
      ),
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (_direction != Direction.up && details.delta.dy > 0) {
            _direction = Direction.down;
          } else if (_direction != Direction.down && details.delta.dy < 0) {
            _direction = Direction.up;
          }
        },
        onHorizontalDragUpdate: (details) {
          if (_direction != Direction.left && details.delta.dx > 0) {
            _direction = Direction.right;
          } else if (_direction != Direction.right && details.delta.dx < 0) {
            _direction = Direction.left;
          }
        },
        child: Container(
          color: Colors.grey[200],
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 20,
            ),
            itemCount: 400,
            itemBuilder: (context, index) {
              int x = index % 20;
              int y = index ~/ 20;
              Offset position = Offset(x.toDouble(), y.toDouble());

              if (_snakePositions.contains(position)) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    border: Border.all(color: Colors.white),
                  ),
                );
              } else if (position == _foodPosition) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    border: Border.all(color: Colors.white),
                  ),
                );
              } else {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: SnakeGame(),
  ));
}
