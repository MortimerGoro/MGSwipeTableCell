//
//  TaskClockTableViewCell.h
//  TimeTracker
//
//  Created by HJC on 14/10/23.
//  Copyright (c) 2014年 HJC. All rights reserved.
//

#import "MGSwipeTableCell.h"

@interface TaskTableViewCell : MGSwipeTableCell
{
}
@property (nonatomic, assign) BOOL isRunning;
@property (nonatomic, retain) NSString* taskName;
@property (nonatomic, assign) NSTimeInterval currentSeconds;

@end
