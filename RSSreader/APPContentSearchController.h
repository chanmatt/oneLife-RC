//
//  APPContentSearchController.h
//  oneLife
//
//  Created by Matthew Chan on 7/9/14.
//  Copyright (c) 2014 Matthew Chan. All rights reserved.
//

#import "DataModel.h"
#import "SourceDatabase.h"

@interface APPContentSearchController: UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UISearchBar *sourceSearchBar;

@property (nonatomic, strong) DataModel *data;

- (IBAction)done;

@end