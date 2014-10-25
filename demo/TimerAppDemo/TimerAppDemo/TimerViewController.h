//
//  ViewController.h
//  TimerAppDemo
//
//  Created by HJC on 14/10/25.
//  Copyright (c) 2014年 HJC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"

@interface TimerViewController : UITableViewController <MGSwipeTableCellDelegate>
{
@private
    NSMutableArray* _allTasks;
    NSMutableSet* _runningTasks;
    CADisplayLink* _displayLink;
}
@end
