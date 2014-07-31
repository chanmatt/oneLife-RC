//
//  APPSettingsViewController.m
//  RSSreader
//
//  Created by Matthew Chan on 7/3/14.
//  Copyright (c) 2014 Matthew Chan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APPSettingsViewController.h"
#import "APPContentFeaturedController.h"
#import "APPContentLifeController.h"
#import "APPContentNewsController.h"
#import "APPContentSearchController.h"
#import "APPTabBarController.h"
#import "emailSettings.h"

#import <EventKit/EKEvent.h>
#import <EventKit/EKEventStore.h>

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface APPSettingsViewController () {
    NSMutableArray *currentchoices;
    int amountchoices;
    int amountsources;
}
@end

@implementation APPSettingsViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"Settings Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    if (self.data.emailchanged) {
        self.data.emailchanged = FALSE;
    }
    if (self.data.changed == TRUE) {
    [self updateData];
}
    
    //self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    [self updateData];
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
    return amountchoices+amountsources+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row<(amountchoices+amountsources)) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        UILabel *celllabel = (UILabel *)[cell viewWithTag:1];
        UIImageView *cellicon = (UIImageView *)[cell viewWithTag:2];
        celllabel.text = [[currentchoices objectAtIndex:indexPath.row] objectForKey:@"title"];
        cellicon.image = [UIImage imageNamed:[[currentchoices objectAtIndex:indexPath.row] objectForKey:@"icon"]];
        if ([[[currentchoices objectAtIndex:indexPath.row] objectForKey:@"more"] boolValue]) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"lastCell" forIndexPath:indexPath];
        return cell;
    }
}

// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    if (indexPath.row<(amountchoices+amountsources)) {
        return TRUE;
    }
    return FALSE;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Detemine if it's in editing mode
    if (indexPath.row<(amountchoices+amountsources)) {
        NSLog(@"Delete style for: %d",indexPath.row);
        return UITableViewCellEditingStyleDelete;
    } else {
        NSLog(@"Regular style: %d",indexPath.row);
        return UITableViewCellEditingStyleNone;
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (indexPath.row<amountchoices) {
            NSString *deleted_id = [[currentchoices objectAtIndex:indexPath.row] objectForKey:@"id"];
            [self.data.choices setObject:[NSNumber numberWithBool:FALSE] forKey:deleted_id];
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"source_removed"     // Event category (required)
                                                                  action:[NSMutableString stringWithFormat:@"%@_removed",deleted_id]  // Event action (required)
                                                                   label:@"[settings]"    // Event label
                                                                   value:nil] build]];    // Event value
        } else {
            NSString *deleted_id = [[self.data.source_list objectAtIndex:(indexPath.row-amountchoices)] objectForKey:@"identifier"];
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"source_removed"     // Event category (required)
                                                                  action:@"news_removed"  // Event action (required)
                                                                   label:[NSMutableString stringWithFormat:@"%@ [settings]",deleted_id]    // Event label
                                                                   value:nil] build]];    // Event value
            [self.data.source_list removeObjectAtIndex:(indexPath.row-amountchoices)];
        }
        self.data.changed = TRUE;
        [self updateData];
    }
}

