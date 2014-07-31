//
//  APPContentFeaturedController.m
//  oneLife
//
//  Created by Matthew Chan on 7/4/14.
//  Copyright (c) 2014 Matthew Chan. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "APPContentFeaturedController.h"
#import "emailSettings.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <EventKit/EKEvent.h>
#import <EventKit/EKEventStore.h>
#import <Accounts/Accounts.h>
#import <Accounts/ACAccountStore.h>
#import <Social/Social.h>

#import <CoreLocation/CoreLocation.h>

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"



@interface APPContentFeaturedController () {
    NSMutableArray *currentchoices;
    int amountchoices;
    int amountsources;
    CLLocationManager *locationManager;
}
@end

@implementation APPContentFeaturedController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"Content_Featured"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    if (self.data.changed) {
        [self.tableView reloadData];
    }
    
    if (self.data.emailchanged) {
        self.data.emailchanged = FALSE;
        [self.data.choices setObject:[NSNumber numberWithBool:FALSE] forKey:@"mail"];
        [self.tableView reloadData];
    }
    
    //self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
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
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 550;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    //UILabel *featured_1_1 = (UILabel *)[cell viewWithTag:1];
    //UILabel *featured_1_2 = (UILabel *)[cell viewWithTag:2];
    //UILabel *featured_2_1 = (UILabel *)[cell viewWithTag:3];
    //UILabel *featured_2_2 = (UILabel *)[cell viewWithTag:4];
    //UILabel *featured_3_1 = (UILabel *)[cell viewWithTag:5];
    //UILabel *featured_3_2 = (UILabel *)[cell viewWithTag:6];
    //UILabel *featured_4_1 = (UILabel *)[cell viewWithTag:7];
    //UILabel *featured_4_2 = (UILabel *)[cell viewWithTag:8];
    UIButton *button_1_1 = (UIButton *)[cell viewWithTag:30];
    UIButton *button_1_2 = (UIButton *)[cell viewWithTag:31];
    UIButton *button_2_1 = (UIButton *)[cell viewWithTag:32];
    UIButton *button_2_2 = (UIButton *)[cell viewWithTag:33];
    UIButton *button_3_1 = (UIButton *)[cell viewWithTag:34];
    UIButton *button_3_2 = (UIButton *)[cell viewWithTag:35];
    UIButton *button_4_1 = (UIButton *)[cell viewWithTag:36];
    UIButton *button_4_2 = (UIButton *)[cell viewWithTag:37];
    UILabel *added_1_1 = (UILabel *)[cell viewWithTag:9];
    UILabel *added_1_2 = (UILabel *)[cell viewWithTag:10];
    UILabel *added_2_1 = (UILabel *)[cell viewWithTag:11];
    UILabel *added_2_2 = (UILabel *)[cell viewWithTag:12];
    UILabel *added_3_1 = (UILabel *)[cell viewWithTag:13];
    UILabel *added_3_2 = (UILabel *)[cell viewWithTag:14];
    UILabel *added_4_1 = (UILabel *)[cell viewWithTag:15];
    UILabel *added_4_2 = (UILabel *)[cell viewWithTag:16];
    if ([[self.data.choices objectForKey:@"calendar"] boolValue]) {
        button_1_1.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.7];
        added_1_1.text = @"ADDED";
    } else {
        button_1_1.backgroundColor = [UIColor clearColor];
        added_1_1.text = @"";
    }
    if ([self.data determineExist:@"thoughtcatalog"]>=0) {
        button_1_2.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.7];
        added_1_2.text = @"ADDED";
    } else {
        button_1_2.backgroundColor = [UIColor clearColor];
        added_1_2.text = @"";
    }
    if ([self.data determineExist:@"nytimes"]>=0) {
        button_2_1.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.7];
        added_2_1.text = @"ADDED";
    } else {
        button_2_1.backgroundColor = [UIColor clearColor];
        added_2_1.text = @"";
    }
    if ([[self.data.choices objectForKey:@"weather"] boolValue]) {
        button_2_2.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.7];
        added_2_2.text = @"ADDED";
    } else {
        button_2_2.backgroundColor = [UIColor clearColor];
        added_2_2.text = @"";
    }
    if ([self.data determineExist:@"techcrunch"]>=0) {
        button_3_1.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.7];
        added_3_1.text = @"ADDED";
    } else {
        button_3_1.backgroundColor = [UIColor clearColor];
        added_3_1.text = @"";
    }
    if ([[self.data.choices objectForKey:@"mail"] boolValue]) {
        button_3_2.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.7];
        added_3_2.text = @"ADDED";
    } else {
        button_3_2.backgroundColor = [UIColor clearColor];
        added_3_2.text = @"";
    }
    if ([[self.data.choices objectForKey:@"twitter"] boolValue]) {
        button_4_1.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.7];
        added_4_1.text = @"ADDED";
    } else {
        button_4_1.backgroundColor = [UIColor clearColor];
        added_4_1.text = @"";
    }
    if ([[self.data.choices objectForKey:@"photos"] boolValue]) {
        button_4_2.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.7];
        added_4_2.text = @"ADDED";
    } else {
        button_4_2.backgroundColor = [UIColor clearColor];
        added_4_2.text = @"";
    }
    return cell;
}

