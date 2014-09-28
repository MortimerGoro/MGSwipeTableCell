/*
 * MGSwipeTableCell is licensed under MIT license. See LICENSE.md file for more information.
 * Copyright (c) 2014 Imanol Fernandez @MortimerGoro
 */

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"

@interface MailViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, MGSwipeTableCellDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) UITableView * tableView;

@end

