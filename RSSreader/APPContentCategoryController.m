//
//  APPContentCategoryController.m
//  oneLife
//
//  Created by Matthew Chan on 7/9/14.
//  Copyright (c) 2014 Matthew Chan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APPContentCategoryController.h"

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface APPContentCategoryController () {
    SourceDatabase *theSources;
    NSMutableArray *source_list_by_category;
}
@end

@implementation APPContentCategoryController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"Content_Category"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    if (self.data.changed) {
        [self.tableView reloadData];
    }
    
    //self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    theSources = [[SourceDatabase alloc] init];
    source_list_by_category = [[NSMutableArray alloc] init];
    
    for (int x = 0; x<theSources.source_database.count; x++) {
        if ([[[theSources.source_database objectAtIndex:x] objectForKey:@"category"] isEqualToString:self.data.chosen_category]) {
            [source_list_by_category addObject:[theSources.source_database objectAtIndex:x]];
        }
    }
    //[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return source_list_by_category.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    UILabel *celllabel = (UILabel *)[cell viewWithTag:1];
    UIImageView *cellicon = (UIImageView *)[cell viewWithTag:2];
    UILabel *cellwhiteout = (UILabel *)[cell viewWithTag:3];
    UILabel *cellselected = (UILabel *)[cell viewWithTag:4];
    
    celllabel.text = [[source_list_by_category objectAtIndex:indexPath.row] objectForKey:@"title"];
    cellicon.image = [UIImage imageNamed:[[source_list_by_category objectAtIndex:indexPath.row] objectForKey:@"icon"]];
    if ([self.data determineExist:[[source_list_by_category objectAtIndex:indexPath.row] objectForKey:@"identifier"]]>=0) {
        cellwhiteout.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:0.7];
        cellselected.text = @"ADDED";
    } else {
        cellwhiteout.backgroundColor = [UIColor clearColor];
        cellselected.text = @"";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = [[source_list_by_category objectAtIndex:indexPath.row] objectForKey:@"identifier"];
    int objectIndex = [self.data determineExist:identifier];
    if (objectIndex >= 0) {
        NSLog(@"Removed");
        [self.data.source_list removeObjectAtIndex:objectIndex];
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"source_removed"     // Event category (required)
                                                              action:@"news_removed"  // Event action (required)
                                                               label:[NSMutableString stringWithFormat:@"%@ [categories]",identifier]    // Event label
                                                               value:nil] build]];    // Event value
    } else {
        NSLog(@"Added");
        [self.data.source_list addObject:[source_list_by_category objectAtIndex:indexPath.row]];
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"source_added"     // Event category (required)
                                                              action:@"news_added"  // Event action (required)
                                                               label:[NSMutableString stringWithFormat:@"%@ [categories]",identifier]    // Event label
                                                               value:nil] build]];    // Event value
    }
    self.data.changed = TRUE;
    [self.tableView reloadData];
}

@end