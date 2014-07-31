//
//  APPShareViewController.h
//  RSSreader
//
//  Created by Matthew Chan on 6/20/14.
//  Copyright (c) 2014 Matthew Chan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>


@interface APPShareViewController : UITableViewController <UITextFieldDelegate, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UITextField *theTextField;

@property (nonatomic, strong) NSMutableDictionary *sharedObject;

- (IBAction)cancel;
- (IBAction)share;

@end