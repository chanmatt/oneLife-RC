//
//  emailSettings.h
//  oneLife
//
//  Created by Matthew Chan on 7/11/14.
//  Copyright (c) 2014 Matthew Chan. All rights reserved.
//

#import "DataModel.h"
#import <GooglePlus/GooglePlus.h>

@interface emailSettings : UITableViewController <GPPSignInDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *loginlogout;
@property (nonatomic, strong) DataModel *data;

- (IBAction)done;
- (IBAction)login;
- (IBAction)deleteuser;

@end