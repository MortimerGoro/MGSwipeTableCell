/*
 * MGSwipeTableCell is licensed under MIT license. See LICENSE.md file for more information.
 * Copyright (c) 2016 Imanol Fernandez @MortimerGoro
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
typedef BOOL(^ MGSwipeButtonCallback)(MGSwipeTableCell * _Nonnull cell);
@property (nonatomic, strong, nullable) MGSwipeButtonCallback callback;

/** A width for the expanded buttons. Defaults to 0, which means sizeToFit will be called. */
@property (nonatomic, assign) CGFloat buttonWidth;

/** 
 * Convenience static constructors
 */
+(nonnull instancetype) buttonWithTitle:(nonnull NSString *) title backgroundColor:(nullable UIColor *) color;
+(nonnull instancetype) buttonWithTitle:(nonnull NSString *) title backgroundColor:(nullable UIColor *) color padding:(NSInteger) padding;
+(nonnull instancetype) buttonWithTitle:(nonnull NSString *) title backgroundColor:(nullable UIColor *) color insets:(UIEdgeInsets) insets;
+(nonnull instancetype) buttonWithTitle:(nonnull NSString *) title backgroundColor:(nullable UIColor *) color callback:(nullable MGSwipeButtonCallback) callback;
+(nonnull instancetype) buttonWithTitle:(nonnull NSString *) title backgroundColor:(nullable UIColor *) color padding:(NSInteger) padding callback:(nullable MGSwipeButtonCallback) callback;
+(nonnull instancetype) buttonWithTitle:(nonnull NSString *) title backgroundColor:(nullable UIColor *) color insets:(UIEdgeInsets) insets callback:(nullable MGSwipeButtonCallback) callback;
+(nonnull instancetype) buttonWithTitle:(nonnull NSString *) title icon:(nullable UIImage*) icon backgroundColor:(nullable UIColor *) color;
+(nonnull instancetype) buttonWithTitle:(nonnull NSString *) title icon:(nullable UIImage*) icon backgroundColor:(nullable UIColor *) color padding:(NSInteger) padding;
+(nonnull instancetype) buttonWithTitle:(nonnull NSString *) title icon:(nullable UIImage*) icon backgroundColor:(nullable UIColor *) color insets:(UIEdgeInsets) insets;
+(nonnull instancetype) buttonWithTitle:(nonnull NSString *) title icon:(nullable UIImage*) icon backgroundColor:(nullable UIColor *) color callback:(nullable MGSwipeButtonCallback) callback;
+(nonnull instancetype) buttonWithTitle:(nonnull NSString *) title icon:(nullable UIImage*) icon backgroundColor:(nullable UIColor *) color padding:(NSInteger) padding callback:(nullable MGSwipeButtonCallback) callback;
+(nonnull instancetype) buttonWithTitle:(nonnull NSString *) title icon:(nullable UIImage*) icon backgroundColor:(nullable UIColor *) color insets:(UIEdgeInsets) insets callback:(nullable MGSwipeButtonCallback) callback;

-(void) setPadding:(CGFloat) padding;
-(void) setEdgeInsets:(UIEdgeInsets)insets;
-(void) centerIconOverText;
-(void) centerIconOverTextWithSpacing: (CGFloat) spacing;
-(void) iconTintColor:(nullable UIColor *)tintColor;


@end
