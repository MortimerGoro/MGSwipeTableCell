# Changelog


## 1.5.3

- Fix duplicated callbacks with reused button instances among many cells
- Fix Carthage header for normal projects

## 1.5.2

- Add Carthage support
- Fix issues #160 and #162: Delegate call multiple time on single touch on iOS 9
- Fix programmatic call to setSwipeOffset when swipeView is not yet created
- Fix Swipe backgroundColor change without re-initializing the cell
- Fix UITableCellSelectionStyle on end swipe
- centerIconOverText now takes a spacing argument

## 1.5.1

- Fix default animation values

## 1.5.0

- Feature: Add predefined and configurable easing functions to the API. Swipe animations are now splitted into different settings so you can now use different animations (easing function, duration, etc) for each kind of animations: show swipe, hide swipe, stretch cell from already swiped buttons and more.
- Feature: Full support for Spotify App like swipe animations. Create new Spotify Demo project.
- Feature: add onlySwipeButtons property that allows to only swipe the buttons and keep the cell content static
- Feature: add fromOffset argument to the canSwipe delegate method. Useful for supporting sidebar menus with swipe to open. You can use it to restrict the cell from being swiped if the offset is to close to the edge.
- Feature: add preservesSelectionStatus property that allows to control whether selection/highlight is changed when swiped.
- Feature: add keepButtonsSwiped property to Swipe settings
- Feature: new delegate method: shouldHideSwipeOnTap:(CGPoint) point. Now you can cancel to hide opened swipe depending on the tap point
- Feature: new delegate methods: swipeTableCellWillBeginSwiping & swipeTableCellWillEndSwiping. Useful to make cell changes that only are shown after the cell is swiped open
- Fixed issue #113: Bug when changing the orientation of the device
- Fixed typo throughout readme and source of "swiping"
- Fixed issue #100: canSwipe not working when swipe to the allowed direction and swipe with inertia to the forbidden direction
- Fixed clip mask when animating expansion
- Keep expansion color while expansion is animating to 0


## 1.4.3

- Fixed crash with different class cells in multiple section tables
- Add completion handlers to convenience show/hide methods

## 1.4.2

- Fixed issue #89: Swipe fails after table reload while swipping gesture is active

## 1.4.1

- Implemented Spotify App style cell expansion: added expansionLayout and expansionColor properties to MGSwipeExpansionSettings
- New property allowsSwipeWhenTappingButtons. Fixed issue #80: swiping the cell when you swipe the buttons in the cell
- Fixed issue #78: Swift problem with one enum
- Fixed issue #82: fillOnTrigger not working properly with UITableViewCellAccessoryDisclosureIndicator
- Fixed issue #84: can't compile in xcode 6.3
- Fixed issue #76: Swiped cell state issue when table view is scrolling

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
