/*
 * MGSwipeTableCell is licensed under MIT license. See LICENSE.md file for more information.
 * Copyright (c) 2014 Imanol Fernandez @MortimerGoro
 */

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"

@interface DemoViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, MGSwipeTableCellDelegate, UIActionSheetDelegate>

@property (nonatomic, assign) BOOL testingStoryboardCell;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
