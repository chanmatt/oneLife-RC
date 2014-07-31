//
//  APPMasterViewController.h
//  RSSreader
//
//  Created by Matthew Chan on 6/9/14.
//  Copyright (c) 2014 Matthew Chan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataModel.h"
#import "HHPanningTableViewCell.h"
#import <AVFoundation/AVSpeechSynthesis.h>
#import <GooglePlus/GooglePlus.h>
#import "RSSParser.h"


@interface APPMasterViewController : UITableViewController <HHPanningTableViewCellDelegate, AVSpeechSynthesizerDelegate, GPPSignInDelegate, RSSParserClassDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *playButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@property (nonatomic, strong) DataModel *dataModel;

@property (nonatomic, strong) NSMutableDictionary *shareObject;


- (IBAction) edit;
- (IBAction) play;

@end
