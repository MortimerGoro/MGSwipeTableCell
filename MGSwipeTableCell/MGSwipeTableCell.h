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

/** Swipe state */
typedef NS_ENUM(NSInteger, MGSwipeState) {
    MGSwipeStateNone = 0,
    MGSwipeStateSwippingLeftToRight,
    MGSwipeStateSwippingRightToLeft,
    MGSwipeStateExpandingLeftToRight,
    MGSwipeStateExpandingRightToLeft,
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

/** Property to read or change swipe animation durations. Default value 0.3 */
@property (nonatomic, assign) CGFloat animationDuration;

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

/** Property to read or change expansion animation durations. Default value 0.2 
 * The target animation is the change of a button from normal state to expanded state
 */
@property (nonatomic, assign) CGFloat animationDuration;
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
 * Delegate method invoked when the current swipe state changes
 @param state the current Swipe State
 @param gestureIsActive YES if the user swipe gesture is active. No if the uses has already ended the gesture
 **/
-(void) swipeTableCell:(MGSwipeTableCell*) cell didChangeSwipeState:(MGSwipeState) state gestureIsActive:(BOOL) gestureIsActive;

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
@property (nonatomic, weak) id<MGSwipeTableCellDelegate> delegate;

/** optional to use contentView alternative. Use this property instead of contentView to support animated views while swipping */
@property (nonatomic, strong, readonly) UIView * swipeContentView;

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

/** Readonly property to fetch the current swipe state */
@property (nonatomic, readonly) MGSwipeState swipeState;
/** Readonly property to check if the user swipe gesture is currently active */
@property (nonatomic, readonly) BOOL isSwipeGestureActive;

// default is NO. Controls whether multiple cells can be swipped simultaneously
@property (nonatomic) BOOL allowsMultipleSwipe;
// default is NO. Controls whether buttons with different width are allowed. Buttons are resized to have the same size by default.
@property (nonatomic) BOOL allowsButtonsWithDifferentWidth;

/** Optional background color for swipe overlay. If not set, its inferred automatically from the cell contentView */
@property (nonatomic, strong) UIColor * swipeBackgroundColor;
/** Property to read or change the current swipe offset programmatically */
@property (nonatomic, assign) CGFloat swipeOffset;

/** Utility methods to show or hide swipe buttons programmatically */
-(void) hideSwipeAnimated: (BOOL) animated;
-(void) showSwipe: (MGSwipeDirection) direction animated: (BOOL) animated;
-(void) setSwipeOffset:(CGFloat)offset animated: (BOOL) animated completion:(void(^)()) completion;
-(void) expandSwipe: (MGSwipeDirection) direction animated: (BOOL) animated;

/** Refresh method to be used when you want to update the cell contents while the user is swipping */
-(void) refreshContentView;
/** Refresh method to be used when you want to dinamically change the left or right buttons (add or remove)
 * If you only want to change the title or the backgroundColor of a button you can change it's properties (get the button instance from leftButtons or rightButtons arrays)
 * @param usingDelegate if YES new buttons will be fetched using the MGSwipeTableCellDelegate. Otherwise new buttons will be fetched from leftButtons/rightButtons properties.
 */
-(void) refreshButtons: (BOOL) usingDelegate;

@end

