//
//  MailTableCell.swift
//  MailAppDemoSwift
//

import UIKit

class MailIndicatorView: UIView {
    
    var indicatorColor : UIColor {
        didSet {
            self.setNeedsDisplay();
        }
    }
    var innerColor : UIColor? {
        didSet {
            self.setNeedsDisplay();
        }
    }
    
    override init(frame:CGRect) {
        indicatorColor = UIColor.clearColor();
        super.init(frame:frame);
    }

    required init?(coder aDecoder: NSCoder) {
        indicatorColor = UIColor.clearColor();
        super.init(coder: aDecoder);
    }
    
    override func drawRect(rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext();
        CGContextAddEllipseInRect(ctx, rect);
        CGContextSetFillColor(ctx, CGColorGetComponents(indicatorColor.CGColor));
        CGContextFillPath(ctx);
        
        if innerColor != nil {
            let innerSize = rect.size.width * 0.5;
            let innerRect = CGRectMake(rect.origin.x + rect.size.width * 0.5 - innerSize * 0.5,
                rect.origin.y + rect.size.height * 0.5 - innerSize * 0.5,
                innerSize, innerSize);
            CGContextAddEllipseInRect(ctx, innerRect);
            CGContextSetFillColor(ctx, CGColorGetComponents(innerColor!.CGColor));
            CGContextFillPath(ctx);
        }
    }
}

class MailTableCell: MGSwipeTableCell {
    
    var mailFrom: UILabel!;
    var mailSubject: UILabel!;
    var mailMessage: UITextView!;
    var mailTime: UILabel!;
    var indicatorView: MailIndicatorView!;
    
    func initViews() {
        mailFrom = UILabel(frame: CGRectZero);
        mailMessage = UITextView(frame: CGRectZero);
        mailSubject = UILabel(frame: CGRectZero);
        mailTime = UILabel(frame: CGRectZero);
        
        mailFrom.font = UIFont(name:"HelveticaNeue", size:18.0);
        mailSubject.font = UIFont(name:"HelveticaNeue-Light", size:15.0);
        mailMessage.font = UIFont(name:"HelveticaNeue-Light", size:14.0);
        mailTime.font = UIFont(name:"HelveticaNeue-Light", size:13.0);
        
        mailMessage.scrollEnabled = false;
        mailMessage.editable = false;
        mailMessage.backgroundColor = UIColor.clearColor();
        mailMessage.contentInset = UIEdgeInsetsMake(-5, -5, 0, 0);
        mailMessage.textColor = UIColor.grayColor();
        mailMessage.userInteractionEnabled = false;
        
        indicatorView = MailIndicatorView(frame: CGRectMake(0, 0, 10, 10));
        indicatorView.backgroundColor = UIColor.clearColor();
        
        contentView.addSubview(mailFrom);
        contentView.addSubview(mailMessage);
        contentView.addSubview(mailSubject);
        contentView.addSubview(mailTime);
        contentView.addSubview(indicatorView);
        
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier:String?)
    {
        super.init(style:style, reuseIdentifier: reuseIdentifier);
        initViews();
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        initViews();
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews();
        
        let leftPadding:CGFloat = 25.0;
        let topPadding:CGFloat = 3.0;
        let textWidth = contentView.bounds.size.width - 2.0 * leftPadding;
        let dateWidth:CGFloat = 40;
        
        mailFrom.frame = CGRectMake(leftPadding, topPadding, textWidth, 20);
        mailSubject.frame = CGRectMake(leftPadding, mailFrom.frame.origin.y + mailFrom.frame.size.height + topPadding, textWidth - dateWidth, 17);
        let messageHeight = contentView.bounds.size.height - (mailSubject.frame.origin.y + mailSubject.frame.size.height) - topPadding * 2;
        mailMessage.frame = CGRectMake(leftPadding, mailSubject.frame.origin.y + mailSubject.frame.size.height + topPadding, textWidth, messageHeight);
        
        var frame = mailFrom.frame;
        frame.origin.x = self.contentView.frame.size.width - leftPadding - dateWidth;
        frame.size.width = dateWidth;
        mailTime.frame = frame;
        
        indicatorView.center = CGPointMake(leftPadding * 0.5, mailFrom.frame.origin.y + mailFrom.frame.size.height * 0.5);
    }
    
}

