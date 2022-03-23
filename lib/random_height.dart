import 'dart:math';

List<double> getRandomPipeHeights(double screenHeight) {
  Random random = Random();
  double _bottomHeight = random.nextDouble() * 300 + 50;
  return [_bottomHeight, screenHeight - _bottomHeight - 200];
}
