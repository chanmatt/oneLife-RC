//
//  APPSettingsViewController.h
//  RSSreader
//
//  Created by Matthew Chan on 7/3/14.
//  Copyright (c) 2014 Matthew Chan. All rights reserved.
//


#import "DataModel.h"

@interface APPSettingsViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) DataModel *data;

- (IBAction)done;
- (IBAction)add;

@end