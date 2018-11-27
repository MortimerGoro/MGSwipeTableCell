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
        indicatorColor = UIColor.clear;
        super.init(frame:frame);
    }

    required init?(coder aDecoder: NSCoder) {
        indicatorColor = UIColor.clear;
        super.init(coder: aDecoder);
    }
    
    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext();
        ctx?.addEllipse(in: rect);
        ctx?.setFillColor(indicatorColor.cgColor.components!);
        ctx?.fillPath();
        
        if innerColor != nil {
            let innerSize = rect.size.width * 0.5;
            let innerRect = CGRect(x: rect.origin.x + rect.size.width * 0.5 - innerSize * 0.5,
                y: rect.origin.y + rect.size.height * 0.5 - innerSize * 0.5,
                width: innerSize, height: innerSize);
            ctx?.addEllipse(in: innerRect);
            ctx?.setFillColor(innerColor!.cgColor.components!);
            ctx?.fillPath();
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
        mailFrom = UILabel(frame: CGRect.zero);
        mailMessage = UITextView(frame: CGRect.zero);
        mailSubject = UILabel(frame: CGRect.zero);
        mailTime = UILabel(frame: CGRect.zero);
        
        mailFrom.font = UIFont(name:"HelveticaNeue", size:18.0);
        mailSubject.font = UIFont(name:"HelveticaNeue-Light", size:15.0);
        mailMessage.font = UIFont(name:"HelveticaNeue-Light", size:14.0);
        mailTime.font = UIFont(name:"HelveticaNeue-Light", size:13.0);
        
        mailMessage.isScrollEnabled = false;
        mailMessage.isEditable = false;
        mailMessage.backgroundColor = UIColor.clear;
        mailMessage.contentInset = UIEdgeInsets.init(top: -5, left: -5, bottom: 0, right: 0);
        mailMessage.textColor = UIColor.gray;
        mailMessage.isUserInteractionEnabled = false;
        
        indicatorView = MailIndicatorView(frame: CGRect(x: 0, y: 0, width: 10, height: 10));
        indicatorView.backgroundColor = UIColor.clear;
        
        contentView.addSubview(mailFrom);
        contentView.addSubview(mailMessage);
        contentView.addSubview(mailSubject);
        contentView.addSubview(mailTime);
        contentView.addSubview(indicatorView);
        
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier:String?)
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
        
        mailFrom.frame = CGRect(x: leftPadding, y: topPadding, width: textWidth, height: 20);
        mailSubject.frame = CGRect(x: leftPadding, y: mailFrom.frame.origin.y + mailFrom.frame.size.height + topPadding, width: textWidth - dateWidth, height: 17);
        let messageHeight = contentView.bounds.size.height - (mailSubject.frame.origin.y + mailSubject.frame.size.height) - topPadding * 2;
        mailMessage.frame = CGRect(x: leftPadding, y: mailSubject.frame.origin.y + mailSubject.frame.size.height + topPadding, width: textWidth, height: messageHeight);
        
        var frame = mailFrom.frame;
        frame.origin.x = self.contentView.frame.size.width - leftPadding - dateWidth;
        frame.size.width = dateWidth;
        mailTime.frame = frame;
        
        indicatorView.center = CGPoint(x: leftPadding * 0.5, y: mailFrom.frame.origin.y + mailFrom.frame.size.height * 0.5);
    }
    
}

