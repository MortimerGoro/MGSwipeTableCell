/*
 * MGSwipeTableCell is licensed under MIT license. See LICENSE.md file for more information.
 * Copyright (c) 2014 Imanol Fernandez @MortimerGoro
 */

#import <Foundation/Foundation.h>
#import "MGSwipeTableCell.h"


@interface MailIndicatorView : UIView
@property (nonatomic, strong) UIColor * indicatorColor;
@property (nonatomic, strong) UIColor * innerColor;
@end

@interface MailTableCell : MGSwipeTableCell

@property (nonatomic, strong) UILabel * mailFrom;
@property (nonatomic, strong) UILabel * mailSubject;
@property (nonatomic, strong) UITextView * mailMessage;
@property (nonatomic, strong) UILabel * mailTime;
@property (nonatomic, strong) MailIndicatorView * indicatorView;

-(instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
