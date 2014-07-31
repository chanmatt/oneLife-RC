//
//  APPContentNewsController.m
//  oneLife
//
//  Created by Matthew Chan on 7/6/14.
//  Copyright (c) 2014 Matthew Chan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APPContentNewsController.h"
#import "APPContentCategoryController.h"

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface APPContentNewsController () {
    SourceDatabase *theSources;
}
@end

@implementation APPContentNewsController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"Content_Catgories"];
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
    return theSources.categories.count;
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

    NSDictionary *thisCategory = [theSources.categories objectAtIndex:indexPath.row];
    
    celllabel.text = [thisCategory objectForKey:@"name"];
    cellicon.image = [UIImage imageNamed:[thisCategory objectForKey:@"icon"]];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.data.chosen_category = [[theSources.categories objectAtIndex:indexPath.row] objectForKey:@"name"];
    [self performSegueWithIdentifier:@"categorySegway" sender:self.data];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"categorySegway"]) {
        //UINavigationController *navigationController = segue.destinationViewController;
        APPContentCategoryController *controller = (APPContentCategoryController *)segue.destinationViewController;
        controller.data = sender;
    }
}

- (IBAction)done
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


@end