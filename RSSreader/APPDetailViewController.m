//
//  APPDetailViewController.m
//  RSSreader
//
//  Created by Matthew Chan on 6/9/14.
//  Copyright (c) 2014 Matthew Chan. All rights reserved.
//

#import "APPDetailViewController.h"

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface APPDetailViewController ()

@end

@implementation APPDetailViewController

#pragma mark - Managing the detail item


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"Webview"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    //self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityView startAnimating];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:activityView];
    NSArray *items = [[NSArray alloc] initWithObjects:item, nil];
    [self.navigationController.toolbar setItems:items];
    //[self.navigationController setToolbarHidden:TRUE];
    
    NSURL *myURL = [NSURL URLWithString: [self.url stringByAddingPercentEscapesUsingEncoding:
                                          NSUTF8StringEncoding]];
    NSURLRequest *request = [NSURLRequest requestWithURL:myURL];
    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
