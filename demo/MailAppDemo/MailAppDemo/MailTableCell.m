/*
 * MGSwipeTableCell is licensed under MIT license. See LICENSE.md file for more information.
 * Copyright (c) 2014 Imanol Fernandez @MortimerGoro
 */

#import "MailTableCell.h"

@implementation MailIndicatorView

-(void) drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(ctx, rect);
    CGContextSetFillColor(ctx, CGColorGetComponents(_indicatorColor.CGColor));
    CGContextFillPath(ctx);
    
    if (_innerColor) {
        CGFloat innerSize = rect.size.width * 0.5;
        CGRect innerRect = CGRectMake(rect.origin.x + rect.size.width * 0.5 - innerSize * 0.5,
                                      rect.origin.y + rect.size.height * 0.5 - innerSize * 0.5,
                                      innerSize, innerSize);
        CGContextAddEllipseInRect(ctx, innerRect);
        CGContextSetFillColor(ctx, CGColorGetComponents(_innerColor.CGColor));
        CGContextFillPath(ctx);
    }
}

-(void) setIndicatorColor:(UIColor *)indicatorColor
{
    _indicatorColor = indicatorColor;
    [self setNeedsDisplay];
}

-(void) setInnerColor:(UIColor *)innerColor
{
    _innerColor = innerColor;
    [self setNeedsDisplay];
}

@end

@implementation MailTableCell

-(instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _mailFrom = [[UILabel alloc] initWithFrame:CGRectZero];
        _mailMessage = [[UITextView alloc] initWithFrame:CGRectZero];
        _mailSubject = [[UILabel alloc] initWithFrame:CGRectZero];
        _mailTime = [[UILabel alloc] initWithFrame:CGRectZero];
        
        _mailFrom.font = [UIFont fontWithName:@"HelveticaNeue" size:18.0f];
        _mailSubject.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f];
        _mailMessage.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f];
        _mailTime.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
        
        _mailMessage.scrollEnabled = NO;
        _mailMessage.editable = NO;
        _mailMessage.backgroundColor = [UIColor clearColor];
        _mailMessage.contentInset = UIEdgeInsetsMake(-5, -5, 0, 0);
        _mailMessage.textColor = [UIColor grayColor];
        _mailMessage.userInteractionEnabled = NO;
        
        _indicatorView = [[MailIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        _indicatorView.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:_mailFrom];
        [self.contentView addSubview:_mailMessage];
        [self.contentView addSubview:_mailSubject];
        [self.contentView addSubview:_mailTime];
        [self.contentView addSubview:_indicatorView];
    }
    return self;
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat leftPadding = 25.0;
    CGFloat topPadding = 3.0;
    CGFloat textWidth = self.contentView.bounds.size.width - leftPadding * 2;
    CGFloat dateWidth = 40;
    
    _mailFrom.frame = CGRectMake(leftPadding, topPadding, textWidth, 20);
    _mailSubject.frame = CGRectMake(leftPadding, _mailFrom.frame.origin.y + _mailFrom.frame.size.height + topPadding, textWidth - dateWidth, 17);
    CGFloat messageHeight = self.contentView.bounds.size.height - (_mailSubject.frame.origin.y + _mailSubject.frame.size.height) - topPadding * 2;
    _mailMessage.frame = CGRectMake(leftPadding, _mailSubject.frame.origin.y + _mailSubject.frame.size.height + topPadding, textWidth, messageHeight);
    
    CGRect frame = _mailFrom.frame;
    frame.origin.x = self.contentView.frame.size.width - leftPadding - dateWidth;
    frame.size.width = dateWidth;
    _mailTime.frame = frame;
    
    _indicatorView.center = CGPointMake(leftPadding * 0.5, _mailFrom.frame.origin.y + _mailFrom.frame.size.height * 0.5);

}

@end
