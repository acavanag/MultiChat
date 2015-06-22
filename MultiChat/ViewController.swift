//
//  ViewController.swift
//  MultiChat
//
//  Created by Andrew Cavanagh on 6/21/15.
//  Copyright (c) 2015 WeddingWire. All rights reserved.
//

import UIKit

private let mc_chatCell = "mcChatCellIdentifier"

class ViewController: UIViewController, MessageResponderDelegate, UITableViewDataSource {

    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var session: SessionManager?
    var messageCollection = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        session = SessionManager(displayName: "Andrew", delegate: self)
        tableView.dataSource = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        registerForKeyboardNotifications()
    }

    // MARK: - Message Handling
    
    @IBAction func sendMessagePressed(sender: AnyObject) {
        if inputTextField.text != nil && count(inputTextField.text) > 0 {
            session?.writeMessage(inputTextField.text)
            inputTextField.text = ""
        }
    }

    func didReceiveMessage(message: Message) {
        insertMessage(message)
    }
    
    func insertMessage(message: Message) {
        messageCollection.append(message)
        let insertionIndexPath = NSIndexPath(forRow: messageCollection.count - 1, inSection: 0)
        tableView.insertRowsAtIndexPaths([insertionIndexPath], withRowAnimation: .Fade)
        tableView.scrollToRowAtIndexPath(insertionIndexPath, atScrollPosition: .Bottom, animated: false)
    }
    
    // MARK: - UITableView DataSource

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageCollection.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(mc_chatCell, forIndexPath: indexPath) as! MessageTableViewCell
        configureCell(cell, indexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: MessageTableViewCell, indexPath: NSIndexPath) {
        let message = messageCollection[indexPath.row]
        cell.senderLabel.text = message.peer?.displayName
        cell.messageLabel.text = message.message
    }
    
    // MARK: - Keyboard Handling
    
    func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillChangeFrame:", name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardWillChangeFrame(aNotification: NSNotification) {
        let info = aNotification.userInfo!
        
        var frameEnd = info[UIKeyboardFrameEndUserInfoKey]!.CGRectValue()
        var convertedFrameEnd = self.view.convertRect(frameEnd, fromView: nil)
        let heightOffset = self.view.bounds.size.height - convertedFrameEnd.origin.y
        
        var animationDurationValue = info[UIKeyboardAnimationDurationUserInfoKey] as! NSValue
        var duration: NSTimeInterval = 0
        animationDurationValue.getValue(&duration)
        
        self.bottomConstraint.constant = heightOffset
        UIView.animateWithDuration(duration, animations: { () -> Void in
            self.messageView.layoutIfNeeded()
        })
    }
    
}
    


