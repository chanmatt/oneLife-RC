//
//  emailSettings.m
//  oneLife
//
//  Created by Matthew Chan on 7/11/14.
//  Copyright (c) 2014 Matthew Chan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "emailSettings.h"

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

#import <GoogleOpenSource/GoogleOpenSource.h>

@interface emailSettings () {
    BOOL loggedout;
}
@end

@implementation emailSettings

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"Settings_Email"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    //self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([[GPPSignIn sharedInstance] authentication]){
        loggedout = FALSE;
    } else {
        loggedout = TRUE;
    }
    [self refreshView];
    //[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        NSString *kClientId = @"766266857523-1k0na0t4dt9cuod8u8gav3etnfbld638.apps.googleusercontent.com";
        GPPSignIn *signIn = [GPPSignIn sharedInstance];
        signIn.shouldFetchGooglePlusUser = YES;
        signIn.shouldFetchGoogleUserEmail = YES;  // Uncomment to get the user's email
        
        // You previously set kClientId in the "Initialize the Google+ client" step
        signIn.clientID = kClientId;
        
        // Uncomment one of these two statements for the scope you chose in the previous step
        signIn.scopes = @[ @"profile", @"https://mail.google.com/" ];
        
        // Optional: declare signIn.actions, see "app activities"
        signIn.delegate = self;
        
        if (loggedout) {
            NSLog(@"Login/Logout Button");
            [signIn authenticate];
        } else {
            loggedout = TRUE;
            [signIn signOut];
            [[GPPSignIn sharedInstance] disconnect];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Signed Out"
                                                            message:@"Your gmail account has been disconnected from oneLife."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    
    [self refreshView];
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)didDisconnectWithError:(NSError *)error
{
    if (error) {
        NSLog(@"Log out error");
    }
}

- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error {
    NSLog(@"Received error %@ and auth object %@",error, auth);
    if (error) {
        loggedout = TRUE;
        [self refreshView];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't Connect to Gmail"
                                                        message:@"Please check to see if you gave oneLife permission to connect to your Gmail"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        loggedout = FALSE;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Signed In"
                                                        message:@"You have been signed in to your gmail account."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)refreshView
{
    if (loggedout) {
        self.loginlogout.text = @"Log in to Gmail";
    } else {
        self.loginlogout.text = @"Disconnect your Gmail Account";
    }
}

- (void)presentSignInViewController:(UIViewController *)viewController {
    // This is an example of how you can implement it if your app is navigation-based.
    [[self navigationController] pushViewController:viewController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done
{
    //Use this statement if email is not logged in
    if (loggedout) {
        self.data.emailchanged = TRUE;
    }
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end

