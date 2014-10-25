//
//  Task.h
//  TimerAppDemo
//
//  Created by HJC on 14/10/25.
//  Copyright (c) 2014年 HJC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Task : NSObject
{
}
@property (nonatomic, copy) NSString* name;
@property (nonatomic, retain) NSDate* startDate;
@property (nonatomic, assign) BOOL isRunning;

- (id)initWithName:(NSString*)name;

@end
