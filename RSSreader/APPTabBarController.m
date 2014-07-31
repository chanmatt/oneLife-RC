//
//  APPTabViewController.m
//  oneLife
//
//  Created by Matthew Chan on 7/6/14.
//  Copyright (c) 2014 Matthew Chan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APPTabBarController.h"
#import "APPContentFeaturedController.h"

@interface APPTabBarController ()
@end

@implementation APPTabBarController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    //self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"The Data Tab");
    NSLog(@"%d",[[self.data.choices objectForKey:@"calendar"] boolValue]);
    NSLog(@"%d",[[self.data.choices objectForKey:@"stocks"] boolValue]);
    NSLog(@"%d",[[self.data.choices objectForKey:@"weather"] boolValue]);
    
}

- (IBAction)done
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end