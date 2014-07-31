//
//  APPPageViewController.h
//  oneLife
//
//  Created by Matthew Chan on 7/16/14.
//  Copyright (c) 2014 Matthew Chan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APPPageViewController : UIViewController <UIPageViewControllerDataSource>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageTitles;
@property (strong, nonatomic) NSArray *pageImages;

- (IBAction)startWalkthrough:(id)sender;

@end
