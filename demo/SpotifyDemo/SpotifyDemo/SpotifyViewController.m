/*
 * MGSwipeTableCell is licensed under MIT license. See LICENSE.md file for more information.
 * Copyright (c) 2014 Imanol Fernandez @MortimerGoro
 */

#import "SpotifyViewController.h"
#import "MGSwipeButton.h"


@interface SongData : NSObject
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * album;
@end

@implementation SongData
@end


typedef void(^MailActionCallback)(BOOL cancelled, BOOL deleted, NSInteger actionIndex);

@implementation SpotifyViewController
{
    NSMutableArray * demoData;
    MailActionCallback actionCallback;
    UIRefreshControl * refreshControl;
}

-(BOOL) prefersStatusBarHidden
{
    return YES;
}


-(void) prepareDemoData
{
    demoData = [NSMutableArray array];
    
    NSArray * titles = @[
                       @"Vincent",
                       @"Mr Glass",
                       @"Marsellus",
                       @"Ringo",
                       @"Sullivan",
                       @"Mr Wolf",
                       @"Butch Coolidge",
                       @"Marvin",
                       @"Captain Koons",
                       @"Jules",
                       @"Jimmie Dimmick"
                       ];
    
    NSArray * albums = @[
                           @"You think water moves fast?",
                           @"They called me Mr Glass",
                           @"The path of the righteous man",
                           @"Do you see any Teletubbies in here?",
                           @"Now that we know who you are",
                           @"My money's in that office, right?",
                           @"Now we took an oath",
                           @"That show's called a pilot",
                           @"I know who I am. I'm not a mistake",
                           @"It all makes sense!",
                           @"The selfish and the tyranny of evil men",
                           ];
    
    for (int i = 0; i < titles.count; ++i) {
        SongData * song = [[SongData alloc] init];
        song.title = [titles objectAtIndex:i];
        song.album = [albums objectAtIndex:i];
        [demoData addObject:song];
    }
}

-(void) refreshCallback
{
    [self prepareDemoData];
    [_tableView reloadData];
    [refreshControl endRefreshing];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorColor = [UIColor clearColor];
    _tableView.backgroundColor = [UIColor colorWithRed:15/255.0 green:16/255.0 blue:16/255.0 alpha:1.0];
    [self.view addSubview:_tableView];
    
    self.title = @"Spotify App Demo";
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshCallback) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    [self prepareDemoData];
}

-(void) viewDidAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

-(void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    _tableView.frame = self.view.bounds;
}

-(void) deleteMail:(NSIndexPath *) indexPath
{
    [demoData removeObjectAtIndex:indexPath.row];
    [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

-(SongData *) songForIndexPath:(NSIndexPath*) path
{
    return [demoData objectAtIndex:path.row];
}

#pragma mark Table Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return demoData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier = @"SongCell";
    MGSwipeTableCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[MGSwipeTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.textLabel.font =  [UIFont fontWithName:@"HelveticaNeue-Light" size:21.0f];
        cell.textLabel.textColor = [UIColor colorWithRed:152/255.0 green:152/255.0 blue:157/255.0 alpha:1.0];
        cell.textLabel.font =  [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0f];
        cell.detailTextLabel.textColor = cell.textLabel.textColor;
        cell.backgroundColor = [UIColor colorWithRed:15/255.0 green:16/255.0 blue:16/255.0 alpha:1.0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIImageView * view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"more.png"]];
        view.contentMode = UIViewContentModeScaleAspectFit;
        view.frame = CGRectMake(0, 0, 25, 25);
        cell.accessoryView = view;
    }
    cell.delegate = self;
    
    SongData * data = [demoData objectAtIndex:indexPath.row];
    cell.textLabel.text = data.title;
    cell.detailTextLabel.text = data.album;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

#pragma mark Swipe Delegate

-(BOOL) swipeTableCell:(MGSwipeTableCell*) cell canSwipe:(MGSwipeDirection) direction;
{
    return YES;
}

-(NSArray*) swipeTableCell:(MGSwipeTableCell*) cell swipeButtonsForDirection:(MGSwipeDirection)direction
             swipeSettings:(MGSwipeSettings*) swipeSettings expansionSettings:(MGSwipeExpansionSettings*) expansionSettings
{
    
    swipeSettings.transition = MGSwipeTransitionClipCenter;
    swipeSettings.keepButtonsSwiped = NO;
    expansionSettings.buttonIndex = 0;
    expansionSettings.threshold = 1.0;
    expansionSettings.expansionLayout = MGSwipeExpansionLayoutCenter;
    expansionSettings.expansionColor = [UIColor colorWithRed:33/255.0 green:175/255.0 blue:67/255.0 alpha:1.0];
    expansionSettings.triggerAnimation.easingFunction = MGSwipeEasingFunctionCubicOut;
    expansionSettings.fillOnTrigger = NO;
    
    __weak SpotifyViewController * me = self;
    UIColor * color = [UIColor colorWithRed:47/255.0 green:47/255.0 blue:49/255.0 alpha:1.0];
    UIFont * font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f];
    if (direction == MGSwipeDirectionLeftToRight) {
        MGSwipeButton * queueButton = [MGSwipeButton buttonWithTitle:@"QUEUE" backgroundColor:color padding:15 callback:^BOOL(MGSwipeTableCell *sender) {
            SongData * song = [me songForIndexPath:[me.tableView indexPathForCell:sender]];
            NSLog(@"Queue song: %@", song.title);
            return YES;
        }];
        queueButton.titleLabel.font = font;
        
        return @[queueButton];
    }
    else {
        
        MGSwipeButton * saveButton = [MGSwipeButton buttonWithTitle:@"SAVE" backgroundColor:color padding:15 callback:^BOOL(MGSwipeTableCell *sender) {
            SongData * song = [me songForIndexPath:[me.tableView indexPathForCell:sender]];
            NSLog(@"Save song: %@", song.title);
            return YES; //don't autohide to improve delete animation
        }];
        saveButton.titleLabel.font = font;
        return @[saveButton];
    }
    
    return nil;
    
}

-(void) swipeTableCell:(MGSwipeTableCell*) cell didChangeSwipeState:(MGSwipeState)state gestureIsActive:(BOOL)gestureIsActive
{
    NSString * str;
    switch (state) {
        case MGSwipeStateNone: str = @"None"; break;
        case MGSwipeStateSwippingLeftToRight: str = @"SwippingLeftToRight"; break;
        case MGSwipeStateSwippingRightToLeft: str = @"SwippingRightToLeft"; break;
        case MGSwipeStateExpandingLeftToRight: str = @"ExpandingLeftToRight"; break;
        case MGSwipeStateExpandingRightToLeft: str = @"ExpandingRightToLeft"; break;
    }
    NSLog(@"Swipe state: %@ ::: Gesture: %@", str, gestureIsActive ? @"Active" : @"Ended");
}

@end
