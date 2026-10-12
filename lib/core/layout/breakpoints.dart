import 'package:flutter/widgets.dart';

/// compact  (< 600)   phones in portrait          -> bottom bar, 1 column
/// medium   (600-900) phones in landscape, tablets -> side rail, 1-2 columns
/// expanded (>= 900)  large tablets, desktop       -> wide rail, 2-3 columns
enum ScreenSize { compact, medium, expanded }

ScreenSize screenSizeForWidth(double width) {
  if (width < 600) return ScreenSize.compact;
  if (width < 900) return ScreenSize.medium;
  return ScreenSize.expanded;
}

extension ScreenSizeContext on BuildContext {
  ScreenSize get screenSize =>
      screenSizeForWidth(MediaQuery.sizeOf(this).width);
}
