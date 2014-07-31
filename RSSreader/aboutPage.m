//
//  aboutPage.m
//  oneLife
//
//  Created by Matthew Chan on 7/13/14.
//  Copyright (c) 2014 Matthew Chan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "aboutPage.h"

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

#import "SWRevealViewController.h"

@interface aboutPage ()
@end

@implementation aboutPage

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"About Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)email
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:chanmatt12@gmail.com"]];
}

@end