import 'package:flutter/material.dart';

class Pipe extends StatelessWidget {
  const Pipe({
    Key? key,
    required this.pipeHeight,
    required this.pipeWidth,
    this.isBottomPipe = false,
    required this.xPipePosition,
  }) : super(key: key);

  final double pipeHeight;
  final double pipeWidth;
  final bool isBottomPipe;
  final double xPipePosition;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: xPipePosition,
      bottom: isBottomPipe ? 0 : null,
      top: isBottomPipe ? null : 0,
      child: Container(
        color: Colors.green,
        height: pipeHeight,
        width: pipeWidth,
      ),
    );
  }
}
