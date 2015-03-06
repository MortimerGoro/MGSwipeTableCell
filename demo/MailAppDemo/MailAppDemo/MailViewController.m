/*
 * MGSwipeTableCell is licensed under MIT license. See LICENSE.md file for more information.
 * Copyright (c) 2014 Imanol Fernandez @MortimerGoro
 */

#import "MailViewController.h"
#import "MailTableCell.h"
#import "MGSwipeButton.h"


@interface MailData : NSObject
@property (nonatomic, strong) NSString * from;
@property (nonatomic, strong) NSString * subject;
@property (nonatomic, strong) NSString * message;
@property (nonatomic, strong) NSString * date;
@property (nonatomic, assign) BOOL read;
@property (nonatomic, assign) BOOL flag;

@end

@implementation MailData
@end


typedef void(^MailActionCallback)(BOOL cancelled, BOOL deleted, NSInteger actionIndex);

@implementation MailViewController
{
    NSMutableArray * demoData;
    MailActionCallback actionCallback;
    UIRefreshControl * refreshControl;
}


-(void) prepareDemoData
{
    demoData = [NSMutableArray array];
    
    NSArray * from = @[
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
    
    NSArray * subjects = @[
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
    
    NSArray * messages = @[
                           @"You should see ice. It moves like it has a mind. Like it knows it killed the world once and got a taste for murder. After the avalanche, it took us a week to climb out.",
                           @"And I will strike down upon thee with great vengeance and furious anger those who would attempt to poison and destroy My brothers.",
                           @"Look, just because I don't be givin' no man a foot massage don't make it right for Marsellus to throw Antwone into a glass motherfuckin' house",
                           @"No? Well, that's what you see at a toy store. And you must think you're in a toy store, because you're here shopping for an infant named Jeb.",
                           @"In a comic, you know how you can tell who the arch-villain's going to be? He's the exact opposite of the hero",
                           @"If she start giving me some bullshit about it ain't there, and we got to go someplace else and get it, I'm gonna shoot you in the head then and there.",
                           @"that I'm breaking now. We said we'd say it was the snow that killed the other two, but it wasn't. Nature is lethal but it doesn't hold a candle to man.",
                           @"Then they show that show to the people who make shows, and on the strength of that one show they decide if they're going to make more shows.",
                           @"And most times they're friends, like you and me! I should've known way back when...",
                           @"After the avalanche, it took us a week to climb out. Now, I don't know exactly when we turned on each other, but I know that seven of us survived the slide",
                           @"Blessed is he who, in the name of charity and good will, shepherds the weak through the valley of darkness, for he is truly his brother's keeper and the finder of lost children",
                           ];
    
    
    for (int i = 0; i < messages.count; ++i) {
        MailData * mail = [[MailData alloc] init];
        mail.from = [from objectAtIndex:i];
        mail.subject = [subjects objectAtIndex:i];
        mail.message = [messages objectAtIndex:i];
        mail.date = [NSString stringWithFormat:@"11:%d", 43 - i];
        [demoData addObject:mail];
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
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    self.title = @"MSwipeTableCell MailApp";
    
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

-(MailData *) mailForIndexPath:(NSIndexPath*) path
{
    return [demoData objectAtIndex:path.row];
}

-(void) updateCellIndicactor:(MailData *) mail cell:(MailTableCell*) cell
{
    UIColor * color;
    UIColor * innerColor;
    if (!mail.read && mail.flag) {
        color = [UIColor colorWithRed:1.0 green:149/255.0 blue:0.05 alpha:1.0];
        innerColor = [UIColor colorWithRed:0 green:122/255.0 blue:1.0 alpha:1.0];
    }
    else if (mail.flag) {
        color = [UIColor colorWithRed:1.0 green:149/255.0 blue:0.05 alpha:1.0];
    }
    else if (mail.read) {
        color = [UIColor clearColor];
    }
    else {
        color = [UIColor colorWithRed:0 green:122/255.0 blue:1.0 alpha:1.0];
    }
    
    cell.indicatorView.indicatorColor = color;
    cell.indicatorView.innerColor = innerColor;
}

-(void) showMailActions:(MailData *) mail callback:(MailActionCallback) callback
{
    actionCallback = callback;
    UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:@"Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Trash" otherButtonTitles:mail.read ? @"Mark as unread": @"Mark as read", @"Flag", nil];
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    actionCallback(buttonIndex == actionSheet.cancelButtonIndex, buttonIndex == actionSheet.destructiveButtonIndex, buttonIndex);
    actionCallback = nil;
}

-(NSString *) readButtonText:(BOOL) read
{
    return read ? @"Mark as\nunread" :@"Mark as\nread";
}


#pragma mark Table Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return demoData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier = @"MailCell";
    MailTableCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[MailTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.delegate = self;
    
    MailData * data = [demoData objectAtIndex:indexPath.row];
    cell.mailFrom.text = data.from;
    cell.mailSubject.text = data.subject;
    cell.mailMessage.text = data.message;
    cell.mailTime.text = data.date;
    [self updateCellIndicactor:data cell:cell];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110;
}

#pragma mark Swipe Delegate

-(BOOL) swipeTableCell:(MGSwipeTableCell*) cell canSwipe:(MGSwipeDirection) direction;
{
    return YES;
}

-(NSArray*) swipeTableCell:(MGSwipeTableCell*) cell swipeButtonsForDirection:(MGSwipeDirection)direction
             swipeSettings:(MGSwipeSettings*) swipeSettings expansionSettings:(MGSwipeExpansionSettings*) expansionSettings
{
    
    swipeSettings.transition = MGSwipeTransitionBorder;
    expansionSettings.buttonIndex = 0;
    
    __weak MailViewController * me = self;
    MailData * mail = [me mailForIndexPath:[self.tableView indexPathForCell:cell]];
    
    if (direction == MGSwipeDirectionLeftToRight) {
        
        expansionSettings.fillOnTrigger = NO;
        expansionSettings.threshold = 2;
        return @[[MGSwipeButton buttonWithTitle:[me readButtonText:mail.read] backgroundColor:[UIColor colorWithRed:0 green:122/255.0 blue:1.0 alpha:1.0] padding:5 callback:^BOOL(MGSwipeTableCell *sender) {
            
            MailData * mail = [me mailForIndexPath:[me.tableView indexPathForCell:sender]];
            mail.read = !mail.read;
            [me updateCellIndicactor:mail cell:(MailTableCell*)sender];
            [cell refreshContentView]; //needed to refresh cell contents while swipping
            
            //change button text
            [(UIButton*)[cell.leftButtons objectAtIndex:0] setTitle:[me readButtonText:mail.read] forState:UIControlStateNormal];
            
            return YES;
        }]];
    }
    else {
        
        expansionSettings.fillOnTrigger = YES;
        expansionSettings.threshold = 1.1;

        CGFloat padding = 15;
        
        MGSwipeButton * trash = [MGSwipeButton buttonWithTitle:@"Trash" backgroundColor:[UIColor colorWithRed:1.0 green:59/255.0 blue:50/255.0 alpha:1.0] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            
            NSIndexPath * indexPath = [me.tableView indexPathForCell:sender];
            [me deleteMail:indexPath];
            return NO; //don't autohide to improve delete animation
        }];
        MGSwipeButton * flag = [MGSwipeButton buttonWithTitle:@"Flag" backgroundColor:[UIColor colorWithRed:1.0 green:149/255.0 blue:0.05 alpha:1.0] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            
            MailData * mail = [me mailForIndexPath:[me.tableView indexPathForCell:sender]];
            mail.flag = !mail.flag;
            [me updateCellIndicactor:mail cell:(MailTableCell*)sender];
            [cell refreshContentView]; //needed to refresh cell contents while swipping
            return YES;
        }];
        MGSwipeButton * more = [MGSwipeButton buttonWithTitle:@"More" backgroundColor:[UIColor colorWithRed:200/255.0 green:200/255.0 blue:205/255.0 alpha:1.0] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            
            NSIndexPath * indexPath = [me.tableView indexPathForCell:sender];
            MailData * mail = [me mailForIndexPath:indexPath];
            MailTableCell * cell = (MailTableCell*) sender;
            [me showMailActions:mail callback:^(BOOL cancelled, BOOL deleted, NSInteger actionIndex) {
                if (cancelled) {
                    return;
                }
                if (deleted) {
                    [me deleteMail:indexPath];
                }
                else if (actionIndex == 1) {
                    mail.read = !mail.read;
                    [(UIButton*)[cell.leftButtons objectAtIndex:0] setTitle:[me readButtonText:mail.read] forState:UIControlStateNormal];
                    [me updateCellIndicactor:mail cell:cell];
                    [cell refreshContentView]; //needed to refresh cell contents while swipping
                }
                else if (actionIndex == 2) {
                    mail.flag = !mail.flag;
                    [me updateCellIndicactor:mail cell:cell];
                    [cell refreshContentView]; //needed to refresh cell contents while swipping
                }
                
                [cell hideSwipeAnimated:YES];
                
            }];
            
            return NO; //avoid autohide swipe
        }];
        
        return @[trash, flag, more];
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
