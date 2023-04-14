import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_app/bird.dart';
import 'package:my_app/pipe.dart';
import 'package:my_app/random_height.dart';
import 'package:my_app/scores.dart';

const _gravity = -4.3; //TODO check this
const _velocity = 2.0;
const _birdX = 0.25;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  final _pipeWidth = 80.0;
  final _pipeHeights = <List<double>>[
    [0.4, 0.2],
    [0.25, 0.35],
    [0.15, 0.45],
  ];
  final _birdSize = 50.0;

  var _gameStarted = false;
  var _birdY = 0.5;
  var initialPos = 0.5;
  var time = 0.0;
  var xPipe = <double>[0.8, 1.4, 2.0];
  var score = 0;
  var scoreRecord = 0;

  void _startGame() {
    _gameStarted = true;
    var height = 0.0;

    Timer.periodic(const Duration(milliseconds: 10), (timer) {
      height = _gravity * time * time + _velocity * time;

      setState(() {
        _birdY = initialPos + height;
      });

      setState(() {
        for (int i = 0; i < xPipe.length; i++) {
          if (xPipe[i] < -1) {
            xPipe[i] += 1.8;
            _pipeHeights[i] = getRandomPipeHeights();
            score++;
            _checkScoreRecord(score);
          } else {
            xPipe[i] -= 0.01;
          }
        }
      });

      if (_birdIsDead()) {
        timer.cancel();
        _showGameOverDialog();
      }

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
    if (_birdY < 0 || _birdY > 1) {
      return true;
    }
    return false;
  }

  bool _birdHitPipe() {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height * 0.75;

    final birdStartPosition = _birdX * width;
    final birdEndPosition = _birdX * width + _birdSize;

    for (int pipeNumber = 0; pipeNumber < xPipe.length; pipeNumber++) {
      final xPipeStartPosition = xPipe[pipeNumber] * width;
      final xPipeEndPosition = xPipe[pipeNumber] * width + _pipeWidth;

      final birdAndPipeXIntersects = xPipeStartPosition <= birdEndPosition &&
          xPipeEndPosition >= birdStartPosition;

      final birdHitTopPipe =
          _birdY + (_birdSize / height) >= 1 - _pipeHeights[pipeNumber][1];

      final birdHitBottomPipe = _birdY <= _pipeHeights[pipeNumber][0];

      final birdAndPipeYIntersects = birdHitTopPipe || birdHitBottomPipe;

      if (birdAndPipeXIntersects && birdAndPipeYIntersects) {
        return true;
      }
    }

    return false;
  }

  void restartGame() {
    setState(() {
      _birdY = 0.5;
      _gameStarted = false;
      _pipeHeights[0] = [0.4, 0.2];
      time = 0;
      initialPos = 0.5;
      xPipe = <double>[0.8, 1.4, 2.0];
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

  double birdXPosition(double screenWidth) {
    return screenWidth * _birdX;
  }

  double birdYPosition(double gameHeight) {
    return gameHeight * _birdY;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _gameStarted ? _jump : _startGame,
      child: Column(
        children: [
          Expanded(
              flex: 3,
              child: LayoutBuilder(builder: (context, constraints) {
                double width = constraints.maxWidth;
                double height = constraints.maxHeight;
                return Container(
                  color: Colors.blue[300],
                  child: Stack(
                    children: [
                      Positioned(
                        left: birdXPosition(width),
                        bottom: birdYPosition(height),
                        child: Bird(birdSize: _birdSize),
                      ),
                      Pipe(
                        pipeHeight: _pipeHeights[0][0] * height,
                        pipeWidth: _pipeWidth,
                        isBottomPipe: true,
                        xPipePosition: xPipe[0] * width,
                      ),
                      Pipe(
                        pipeHeight: _pipeHeights[0][1] * height,
                        pipeWidth: _pipeWidth,
                        xPipePosition: xPipe[0] * width,
                      ),
                      Pipe(
                        pipeHeight: _pipeHeights[1][0] * height,
                        pipeWidth: _pipeWidth,
                        isBottomPipe: true,
                        xPipePosition: xPipe[1] * width,
                      ),
                      Pipe(
                        pipeHeight: _pipeHeights[1][1] * height,
                        pipeWidth: _pipeWidth,
                        xPipePosition: xPipe[1] * width,
                      ),
                      Pipe(
                        pipeHeight: _pipeHeights[2][0] * height,
                        pipeWidth: _pipeWidth,
                        isBottomPipe: true,
                        xPipePosition: xPipe[2] * width,
                      ),
                      Pipe(
                        pipeHeight: _pipeHeights[2][1] * height,
                        pipeWidth: _pipeWidth,
                        xPipePosition: xPipe[2] * width,
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
                );
              })),
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
