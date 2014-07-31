//
//  APPContentLifeController.m
//  oneLife
//
//  Created by Matthew Chan on 7/6/14.
//  Copyright (c) 2014 Matthew Chan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EKEvent.h>
#import <EventKit/EKEventStore.h>
#import <EventKit/EKReminder.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "APPContentLifeController.h"
#import <Accounts/Accounts.h>
#import <Accounts/ACAccountStore.h>
#import <Social/Social.h>

#import "emailSettings.h"

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"


@interface APPContentLifeController () {
    NSMutableArray *lifechoices;
    int amountchoices;
}
@end

@implementation APPContentLifeController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"Content_Life"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    if (self.data.changed) {
        [self updateContent];
    }
    if (self.data.emailchanged) {
        self.data.emailchanged = FALSE;
        [self.data.choices setObject:[NSNumber numberWithBool:FALSE] forKey:@"mail"];
        [self updateContent];
    }
    
    //self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    [self updateContent];
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
    return amountchoices;
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
    
    celllabel.text = [[lifechoices objectAtIndex:indexPath.row] objectForKey:@"title"];
    cellicon.image = [UIImage imageNamed:[[lifechoices objectAtIndex:indexPath.row] objectForKey:@"icon"]];
    if ([[[lifechoices objectAtIndex:indexPath.row] objectForKey:@"selected"] boolValue]) {
        cellwhiteout.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:0.7];
        cellselected.text = @"ADDED";
    } else {
        cellwhiteout.backgroundColor = [UIColor clearColor];
        cellselected.text = @"";
    }
    return cell;
}