- (void)updateData {
    amountchoices = 0;
    amountsources = 0;
    currentchoices = [[NSMutableArray alloc] init];
    if ([[self.data.choices valueForKey:@"time"] boolValue]) {
        [currentchoices addObject:[[NSMutableDictionary alloc] init]];
        [[currentchoices objectAtIndex:amountchoices] setObject:@"time" forKey:@"id"];
        [[currentchoices objectAtIndex:amountchoices] setObject:@"Time" forKey:@"title"];
        [[currentchoices objectAtIndex:amountchoices] setObject:@"Time.png" forKey:@"icon"];
        [[currentchoices objectAtIndex:amountchoices] setObject:[NSNumber numberWithBool:FALSE] forKey:@"more"];
        amountchoices++;
    }
    if ([[self.data.choices valueForKey:@"help"] boolValue]) {
        [currentchoices addObject:[[NSMutableDictionary alloc] init]];
        [[currentchoices objectAtIndex:amountchoices] setObject:@"help" forKey:@"id"];
        [[currentchoices objectAtIndex:amountchoices] setObject:@"Getting Started" forKey:@"title"];
        [[currentchoices objectAtIndex:amountchoices] setObject:@"Productivity.png" forKey:@"icon"];
        [[currentchoices objectAtIndex:amountchoices] setObject:[NSNumber numberWithBool:FALSE] forKey:@"more"];
        amountchoices++;
    }
    if ([[self.data.choices valueForKey:@"calendar"] boolValue]) {
        [currentchoices addObject:[[NSMutableDictionary alloc] init]];
        [[currentchoices objectAtIndex:amountchoices] setObject:@"calendar" forKey:@"id"];
        [[currentchoices objectAtIndex:amountchoices] setObject:@"Calendar" forKey:@"title"];
        [[currentchoices objectAtIndex:amountchoices] setObject:@"Calendar_Icon.png" forKey:@"icon"];
        [[currentchoices objectAtIndex:amountchoices] setObject:[NSNumber numberWithBool:FALSE] forKey:@"more"];
        amountchoices++;
    }
    if ([[self.data.choices valueForKey:@"reminders"] boolValue]) {
        [currentchoices addObject:[[NSMutableDictionary alloc] init]];
        [[currentchoices objectAtIndex:amountchoices] setObject:@"reminders" forKey:@"id"];
        [[currentchoices objectAtIndex:amountchoices] setObject:@"Reminders" forKey:@"title"];
        [[currentchoices objectAtIndex:amountchoices] setObject:@"Reminders.png" forKey:@"icon"];
        [[currentchoices objectAtIndex:amountchoices] setObject:[NSNumber numberWithBool:FALSE] forKey:@"more"];
        amountchoices++;
    }
    if ([[self.data.choices valueForKey:@"weather"] boolValue]) {
        [currentchoices addObject:[[NSMutableDictionary alloc] init]];
        [[currentchoices objectAtIndex:amountchoices] setObject:@"weather" forKey:@"id"];
        [[currentchoices objectAtIndex:amountchoices] setObject:@"Weather" forKey:@"title"];
        [[currentchoices objectAtIndex:amountchoices] setObject:@"Weather.png" forKey:@"icon"];
        [[currentchoices objectAtIndex:amountchoices] setObject:[NSNumber numberWithBool:FALSE] forKey:@"more"];
        amountchoices++;
    }
    if ([[self.data.choices valueForKey:@"photos"] boolValue]) {
        [currentchoices addObject:[[NSMutableDictionary alloc] init]];
        [[currentchoices objectAtIndex:amountchoices] setObject:@"photos" forKey:@"id"];
        [[currentchoices objectAtIndex:amountchoices] setObject:@"Photos" forKey:@"title"];
        [[currentchoices objectAtIndex:amountchoices] setObject:@"Photos.png" forKey:@"icon"];
        [[currentchoices objectAtIndex:amountchoices] setObject:[NSNumber numberWithBool:FALSE] forKey:@"more"];
        amountchoices++;
    }
    if ([[self.data.choices valueForKey:@"mail"] boolValue]) {
        [currentchoices addObject:[[NSMutableDictionary alloc] init]];
        [[currentchoices objectAtIndex:amountchoices] setObject:@"mail" forKey:@"id"];
        [[currentchoices objectAtIndex:amountchoices] setObject:@"Mail" forKey:@"title"];
        [[currentchoices objectAtIndex:amountchoices] setObject:@"Mail.png" forKey:@"icon"];
        [[currentchoices objectAtIndex:amountchoices] setObject:[NSNumber numberWithBool:TRUE] forKey:@"more"];
        amountchoices++;
    }
    if ([[self.data.choices valueForKey:@"facebook"] boolValue]) {
        [currentchoices addObject:[[NSMutableDictionary alloc] init]];
        [[currentchoices objectAtIndex:amountchoices] setObject:@"facebook" forKey:@"id"];
        [[currentchoices objectAtIndex:amountchoices] setObject:@"Facebook" forKey:@"title"];
        [[currentchoices objectAtIndex:amountchoices] setObject:@"Facebook.png" forKey:@"icon"];
        [[currentchoices objectAtIndex:amountchoices] setObject:[NSNumber numberWithBool:FALSE] forKey:@"more"];
        amountchoices++;
    }
    if ([[self.data.choices valueForKey:@"twitter"] boolValue]) {
        [currentchoices addObject:[[NSMutableDictionary alloc] init]];
        [[currentchoices objectAtIndex:amountchoices] setObject:@"twitter" forKey:@"id"];
        [[currentchoices objectAtIndex:amountchoices] setObject:@"Twitter" forKey:@"title"];
        [[currentchoices objectAtIndex:amountchoices] setObject:@"Twitter.png" forKey:@"icon"];
        [[currentchoices objectAtIndex:amountchoices] setObject:[NSNumber numberWithBool:FALSE] forKey:@"more"];
        amountchoices++;
    }
    if (self.data.source_list.count>0) {
        for (int x = 0; x<self.data.source_list.count; x++) {
            NSLog(@"Added object");
            [currentchoices addObject:[[NSMutableDictionary alloc] init]];
            [[currentchoices objectAtIndex:(amountchoices+amountsources)] setObject:[NSNumber numberWithInt:amountsources] forKey:@"sourceindex"];
            [[currentchoices objectAtIndex:(amountchoices+amountsources)] setObject:[[self.data.source_list objectAtIndex:amountsources] objectForKey:@"identifier"] forKey:@"id"];
            [[currentchoices objectAtIndex:(amountchoices+amountsources)] setObject:[[self.data.source_list objectAtIndex:amountsources] objectForKey:@"title"] forKey:@"title"];
            [[currentchoices objectAtIndex:(amountchoices+amountsources)] setObject:[[self.data.source_list objectAtIndex:amountsources] objectForKey:@"icon"] forKey:@"icon"];
            [[currentchoices objectAtIndex:(amountchoices+amountsources)] setObject:[NSNumber numberWithBool:FALSE] forKey:@"more"];
            amountsources++;
        }
    }
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[[currentchoices objectAtIndex:indexPath.row] objectForKey:@"id"] isEqualToString:@"mail"]) {
        [self performSegueWithIdentifier:@"emailSettings" sender:self.data];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"addSegway"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        APPTabBarController *controller = (APPTabBarController *)navigationController;
        APPContentFeaturedController *anotherController = (APPContentFeaturedController *)[[controller.viewControllers objectAtIndex:0] topViewController];
        APPContentLifeController *oneOtherController = (APPContentLifeController *)[[controller.viewControllers objectAtIndex:1] topViewController];
        APPContentNewsController *twoOtherController = (APPContentNewsController *)[[controller.viewControllers objectAtIndex:2] topViewController];
        APPContentSearchController *threeOtherController = (APPContentSearchController *)[[controller.viewControllers objectAtIndex:3] topViewController];
        controller.data = sender;
        anotherController.data = sender;
        oneOtherController.data = sender;
        twoOtherController.data = sender;
        threeOtherController.data = sender;
    }
    if ([segue.identifier isEqualToString:@"emailSettings"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        emailSettings *controller = (emailSettings *)navigationController.topViewController;
        controller.data = sender;
    }
}

- (IBAction)done
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)add
{
    [self performSegueWithIdentifier:@"addSegway" sender:self.data];
}


@end