//
//  APPContentFeaturedController.h
//  oneLife
//
//  Created by Matthew Chan on 7/4/14.
//  Copyright (c) 2014 Matthew Chan. All rights reserved.
//

#import "DataModel.h"

@interface APPContentFeaturedController : UITableViewController

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) DataModel *data;

- (IBAction)button_1_1;
- (IBAction)button_1_2;
- (IBAction)button_2_1;
- (IBAction)button_2_2;
- (IBAction)button_3_1;
- (IBAction)button_3_2;
- (IBAction)button_4_1;
- (IBAction)button_4_2;

- (IBAction)done;

@end