- (IBAction)button_1_1
{
    EKEventStore *store = [[EKEventStore alloc] init];
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([[self.data.choices objectForKey:@"calendar"] boolValue]) {
                    [self.data.choices setObject:[NSNumber numberWithBool:FALSE] forKey:@"calendar"];
                    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"source_removed"     // Event category (required)
                                                                          action:@"calendar_removed"  // Event action (required)
                                                                           label:@"[featured]"          // Event label
                                                                           value:nil] build]];    // Event value
                } else {
                    [self.data.choices setObject:[NSNumber numberWithBool:TRUE] forKey:@"calendar"];
                    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"source_added"     // Event category (required)
                                                                          action:@"calendar_added"  // Event action (required)
                                                                           label:@"[featured]"          // Event label
                                                                           value:nil] build]];    // Event value
                }
                self.data.changed = TRUE;
                [self.tableView reloadData];
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
                id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Error"     // Event category (required)
                                                                      action:@"no_calendar_permissions"  // Event action (required)
                                                                       label:nil  // Event label
                                                                       value:nil] build]];    // Event value
                [self.data.choices setObject:[NSNumber numberWithBool:FALSE] forKey:@"calendar"];
                [self.tableView reloadData];
            });
        }
    }];
}
- (IBAction)button_1_2
{
    /*if ([[self.data.choices objectForKey:@"facebook"] boolValue]) {
        [self.data.choices setObject:[NSNumber numberWithBool:FALSE] forKey:@"facebook"];
    } else {
        [self.data.choices setObject:[NSNumber numberWithBool:TRUE] forKey:@"facebook"];
    }
    self.data.changed = TRUE;
    [self.tableView reloadData];*/
    int tempexist = [self.data determineExist:@"thoughtcatalog"];
    if (tempexist>=0) {
        [self.data.source_list removeObjectAtIndex:tempexist];
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"source_removed"     // Event category (required)
                                                              action:@"news_removed"  // Event action (required)
                                                               label:@"thoughtcatalog [featured]" // Event label
                                                               value:nil] build]];    // Event value
    } else {
        NSMutableDictionary *newSource = [[NSMutableDictionary alloc] init];
        [newSource setObject:@"Thought Catalog" forKey:@"title"];
        [newSource setObject:@"thoughtcatalog" forKey:@"identifier"];
        [newSource setObject:@"http://feeds.feedburner.com/ThoughtCatalog" forKey:@"url"];
        [newSource setObject:@"Experiment.png" forKey:@"icon"];
        [self.data addSource:newSource];
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"source_added"     // Event category (required)
                                                              action:@"news_added"  // Event action (required)
                                                               label:@"thoughtcatalog [featured]" // Event label
                                                               value:nil] build]];    // Event value
    }
    self.data.changed = TRUE;
    [self.tableView reloadData];
}

