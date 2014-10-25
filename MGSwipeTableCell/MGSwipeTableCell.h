/*
 * MGSwipeTableCell is licensed under MIT license. See LICENSE.md file for more information.
 * Copyright (c) 2014 Imanol Fernandez @MortimerGoro
 */

#import <UIKit/UIKit.h>

/** Transition types */
typedef NS_ENUM(NSInteger, MGSwipeTransition) {
    MGSwipeTransitionBorder = 0,
    MGSwipeTransitionStatic,
    MGSwipeTransitionDrag,
    MGSwipeTransitionClipCenter,
    MGSwipeTransition3D,
};

/** Swipe directions */
typedef NS_ENUM(NSInteger, MGSwipeDirection) {
    MGSwipeDirectionLeftToRight = 0,
    MGSwipeDirectionRightToLeft
};


/**
 * Swipe settings
 **/
@interface MGSwipeSettings: NSObject
/** Transition used while swipping buttons */
@property (nonatomic, assign) MGSwipeTransition transition;
/** Size proportional threshold to hide/keep the buttons when the user ends swipping. Default value 0.5 */
@property (nonatomic, assign) CGFloat threshold;
/** Optional offset to change the swipe buttons position. Relative to the cell border position. Default value: 0 
 ** For example it can be used to avoid cropped buttons when sectionIndexTitlesForTableView is used in the UITableView
 **/
@property (nonatomic, assign) CGFloat offset;
@end


/**
 * Expansion settings to make expandable buttons
 * Swipe button are not expandable by default
 **/
@interface MGSwipeExpansionSettings: NSObject
/** index of the expandable button (in the left or right buttons arrays) */
@property (nonatomic, assign) NSInteger buttonIndex;
/** if true the button fills the cell on trigger, else it bounces back to its initial position */
@property (nonatomic, assign) BOOL fillOnTrigger;
/** Size proportional threshold to trigger the expansion button. Default value 1.5 */
@property (nonatomic, assign) CGFloat threshold;
@end


/** helper forward declaration */
@class MGSwipeTableCell;

/** 
 * Optional delegate to configure swipe buttons or to receive triggered actions.
 * Buttons can be configured inline when the cell is created instead of using this delegate,
 * but using the delegate improves memory usage because buttons are only created in demand
 */
@protocol MGSwipeTableCellDelegate <NSObject>

@optional
/**
 * Delegate method to enable/disable swipe gestures
 * @return YES if swipe is allowed
 **/
-(BOOL) swipeTableCell:(MGSwipeTableCell*) cell canSwipe:(MGSwipeDirection) direction;
/**
 * Called when the user clicks a swipe button or when a expandable button is automatically triggered
 * @return YES to autohide the current swipe buttons
 **/
-(BOOL) swipeTableCell:(MGSwipeTableCell*) cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion;
/**
 * Delegate method to setup the swipe buttons and swipe/expansion settings
 * Buttons can be any kind of UIView but it's recommended to use the convenience MGSwipeButton class
 * Setting up buttons with this delegate instead of using cell properties improves memory usage because buttons are only created in demand
 * @param swipeTableCell the UITableVieCel to configure. You can get the indexPath using [tableView indexPathForCell:cell]
 * @param direction The swipe direction (left to right or right to left)
 * @param swipeSettings instance to configure the swipe transition and setting (optional)
 * @param expansionSettings instance to configure button expansions (optional)
 * @return Buttons array
 **/
-(NSArray*) swipeTableCell:(MGSwipeTableCell*) cell swipeButtonsForDirection:(MGSwipeDirection)direction
             swipeSettings:(MGSwipeSettings*) swipeSettings expansionSettings:(MGSwipeExpansionSettings*) expansionSettings;

@end


/**
 * Swipe Cell class
 * To implement swipe cells you have to override from this class
 * You can create the cells programmatically, using xibs or storyboards
 */
@interface MGSwipeTableCell : UITableViewCell

/** optional delegate (not retained) */
@property (nonatomic, assign) id<MGSwipeTableCellDelegate> delegate;

/** 
 * Left and right swipe buttons and its settings.
 * Buttons can be any kind of UIView but it's recommended to use the convenience MGSwipeButton class
 */
@property (nonatomic, copy) NSArray * leftButtons;
@property (nonatomic, copy) NSArray * rightButtons;
@property (nonatomic, strong) MGSwipeSettings * leftSwipeSettings;
@property (nonatomic, strong) MGSwipeSettings * rightSwipeSettings;

/** Optional settings to allow expandable buttons */
@property (nonatomic, strong) MGSwipeExpansionSettings * leftExpansion;
@property (nonatomic, strong) MGSwipeExpansionSettings * rightExpansion;

/** Property to read or change the current swipe offset programmatically */
@property (nonatomic, assign) CGFloat swipeOffset;
/** Property to read or change swipe animation durations. Default value 0.3 */
@property (nonatomic, assign) CGFloat swipeAnimationDuration;

/** Utility methods to show or hide swipe buttons programmatically */
-(void) hideSwipeAnimated: (BOOL) animated;
-(void) showSwipe: (MGSwipeDirection) direction animated: (BOOL) animated;
-(void) setSwipeOffset:(CGFloat)offset animated: (BOOL) animated completion:(void(^)()) completion;

/** Refresh method to be used when you want to update the cell contents while the user is swipping */
-(void) refreshContentView;

@end

