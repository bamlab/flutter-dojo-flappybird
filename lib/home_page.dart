import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_app/bird.dart';
import 'package:my_app/pipe.dart';
import 'package:my_app/random_height.dart';
import 'package:my_app/scores.dart';

const _gravity = -4.9;
const _velocity = 2.5;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  final _pipeWidth = 80.0;
  final _pipeHeights = <List<double>>[
    [250, 150],
    [100, 300],
    [150, 250],
  ];
  final _birdSize = 50.0;

  var _gameStarted = false;
  var _birdY = 0.0;
  var initialPos = 0.0;
  var time = 0.0;
  var xPipeAlignment = <double>[1.0, 2.2, 3.4];
  var score = 0;
  var scoreRecord = 0;

  void _startGame() {
    _gameStarted = true;
    var height = 0.0;

    Timer.periodic(const Duration(milliseconds: 10), (timer) {
      height = _gravity * time * time + _velocity * time;

      setState(() {
        _birdY = initialPos - height;
      });

      setState(() {
        for (int i = 0; i < xPipeAlignment.length; i++) {
          if (xPipeAlignment[i] < -2) {
            xPipeAlignment[i] += 3.5;
            _pipeHeights[i] =
                getRandomPipeHeights(MediaQuery.of(context).size.height * 0.75);
            score++;
            _checkScoreRecord(score);
          } else {
            xPipeAlignment[i] -= 0.01;
          }
        }
      });

      _birdIsDead()
          ? {
              timer.cancel(),
              _showGameOverDialog(),
            }
          : null;

      time += 0.01;
    });
  }

  void _checkScoreRecord(int score) {
    if (score > scoreRecord) {
      scoreRecord = score;
    }
  }

  bool _birdIsDead() {
    return _birdHitGroundOrTop() || _birdHitPipe();
  }

  bool _birdHitGroundOrTop() {
    if (_birdY < -1 || _birdY > 1) {
      return true;
    }
    return false;
  }

  bool _birdHitPipe() {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height * 0.75 / 2;

    for (int pipeNumber = 0; pipeNumber < xPipeAlignment.length; pipeNumber++) {
      if (xPipeAlignment[pipeNumber] - _pipeWidth / width <= -0.45 &&
          xPipeAlignment[pipeNumber] + _pipeWidth / width >= -0.65 &&
          (_birdY >= 1 - (_pipeHeights[pipeNumber][0]) / height ||
              _birdY <= -1 + (_pipeHeights[pipeNumber][1]) / height)) {
        return true;
      }
    }
    return false;
  }

  void restartGame() {
    setState(() {
      _birdY = 0;
      _gameStarted = false;
      time = 0;
      initialPos = 0;
      xPipeAlignment = [1.0, 2.2, 3.4];
      score = 0;
    });
  }

  void _showGameOverDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.brown,
            title: Center(
              child: Text(
                'Game over!'.toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            actions: [
              MaterialButton(
                color: Colors.grey[100],
                onPressed: () {
                  restartGame();
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.refresh,
                  color: Colors.brown,
                ),
              )
            ],
            actionsAlignment: MainAxisAlignment.center,
          );
        });
  }

  void _jump() {
    setState(() {
      time = 0.0;
      initialPos = _birdY;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _gameStarted ? _jump : _startGame,
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.blue[300],
              child: Stack(
                children: [
                  Container(
                    alignment: Alignment(-0.5, _birdY),
                    child: Bird(birdSize: _birdSize),
                  ),
                  Pipe(
                    pipeHeight: _pipeHeights[0][0],
                    pipeWidth: _pipeWidth,
                    isBottomPipe: true,
                    xPipeAlignment: xPipeAlignment[0],
                  ),
                  Pipe(
                    pipeHeight: _pipeHeights[0][1],
                    pipeWidth: _pipeWidth,
                    xPipeAlignment: xPipeAlignment[0],
                  ),
                  Pipe(
                    pipeHeight: _pipeHeights[1][0],
                    pipeWidth: _pipeWidth,
                    isBottomPipe: true,
                    xPipeAlignment: xPipeAlignment[1],
                  ),
                  Pipe(
                    pipeHeight: _pipeHeights[1][1],
                    pipeWidth: _pipeWidth,
                    xPipeAlignment: xPipeAlignment[1],
                  ),
                  Pipe(
                    pipeHeight: _pipeHeights[2][0],
                    pipeWidth: _pipeWidth,
                    isBottomPipe: true,
                    xPipeAlignment: xPipeAlignment[2],
                  ),
                  Pipe(
                    pipeHeight: _pipeHeights[2][1],
                    pipeWidth: _pipeWidth,
                    xPipeAlignment: xPipeAlignment[2],
                  ),
                  Container(
                    alignment: const Alignment(0, -0.4),
                    child: Text(
                      _gameStarted ? '' : 'T A P  T O  P L A Y',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.brown,
              child: GameScore(
                score: score,
                scoreRecord: scoreRecord,
              ),
            ),
          )
        ],
      ),
    );
  }
}
