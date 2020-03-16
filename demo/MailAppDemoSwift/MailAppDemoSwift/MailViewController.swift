//
//  ViewController.swift
//  MailAppDemoSwift
//

import UIKit

class MailData {
    var from: String!;
    var subject: String!;
    var message: String!;
    var date: String!;
    var read = false;
    var flag = false;
}

typealias MailActionCallback = (_ cancelled: Bool, _ deleted: Bool, _ actionIndex: Int) -> Void

class MailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MGSwipeTableCellDelegate, UIActionSheetDelegate {
    
    var tableView: UITableView!;
    var demoData = [MailData]();
    var refreshControl: UIRefreshControl!;
    var actionCallback: MailActionCallback?;
    
    func prepareDemoData() {
        var from = [
        "Vincent",
        "Mr Glass",
        "Marsellus",
        "Ringo",
        "Sullivan",
        "Mr Wolf",
        "Butch Coolidge",
        "Marvin",
        "Captain Koons",
        "Jules",
        "Jimmie Dimmick"
        ];
        
        var subjects = [
       "You think water moves fast?",
       "They called me Mr Glass",
       "The path of the righteous man",
       "Do you see any Teletubbies in here?",
       "Now that we know who you are",
       "My money's in that office, right?",
       "Now we took an oath",
       "That show's called a pilot",
       "I know who I am. I'm not a mistake",
       "It all makes sense!",
       "The selfish and the tyranny of evil men",
        ];
        
        var messages = [
        "You should see ice. It moves like it has a mind. Like it knows it killed the world once and got a taste for murder. After the avalanche, it took us a week to climb out.",
        "And I will strike down upon thee with great vengeance and furious anger those who would attempt to poison and destroy My brothers.",
        "Look, just because I don't be givin' no man a foot massage don't make it right for Marsellus to throw Antwone into a glass motherfuckin' house",
        "No? Well, that's what you see at a toy store. And you must think you're in a toy store, because you're here shopping for an infant named Jeb.",
        "In a comic, you know how you can tell who the arch-villain's going to be? He's the exact opposite of the hero",
        "If she start giving me some bullshit about it ain't there, and we got to go someplace else and get it, I'm gonna shoot you in the head then and there.",
        "that I'm breaking now. We said we'd say it was the snow that killed the other two, but it wasn't. Nature is lethal but it doesn't hold a candle to man.",
        "Then they show that show to the people who make shows, and on the strength of that one show they decide if they're going to make more shows.",
        "And most times they're friends, like you and me! I should've known way back when...",
        "After the avalanche, it took us a week to climb out. Now, I don't know exactly when we turned on each other, but I know that seven of us survived the slide",
        "Blessed is he who, in the name of charity and good will, shepherds the weak through the valley of darkness, for he is truly his brother's keeper and the finder of lost children",
        ];
        
        
        for i in 0 ..< messages.count {
            let mail = MailData();
            mail.from = from[i];
            mail.subject = subjects[i];
            mail.message = messages[i];
            mail.date = String(format: "11:%d", arguments: [43 - i]);
            demoData.append(mail);
        }
    }
    
    func mailForIndexPath(_ path: IndexPath) -> MailData {
        return demoData[(path as NSIndexPath).row];
    }
    @objc
    func refreshCallback() {
        prepareDemoData();
        tableView.reloadData();
        refreshControl.endRefreshing();
    }
    
    func deleteMail(_ path:IndexPath) {
        demoData.remove(at: (path as NSIndexPath).row);
        tableView.deleteRows(at: [path], with: .left);
    }
    
    func updateCellIndicator(_ mail: MailData, cell: MailTableCell) {
        var color: UIColor;
        var innerColor : UIColor?;
        
        if !mail.read && mail.flag {
            color = UIColor.init(red: 1.0, green: 149/255.0, blue: 0.05, alpha: 1.0);
            innerColor = UIColor.init(red: 0.0, green: 122/255.0, blue: 1.0, alpha: 1.0);
        }
        else if mail.flag {
            color = UIColor.init(red: 1.0, green: 149/255.0, blue: 0.05, alpha: 1.0);
        }
        else if mail.read {
            color = UIColor.clear;
        }
        else {
            color = UIColor.init(red: 0.0, green: 122/255.0, blue: 1.0, alpha: 1.0);
        }
        
        cell.indicatorView.indicatorColor = color;
        cell.indicatorView.innerColor = innerColor;
    }
    
