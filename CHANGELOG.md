# Changelog

## 1.6.8

- Fix duplicaged buttons on orientation change.

## 1.6.7

- Fix quality loss in snapshot image.
- Got rid from Block implicitly warning.

## 1.6.6

- Improve notch code to better handle edge cases like orientation changes while swiping.
- Correctly handle safeAreaInsets for RTL language.
- Add allowsButtonWithDifferentWidth property to MGSwipeSettings and deprecate the one in MGSwipeTableCell.

## 1.6.5

- Expand the first or last button width to make appearance look good with a notch (e.g. iPhone X).
- Add expandLastButtonBySafeAreaInsets property to optionally enable/disable the default behaviour.

## 1.6.4

- Backwards compatibility with XCode 8 compilation

## 1.6.2

- Handle iOS 11 safeAreaInsets.
- Fix issue #302: Right Buttons are covered iPhone X when landscape.
- Use availability checks for Objective-C to remove some warings in XCode 9.

## 1.6.1

- Fix issue #294: iOS 11 crash.

## 1.6.0

- Fix glitch when dragging before animation completes.
- Fix cell separator overlap when swiping.
- Add buttonsDistance property to MGSwipeSettings: allows to control distance between the buttons.
- Add MGSwipeExpansionLayoutNone type that allows not to performont button layout in expansions.
- Improved AppExtension and RTL language support.
- Improved Swift interoperation.

## 1.5.6

- Improve iOS 10.0 support
- Objective-C nullable annotations to improve Swift 3.0 interoperation. Add Swift 3.0 sample.
- Improve accesibility implementation to allow recording UI Tests
- Add preprocessor macro to allow compilations on App Extension projects
- Add swipeBounceRate property. Coefficient applied to cell movement in bounce zone
- Fix issue #216: Crash when combining programmatically created offset animations in consecutive block callbacks
- Fix issue #139: Accessing Buttons in UITests does not work
- Fix issue #134: Crash due to zombie object in expansion
- Fix button text alignment for RTL languages

## 1.5.5

- Fix iOS 8.0 compatibility issue
- Fix issue #190: duplicate callback

## 1.5.4

- Safer animation and callbacks checks after a cell is deleted. Fixes issue #91 caused by a null cell.indexPath because the callback was called while/after a cell is deleted
- Fix issue #168: problem with devices that read right to left (Arabic and Hebrew)
- Fix swipe issues after reloading a table
- Fix issue #163: Swipe not working after deleting a cell
- Add enableSwipeBounces property. Enabled by default, if disabled the swipe bounces will be disabled and the swipe motion will stop right after the button.
- Add allowsOppositeSwipe property. Controls whether swipe gesture is allowed in opposite directions. NO value disables swiping in opposite direction once started in one direction
- Add topMargin and bottomMargin properties to MGSwipeSettings
- Add touchOnDismissSwipe property. Controls whether dismissing a swiped cell when clicking outside of the cell generates a real touch event on the other cell. Default behaviour is the same as the Mail app on iOS. Enable it if you want to allow to start a new swipe while a cell is already in swiped.
- Add a 'BOOL finished' parameter to completion animation callbacks

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
