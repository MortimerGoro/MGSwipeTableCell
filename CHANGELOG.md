# Changelog

## 1.4.0

- Implemented allowsButtonsWithDifferentWidth property to support buttons with different widths
- Implemented allowsMultipleSwipe feature 
- Allow starting swiping on one cell while another one is open 
- Keep cell's selection state when swipe is closed
- Fixed flash of the cell in its default state before the cell is deleted when fillOnTrigger is set.
- Improved MGSwipeButton. New utility methods to Center image over text, set edge insets, set a fixed with and more.
- Other minor bugfixes

## 1.3.6

- Improved gestureRecognizer ending detection. Fixed issue #50: Not able to swipe to reveal right after scrolling collection view children of cell content view
- Fixed the white background issue when the cell.backgroundColor is set to UIColor.clearColor
- Added utility method to perform swipe expansions programmatically

## 1.3.5

- Fixed issue #43: Two Cell Can Swipe simultaneously
