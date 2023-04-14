import 'dart:math';

List<double> getRandomPipeHeights() {
  Random random = Random();
  double _bottomHeight = random.nextDouble() * 0.4 + 0.05;
  return [_bottomHeight, 1 - _bottomHeight - 0.4];
}
