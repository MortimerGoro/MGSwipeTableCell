//
//  ViewController.m
//  TimerAppDemo
//
//  Created by HJC on 14/10/25.
//  Copyright (c) 2014年 HJC. All rights reserved.
//

#import "TimerViewController.h"
#import "Task.h"
#import "TaskTableViewCell.h"

#define kCellID @"CellID"

@implementation TimerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.rowHeight = 60;
    self.title = NSLocalizedString(@"Task", @"");
    [self.tableView registerClass:[TaskTableViewCell class] forCellReuseIdentifier:kCellID];

    NSArray* taskNames =  @[ NSLocalizedString(@"read", @""),
                             NSLocalizedString(@"play", @""),
                             NSLocalizedString(@"shopping", @""),
                             NSLocalizedString(@"program", @""),
                             NSLocalizedString(@"work", @""),
                             NSLocalizedString(@"watch TV", @"")
                             ];
    _allTasks = [[NSMutableArray alloc] initWithCapacity:taskNames.count];
    for (NSString* name in taskNames)
    {
        Task* task = [[Task alloc] initWithName:name];
        [_allTasks addObject:task];
    }
}

- (void)displayLinkStep:(CADisplayLink*)displayLink
{
    if (_runningTasks.count == 0)
    {
        return;
    }

    NSDate* currentDate = [NSDate date];
    NSArray* indexPaths = [self.tableView indexPathsForVisibleRows];

    for (NSIndexPath* indexPath in indexPaths)
    {
        Task* task = _allTasks[indexPath.row];
        if (task.isRunning)
        {
            TaskTableViewCell* cell = (TaskTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
            NSAssert(cell.isRunning, @"");
            cell.currentSeconds = [currentDate timeIntervalSinceDate:task.startDate];
        }
    }
}

- (void)startTask:(Task*)task
{
    if (_runningTasks == nil)
    {
        _runningTasks = [[NSMutableSet alloc] initWithCapacity:1];
    }

    if (_runningTasks.count == 0)
    {
        if (_displayLink == nil)
        {
            _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkStep:)];
            [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        }
    }
    task.startDate = [NSDate date];
    task.isRunning = YES;
    [_runningTasks addObject:task];
}

- (void)stopTask:(Task*)task
{
    task.isRunning = NO;
    [_runningTasks removeObject:task];
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_allTasks count];
}

- (void)configureCell:(TaskTableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    Task* task = _allTasks[indexPath.row];
    cell.taskName = task.name;
    cell.isRunning = task.isRunning;
    if (cell.isRunning)
    {
        cell.currentSeconds = [[NSDate date] timeIntervalSinceDate:task.startDate];
    }
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    TaskTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kCellID forIndexPath:indexPath];
    cell.delegate = self;
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    TaskTableViewCell* cell = (TaskTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell showSwipe:MGSwipeDirectionLeftToRight animated:YES];
}

- (BOOL)swipeTableCell:(MGSwipeTableCell*)cell
    tappedButtonAtIndex:(NSInteger)index
              direction:(MGSwipeDirection)direction
          fromExpansion:(BOOL)fromExpansion
{
    if (direction == MGSwipeDirectionRightToLeft && index == 0)
    {
        NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
        [_runningTasks removeObject:_allTasks[indexPath.row]];
        [_allTasks removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (direction == MGSwipeDirectionLeftToRight && index == 0)
    {
        TaskTableViewCell* taskCell = (TaskTableViewCell*)cell;
        NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
        Task* task = _allTasks[indexPath.row];

        if (taskCell.isRunning)
        {
            [self stopTask:task];
            taskCell.isRunning = NO;
        }
        else
        {
            [self startTask:task];
            taskCell.isRunning = YES;
        }
    }
    return YES;
}

@end
