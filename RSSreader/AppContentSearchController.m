//
//  AppContentSearchController.m
//  oneLife
//
//  Created by Matthew Chan on 7/9/14.
//  Copyright (c) 2014 Matthew Chan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APPContentSearchController.h"

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"


@interface APPContentSearchController () {
    SourceDatabase *theSources;
    NSMutableArray *searchResults;
    BOOL searched;
}
@end

@implementation APPContentSearchController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"Content_Search"];
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
    searchResults = [[NSMutableArray alloc] init];
    searched = FALSE;
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
    if (searched) {
        return searchResults.count;
    } else {
        return theSources.source_database.count;
    }
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
    if (searched) {
        celllabel.text = [[searchResults objectAtIndex:indexPath.row] objectForKey:@"title"];
        cellicon.image = [UIImage imageNamed:[[searchResults objectAtIndex:indexPath.row] objectForKey:@"icon"]];
        if ([self.data determineExist:[[searchResults objectAtIndex:indexPath.row] objectForKey:@"identifier"]]>=0) {
            cellwhiteout.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:0.7];
            cellselected.text = @"ADDED";
        } else {
            cellwhiteout.backgroundColor = [UIColor clearColor];
            cellselected.text = @"";
        }
    } else {
        celllabel.text = [[theSources.source_database objectAtIndex:indexPath.row] objectForKey:@"title"];
        cellicon.image = [UIImage imageNamed:[[theSources.source_database objectAtIndex:indexPath.row] objectForKey:@"icon"]];
        if ([self.data determineExist:[[theSources.source_database objectAtIndex:indexPath.row] objectForKey:@"identifier"]]>=0) {
            cellwhiteout.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:0.7];
            cellselected.text = @"ADDED";
        } else {
            cellwhiteout.backgroundColor = [UIColor clearColor];
            cellselected.text = @"";
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (searched) {
        NSString *identifier = [[searchResults objectAtIndex:indexPath.row] objectForKey:@"identifier"];
        int objectIndex = [self.data determineExist:identifier];
        if (objectIndex >= 0) {
            NSLog(@"Removed");
            [self.data.source_list removeObjectAtIndex:objectIndex];
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"source_removed"     // Event category (required)
                                                                  action:@"news_removed"  // Event action (required)
                                                                   label:[NSMutableString stringWithFormat:@"%@ [search]",identifier]    // Event label
                                                                   value:nil] build]];    // Event value
        } else {
            NSLog(@"Added");
            [self.data.source_list addObject:[searchResults objectAtIndex:indexPath.row]];
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"source_added"     // Event category (required)
                                                                  action:@"news_added"  // Event action (required)
                                                                   label:[NSMutableString stringWithFormat:@"%@ [search]",identifier]    // Event label
                                                                   value:nil] build]];    // Event value
        }
        self.data.changed = TRUE;
        [self.tableView reloadData];
    } else {
        NSString *identifier = [[theSources.source_database objectAtIndex:indexPath.row] objectForKey:@"identifier"];
        int objectIndex = [self.data determineExist:identifier];
        if (objectIndex >= 0) {
            NSLog(@"Removed");
            [self.data.source_list removeObjectAtIndex:objectIndex];
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"source_removed"     // Event category (required)
                                                                  action:@"news_removed"  // Event action (required)
                                                                   label:[NSMutableString stringWithFormat:@"%@ [search]",identifier]    // Event label
                                                                   value:nil] build]];    // Event value
        } else {
            NSLog(@"Added");
            [self.data.source_list addObject:[theSources.source_database objectAtIndex:indexPath.row]];
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"source_added"     // Event category (required)
                                                                  action:@"news_added"  // Event action (required)
                                                                   label:[NSMutableString stringWithFormat:@"%@ [search]",identifier]    // Event label
                                                                   value:nil] build]];    // Event value
        }
        self.data.changed = TRUE;
        [self.tableView reloadData];
    }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self.sourceSearchBar setShowsCancelButton:YES animated:YES];
    //self.tableView.allowsSelection = NO;
    self.tableView.scrollEnabled = NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text=@"";
    
    [self.sourceSearchBar setShowsCancelButton:NO animated:YES];
    [self.sourceSearchBar resignFirstResponder];
    //self.tableView.allowsSelection = YES;
    self.tableView.scrollEnabled = YES;
    searched = FALSE;
    [self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self searchForResults:self.sourceSearchBar.text];
    searched = TRUE;
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"Searched");
    [self.sourceSearchBar setShowsCancelButton:NO animated:YES];
    [self.sourceSearchBar resignFirstResponder];
    //self.tableView.allowsSelection = YES;
    self.tableView.scrollEnabled = YES;
    [self searchForResults:self.sourceSearchBar.text];
    searched = TRUE;
    [self.tableView reloadData];
}

- (void)searchForResults:(NSString *)searchTerm
{
    searchResults = [[NSMutableArray alloc] init];
    for (int x = 0; x<theSources.source_database.count; x++) {
        NSString *title = [[theSources.source_database objectAtIndex:x] objectForKey:@"title"];
        if ([title rangeOfString:searchTerm options:NSCaseInsensitiveSearch].location != NSNotFound) {
            [searchResults addObject:[theSources.source_database objectAtIndex:x]];
        }
    }
}

- (IBAction)done
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


@end