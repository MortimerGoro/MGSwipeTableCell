//
//  Task.m
//  TimerAppDemo
//
//  Created by HJC on 14/10/25.
//  Copyright (c) 2014年 HJC. All rights reserved.
//

#import "Task.h"

@implementation Task

- (id)initWithName:(NSString*)name
{
    self = [super init];
    if (self)
    {
        self.name = name;
        self.isRunning = FALSE;
    }
    return self;
}

@end
