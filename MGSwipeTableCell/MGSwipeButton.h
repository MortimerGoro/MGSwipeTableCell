/*
 * MGSwipeTableCell is licensed under MIT license. See LICENSE.md file for more information.
 * Copyright (c) 2014 Imanol Fernandez @MortimerGoro
 */

#import <UIKit/UIKit.h>


@class MGSwipeTableCell;

/** 
 * This is a convenience class to create MGSwipeTableCell buttons
 * Using this class is optional because MGSwipeTableCell is button agnostic and can use any UIView for that purpose
 * Anyway, it's recommended that you use this class because is totally tested and easy to use ;)
 */
@interface MGSwipeButton : UIButton

/**
 * Convenience block callback for developers lazy to implement the MGSwipeTableCellDelegate.
 * @return Return YES to autohide the swipe view
 */
typedef BOOL(^MGSwipeButtonCallback)(MGSwipeTableCell * sender);
@property (nonatomic, strong) MGSwipeButtonCallback callback;

/** A width for the expanded buttons. Defaults to 0, which means sizeToFit will be called. */
@property (nonatomic, assign) CGFloat buttonWidth;

/** 
 * Convenience static constructors
 */
+(instancetype) buttonWithTitle:(NSString *) title backgroundColor:(UIColor *) color;
+(instancetype) buttonWithTitle:(NSString *) title backgroundColor:(UIColor *) color padding:(NSInteger) padding;
+(instancetype) buttonWithTitle:(NSString *) title backgroundColor:(UIColor *) color insets:(UIEdgeInsets) insets;
+(instancetype) buttonWithTitle:(NSString *) title backgroundColor:(UIColor *) color callback:(MGSwipeButtonCallback) callback;
+(instancetype) buttonWithTitle:(NSString *) title backgroundColor:(UIColor *) color padding:(NSInteger) padding callback:(MGSwipeButtonCallback) callback;
+(instancetype) buttonWithTitle:(NSString *) title backgroundColor:(UIColor *) color insets:(UIEdgeInsets) insets callback:(MGSwipeButtonCallback) callback;
+(instancetype) buttonWithTitle:(NSString *) title icon:(UIImage*) icon backgroundColor:(UIColor *) color;
+(instancetype) buttonWithTitle:(NSString *) title icon:(UIImage*) icon backgroundColor:(UIColor *) color padding:(NSInteger) padding;
+(instancetype) buttonWithTitle:(NSString *) title icon:(UIImage*) icon backgroundColor:(UIColor *) color insets:(UIEdgeInsets) insets;
+(instancetype) buttonWithTitle:(NSString *) title icon:(UIImage*) icon backgroundColor:(UIColor *) color callback:(MGSwipeButtonCallback) callback;
+(instancetype) buttonWithTitle:(NSString *) title icon:(UIImage*) icon backgroundColor:(UIColor *) color padding:(NSInteger) padding callback:(MGSwipeButtonCallback) callback;
+(instancetype) buttonWithTitle:(NSString *) title icon:(UIImage*) icon backgroundColor:(UIColor *) color insets:(UIEdgeInsets) insets callback:(MGSwipeButtonCallback) callback;

-(void) setPadding:(CGFloat) padding;
-(void) setEdgeInsets:(UIEdgeInsets)insets;
-(void) centerIconOverText;

@end