- (void)updateContent
{
    amountchoices = 0;
    lifechoices = [[NSMutableArray alloc] init];
    
    [lifechoices addObject:[[NSMutableDictionary alloc] init]];
    [[lifechoices objectAtIndex:amountchoices] setObject:@"time" forKey:@"id"];
    [[lifechoices objectAtIndex:amountchoices] setObject:@"Time" forKey:@"title"];
    [[lifechoices objectAtIndex:amountchoices] setObject:@"Time.png" forKey:@"icon"];
    [[lifechoices objectAtIndex:amountchoices] setObject:[NSNumber numberWithBool:FALSE] forKey:@"more"];
    if ([[self.data.choices objectForKey:@"time"] boolValue]) {
        [[lifechoices objectAtIndex:amountchoices] setObject:[NSNumber numberWithBool:TRUE] forKey:@"selected"];
    } else {
        [[lifechoices objectAtIndex:amountchoices] setObject:[NSNumber numberWithBool:FALSE] forKey:@"selected"];
    }
    amountchoices++;
    
    [lifechoices addObject:[[NSMutableDictionary alloc] init]];
    [[lifechoices objectAtIndex:amountchoices] setObject:@"calendar" forKey:@"id"];
    [[lifechoices objectAtIndex:amountchoices] setObject:@"Calendar" forKey:@"title"];
    [[lifechoices objectAtIndex:amountchoices] setObject:@"Calendar_Icon.png" forKey:@"icon"];
    [[lifechoices objectAtIndex:amountchoices] setObject:[NSNumber numberWithBool:TRUE] forKey:@"more"];
    if ([[self.data.choices objectForKey:@"calendar"] boolValue]) {
        [[lifechoices objectAtIndex:amountchoices] setObject:[NSNumber numberWithBool:TRUE] forKey:@"selected"];
    } else {
        [[lifechoices objectAtIndex:amountchoices] setObject:[NSNumber numberWithBool:FALSE] forKey:@"selected"];
    }
    amountchoices++;

    [lifechoices addObject:[[NSMutableDictionary alloc] init]];
    [[lifechoices objectAtIndex:amountchoices] setObject:@"reminders" forKey:@"id"];
    [[lifechoices objectAtIndex:amountchoices] setObject:@"Reminders" forKey:@"title"];
    [[lifechoices objectAtIndex:amountchoices] setObject:@"Reminders.png" forKey:@"icon"];
    [[lifechoices objectAtIndex:amountchoices] setObject:[NSNumber numberWithBool:FALSE] forKey:@"more"];
    if ([[self.data.choices objectForKey:@"reminders"] boolValue]) {
        [[lifechoices objectAtIndex:amountchoices] setObject:[NSNumber numberWithBool:TRUE] forKey:@"selected"];
    } else {
        [[lifechoices objectAtIndex:amountchoices] setObject:[NSNumber numberWithBool:FALSE] forKey:@"selected"];
    }
    amountchoices++;

    [lifechoices addObject:[[NSMutableDictionary alloc] init]];
    [[lifechoices objectAtIndex:amountchoices] setObject:@"weather" forKey:@"id"];
    [[lifechoices objectAtIndex:amountchoices] setObject:@"Weather" forKey:@"title"];
    [[lifechoices objectAtIndex:amountchoices] setObject:@"Weather.png" forKey:@"icon"];
    [[lifechoices objectAtIndex:amountchoices] setObject:[NSNumber numberWithBool:FALSE] forKey:@"more"];
    if ([[self.data.choices objectForKey:@"weather"] boolValue]) {
        [[lifechoices objectAtIndex:amountchoices] setObject:[NSNumber numberWithBool:TRUE] forKey:@"selected"];
    } else {
        [[lifechoices objectAtIndex:amountchoices] setObject:[NSNumber numberWithBool:FALSE] forKey:@"selected"];
        
    }
    amountchoices++;

    [lifechoices addObject:[[NSMutableDictionary alloc] init]];
    [[lifechoices objectAtIndex:amountchoices] setObject:@"photos" forKey:@"id"];
    [[lifechoices objectAtIndex:amountchoices] setObject:@"Photos" forKey:@"title"];
    [[lifechoices objectAtIndex:amountchoices] setObject:@"Photos.png" forKey:@"icon"];
    [[lifechoices objectAtIndex:amountchoices] setObject:[NSNumber numberWithBool:TRUE] forKey:@"more"];
    if ([[self.data.choices objectForKey:@"photos"] boolValue]) {
        [[lifechoices objectAtIndex:amountchoices] setObject:[NSNumber numberWithBool:TRUE] forKey:@"selected"];
    } else {
        [[lifechoices objectAtIndex:amountchoices] setObject:[NSNumber numberWithBool:FALSE] forKey:@"selected"];
    }
    amountchoices++;

    [lifechoices addObject:[[NSMutableDictionary alloc] init]];
    [[lifechoices objectAtIndex:amountchoices] setObject:@"mail" forKey:@"id"];
    [[lifechoices objectAtIndex:amountchoices] setObject:@"Mail" forKey:@"title"];
    [[lifechoices objectAtIndex:amountchoices] setObject:@"Mail.png" forKey:@"icon"];
    [[lifechoices objectAtIndex:amountchoices] setObject:[NSNumber numberWithBool:TRUE] forKey:@"more"];
    if ([[self.data.choices objectForKey:@"mail"] boolValue]) {
        [[lifechoices objectAtIndex:amountchoices] setObject:[NSNumber numberWithBool:TRUE] forKey:@"selected"];
    } else {
        [[lifechoices objectAtIndex:amountchoices] setObject:[NSNumber numberWithBool:FALSE] forKey:@"selected"];
        
    }
    amountchoices++;

    /*[lifechoices addObject:[[NSMutableDictionary alloc] init]];
    [[lifechoices objectAtIndex:amountchoices] setObject:@"facebook" forKey:@"id"];
    [[lifechoices objectAtIndex:amountchoices] setObject:@"Facebook" forKey:@"title"];
    [[lifechoices objectAtIndex:amountchoices] setObject:@"Facebook.png" forKey:@"icon"];
    [[lifechoices objectAtIndex:amountchoices] setObject:[NSNumber numberWithBool:TRUE] forKey:@"more"];
    if ([[self.data.choices objectForKey:@"facebook"] boolValue]) {
        [[lifechoices objectAtIndex:amountchoices] setObject:[NSNumber numberWithBool:TRUE] forKey:@"selected"];
    } else {
        [[lifechoices objectAtIndex:amountchoices] setObject:[NSNumber numberWithBool:FALSE] forKey:@"selected"];
    }
    amountchoices++;*/

    [lifechoices addObject:[[NSMutableDictionary alloc] init]];
    [[lifechoices objectAtIndex:amountchoices] setObject:@"twitter" forKey:@"id"];
    [[lifechoices objectAtIndex:amountchoices] setObject:@"Twitter" forKey:@"title"];
    [[lifechoices objectAtIndex:amountchoices] setObject:@"Twitter.png" forKey:@"icon"];
    [[lifechoices objectAtIndex:amountchoices] setObject:[NSNumber numberWithBool:TRUE] forKey:@"more"];
    if ([[self.data.choices objectForKey:@"twitter"] boolValue]) {
        [[lifechoices objectAtIndex:amountchoices] setObject:[NSNumber numberWithBool:TRUE] forKey:@"selected"];
    } else {
        [[lifechoices objectAtIndex:amountchoices] setObject:[NSNumber numberWithBool:FALSE] forKey:@"selected"];
    }
    amountchoices++;

    NSLog(@"Content updated");
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = [[lifechoices objectAtIndex:indexPath.row] objectForKey:@"id"];
    if ([identifier isEqualToString:@"calendar"]) {
        EKEventStore *store = [[EKEventStore alloc] init];
        [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"granted");
                    if ([[[lifechoices objectAtIndex:indexPath.row] objectForKey:@"selected"] boolValue]) {
                        [self.data.choices setObject:[NSNumber numberWithBool:FALSE] forKey:identifier];
                        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"source_removed"     // Event category (required)
                                                                              action:@"calendar_removed"  // Event action (required)
                                                                               label:@"[life]"          // Event label
                                                                               value:nil] build]];    // Event value
                    } else {
                        [self.data.choices setObject:[NSNumber numberWithBool:TRUE] forKey:identifier];
                        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"source_added"     // Event category (required)
                                                                              action:@"calendar_added"  // Event action (required)
                                                                               label:@"[life]"          // Event label
                                                                               value:nil] build]];    // Event value
                    }
                    self.data.changed = TRUE;
                    [self updateContent];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"not granted");
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Calendar Permissions"
                                                                message:@"You must grant permission under settings->privacy in order to add this content."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                    [alert show];
                    [self.data.choices setObject:[NSNumber numberWithBool:FALSE] forKey:identifier];
                    self.data.changed = TRUE;
                    [self updateContent];
                });
            }
            
            
            
        }];
    } else if ([identifier isEqualToString:@"reminders"]) {
        EKEventStore *store = [[EKEventStore alloc] init];
        [store requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
            // handle access here
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"granted");
                    if ([[[lifechoices objectAtIndex:indexPath.row] objectForKey:@"selected"] boolValue]) {
                        [self.data.choices setObject:[NSNumber numberWithBool:FALSE] forKey:identifier];
                        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"source_removed"     // Event category (required)
                                                                              action:@"reminders_removed"  // Event action (required)
                                                                               label:@"[life]"          // Event label
                                                                               value:nil] build]];    // Event value
                    } else {
                        [self.data.choices setObject:[NSNumber numberWithBool:TRUE] forKey:identifier];
                        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"source_added"     // Event category (required)
                                                                              action:@"reminders_added"  // Event action (required)
                                                                               label:@"[life]"          // Event label
                                                                               value:nil] build]];    // Event value
                    }
                    self.data.changed = TRUE;
                    [self updateContent];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"not granted");
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reminders Permissions"
                                                                message:@"You must grant permission under settings->privacy in order to add this content."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                    [alert show];
                    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Error"     // Event category (required)
                                                                          action:@"no_reminders_permissions"  // Event action (required)
                                                                           label:nil  // Event label
                                                                           value:nil] build]];    // Event value
                    [self.data.choices setObject:[NSNumber numberWithBool:FALSE] forKey:identifier];
                    self.data.changed = TRUE;
                    [self updateContent];
                });
            }
            
                
            
        }];
    } else if ([identifier isEqualToString:@"photos"]) {
        ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
        
        if ([[[lifechoices objectAtIndex:indexPath.row] objectForKey:@"selected"] boolValue]) {
            [self.data.choices setObject:[NSNumber numberWithBool:FALSE] forKey:identifier];
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"source_removed"     // Event category (required)
                                                                  action:@"photos_removed"  // Event action (required)
                                                                   label:@"[life]"          // Event label
                                                                   value:nil] build]];    // Event value
            
        } else {
            [self.data.choices setObject:[NSNumber numberWithBool:TRUE] forKey:identifier];
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"source_added"     // Event category (required)
                                                                  action:@"photos_added"  // Event action (required)
                                                                   label:@"[life]"          // Event label
                                                                   value:nil] build]];    // Event value
        }
        self.data.changed = TRUE;
        [self updateContent];
        
        [lib enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"granted");
            });
        } failureBlock:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"not granted");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Photos Permissions"
                                                                message:@"You must grant permission under settings->privacy in order to add this content."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Error"     // Event category (required)
                                                                      action:@"no_photo_permissions"  // Event action (required)
                                                                       label:nil  // Event label
                                                                       value:nil] build]];    // Event value
                [self.data.choices setObject:[NSNumber numberWithBool:FALSE] forKey:identifier];
                self.data.changed = TRUE;
                [self updateContent];
            });
        }];
    } else if ([identifier isEqualToString:@"twitter"]) {
        ACAccountStore *accountStore = [[ACAccountStore alloc] init];
        ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSArray *accounts = [accountStore accountsWithAccountType:accountType];
                    
                    //Check if the user has setup at least one twitter account
                    if (accounts.count > 0) {
                        if ([[self.data.choices objectForKey:@"twitter"] boolValue]) {
                            [self.data.choices setObject:[NSNumber numberWithBool:FALSE] forKey:@"twitter"];
                            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"source_removed"     // Event category (required)
                                                                                  action:@"twitter_removed"  // Event action (required)
                                                                                   label:@"[life]"          // Event label
                                                                                   value:nil] build]];    // Event value
                            
                        } else {
                            [self.data.choices setObject:[NSNumber numberWithBool:TRUE] forKey:@"twitter"];
                            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"source_added"     // Event category (required)
                                                                                  action:@"twitter_added"  // Event action (required)
                                                                                   label:@"[life]"          // Event label
                                                                                   value:nil] build]];    // Event value
                        }
                        self.data.changed = TRUE;
                        [self updateContent];
                    } else {
                        NSLog(@"no Twitter accounts");
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Twitter Accounts"
                                                                        message:@"Add a Twitter account under settings->twitter first."
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                        [alert show];
                        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Error"     // Event category (required)
                                                                              action:@"no_twitter_accounts"  // Event action (required)
                                                                               label:nil  // Event label
                                                                               value:nil] build]];    // Event value
                        [self.data.choices setObject:[NSNumber numberWithBool:FALSE] forKey:@"twitter"];
                        self.data.changed = TRUE;
                        [self updateContent];
                    }
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"not granted");
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter Permissions"
                                                                    message:@"You must grant permission under \nsettings->privacy in order to add this content."
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Error"     // Event category (required)
                                                                          action:@"no_twitter_permissions"  // Event action (required)
                                                                           label:nil  // Event label
                                                                           value:nil] build]];    // Event value
                    [self.data.choices setObject:[NSNumber numberWithBool:FALSE] forKey:@"twitter"];
                    self.data.changed = TRUE;
                    [self updateContent];
                });
            }
        }];
    } else {
        if ([[[lifechoices objectAtIndex:indexPath.row] objectForKey:@"selected"] boolValue]) {
            [self.data.choices setObject:[NSNumber numberWithBool:FALSE] forKey:identifier];
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"source_removed"     // Event category (required)
                                                                  action:[NSMutableString stringWithFormat:@"%@_removed",identifier]  // Event action (required)
                                                                   label:@"[life]"          // Event label
                                                                   value:nil] build]];    // Event value
        } else {
            if ([identifier isEqualToString:@"mail"]) {
                [self performSegueWithIdentifier:@"lifeEmailSettings" sender:self.data];
                [self.data.choices setObject:[NSNumber numberWithBool:TRUE] forKey:identifier];
                id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"source_added"     // Event category (required)
                                                                      action:@"mail_added"  // Event action (required)
                                                                       label:@"[life]"          // Event label
                                                                       value:nil] build]];    // Event value

            } else {
                id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"source_added"     // Event category (required)
                                                                      action:[NSMutableString stringWithFormat:@"%@_added",identifier]  // Event action (required)
                                                                       label:@"[life]"          // Event label
                                                                       value:nil] build]];    // Event value
                [self.data.choices setObject:[NSNumber numberWithBool:TRUE] forKey:identifier];
            }
        }
        self.data.changed = TRUE;
        [self updateContent];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"lifeEmailSettings"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        emailSettings *controller = (emailSettings *)navigationController.topViewController;
        controller.data = sender;
    }
}

- (IBAction)done
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


@end