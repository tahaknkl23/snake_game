import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const SnakeGameApp());
}

class SnakeGameApp extends StatelessWidget {
  const SnakeGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Snake Game',
      home: Scaffold(
        body: Center(
          child: SnakeGame(),
        ),
      ),
    );
  }
}

class SnakeGame extends StatefulWidget {
  const SnakeGame({super.key});

  @override
  _SnakeGameState createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> {
  static const int gridSize = 20;
  static const Duration snakeSpeed = Duration(milliseconds: 300);

  List<Offset> snake = [];
  Offset food = const Offset(0, 0);
  Direction direction = Direction.right;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    setState(() {
      snake = [
        const Offset(7, 5),
        const Offset(6, 5),
        const Offset(5, 5),
      ];
      spawnFood();
      isPlaying = true;
    });
    Timer.periodic(snakeSpeed, (Timer timer) {
      if (!isPlaying) {
        timer.cancel();
      } else {
        moveSnake();
      }
    });
  }

  void moveSnake() {
    setState(() {
      Offset newHead = snake.first + direction.toOffset();
      if (isGameOver(newHead)) {
        isPlaying = false;
        showGameOverDialog();
        return;
      }
      snake.insert(0, newHead);
      if (newHead == food) {
        spawnFood();
      } else {
        snake.removeLast();
      }
    });
  }

  bool isGameOver(Offset head) {
    if (head.dx < 0 || head.dx >= gridSize || head.dy < 0 || head.dy >= gridSize || snake.contains(head)) {
      return true;
    }
    return false;
  }

  void spawnFood() {
    Random random = Random();
    Offset newFood;
    do {
      newFood = Offset(
        random.nextInt(gridSize).toDouble(),
        random.nextInt(gridSize).toDouble(),
      );
    } while (snake.contains(newFood));
    food = newFood;
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Over'),
          content: Text('You scored: ${(snake.length - 3)}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                startGame();
              },
              child: const Text('Play Again'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDirectionChange: (newDirection) {
        if ((newDirection == Direction.left && direction != Direction.right) ||
            (newDirection == Direction.right && direction != Direction.left) ||
            (newDirection == Direction.up && direction != Direction.down) ||
            (newDirection == Direction.down && direction != Direction.up)) {
          direction = newDirection;
        }
      },
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          color: Colors.white,
          child: CustomPaint(
            painter: SnakePainter(snake, food, gridSize),
          ),
        ),
      ),
    );
  }
}

enum Direction { up, down, left, right }

extension DirectionExtension on Direction {
  Offset toOffset() {
    switch (this) {
      case Direction.up:
        return const Offset(0, -1);
      case Direction.down:
        return const Offset(0, 1);
      case Direction.left:
        return const Offset(-1, 0);
      case Direction.right:
        return const Offset(1, 0);
      default:
        return Offset.zero;
    }
  }
}

class SnakePainter extends CustomPainter {
  final List<Offset> snake;
  final Offset food;
  final int gridSize;

  SnakePainter(this.snake, this.food, this.gridSize);

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / gridSize;

    final snakePaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    final foodPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    // Draw the game board (white background)
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white,
    );

    // Draw the snake
    for (var cell in snake) {
      canvas.drawRect(
        Rect.fromLTWH(
          cell.dx * cellSize,
          cell.dy * cellSize,
          cellSize,
          cellSize,
        ),
        snakePaint,
      );
    }

    // Draw the food
    canvas.drawRect(
      Rect.fromLTWH(
        food.dx * cellSize,
        food.dy * cellSize,
        cellSize,
        cellSize,
      ),
      foodPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class GestureDetector extends StatelessWidget {
  final Widget child;
  final Function(Direction) onDirectionChange;

  const GestureDetector({super.key, required this.child, required this.onDirectionChange});

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerUp: (_) => onDirectionChange(Direction.up),
      onPointerDown: (_) => onDirectionChange(Direction.down),
      onPointerMove: (details) {
        double dx = details.delta.dx;
        double dy = details.delta.dy;
        if (dx.abs() > dy.abs()) {
          if (dx > 0) {
            onDirectionChange(Direction.right);
          } else {
            onDirectionChange(Direction.left);
          }
        } else {
          if (dy > 0) {
            onDirectionChange(Direction.down);
          } else {
            onDirectionChange(Direction.up);
          }
        }
      },
      child: child,
    );
  }
}
