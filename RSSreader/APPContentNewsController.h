//
//  APPContentNewsController.h
//  oneLife
//
//  Created by Matthew Chan on 7/6/14.
//  Copyright (c) 2014 Matthew Chan. All rights reserved.
//

#import "DataModel.h"
#import "SourceDatabase.h"

@interface APPContentNewsController: UITableViewController

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) DataModel *data;

- (IBAction)done;

@end