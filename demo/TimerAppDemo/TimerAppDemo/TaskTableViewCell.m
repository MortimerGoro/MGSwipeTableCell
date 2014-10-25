//
//  TaskClockTableViewCell.m
//  TimeTracker
//
//  Created by HJC on 14/10/23.
//  Copyright (c) 2014年 HJC. All rights reserved.
//

#import "TaskTableViewCell.h"
#import "MGSwipeButton.h"

static NSString* TimeTextFromSeconds(NSTimeInterval seconds)
{
    NSInteger hours = seconds / 3600;
    seconds -= hours * 3600;

    NSInteger minus = seconds / 60;
    seconds -= minus * 60;

    return [NSString stringWithFormat:@"%02d:%02d:%02d", (int)hours, (int)minus, (int)seconds];
}

@implementation TaskTableViewCell
{
    NSArray* _leftStartButtons;
    NSArray* _leftStopButtons;
}

- (NSArray*)getLeftStartButtons
{
    if (_leftStartButtons == nil)
    {
        UIColor* color = [UIColor colorWithRed:0 green:0x99 / 255.0 blue:0xcc / 255.0 alpha:1.0];
        NSString* title = NSLocalizedString(@"Start", @"");
        MGSwipeButton* button = [MGSwipeButton buttonWithTitle:title backgroundColor:color padding:20 callback:nil];
        _leftStartButtons = @[ button ];
    }
    return _leftStartButtons;
}

- (NSArray*)getLeftStopButtons
{
    if (_leftStopButtons == nil)
    {
        UIColor* color = [UIColor colorWithRed:0.59 green:0.29 blue:0.08 alpha:1.0];
        NSString* title = NSLocalizedString(@"Stop", @"");
        MGSwipeButton* button = [MGSwipeButton buttonWithTitle:title backgroundColor:color padding:20 callback:nil];
        _leftStopButtons = @[ button ];
    }
    return _leftStopButtons;
}

- (NSArray*)createRightButtons
{
    NSMutableArray* result = [NSMutableArray array];
    MGSwipeButton* button = [MGSwipeButton buttonWithTitle:NSLocalizedString(@"Delete", @"")
                                           backgroundColor:[UIColor redColor]
                                                   padding:20
                                                  callback:nil];
    [result addObject:button];
    return result;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.rightButtons = [self createRightButtons];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.leftSwipeSettings.transition = MGSwipeTransitionStatic;
        self.rightSwipeSettings.transition = MGSwipeTransitionStatic;
        self.leftExpansion.buttonIndex = -1;
        self.leftExpansion.fillOnTrigger = YES;
        self.rightExpansion.buttonIndex = -1;
        self.rightExpansion.fillOnTrigger = YES;
    }
    return self;
}

- (void)updateUI
{
    if (_isRunning)
    {
        NSString* text = [NSString stringWithFormat:@"%@ - %@", _taskName, TimeTextFromSeconds(_currentSeconds)];
        self.textLabel.text = text;
    }
    else
    {
        self.textLabel.text = _taskName;
    }
}

- (void)setTaskName:(NSString*)taskName
{
    _taskName = taskName;
    [self updateUI];
}

- (void)setIsRunning:(BOOL)isRunning
{
    _isRunning = isRunning;
    [self updateUI];

    if (_isRunning)
    {
        self.leftButtons = [self getLeftStopButtons];
    }
    else
    {
        self.leftButtons = [self getLeftStartButtons];
    }
}

- (void)setCurrentSeconds:(NSTimeInterval)currentSeconds
{
    _currentSeconds = currentSeconds;
    [self updateUI];
}

@end