- (IBAction)button_2_1
{
    int tempexist = [self.data determineExist:@"nytimes"];
    if (tempexist>=0) {
        [self.data.source_list removeObjectAtIndex:tempexist];
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"source_removed"     // Event category (required)
                                                              action:@"news_removed"  // Event action (required)
                                                               label:@"nytimes [featured]" // Event label
                                                               value:nil] build]];    // Event value
    } else {
        NSMutableDictionary *newSource = [[NSMutableDictionary alloc] init];
        [newSource setObject:@"New York Times" forKey:@"title"];
        [newSource setObject:@"nytimes" forKey:@"identifier"];
        [newSource setObject:@"http://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml" forKey:@"url"];
        [newSource setObject:@"News.png" forKey:@"icon"];
        [self.data addSource:newSource];
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"source_added"     // Event category (required)
                                                              action:@"news_added"  // Event action (required)
                                                               label:@"nytimes [featured]" // Event label
                                                               value:nil] build]];    // Event value
    }
    self.data.changed = TRUE;
    [self.tableView reloadData];
}
- (IBAction)button_2_2
{
    //locationManager = [[CLLocationManager alloc] init];
    //locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    //locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    //[locationManager startUpdatingLocation];
    NSLog(@"latitude: %f longitude: %f", locationManager.location.coordinate.latitude, locationManager.location.coordinate.longitude);
    if ([[self.data.choices objectForKey:@"weather"] boolValue]) {
        [self.data.choices setObject:[NSNumber numberWithBool:FALSE] forKey:@"weather"];
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"source_removed"     // Event category (required)
                                                              action:@"weather_removed"  // Event action (required)
                                                               label:@"[featured]" // Event label
                                                               value:nil] build]];    // Event value
    } else {
        [self.data.choices setObject:[NSNumber numberWithBool:TRUE] forKey:@"weather"];
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"source_added"     // Event category (required)
                                                              action:@"weather_added"  // Event action (required)
                                                               label:@"[featured]"  // Event label
                                                               value:nil] build]];    // Event value
    }
    self.data.changed = TRUE;
    [self.tableView reloadData];
}
- (IBAction)button_3_1
{
    int tempexist = [self.data determineExist:@"techcrunch"];
    if (tempexist>=0) {
        [self.data.source_list removeObjectAtIndex:tempexist];
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"source_removed"     // Event category (required)
                                                              action:@"news_removed"  // Event action (required)
                                                               label:@"techcrunch [featured]"  // Event label
                                                               value:nil] build]];    // Event value
    } else {
        NSMutableDictionary *newSource = [[NSMutableDictionary alloc] init];
        [newSource setObject:@"Tech Crunch" forKey:@"title"];
        [newSource setObject:@"techcrunch" forKey:@"identifier"];
        [newSource setObject:@"http://feeds.feedburner.com/TechCrunch/" forKey:@"url"];
        [newSource setObject:@"Tech.png" forKey:@"icon"];
        [self.data addSource:newSource];
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"source_added"     // Event category (required)
                                                              action:@"news_added"  // Event action (required)
                                                               label:@"techcrunch [featured]"   // Event label
                                                               value:nil] build]];    // Event value
    }
    self.data.changed = TRUE;
    [self.tableView reloadData];
}
- (IBAction)button_3_2
{
    if ([[self.data.choices objectForKey:@"mail"] boolValue]) {
        [self.data.choices setObject:[NSNumber numberWithBool:FALSE] forKey:@"mail"];
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"source_removed"     // Event category (required)
                                                              action:@"mail_removed"  // Event action (required)
                                                               label:@"[featured]" // Event label
                                                               value:nil] build]];    // Event value
    } else {
        [self.data.choices setObject:[NSNumber numberWithBool:TRUE] forKey:@"mail"];
        [self performSegueWithIdentifier:@"featuredEmailSettings" sender:self.data];
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"source_added"     // Event category (required)
                                                              action:@"mail_added"  // Event action (required)
                                                               label:@"[featured]"  // Event label
                                                               value:nil] build]];    // Event value
    }
    self.data.changed = TRUE;
    [self.tableView reloadData];
}
- (IBAction)button_4_1
{
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
                                                                               label:@"[featured]" // Event label
                                                                               value:nil] build]];    // Event value
                    } else {
                        [self.data.choices setObject:[NSNumber numberWithBool:TRUE] forKey:@"twitter"];
                        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"source_added"     // Event category (required)
                                                                              action:@"twitter_added"  // Event action (required)
                                                                               label:@"[featured]"  // Event label
                                                                               value:nil] build]];    // Event value
                    }
                    self.data.changed = TRUE;
                    [self.tableView reloadData];
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
                    [self.tableView reloadData];
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
                [self.tableView reloadData];
            });
        }
    }];
}
- (IBAction)button_4_2
{
    NSLog(@"Button pressed");
    
    if ([[self.data.choices objectForKey:@"photos"] boolValue]) {
        [self.data.choices setObject:[NSNumber numberWithBool:FALSE] forKey:@"photos"];
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"source_removed"     // Event category (required)
                                                              action:@"photos_removed"  // Event action (required)
                                                               label:@"[featured]" // Event label
                                                               value:nil] build]];    // Event value
    } else {
        [self.data.choices setObject:[NSNumber numberWithBool:TRUE] forKey:@"photos"];
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"source_added"     // Event category (required)
                                                              action:@"photos_added"  // Event action (required)
                                                               label:@"[featured]" // Event label
                                                               value:nil] build]];    // Event value
    }
    self.data.changed = TRUE;
    [self.tableView reloadData];
    
    ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
    
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
            [self.data.choices setObject:[NSNumber numberWithBool:FALSE] forKey:@"photos"];
            self.data.changed = TRUE;
            [self.tableView reloadData];
        });
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"featuredEmailSettings"]) {
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
