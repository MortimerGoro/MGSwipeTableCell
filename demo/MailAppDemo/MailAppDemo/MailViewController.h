//
//  ViewController.h
//  MailAppDemo
//
//  Created by Imanol Fernandez Gorostizaga on 26/09/14.
//  Copyright (c) 2014 Mortimer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"

@interface MailViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, MGSwipeTableCellDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) UITableView * tableView;

@end