    func showMailActions(_ mail: MailData, callback: @escaping MailActionCallback) {
        actionCallback = callback;
        let sheet = UIActionSheet.init(title: "Actions", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: "Trash");
        sheet.addButton(withTitle: "Mark as unread");
        sheet.addButton(withTitle: "Mark as read");
        sheet.addButton(withTitle: "Flag");

        sheet.show(in: self.view);
    }
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt index: Int) {
        if let action = actionCallback {
            action(index == actionSheet.cancelButtonIndex,
                   index == actionSheet.destructiveButtonIndex,
                   index);
            actionCallback = nil;
        }
    }
    
    func readButtonText(_ read:Bool) -> String {
        return read ? "Mark as\nunread" : "Mark as\nread";
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView(frame: view.bounds, style: UITableView.Style.plain);
        tableView.delegate = self;
        tableView.dataSource = self;
        view.addSubview(tableView);
        
        self.title = "MSwipeTableCell MailApp";
        
        refreshControl = UIRefreshControl();
        refreshControl.addTarget(self, action: #selector(refreshCallback), for: UIControl.Event.valueChanged);
        tableView.addSubview(refreshControl);
        prepareDemoData();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return demoData.count;
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "MailCell";
        
        var cell: MailTableCell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? MailTableCell;
        if cell == nil {
            cell = MailTableCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier);
        }
        cell.delegate = self;
        
        let data: MailData = demoData[(indexPath as NSIndexPath).row];
        cell!.mailFrom.text = data.from;
        cell!.mailSubject.text = data.subject;
        cell!.mailMessage.text = data.message;
        cell!.mailTime.text = data.date;
        updateCellIndicator(data, cell: cell);
        return cell;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110;
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell, canSwipe direction: MGSwipeDirection) -> Bool {
        return true;
    }
    
    
    func swipeTableCell(_ cell: MGSwipeTableCell, swipeButtonsFor direction: MGSwipeDirection, swipeSettings: MGSwipeSettings, expansionSettings: MGSwipeExpansionSettings) -> [UIView]? {
        
        swipeSettings.transition = MGSwipeTransition.border;
        expansionSettings.buttonIndex = 0;
        
        
        let mail = mailForIndexPath(tableView.indexPath(for: cell)!);
        
        if direction == MGSwipeDirection.leftToRight {
            expansionSettings.fillOnTrigger = false;
            expansionSettings.threshold = 2;
            let color = UIColor.init(red:0.0, green:122/255.0, blue:1.0, alpha:1.0);
            
            return [
                MGSwipeButton(title: readButtonText(mail.read), backgroundColor: color, callback: { (cell) -> Bool in
                    mail.read = !mail.read;
                    self.updateCellIndicator(mail, cell: cell as! MailTableCell);
                    cell.refreshContentView();
                    (cell.leftButtons[0] as! UIButton).setTitle(self.readButtonText(mail.read), for: UIControl.State());
                    
                    return true;
                })
            ]
        }
        else {
            expansionSettings.fillOnTrigger = true;
            expansionSettings.threshold = 1.1;
            let padding = 15;
            let color1 = UIColor.init(red:1.0, green:59/255.0, blue:50/255.0, alpha:1.0);
            let color2 = UIColor.init(red:1.0, green:149/255.0, blue:0.05, alpha:1.0);
            let color3 = UIColor.init(red:200/255.0, green:200/255.0, blue:205/255.0, alpha:1.0);
            
            let trash = MGSwipeButton(title: "Trash", backgroundColor: color1, padding: padding, callback: { (cell) -> Bool in
                self.deleteMail(self.tableView.indexPath(for: cell)!);
                return false; //don't autohide to improve delete animation
            });
    
            let flag = MGSwipeButton(title: "Flag", backgroundColor: color2, padding: padding, callback: { (cell) -> Bool in
                let mail = self.mailForIndexPath(self.tableView.indexPath(for: cell)!);
                mail.flag = !mail.flag;
                self.updateCellIndicator(mail, cell: cell as! MailTableCell);
                cell.refreshContentView(); //needed to refresh cell contents while swipping
                return true; //autohide
            });
            
            let more = MGSwipeButton(title: "More", backgroundColor: color3, padding: padding, callback: { (cell) -> Bool in
                let path = self.tableView.indexPath(for: cell)!;
                let mail = self.mailForIndexPath(path);
                
                self.showMailActions(mail, callback: { (cancelled, deleted, index) in
                    if cancelled {
                        return;
                    }
                    else if deleted {
                        self.deleteMail(path);
                    }
                    else if index == 1 {
                        mail.read = !mail.read;
                        self.updateCellIndicator(mail, cell: cell as! MailTableCell);
                        cell.refreshContentView();
                        (cell.leftButtons[0] as! UIButton).setTitle(self.readButtonText(mail.read), for: UIControl.State());
                        cell.hideSwipe(animated: true);
                    }
                    else if index == 2 {
                        mail.flag = !mail.flag;
                        self.updateCellIndicator(mail, cell: cell as! MailTableCell);
                        cell.refreshContentView(); //needed to refresh cell contents while swipping
                        cell.hideSwipe(animated: true);
                    }
                    
                });
                
                return false; // Don't autohide
            });
            
            return [trash, flag, more];
        }
        
    }



}

