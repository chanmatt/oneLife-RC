//
//  APPMasterViewController.m
//  RSSreader
//
//  Created by Matthew Chan on 6/9/14.
//  Copyright (c) 2014 Matthew Chan. All rights reserved.
//

#import "APPMasterViewController.h"
#import "APPDetailViewController.h"
#import "APPSettingsViewController.h"
#import "APPShareViewController.h"
#import "OWMWeatherAPI.h"

#import "HHDirectionPanGestureRecognizer.h"
#import "HHInnerShadowView.h"
#import "HHPanningTableViewCell.h"

#import <EventKit/EKEvent.h>
#import <EventKit/EKEventStore.h>
#import <EventKit/EKReminder.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AddressBookUI/AddressBookUI.h>
#import <UIKit/UISwipeGestureRecognizer.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <QuartzCore/QuartzCore.h>
#import <FacebookSDK/FacebookSDK.h>
#import <MailCore/MailCore.h>
#import <CoreLocation/CoreLocation.h>

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

#import <GoogleOpenSource/GoogleOpenSource.h>

#import "SWRevealViewController.h"


@interface APPMasterViewController () {
    
    //Feeds
    NSMutableArray *rssfeed_array;
    NSMutableArray *feeds;
    NSMutableArray *temp_feeds;
    dispatch_queue_t myQueue;
    
    //Calendar
    NSString *calendar_eventName1;
    NSString *calendar_eventName2;
    NSString *calendar_eventName3;
    NSString *calendar_eventName4;
    NSString *calendar_temp_eventName[4];
    
    NSDate *calendar_startTime1;
    NSDate *calendar_startTime2;
    NSDate *calendar_startTime3;
    NSDate *calendar_startTime4;
    NSDate *calendar_temp_startTime[4];
    int calendar_eventscount;
    int calendar_temp_eventscount;
    NSDateFormatter *formatter;
    
    //Reminders
    NSString *reminders_taskName1;
    NSString *reminders_taskName2;
    NSString *reminders_taskName3;
    NSString *reminders_taskName4;
    NSString *reminders_temp_taskName[4];
    int reminders_taskscount;
    int reminders_temp_taskscount;
    int x;
    
    //Parser
    int parseindex;
    int epiccount;
    
    BOOL parse_on;
    BOOL parse_done;
    NSMutableData *receivedData;
    
    NSMutableArray *parsers;
    NSMutableArray *parseurls;
    
    NSMutableDictionary *parsed_item;
    NSMutableString *parsed_title;
    NSMutableString *parsed_link;
    NSMutableString *parsed_description;
    NSMutableString *parsed_imageurl;
    NSString *parsed_source;
    NSString *parsed_element;
    
    //UI
    NSMutableDictionary *reloading_done;
    UIRefreshControl *refresh;
    BOOL firstrun;
    
    //Weather;
    OWMWeatherAPI *_weatherAPI;
    NSMutableString *weather_temperature;
    NSMutableString *weather_description;
    NSMutableString *weather_city;
    UIImage *weather_icon[6];
    NSString *weather_times[6];
    NSString *weather_temps[6];
    BOOL weatherupdating;
    
    //Latest Photo
    UIImage *myphoto;
    NSDate *photodate;
    NSString *photolocation;
    
    //Twitter
    NSMutableArray *twitter_feed;
    NSMutableArray *temp_twitter_feed;
    NSMutableArray *importanttwitter_feed;
    int importanttwitter_amount;
    
    //Facebook
    NSMutableArray *facebook_feed;
    NSMutableArray *temp_facebook_feed;
    NSMutableArray *temp_important_facebook_feed;
    NSMutableArray *important_facebook_feed;
    
    //Mail
    MCOIMAPSession *session;
    NSDate *emails_session_created;
    NSMutableArray *emails;
    NSMutableArray *emails_real;
    MCOIMAPMessage *message;
    int emails_parsed;
    
    //The Feed
    NSMutableArray *feedarray;
    NSMutableArray *article_type; //gives the article type for the index in the article list
    NSMutableArray *article_index; //gives the nth article for the type of article for the index in the article list
    NSMutableArray *article_number_at; //gives the article number at the indexPath.row
    int total_types;
    int articlesneeded;
    int temp_moduleamount;
    int moduleamount;
    
    NSDate *updateTime;
    
    
    HHPanningTableViewCell *tempcell;
    AVSpeechSynthesizer *speechSynthesizer;
    AVSpeechUtterance *utterance;
    BOOL playing;
    int currentCell;
    float progress; //The progress out of 100
    int progress_total_to_load;
    int progress_loaded;
    UIProgressView *theProgress;
    NSTimer *nst;
    
    CLLocationManager *locationManager;
    
    BOOL loadingStatus;
    
    BOOL nuking;
    
    int feednumber;
}

@end

@implementation APPMasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSShadow* shadow = [NSShadow new];
    shadow.shadowOffset = CGSizeMake(0.0f, 0.0f);
    shadow.shadowColor = [UIColor blackColor];
    [[UINavigationBar appearance] setTitleTextAttributes: @{
                                                            NSForegroundColorAttributeName: [UIColor blackColor],
                                                            NSFontAttributeName: [UIFont fontWithName:@"Avenir" size:25.0f],
                                                            NSShadowAttributeName: shadow
                                                            }];
    [super viewWillAppear:YES];
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"Home Feed"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    if (self.dataModel.changed == TRUE) {
        self.dataModel.changed = FALSE;
        [refresh beginRefreshing];
        [self startReload];
    }
    
    //self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    firstrun = TRUE;
    moduleamount = 0;
    nuking = FALSE;
    loadingStatus = FALSE;
    
    //Load user settings from memory
    self.dataModel = [[DataModel alloc] init];
    //[self.dataModel defaultValues];
    
    //Allocate space for variables
    formatter = [[NSDateFormatter alloc] init];
    
    //Facebook!
    // If the session state is any of the two "open" states when the button is clicked
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    //Configure Table View
    //[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    //self.tableView.backgroundView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"defaultbg.png"]];
    //self.tafbleView.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    //Initialize speaking stuff
    speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
    speechSynthesizer.delegate = self;
    playing = FALSE;
    
    //Refresh Control
    refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [refresh addTarget:self action:@selector(pullToRefresh)
      forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    myQueue = dispatch_queue_create("Articles Queue", NULL);
    
    if ([self.dataModel.initialrun boolValue]) {
        [self performSegueWithIdentifier:@"helpSegway" sender:nil];
        self.dataModel.changed = TRUE;
    } else {
        [self startReload];
    }

}

- (void)pullToRefresh {
    if (loadingStatus == FALSE) {
        [self startReload];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (void)nuke
{
    nuking = TRUE;
    [self.tableView reloadData];
    nuking = FALSE;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (nuking) {
        return 0;
    }
    if (firstrun && moduleamount == 0) {
        return 1;
    }
    return moduleamount;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (firstrun && moduleamount == 0) {
        return 69;
    } else {
    
    if ([[feedarray objectAtIndex:indexPath.row] intValue] == 99)
    {
        return 69;
    }
    
    if ([[feedarray objectAtIndex:indexPath.row] intValue] == 98)
    {
        return 106;
    }
    
    if ([[feedarray objectAtIndex:indexPath.row] intValue] == 0)
    {
        //clock
        return 69;
    }
    
    if ([[feedarray objectAtIndex:indexPath.row] intValue] == 1) {
        //calendar
        if (calendar_eventscount == 1) {
            return 56;
        } else if (calendar_eventscount == 2) {
            return 96;
        } else if (calendar_eventscount == 3) {
            return 136;
        } else {
            return 176;
        }
    }
    
    if ([[feedarray objectAtIndex:indexPath.row] intValue] == 2) {
        //reminder
        if (reminders_taskscount == 1) {
            return 56;
        } else if (reminders_taskscount == 2) {
            return 96;
        } else if (reminders_taskscount == 3) {
            return 136;
        } else {
            return 176;
        }
    }
    
    if ([[feedarray objectAtIndex:indexPath.row] intValue] == 3) {
        //weather
        return 203;
    }
    
    if ([[feedarray objectAtIndex:indexPath.row] intValue] == 4) {
        //stocks
        return 190;
    }
    
    if ([[feedarray objectAtIndex:indexPath.row] intValue] == 5) {
        //photo
        return 235;
    }
    
    if ([[feedarray objectAtIndex:indexPath.row] intValue] == 6) {
        //mail
        if (emails_real.count>1) {
            return 240;
        } else {
            return 120;
        }
    }
    
    if ([[feedarray objectAtIndex:indexPath.row] intValue] == 7) {
        //twitter
        return 143;
    }
        
    if ([[feedarray objectAtIndex:indexPath.row] intValue] == 8) {
        //facebook
        int facebooknumber = [[article_number_at objectAtIndex:indexPath.row] intValue];
        if ([[important_facebook_feed objectAtIndex:facebooknumber] objectForKey:@"type"] != nil) {
            return 280;
        }
        return 178;
    }
    
    if ([[feedarray objectAtIndex:indexPath.row] intValue] == 10) {
        //news
        if ([[article_type objectAtIndex:[[article_number_at objectAtIndex:indexPath.row] intValue]] intValue] == -1) {
            //twitter
            return 143;
        } else if ([[article_type objectAtIndex:[[article_number_at objectAtIndex:indexPath.row] intValue]] intValue] == -2) {
            //facebook
            int facebooknumber = [[article_index objectAtIndex:[[article_number_at objectAtIndex:indexPath.row] intValue]] intValue];
            if ([[facebook_feed objectAtIndex:facebooknumber] objectForKey:@"type"] != nil) {
                return 280;
            }
            return 178;
        } else if ([[article_type objectAtIndex:[[article_number_at objectAtIndex:indexPath.row] intValue]] intValue] >= 0) {
            return 203;
        }
    }
    
    if ([[feedarray objectAtIndex:indexPath.row] intValue] == 11) {
        //more
        return 69;
    }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[feedarray objectAtIndex:indexPath.row] intValue] == 99 || (firstrun == TRUE && moduleamount == 0))
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LoadingCell" forIndexPath:indexPath];
        theProgress = (UIProgressView *)[cell viewWithTag:1];
        [theProgress setProgress:0.01 animated:NO];
        return cell;
    } else if ([[feedarray objectAtIndex:indexPath.row] intValue] == 98) {
        
        HHPanningTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WelcomeCell" forIndexPath:indexPath];
        cell.directionMask = HHPanningTableViewCellDirectionRight;
        UITextView *drawerView = [[UITextView alloc] initWithFrame:cell.frame];
        drawerView.editable = FALSE;
        drawerView.text = @"";
        drawerView.textColor = [UIColor whiteColor];
        drawerView.backgroundColor = [UIColor whiteColor];
        cell.drawerView = drawerView;
        
        cell.delegate = self;
        return cell;
        
    } else if ([[feedarray objectAtIndex:indexPath.row] intValue] == 0) {

        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TimeCell" forIndexPath:indexPath];
        
        //Time: Time
        UILabel *timelabel = (UILabel *)[cell viewWithTag:2];
        [formatter setDateStyle:NSDateFormatterNoStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        timelabel.text = [[[formatter stringFromDate:updateTime] stringByReplacingOccurrencesOfString:@" AM" withString:@"am"] stringByReplacingOccurrencesOfString:@" PM" withString:@"pm"];
        
        //Time: Date
        UILabel *datelabel = (UILabel *)[cell viewWithTag:1];
        [formatter setDateStyle:NSDateFormatterFullStyle];
        [formatter setTimeStyle:NSDateFormatterNoStyle];
        datelabel.text = [[formatter stringFromDate:updateTime] stringByReplacingOccurrencesOfString:@" AD" withString:@""];;
        //datelabel.text = @"Sunday, March 17th, 2014";
        
        return cell;

    } else if ([[feedarray objectAtIndex:indexPath.row] intValue] == 1) {
        
        HHPanningTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CalendarCell" forIndexPath:indexPath];
        cell.directionMask = HHPanningTableViewCellDirectionRight;
        UITextView *drawerView = [[UITextView alloc] initWithFrame:cell.frame];
        drawerView.editable = FALSE;
        drawerView.text = @"";
        drawerView.textColor = [UIColor whiteColor];
        drawerView.backgroundColor = [UIColor whiteColor];
        cell.drawerView = drawerView;
        
        //Calendar: First Event
        UILabel *time1 = (UILabel *)[cell viewWithTag:1];
        UILabel *event1 = (UILabel *)[cell viewWithTag:2];

        [formatter setDateStyle:NSDateFormatterNoStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        NSString *tempz = [[formatter stringFromDate:calendar_startTime1] stringByReplacingOccurrencesOfString:@" AM" withString:@"a"];
        tempz = [tempz stringByReplacingOccurrencesOfString:@" PM" withString:@"p"];
        time1.text = tempz;
        event1.text = calendar_eventName1;
        
        //Calendar: Second Event
        UILabel *time2 = (UILabel *)[cell viewWithTag:3];
        UILabel *event2 = (UILabel *)[cell viewWithTag:4];
        
        tempz = [[formatter stringFromDate:calendar_startTime2] stringByReplacingOccurrencesOfString:@" AM" withString:@"a"];
        tempz = [tempz stringByReplacingOccurrencesOfString:@" PM" withString:@"p"];
        time2.text = tempz;
        event2.text = calendar_eventName2;
        
        //Calendar: Third Event
        UILabel *time3 = (UILabel *)[cell viewWithTag:5];
        UILabel *event3 = (UILabel *)[cell viewWithTag:6];
        
        tempz = [[formatter stringFromDate:calendar_startTime3] stringByReplacingOccurrencesOfString:@" AM" withString:@"a"];
        tempz = [tempz stringByReplacingOccurrencesOfString:@" PM" withString:@"p"];
        time3.text = tempz;
        event3.text = calendar_eventName3;
        
        //Calendar: Fourth Event
        UILabel *time4 = (UILabel *)[cell viewWithTag:7];
        UILabel *event4 = (UILabel *)[cell viewWithTag:8];
        
        tempz = [[formatter stringFromDate:calendar_startTime4] stringByReplacingOccurrencesOfString:@" AM" withString:@"a"];
        tempz = [tempz stringByReplacingOccurrencesOfString:@" PM" withString:@"p"];
        time4.text = tempz;
        event4.text = calendar_eventName4;
        
        UILabel *line = (UILabel *)[cell viewWithTag:20];
        
        if (calendar_eventscount == 1) {
            line.frame = CGRectMake(0,0,11,55);
        } else if (calendar_eventscount == 2) {
            line.frame = CGRectMake(0,0,11,95);
        } else if (calendar_eventscount == 3) {
            line.frame = CGRectMake(0,0,11,135);
        } else {
            line.frame = CGRectMake(0,0,11,175);
        }
        
        cell.delegate = self;
        return cell;
        
    } else if ([[feedarray objectAtIndex:indexPath.row] intValue] == 2) {
        
        //Reminder
        HHPanningTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReminderCell" forIndexPath:indexPath];
        cell.directionMask = HHPanningTableViewCellDirectionRight;
        UITextView *drawerView = [[UITextView alloc] initWithFrame:cell.frame];
        drawerView.editable = FALSE;
        drawerView.text = @"";
        drawerView.textColor = [UIColor whiteColor];
        drawerView.backgroundColor = [UIColor whiteColor];
        cell.drawerView = drawerView;
        
        UILabel *reminder1 = (UILabel *)[cell viewWithTag:1];
        reminder1.text = reminders_taskName1;
        UILabel *reminder2 = (UILabel *)[cell viewWithTag:2];
        reminder2.text = reminders_taskName2;
        UILabel *reminder3 = (UILabel *)[cell viewWithTag:3];
        reminder3.text = reminders_taskName3;
        UILabel *reminder4 = (UILabel *)[cell viewWithTag:4];
        reminder4.text = reminders_taskName4;
        
        UILabel *line = (UILabel *)[cell viewWithTag:20];
        UILabel *b1 = (UILabel *)[cell viewWithTag:5];
        UILabel *b2 = (UILabel *)[cell viewWithTag:6];
        UILabel *b3 = (UILabel *)[cell viewWithTag:7];
        UILabel *b4 = (UILabel *)[cell viewWithTag:8];
        
        if (reminders_taskscount == 1) {
            line.frame = CGRectMake(0,0,11,55);
            b1.backgroundColor = [UIColor lightGrayColor];
            b2.backgroundColor = [UIColor clearColor];
            b3.backgroundColor = [UIColor clearColor];
            b4.backgroundColor = [UIColor clearColor];
        } else if (reminders_taskscount == 2) {
            line.frame = CGRectMake(0,0,11,95);
            b1.backgroundColor = [UIColor lightGrayColor];
            b2.backgroundColor = [UIColor lightGrayColor];
            b3.backgroundColor = [UIColor clearColor];
            b4.backgroundColor = [UIColor clearColor];
        } else if (reminders_taskscount == 3) {
            line.frame = CGRectMake(0,0,11,135);
            b1.backgroundColor = [UIColor lightGrayColor];
            b2.backgroundColor = [UIColor lightGrayColor];
            b3.backgroundColor = [UIColor lightGrayColor];
            b4.backgroundColor = [UIColor clearColor];
        } else {
            line.frame = CGRectMake(0,0,11,175);
            b1.backgroundColor = [UIColor lightGrayColor];
            b2.backgroundColor = [UIColor lightGrayColor];
            b3.backgroundColor = [UIColor lightGrayColor];
            b4.backgroundColor = [UIColor lightGrayColor];
        }
        
        cell.delegate = self;
        return cell;
        
    } else if ([[feedarray objectAtIndex:indexPath.row] intValue] == 3) {
        
        //Weather
        HHPanningTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WeatherCell" forIndexPath:indexPath];
        cell.directionMask = HHPanningTableViewCellDirectionRight;
        UITextView *drawerView = [[UITextView alloc] initWithFrame:cell.frame];
        drawerView.editable = FALSE;
        drawerView.text = @"";
        drawerView.textColor = [UIColor whiteColor];
        drawerView.backgroundColor = [UIColor whiteColor];
        cell.drawerView = drawerView;
        
        UILabel *currenttemp = (UILabel *)[cell viewWithTag:2];
        currenttemp.text = weather_temperature;
        UILabel *thecity = (UILabel *)[cell viewWithTag:20];
        thecity.text = weather_city;
        UIImageView *imageViewer = (UIImageView *)[cell viewWithTag:3];
        imageViewer.image = weather_icon[0];
        UILabel *currentdescription = (UILabel *)[cell viewWithTag:4];
        currentdescription.text = weather_description;
        
        UIImageView *imageView1 = (UIImageView *)[cell viewWithTag:5];
        imageView1.image = weather_icon[1];
        UIImageView *imageView2 = (UIImageView *)[cell viewWithTag:6];
        imageView2.image = weather_icon[2];
        UIImageView *imageView3 = (UIImageView *)[cell viewWithTag:7];
        imageView3.image = weather_icon[3];
        UIImageView *imageView4 = (UIImageView *)[cell viewWithTag:8];
        imageView4.image = weather_icon[4];
        UIImageView *imageView5 = (UIImageView *)[cell viewWithTag:9];
        imageView5.image = weather_icon[5];
        
        UILabel *time1 = (UILabel *)[cell viewWithTag:10];
        UILabel *time2 = (UILabel *)[cell viewWithTag:11];
        UILabel *time3 = (UILabel *)[cell viewWithTag:12];
        UILabel *time4 = (UILabel *)[cell viewWithTag:13];
        UILabel *time5 = (UILabel *)[cell viewWithTag:14];
        
        time1.text = weather_times[1];
        time2.text = weather_times[2];
        time3.text = weather_times[3];
        time4.text = weather_times[4];
        time5.text = weather_times[5];
        
        UILabel *temp1 = (UILabel *)[cell viewWithTag:15];
        UILabel *temp2 = (UILabel *)[cell viewWithTag:16];
        UILabel *temp3 = (UILabel *)[cell viewWithTag:17];
        UILabel *temp4 = (UILabel *)[cell viewWithTag:18];
        UILabel *temp5 = (UILabel *)[cell viewWithTag:19];
        
        temp1.text = weather_temps[1];
        temp2.text = weather_temps[2];
        temp3.text = weather_temps[3];
        temp4.text = weather_temps[4];
        temp5.text = weather_temps[5];
        
        cell.delegate = self;
        return cell;
        
    } else if ([[feedarray objectAtIndex:indexPath.row] intValue] == 4) {
        
        //Stocks
        HHPanningTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StocksCell" forIndexPath:indexPath];
        cell.directionMask = HHPanningTableViewCellDirectionRight;
        UITextView *drawerView = [[UITextView alloc] initWithFrame:cell.frame];
        drawerView.editable = FALSE;
        drawerView.text = @"";
        drawerView.textColor = [UIColor whiteColor];
        drawerView.backgroundColor = [UIColor blackColor];
        cell.drawerView = drawerView;
        
        cell.delegate = self;
        return cell;
        
    } else if ([[feedarray objectAtIndex:indexPath.row] intValue] == 5) {
        
        //Photos
        HHPanningTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PhotoCell" forIndexPath:indexPath];
        cell.directionMask = HHPanningTableViewCellDirectionRight;
        UITextView *drawerView = [[UITextView alloc] initWithFrame:cell.frame];
        drawerView.editable = FALSE;
        drawerView.text = @"";
        drawerView.textColor = [UIColor whiteColor];
        drawerView.backgroundColor = [UIColor whiteColor];
        cell.drawerView = drawerView;
        
        UIImageView *picView = (UIImageView *)[cell viewWithTag:98];
        //UILabel *datelabel = (UILabel *)[cell viewWithTag:2];
        UILabel *locationlabel = (UILabel *)[cell viewWithTag:3];
        //[formatter setDateStyle:NSDateFormatterLongStyle];
        //[formatter setTimeStyle:NSDateFormatterShortStyle];
        //datelabel.text = [formatter stringFromDate:photodate];
        locationlabel.text = photolocation;
        //myphoto = [UIImage imageNamed:@"picsmall.jpg"];
        picView.image = myphoto;
        
        cell.delegate = self;
        return cell;
    
    } else if ([[feedarray objectAtIndex:indexPath.row] intValue] == 6) {
        
        //Mail
        HHPanningTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MailCell" forIndexPath:indexPath];
        cell.directionMask = HHPanningTableViewCellDirectionRight;
        UITextView *drawerView = [[UITextView alloc] initWithFrame:cell.frame];
        drawerView.editable = FALSE;
        drawerView.text = @"";
        drawerView.textColor = [UIColor whiteColor];
        drawerView.backgroundColor = [UIColor whiteColor];
        cell.drawerView = drawerView;
        
        UILabel *line = (UILabel *)[cell viewWithTag:20];
        
        UILabel *fromlabel = (UILabel *)[cell viewWithTag:1];
        UILabel *datelabel = (UILabel *)[cell viewWithTag:2];
        UILabel *subjectlabel = (UILabel *)[cell viewWithTag:3];
        UILabel *bodylabel = (UILabel *)[cell viewWithTag:4];
        
        fromlabel.text = [[emails_real objectAtIndex:0] objectForKey:@"from"];
        datelabel.text = [[emails_real objectAtIndex:0] objectForKey:@"date"];
        subjectlabel.text = [[emails_real objectAtIndex:0] objectForKey:@"subject"];
        bodylabel.text = [[emails_real objectAtIndex:0] objectForKey:@"body"];
        
        UILabel *fromlabel2 = (UILabel *)[cell viewWithTag:5];
        UILabel *datelabel2 = (UILabel *)[cell viewWithTag:6];
        UILabel *subjectlabel2 = (UILabel *)[cell viewWithTag:7];
        UILabel *bodylabel2 = (UILabel *)[cell viewWithTag:8];

        if (emails_real.count>1) {
            fromlabel2.text = [[emails_real objectAtIndex:1] objectForKey:@"from"];
            datelabel2.text = [[emails_real objectAtIndex:1] objectForKey:@"date"];
            subjectlabel2.text = [[emails_real objectAtIndex:1] objectForKey:@"subject"];
            bodylabel2.text = [[emails_real objectAtIndex:1] objectForKey:@"body"];
            line.frame = CGRectMake(0,0,11,239);
        } else {
            fromlabel2.text = @"";
            datelabel2.text = @"";
            subjectlabel2.text = @"";
            bodylabel2.text = @"";
            line.frame = CGRectMake(0,0,11,119);
        }
        
        cell.delegate = self;
        return cell;
        
    } else if ([[feedarray objectAtIndex:indexPath.row] intValue] == 7) {
        
        int importanttweetnumber = [[article_number_at objectAtIndex:indexPath.row] intValue];
        
        //Twitter
        HHPanningTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TwitterCell" forIndexPath:indexPath];
        cell.directionMask = HHPanningTableViewCellDirectionRight;
        UITextView *drawerView = [[UITextView alloc] initWithFrame:cell.frame];
        drawerView.editable = FALSE;
        drawerView.text = @"";
        drawerView.textColor = [UIColor whiteColor];
        drawerView.backgroundColor = [UIColor blackColor];
        cell.drawerView = drawerView;
        
        UIImageView *twitterview = (UIImageView *)[cell viewWithTag:3];
        UILabel *field1 = (UILabel *)[cell viewWithTag:1];
        UILabel *field2 = (UILabel *)[cell viewWithTag:2];
        UITextView *twitterlabel = (UITextView *)[cell viewWithTag:4];
        field1.text = [[importanttwitter_feed objectAtIndex:importanttweetnumber] objectForKey:@"realname"];
        field2.text = [@"@" stringByAppendingString:[[importanttwitter_feed objectAtIndex:importanttweetnumber] objectForKey:@"username"]];
        twitterview.image = [[importanttwitter_feed objectAtIndex:importanttweetnumber] objectForKey:@"image"];;
        twitterlabel.text = [[importanttwitter_feed objectAtIndex:importanttweetnumber] objectForKey:@"content"];;
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
        twitterlabel.font = font;
        
        cell.delegate = self;
        return cell;
        
    } else if ([[feedarray objectAtIndex:indexPath.row] intValue] == 8) {
        
        int facebooknumber = [[article_number_at objectAtIndex:indexPath.row] intValue];
        HHPanningTableViewCell *cell;
        
        if ([[important_facebook_feed objectAtIndex:facebooknumber] objectForKey:@"type"] != nil) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"FacebookPhotoCell" forIndexPath:indexPath];
            cell.directionMask = HHPanningTableViewCellDirectionRight;
            UITextView *drawerView = [[UITextView alloc] initWithFrame:cell.frame];
            drawerView.editable = FALSE;
            drawerView.text = @"";
            drawerView.textColor = [UIColor whiteColor];
            drawerView.backgroundColor = [UIColor blackColor];
            cell.drawerView = drawerView;
            
            UIImageView *thefacebookphoto = (UIImageView *)[cell viewWithTag:6];
            thefacebookphoto.image = [[important_facebook_feed objectAtIndex:facebooknumber] objectForKey:@"photo_image"];
            
            UILabel *facebooklabel = (UILabel *)[cell viewWithTag:4];
            facebooklabel.text = [[important_facebook_feed objectAtIndex:facebooknumber] objectForKey:@"photo_album"];
            if ([[important_facebook_feed objectAtIndex:facebooknumber] objectForKey:@"status"] != nil) {
                facebooklabel.text = [[important_facebook_feed objectAtIndex:facebooknumber] objectForKey:@"status"];
            }
            
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"FacebookCell" forIndexPath:indexPath];
            cell.directionMask = HHPanningTableViewCellDirectionRight;
            UITextView *drawerView = [[UITextView alloc] initWithFrame:cell.frame];
            drawerView.editable = FALSE;
            drawerView.text = @"";
            drawerView.textColor = [UIColor whiteColor];
            drawerView.backgroundColor = [UIColor blackColor];
            cell.drawerView = drawerView;
            
            UITextView *facebooklabel = (UITextView *)[cell viewWithTag:4];
            facebooklabel.text = [[important_facebook_feed objectAtIndex:facebooknumber] objectForKey:@"status"];
            UIFont *font = [UIFont systemFontOfSize:16];
            facebooklabel.font = font;
        }
        
        //Name
        UILabel *field1 = (UILabel *)[cell viewWithTag:1];
        field1.text = [[important_facebook_feed objectAtIndex:facebooknumber] objectForKey:@"name"];
        
        //Time Published
        UILabel *field2 = (UILabel *)[cell viewWithTag:2];
        
        //Profile Pic
        UIImageView *facebookview = (UIImageView *)[cell viewWithTag:3];
        facebookview.image = [[important_facebook_feed objectAtIndex:facebooknumber] objectForKey:@"image"];
        
        //Likes and Comments
        UILabel *likecomments = (UILabel *)[cell viewWithTag:5];
        NSString *popular;
        int likes = [[[important_facebook_feed objectAtIndex:facebooknumber] objectForKey:@"likes"] intValue];
        int comments = [[[important_facebook_feed objectAtIndex:facebooknumber] objectForKey:@"comments"] intValue];
        popular = [NSString stringWithFormat:@"%i Likes     ",likes];
        if (likes == 1) {
            popular = @"1 Like     ";
        }
        if (likes == 0) {
            popular = @"";
        }
        if (comments > 1) {
            NSString *commentary = [NSString stringWithFormat:@"%i Comments",comments];
            popular = [popular stringByAppendingString:commentary];
        }
        if (comments == 1) {
            NSString *commentary = @"1 Comment";
            popular = [popular stringByAppendingString:commentary];
        }
        likecomments.text = popular;
        
        cell.delegate = self;
        return cell;
        
    } else if ([[feedarray objectAtIndex:indexPath.row] intValue] == 10) {
        
        if ([[article_type objectAtIndex:[[article_number_at objectAtIndex:indexPath.row] intValue]] intValue] == -1) {
            //Twitter
            HHPanningTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TwitterCell" forIndexPath:indexPath];
            cell.directionMask = HHPanningTableViewCellDirectionRight;
            UITextView *drawerView = [[UITextView alloc] initWithFrame:cell.frame];
            drawerView.editable = FALSE;
            drawerView.text = @"";
            drawerView.textColor = [UIColor whiteColor];
            drawerView.backgroundColor = [UIColor whiteColor];
            cell.drawerView = drawerView;
            
            UIImageView *twitterview = (UIImageView *)[cell viewWithTag:3];
            UILabel *field1 = (UILabel *)[cell viewWithTag:1];
            UILabel *field2 = (UILabel *)[cell viewWithTag:2];
            UITextView *twitterlabel = (UITextView *)[cell viewWithTag:4];
            int tweetnumber = [[article_index objectAtIndex:[[article_number_at objectAtIndex:indexPath.row] intValue]] intValue];
            field1.text = [[twitter_feed objectAtIndex:tweetnumber] objectForKey:@"realname"];
            field2.text = [@"@" stringByAppendingString:[[twitter_feed objectAtIndex:tweetnumber] objectForKey:@"username"]];
            twitterview.image = [[twitter_feed objectAtIndex:tweetnumber] objectForKey:@"image"];
            twitterlabel.text = [[twitter_feed objectAtIndex:tweetnumber] objectForKey:@"content"];
            UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
            twitterlabel.font = font;
            
            cell.delegate = self;
            return cell;
        } else if ([[article_type objectAtIndex:[[article_number_at objectAtIndex:indexPath.row] intValue]] intValue] == -2) {
            //Facebook
            int facebooknumber = [[article_index objectAtIndex:[[article_number_at objectAtIndex:indexPath.row] intValue]] intValue];
            HHPanningTableViewCell *cell;
            
            if ([[facebook_feed objectAtIndex:facebooknumber] objectForKey:@"type"] != nil) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"FacebookPhotoCell" forIndexPath:indexPath];
                cell.directionMask = HHPanningTableViewCellDirectionRight;
                UITextView *drawerView = [[UITextView alloc] initWithFrame:cell.frame];
                drawerView.editable = FALSE;
                drawerView.text = @"";
                drawerView.textColor = [UIColor whiteColor];
                drawerView.backgroundColor = [UIColor whiteColor];
                cell.drawerView = drawerView;
                
                UIImageView *thefacebookphoto = (UIImageView *)[cell viewWithTag:6];
                thefacebookphoto.image = [[facebook_feed objectAtIndex:facebooknumber] objectForKey:@"photo_image"];
                
                UILabel *facebooklabel = (UILabel *)[cell viewWithTag:4];
                facebooklabel.text = [[facebook_feed objectAtIndex:facebooknumber] objectForKey:@"photo_album"];
                if ([[facebook_feed objectAtIndex:facebooknumber] objectForKey:@"status"] != nil) {
                    facebooklabel.text = [[facebook_feed objectAtIndex:facebooknumber] objectForKey:@"status"];
                }
                
            } else {
                cell = [tableView dequeueReusableCellWithIdentifier:@"FacebookCell" forIndexPath:indexPath];
                cell.directionMask = HHPanningTableViewCellDirectionRight;
                UITextView *drawerView = [[UITextView alloc] initWithFrame:cell.frame];
                drawerView.editable = FALSE;
                drawerView.text = @"";
                drawerView.textColor = [UIColor whiteColor];
                drawerView.backgroundColor = [UIColor whiteColor];
                cell.drawerView = drawerView;
            
                UITextView *facebooklabel = (UITextView *)[cell viewWithTag:4];
                facebooklabel.text = [[facebook_feed objectAtIndex:facebooknumber] objectForKey:@"status"];
                UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
                facebooklabel.font = font;
            }
            
            //Name
            UILabel *field1 = (UILabel *)[cell viewWithTag:1];
            field1.text = [[facebook_feed objectAtIndex:facebooknumber] objectForKey:@"name"];
            
            //Time Published
            UILabel *field2 = (UILabel *)[cell viewWithTag:2];
            
            //Profile Pic
            UIImageView *facebookview = (UIImageView *)[cell viewWithTag:3];
            facebookview.image = [[facebook_feed objectAtIndex:facebooknumber] objectForKey:@"image"];
            
            //Likes and Comments
            UILabel *likecomments = (UILabel *)[cell viewWithTag:5];
            NSString *popular;
            int likes = [[[facebook_feed objectAtIndex:facebooknumber] objectForKey:@"likes"] intValue];
            int comments = [[[facebook_feed objectAtIndex:facebooknumber] objectForKey:@"comments"] intValue];
            popular = [NSString stringWithFormat:@"%i Likes     ",likes];
            if (likes == 1) {
                popular = @"1 Like     ";
            }
            if (likes == 0) {
                popular = @"";
            }
            if (comments > 1) {
                NSString *commentary = [NSString stringWithFormat:@"%i Comments",comments];
                popular = [popular stringByAppendingString:commentary];
            }
            if (comments == 1) {
                NSString *commentary = @"1 Comment";
                popular = [popular stringByAppendingString:commentary];
            }
            likecomments.text = popular;
            
            cell.delegate = self;
            return cell;
        } else  {
            //News Story
            //if ([[article_type objectAtIndex:[[article_number_at objectAtIndex:indexPath.row] intValue]] intValue] >= 0 )
            HHPanningTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
            cell.directionMask = HHPanningTableViewCellDirectionRight;
            UITextView *drawerView = [[UITextView alloc] initWithFrame:cell.frame];
            drawerView.editable = FALSE;
            drawerView.text = @"";
            drawerView.textColor = [UIColor whiteColor];
            drawerView.backgroundColor = [UIColor whiteColor];
            cell.drawerView = drawerView;
            
            UILabel *storytitle = (UILabel *)[cell viewWithTag:11];
            UITextView *storytext = (UITextView *)[cell viewWithTag:12];
            UILabel *storysource = (UILabel *)[cell viewWithTag:14];
            UIImageView *storyimage = (UIImageView *)[cell viewWithTag:10];
            
            int articleNumber = [[article_type objectAtIndex:[[article_number_at objectAtIndex:indexPath.row] intValue]] intValue];
            NSMutableDictionary *currentArticle = [[rssfeed_array objectAtIndex:articleNumber] objectAtIndex:[[article_index objectAtIndex:[[article_number_at objectAtIndex:indexPath.row] intValue]] intValue]];
            
            storytitle.numberOfLines = 2;
            //[storytitle setFrame:CGRectMake(32, 41, 268, 41)];
            storytitle.text = [currentArticle objectForKey:@"title"];
            CGSize sized = [storytitle.text sizeWithFont:storytitle.font
                                       constrainedToSize:storytitle.frame.size
                                           lineBreakMode:UILineBreakModeWordWrap];
            
            /*if (sized.height<25) {
                storytitle.numberOfLines = 1;
                [storytitle setFrame:CGRectMake(32, 41, 268, 21)];
            }*/
            
            if ([currentArticle objectForKey:@"image"] == nil) {
                storyimage.image = nil;
                [storytext setFrame:CGRectMake(21, 77, 291, 109)];
            } else {
                storyimage.image = [currentArticle objectForKey:@"image"];
                [storytext setFrame:CGRectMake(21, 77, 176, 109)];
            }
            
            //NSLog(@"The size is %f", sized.height);

            storytext.text = [currentArticle objectForKey:@"description"];
            [storytext setContentOffset:CGPointZero animated:NO];
            storysource.text = [currentArticle objectForKey:@"source"];
            
            //storytext.text = @"And in a stunning move today, Apple and Microsoft announced that their two companies were going to merge into one.";
            
            storytext.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
            
            cell.delegate = self;
            return cell;
        }
    } else if ([[feedarray objectAtIndex:indexPath.row] intValue] == 11) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MoreCell" forIndexPath:indexPath];
        return cell;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BlankCell" forIndexPath:indexPath];
    return cell;
}

- (void)panningTableViewCell:(HHPanningTableViewCell *)cell didTriggerWithDirection:(HHPanningTableViewCellDirection)direction
{
    /*self.shareObject = [[NSMutableDictionary alloc] init];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self.shareObject setObject:[NSNumber numberWithInt:[[feedarray objectAtIndex:indexPath.row] intValue]] forKey:@"type" ];
    if ([[self.shareObject objectForKey:@"type"] intValue] == 10) {
        if ([[article_type objectAtIndex:[[article_number_at objectAtIndex:indexPath.row] intValue]] intValue] == -2) {
            [self.shareObject setObject:[NSNumber numberWithInt:8] forKey:@"type"];
        }
        if ([[article_type objectAtIndex:[[article_number_at objectAtIndex:indexPath.row] intValue]] intValue] == -1) {
            [self.shareObject setObject:[NSNumber numberWithInt:7] forKey:@"type"];
        }
    }
    
    if ([[self.shareObject objectForKey:@"type"] intValue] == 1) {
        [self.shareObject setObject:[NSNumber numberWithInt:calendar_eventscount] forKey:@"count"];
        
        if (calendar_eventscount>0) {
            [self.shareObject setObject:calendar_startTime1 forKey:@"time1"];
            [self.shareObject setObject:calendar_eventName1 forKey:@"event1"];
        } else if (calendar_eventscount>1) {
            [self.shareObject setObject:calendar_startTime2 forKey:@"time2"];
            [self.shareObject setObject:calendar_eventName2 forKey:@"event2"];
        } else if (calendar_eventscount>2) {
            [self.shareObject setObject:calendar_startTime3 forKey:@"time3"];
            [self.shareObject setObject:calendar_eventName3 forKey:@"event3"];
        } else if (calendar_eventscount>3) {
            [self.shareObject setObject:calendar_startTime4 forKey:@"time4"];
            [self.shareObject setObject:calendar_eventName4 forKey:@"event4"];
        }
    }
    if ([[self.shareObject objectForKey:@"type"] intValue] == 2) {
        [self.shareObject setObject:[NSNumber numberWithInt:reminders_taskscount] forKey:@"count"];
        if (reminders_taskscount>0) {
            [self.shareObject setObject:reminders_taskName1 forKey:@"task1"];
        }
        if (reminders_taskscount>1) {
            [self.shareObject setObject:reminders_taskName2 forKey:@"task2"];
        }
        if (reminders_taskscount>2) {
            [self.shareObject setObject:reminders_taskName3 forKey:@"task3"];
        }
        if (reminders_taskscount>3) {
            [self.shareObject setObject:reminders_taskName4 forKey:@"task4"];
        }
    }
    if ([[self.shareObject objectForKey:@"type"] intValue] == 3) {
        [self.shareObject setObject:weather_city forKey:@"weather_city"];
        [self.shareObject setObject:weather_description forKey:@"weather_description"];
        [self.shareObject setObject:weather_temperature forKey:@"weather_temperature"];
        [self.shareObject setObject:weather_icon[0] forKey:@"weather_icon0"];
        [self.shareObject setObject:weather_icon[1] forKey:@"weather_icon1"];
        [self.shareObject setObject:weather_icon[2] forKey:@"weather_icon2"];
        [self.shareObject setObject:weather_icon[3] forKey:@"weather_icon3"];
        [self.shareObject setObject:weather_icon[4] forKey:@"weather_icon4"];
        [self.shareObject setObject:weather_icon[5] forKey:@"weather_icon5"];
    }
    if ([[self.shareObject objectForKey:@"type"] intValue] == 5) {
        [self.shareObject setObject:photodate forKey:@"photo_date"];
        [self.shareObject setObject:photolocation forKey:@"photo_location"];
        [self.shareObject setObject:myphoto forKey:@"photo"];
    }
    if ([[self.shareObject objectForKey:@"type"] intValue] == 7) {
        int tweetnumber = [[article_index objectAtIndex:[[article_number_at objectAtIndex:indexPath.row] intValue]] intValue];
        if (twitter_feed.count>(articlesneeded/2)) {
            [self.shareObject setObject:[[twitter_feed objectAtIndex:tweetnumber] objectForKey:@"realname"] forKey:@"twitter_realname"];
            [self.shareObject setObject:[@"@" stringByAppendingString:[[twitter_feed objectAtIndex:tweetnumber] objectForKey:@"username"]] forKey:@"twitter_username"];
            [self.shareObject setObject:[[twitter_feed objectAtIndex:tweetnumber] objectForKey:@"image"] forKey:@"twitter_image"];
            [self.shareObject setObject:[[twitter_feed objectAtIndex:tweetnumber] objectForKey:@"content"] forKey:@"twitter_content"];
        }
    }
    if ([[self.shareObject objectForKey:@"type"] intValue] == 10) {
        int temparticletype = [[article_type objectAtIndex:[[article_number_at objectAtIndex:indexPath.row] intValue]] intValue];

        if ([[[rssfeed_array objectAtIndex:temparticletype] objectAtIndex:[[article_index objectAtIndex:[[article_number_at objectAtIndex:indexPath.row] intValue]] intValue]] objectForKey:@"image"] != nil) {
            [self.shareObject setObject:[[[rssfeed_array objectAtIndex:temparticletype] objectAtIndex:[[article_index objectAtIndex:[[article_number_at objectAtIndex:indexPath.row] intValue]] intValue]] objectForKey:@"image"] forKey:@"news_image"];
        }
        [self.shareObject setObject:[[[rssfeed_array objectAtIndex:temparticletype] objectAtIndex:[[article_index objectAtIndex:[[article_number_at objectAtIndex:indexPath.row] intValue]] intValue]] objectForKey:@"title"] forKey:@"news_title"];
        [self.shareObject setObject:[[[rssfeed_array objectAtIndex:temparticletype] objectAtIndex:[[article_index objectAtIndex:[[article_number_at objectAtIndex:indexPath.row] intValue]] intValue]] objectForKey:@"description"] forKey:@"news_description"];
        [self.shareObject setObject:[[[rssfeed_array objectAtIndex:temparticletype] objectAtIndex:[[article_index objectAtIndex:[[article_number_at objectAtIndex:indexPath.row] intValue]] intValue]] objectForKey:@"source"] forKey:@"news_source"];
    }
    [self performSegueWithIdentifier:@"shareSegway" sender:self.shareObject];*/
    //tempcell = cell;
    //if (tempcell != nil) {
        [cell setDrawerRevealed:FALSE animated:TRUE];
        //tempcell = nil;
    //}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[feedarray objectAtIndex:indexPath.row] intValue] == 0) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else if ([[feedarray objectAtIndex:indexPath.row] intValue] == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"calshow://"]];
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"module_open"     // Event category (required)
                                                              action:@"calendar_open"  // Event action (required)
                                                               label:nil          // Event label
                                                               value:nil] build]];    // Event value
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else if ([[feedarray objectAtIndex:indexPath.row] intValue] == 2) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"x-apple-reminder://"]];
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"module_open"     // Event category (required)
                                                              action:@"reminders_open"  // Event action (required)
                                                               label:nil          // Event label
                                                               value:nil] build]];    // Event value
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else if ([[feedarray objectAtIndex:indexPath.row] intValue] == 3) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.google.com/search?q=weather"]];
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"module_open"     // Event category (required)
                                                              action:@"weather_open"  // Event action (required)
                                                               label:nil          // Event label
                                                               value:nil] build]];    // Event value
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else if ([[feedarray objectAtIndex:indexPath.row] intValue] == 5) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"photos-redirect://"]];
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"module_open"     // Event category (required)
                                                              action:@"photos_open"  // Event action (required)
                                                               label:nil          // Event label
                                                               value:nil] build]];    // Event value
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else if ([[feedarray objectAtIndex:indexPath.row] intValue] == 6) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"message://"]];
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"module_open"     // Event category (required)
                                                              action:@"email_open"  // Event action (required)
                                                               label:nil          // Event label
                                                               value:nil] build]];    // Event value
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - Reload
- (void)startReload
{
    NSLog(@"Starting to Load");
    
    [self addLoadbar];
    
    BOOL needReload = FALSE;
    loadingStatus = TRUE;
    
    progress_total_to_load = 0;
    progress_loaded = 0;
    
    reloading_done = [[NSMutableDictionary alloc] init];
    if ([[self.dataModel.choices objectForKey:@"calendar"] boolValue] == TRUE) {
        [reloading_done setObject:[NSNumber numberWithBool:FALSE] forKey:@"calendar"];
        [self updateCalendar];
        progress_total_to_load++;
    }
    if ([[self.dataModel.choices objectForKey:@"reminders"] boolValue] == TRUE) {
        [reloading_done setObject:[NSNumber numberWithBool:FALSE] forKey:@"reminders"];
        [self updateReminders];
        progress_total_to_load++;
    }
    if ([[self.dataModel.choices objectForKey:@"twitter"] boolValue] == TRUE) {
        [reloading_done setObject:[NSNumber numberWithBool:FALSE] forKey:@"twitter"];
        [reloading_done setObject:[NSNumber numberWithBool:FALSE] forKey:@"importanttwitter"];
        [self getTwitterInfo];
        [self getImportantTwitterInfo];
        progress_total_to_load++;
        progress_total_to_load++;
    }
    if ([[self.dataModel.choices objectForKey:@"facebook"] boolValue] == TRUE) {
        [reloading_done setObject:[NSNumber numberWithBool:FALSE] forKey:@"facebook"];
        [reloading_done setObject:[NSNumber numberWithBool:FALSE] forKey:@"importantfacebook"];
        [self getFacebookInfo];
        progress_total_to_load++;
        progress_total_to_load++;
    }
    if ([[self.dataModel.choices objectForKey:@"weather"] boolValue] == TRUE) {
        weatherupdating = FALSE;
        [reloading_done setObject:[NSNumber numberWithBool:FALSE] forKey:@"weathernow"];
        [reloading_done setObject:[NSNumber numberWithBool:FALSE] forKey:@"weatherfuture"];
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer; // 1 km
        [locationManager startUpdatingLocation];
        progress_total_to_load++;
        progress_total_to_load++;
    }
    if ([[self.dataModel.choices objectForKey:@"photos"] boolValue] == TRUE) {
        [reloading_done setObject:[NSNumber numberWithBool:FALSE] forKey:@"photos"];
        [self updatePhotos];
        progress_total_to_load++;
        progress_total_to_load++;
    }
    if ([[self.dataModel.choices objectForKey:@"mail"] boolValue] == TRUE) {
        [reloading_done setObject:[NSNumber numberWithBool:FALSE] forKey:@"mail"];
        [self getMailInfo];
        progress_total_to_load++;
    }
    
    [self determineChosen];
    NSLog(@"Total types: %d",total_types);
    int theArticleCount = self.dataModel.source_list.count;
    if (theArticleCount>0) {
        parse_on = TRUE;
    } else {
        parse_on = FALSE;
    }
    if (parse_on == TRUE) {
        progress_total_to_load = progress_total_to_load+theArticleCount;
        parse_done = FALSE;
        if (parsers == nil) {
            parsers = [[NSMutableArray alloc] init];
        }
        if (temp_feeds == nil) {
            temp_feeds = [[NSMutableArray alloc] init];
        }
        [parsers removeAllObjects];
        [temp_feeds removeAllObjects];
        epiccount = 0;
        dispatch_async(myQueue, ^{
            [self getArticleInfo];
        });
    }
    
    if (progress_total_to_load == 0) {
        [self endReload];
    }
    
    nst = [NSTimer timerWithTimeInterval:60 target:self selector:@selector(reloadTimeOut) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:nst forMode:NSDefaultRunLoopMode];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    [locationManager stopUpdatingLocation];
    if (weatherupdating == FALSE) {
        weatherupdating = TRUE;
        self.dataModel.locationed = newLocation.coordinate;
        NSLog(@"Updated Location");
        [self updateWeather];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Weather Error" message:@"We could not find your location to update the weather. Please ensure that you have location settings enabled." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
    [self updateWeather];
    [locationManager stopUpdatingLocation];
}

- (void)reloadTimeOut
{
    if (loadingStatus) {
        loadingStatus = FALSE;
        NSLog(@"Reloading Timeout");
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"reloading"     // Event category (required)
                                                              action:@"time_out"  // Event action (required)
                                                               label:nil          // Event label
                                                               value:nil] build]];    // Event value
        //[self unTemp];
        //[self makeFeed];
        //moduleamount = temp_moduleamount;
        //NSLog(@"The amount of modules is: %d", moduleamount);
        //dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //    [self destroyAllParsers];
        //});
        //[self nuke];
        //updateTime = [NSDate date];
        //[self.tableView reloadData];
        [self.refreshControl endRefreshing];
        
        NSLog(@"Removing loadbar");
        //Remove Loadbar
        [theProgress setProgress:0.01 animated:NO];
        progress = 0.01;
        [feedarray removeObjectAtIndex:0];
        [article_number_at removeObjectAtIndex:0];
        moduleamount--;
        
        self.dataModel.initialrun = [NSNumber numberWithBool:FALSE];
        NSLog(@"If view is unpopulated, add a message");
        if (firstrun) {
            [feedarray addObject:[NSNumber numberWithInt:98]];
            [feedarray addObject:[NSNumber numberWithInt:11]];
            moduleamount = 2;
        }
        
        dispatch_async(myQueue, ^{
            [self destroyAllParsers];
        });
        
        NSLog(@"Nuke and reload data");
        [self nuke];
        [self.tableView reloadData];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reloading Time Out"
                                                        message:@"Please check your internet connection and try again. Or you may have entered an incorrect mail account. We don't know lol. But that's why this is the Beta!"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)endReload
{
    if (loadingStatus) {
    BOOL doneReloading = TRUE;
    progress_loaded++;
    
    if ([[self.dataModel.choices objectForKey:@"calendar"] boolValue] == TRUE
        && [[reloading_done objectForKey:@"calendar"] boolValue] == FALSE) {
        doneReloading = FALSE;
    }
    if ([[self.dataModel.choices objectForKey:@"reminders"] boolValue] == TRUE
        && [[reloading_done objectForKey:@"reminders"] boolValue] == FALSE) {
        doneReloading = FALSE;
    }
    if ([[self.dataModel.choices objectForKey:@"twitter"] boolValue] == TRUE
        && [[reloading_done objectForKey:@"importanttwitter"] boolValue] == FALSE) {
        doneReloading = FALSE;
    }
    if ([[self.dataModel.choices objectForKey:@"twitter"] boolValue] == TRUE
        && [[reloading_done objectForKey:@"twitter"] boolValue] == FALSE) {
        doneReloading = FALSE;
    }
    if ([[self.dataModel.choices objectForKey:@"facebook"] boolValue] == TRUE
        && [[reloading_done objectForKey:@"facebook"] boolValue] == FALSE) {
        doneReloading = FALSE;
    }
    if ([[self.dataModel.choices objectForKey:@"importantfacebook"] boolValue] == TRUE
        && [[reloading_done objectForKey:@"importantfacebook"] boolValue] == FALSE) {
        doneReloading = FALSE;
    }
    if ([[self.dataModel.choices objectForKey:@"weather"] boolValue] == TRUE
        && [[reloading_done objectForKey:@"weathernow"] boolValue] == FALSE) {
        doneReloading = FALSE;
    }
    if ([[self.dataModel.choices objectForKey:@"weather"] boolValue] == TRUE
        && [[reloading_done objectForKey:@"weatherfuture"] boolValue] == FALSE) {
        doneReloading = FALSE;
    }
    if ([[self.dataModel.choices objectForKey:@"photos"] boolValue] == TRUE
        && [[reloading_done objectForKey:@"photos"] boolValue] == FALSE) {
        doneReloading = FALSE;
    }
    if ([[self.dataModel.choices objectForKey:@"mail"] boolValue] == TRUE
        && [[reloading_done objectForKey:@"mail"] boolValue] == FALSE) {
        doneReloading = FALSE;
    }
    if (parse_on == TRUE
        && parse_done == FALSE) {
        doneReloading = FALSE;
    }
    
    if (doneReloading) {
        loadingStatus = FALSE;
        NSLog(@"Done loading");
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"reloading"     // Event category (required)
                                                              action:@"success"  // Event action (required)
                                                               label:nil          // Event label
                                                               value:nil] build]];    // Event value
        [nst invalidate];
        firstrun = FALSE;
        [self unTemp];
        [self makeFeed];
        moduleamount = temp_moduleamount;
        NSLog(@"The amount of modules is: %d", moduleamount);
        [theProgress setProgress:0.01 animated:NO];
        [self nuke];
        updateTime = [NSDate date];
        self.dataModel.initialrun = [NSNumber numberWithBool:FALSE];
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    } else {
        if (progress_total_to_load>0) {
            progress = ((float)progress_loaded)/((float)progress_total_to_load);
            NSLog(@"Progress loaded: %d", progress_loaded);
            NSLog(@"Progress total: %d", progress_total_to_load);
            NSLog(@"Progress: %f", progress);
            theProgress.progress = progress;
            //NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:0 inSection:0];
            //NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
            //[self.tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    }
}

- (void)unTemp
{
    if ([[self.dataModel.choices objectForKey:@"twitter"] boolValue] == TRUE) {
        twitter_feed = [[NSMutableArray alloc] initWithArray:temp_twitter_feed];
    }
    if ([[self.dataModel.choices objectForKey:@"facebook"] boolValue] == TRUE) {
        facebook_feed = [[NSMutableArray alloc] initWithArray:temp_facebook_feed];
        important_facebook_feed = [[NSMutableArray alloc] initWithArray:temp_important_facebook_feed];
        NSLog(@"Facebook Feed Started");
    }
    if ([[self.dataModel.choices objectForKey:@"mail"] boolValue] == TRUE) {
        emails_real = emails;
    }
    if ([[self.dataModel.choices objectForKey:@"calendar"] boolValue] == TRUE) {
        calendar_startTime1 = calendar_temp_startTime[0];
        calendar_startTime2 = calendar_temp_startTime[1];
        calendar_startTime3 = calendar_temp_startTime[2];
        calendar_startTime4 = calendar_temp_startTime[3];
        calendar_eventName1 = calendar_temp_eventName[0];
        calendar_eventName2 = calendar_temp_eventName[1];
        calendar_eventName3 = calendar_temp_eventName[2];
        calendar_eventName4 = calendar_temp_eventName[3];
        calendar_eventscount = calendar_temp_eventscount;
    }
    if ([[self.dataModel.choices objectForKey:@"reminders"] boolValue] == TRUE) {
        reminders_taskName1 = reminders_temp_taskName[0];
        reminders_taskName2 = reminders_temp_taskName[1];
        reminders_taskName3 = reminders_temp_taskName[2];
        reminders_taskName4 = reminders_temp_taskName[3];
        reminders_taskscount = reminders_temp_taskscount;
        
    }
    if (self.dataModel.source_list.count>0) {
        rssfeed_array = [[NSMutableArray alloc] initWithArray:temp_feeds];
    }
}

#pragma mark - Determining Priority

- (void)addLoadbar
{
    NSLog(@"Adding Loadbar");
    if (feedarray == nil) {
        feedarray = [[NSMutableArray alloc] init];
        article_number_at = [[NSMutableArray alloc] init];
    }
    [feedarray insertObject:[NSNumber numberWithInt:99] atIndex:0];
    [article_number_at insertObject:[NSNumber numberWithInt:0] atIndex:0];
    moduleamount++;
    progress = 0.01;
    [self nuke];
    [self.tableView reloadData];
}

- (void)makeFeed
{
    NSLog(@"Make feed");
    BOOL choicesused[20];
    
    BOOL picked;
    for (int index = 0; index<20; index++) {
        choicesused[index] = FALSE;
    }
    choicesused[18] = TRUE;
    
    feedarray = [[NSMutableArray alloc] init];
    article_number_at = [[NSMutableArray alloc] init];
    articlesneeded = 0;
    temp_moduleamount = 0;
    int index = 0;
    
    [self makeSourceFeed];
    int source_total_amount = temp_moduleamount;
    
    while (articlesneeded<=source_total_amount) {
        picked = FALSE;

        //Populate feed with one of each widget that should show up
        if ([[self.dataModel.choices objectForKey:@"time"] boolValue] == TRUE && choicesused[0] == FALSE) {
            [feedarray insertObject:[NSNumber numberWithInt:0] atIndex:index];
            [article_number_at insertObject:[NSNumber numberWithInt:0] atIndex:index];
            choicesused[0] = TRUE;
            temp_moduleamount++;
        } else if ([[self.dataModel.choices objectForKey:@"help"] boolValue] == TRUE && choicesused[19] == FALSE) {
            [feedarray insertObject:[NSNumber numberWithInt:98] atIndex:index];
            [article_number_at insertObject:[NSNumber numberWithInt:0] atIndex:index];
            choicesused[19] = TRUE;
            temp_moduleamount++;
        } else if ([[self.dataModel.choices objectForKey:@"calendar"] boolValue] == TRUE && choicesused[1] == FALSE && calendar_eventscount>0) {
            [feedarray insertObject:[NSNumber numberWithInt:1] atIndex:index];
            [article_number_at insertObject:[NSNumber numberWithInt:0] atIndex:index];
            choicesused[1] = TRUE;
            temp_moduleamount++;
        } else if ([[self.dataModel.choices objectForKey:@"reminders"] boolValue] == TRUE && choicesused[2] == FALSE && reminders_taskscount>0) {
            [feedarray insertObject:[NSNumber numberWithInt:2] atIndex:index];
            [article_number_at insertObject:[NSNumber numberWithInt:0] atIndex:index];
            choicesused[2] = TRUE;
            temp_moduleamount++;
        } else if ([[self.dataModel.choices objectForKey:@"facebook"] boolValue] == TRUE && choicesused[3] == FALSE && temp_important_facebook_feed.count>0) {
            [feedarray insertObject:[NSNumber numberWithInt:8] atIndex:index];
            [article_number_at insertObject:[NSNumber numberWithInt:0] atIndex:index];
            choicesused[3] = TRUE;
            temp_moduleamount++;
        } else if ([[self.dataModel.choices objectForKey:@"facebook"] boolValue] == TRUE && choicesused[4] == FALSE && temp_important_facebook_feed.count>1) {
            [feedarray insertObject:[NSNumber numberWithInt:8] atIndex:index];
            [article_number_at insertObject:[NSNumber numberWithInt:1] atIndex:index];
            choicesused[4] = TRUE;
            temp_moduleamount++;
        } else if ([[self.dataModel.choices objectForKey:@"facebook"] boolValue] == TRUE && choicesused[5] == FALSE && temp_important_facebook_feed.count>2) {
            [feedarray insertObject:[NSNumber numberWithInt:8] atIndex:index];
            [article_number_at insertObject:[NSNumber numberWithInt:2] atIndex:index];
            choicesused[5] = TRUE;
            temp_moduleamount++;
        } else if ([[self.dataModel.choices objectForKey:@"mail"] boolValue] == TRUE && choicesused[6] == FALSE && emails_real.count>0) {
            [feedarray insertObject:[NSNumber numberWithInt:6] atIndex:index];
            [article_number_at insertObject:[NSNumber numberWithInt:0] atIndex:index];
            choicesused[6] = TRUE;
            temp_moduleamount++;
        } else if ([[self.dataModel.choices objectForKey:@"twitter"] boolValue] == TRUE && choicesused[7] == FALSE && importanttwitter_amount>0) {
            [feedarray insertObject:[NSNumber numberWithInt:7] atIndex:index];
            [article_number_at insertObject:[NSNumber numberWithInt:0] atIndex:index];
            choicesused[7] = TRUE;
            temp_moduleamount++;
        } else if ([[self.dataModel.choices objectForKey:@"twitter"] boolValue] == TRUE && choicesused[8] == FALSE && importanttwitter_amount>1) {
            [feedarray insertObject:[NSNumber numberWithInt:7] atIndex:index];
            [article_number_at insertObject:[NSNumber numberWithInt:1] atIndex:index];
            choicesused[8] = TRUE;
            temp_moduleamount++;
        } else if ([[self.dataModel.choices objectForKey:@"twitter"] boolValue] == TRUE && choicesused[9] == FALSE && importanttwitter_amount>2) {
            [feedarray insertObject:[NSNumber numberWithInt:7] atIndex:index];
            [article_number_at insertObject:[NSNumber numberWithInt:2] atIndex:index];
            choicesused[9] = TRUE;
            temp_moduleamount++;
        } else if ([[self.dataModel.choices objectForKey:@"weather"] boolValue] == TRUE && choicesused[11] == FALSE) {
            [feedarray insertObject:[NSNumber numberWithInt:3] atIndex:index];
            [article_number_at insertObject:[NSNumber numberWithInt:0] atIndex:index];
            choicesused[11] = TRUE;
            temp_moduleamount++;
        } else if (total_types>0 && choicesused[10] == FALSE) {
            [feedarray insertObject:[NSNumber numberWithInt:10] atIndex:index];
            [article_number_at insertObject:[NSNumber numberWithInt:articlesneeded] atIndex:index];
            articlesneeded++;
            choicesused[10] = TRUE;
        } else if (total_types>1 && choicesused[12] == FALSE) {
            [feedarray insertObject:[NSNumber numberWithInt:10] atIndex:index];
            [article_number_at insertObject:[NSNumber numberWithInt:articlesneeded] atIndex:index];
            articlesneeded++;
            choicesused[12] = TRUE;
        } else if (total_types>2 && choicesused[13] == FALSE) {
            [feedarray insertObject:[NSNumber numberWithInt:10] atIndex:index];
            [article_number_at insertObject:[NSNumber numberWithInt:articlesneeded] atIndex:index];
            articlesneeded++;
            choicesused[13] = TRUE;
        } else if ([[self.dataModel.choices objectForKey:@"stocks"] boolValue] == TRUE && choicesused[14] == FALSE) {
            [feedarray insertObject:[NSNumber numberWithInt:4] atIndex:index];
            [article_number_at insertObject:[NSNumber numberWithInt:0] atIndex:index];
            choicesused[14] = TRUE;
            temp_moduleamount++;
        } else if ([[self.dataModel.choices objectForKey:@"photos"] boolValue] == TRUE && choicesused[15] == FALSE && myphoto != nil) {
            [feedarray insertObject:[NSNumber numberWithInt:5] atIndex:index];
            [article_number_at insertObject:[NSNumber numberWithInt:0] atIndex:index];
            choicesused[15] = TRUE;
            temp_moduleamount++;
        } else if (total_types>0 && choicesused[16] == FALSE) {
            [feedarray insertObject:[NSNumber numberWithInt:10] atIndex:index];
            [article_number_at insertObject:[NSNumber numberWithInt:articlesneeded] atIndex:index];
            articlesneeded++;
            choicesused[16] = TRUE;
        } else if ([[self.dataModel.choices objectForKey:@"weather"] boolValue] == TRUE && choicesused[18] == FALSE) {
            [feedarray insertObject:[NSNumber numberWithInt:3] atIndex:index];
            [article_number_at insertObject:[NSNumber numberWithInt:0] atIndex:index];
            choicesused[18] = TRUE;
            temp_moduleamount++;
        } else {
            [feedarray addObject:[NSNumber numberWithInt:10]];
            [article_number_at addObject:[NSNumber numberWithInt:articlesneeded]];
            articlesneeded++;
        }
        NSLog(@"an iteration");
        index++;
    }
    [feedarray removeObjectAtIndex:feedarray.count-1];
    [article_number_at removeObjectAtIndex:article_number_at.count-1];
    [feedarray addObject:[NSNumber numberWithInt:11]];
    NSLog(@"Amount in feed: %d",feedarray.count);
    temp_moduleamount++;
}

-(void)determineChosen {
    total_types = 0;
    if ([[self.dataModel.choices objectForKey:@"facebook"]boolValue] == TRUE) {
        total_types++;
    }
    if ([[self.dataModel.choices objectForKey:@"twitter"]boolValue] == TRUE) {
        total_types++;
    }
    total_types = total_types + self.dataModel.source_list.count;
}

-(void)makeSourceFeed {
    int count = 0;
    int iteration = 0;
    int tweetsused = 0;
    int facebookused = 0;
    NSArray *temparray;
    NSLog(@"Making source feed");
    article_type = [[NSMutableArray alloc] init];
    article_index = [[NSMutableArray alloc] init];
    BOOL pause = FALSE;
    while (count<15) {
        pause = TRUE;
        //Ideally we want to randomize this stuff later
        if (self.dataModel.source_list.count > 0 && rssfeed_array.count > 0) {
            temparray = [rssfeed_array objectAtIndex:0];
            if ([temparray count] > iteration) {
                [article_type addObject:[NSNumber numberWithInt:0]];
                [article_index addObject:[NSNumber numberWithInt:iteration]];
                temp_moduleamount++;
                pause = FALSE;
            }
        }
        if ([[self.dataModel.choices objectForKey:@"twitter"]boolValue] == TRUE) {
            if (twitter_feed.count > tweetsused) {
                [article_type addObject:[NSNumber numberWithInt:-1]];
                [article_index addObject:[NSNumber numberWithInt:tweetsused]];
                temp_moduleamount++;
                pause = FALSE;
                tweetsused++;
            }
        }
        if (self.dataModel.source_list.count > 1 && rssfeed_array.count > 1) {
            temparray = [rssfeed_array objectAtIndex:1];
            if ([temparray count] > iteration) {
                [article_type addObject:[NSNumber numberWithInt:1]];
                [article_index addObject:[NSNumber numberWithInt:iteration]];
                temp_moduleamount++;
                pause = FALSE;
            }
        }
        if ([[self.dataModel.choices objectForKey:@"facebook"]boolValue] == TRUE) {
            if (facebook_feed.count > facebookused) {
                [article_type addObject:[NSNumber numberWithInt:-2]];
                [article_index addObject:[NSNumber numberWithInt:facebookused]];
                temp_moduleamount++;
                facebookused++;
                pause = FALSE;
            }
        }
        if (self.dataModel.source_list.count>2 && rssfeed_array.count>2) {
            for (int tempcount = 2; (tempcount<self.dataModel.source_list.count || tempcount<rssfeed_array.count); tempcount++) {
                temparray = [rssfeed_array objectAtIndex:tempcount];
                if ([temparray count] > iteration) {
                    [article_type addObject:[NSNumber numberWithInt:tempcount]];
                    [article_index addObject:[NSNumber numberWithInt:iteration]];
                    temp_moduleamount++;
                    pause = FALSE;
                }
                if (tempcount%2 == 1) {
                    if (twitter_feed.count > tweetsused) {
                        [article_type addObject:[NSNumber numberWithInt:-1]];
                        [article_index addObject:[NSNumber numberWithInt:tweetsused]];
                        temp_moduleamount++;
                        pause = FALSE;
                        tweetsused++;
                    }
                } else {
                    if (facebook_feed.count > facebookused) {
                        [article_type addObject:[NSNumber numberWithInt:-2]];
                        [article_index addObject:[NSNumber numberWithInt:facebookused]];
                        temp_moduleamount++;
                        facebookused++;
                        pause = FALSE;
                    }
                }
            }
        }
        iteration++;
        if (pause == TRUE) {
            count = 16;
        }
    }
}

#pragma mark - Updating Widgets

-(void) updateCalendar {
    
    EKEventStore *store = [[EKEventStore alloc] init];
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        // handle access here
    }];
    // Get the appropriate calendar
    NSCalendar *calendar = [NSCalendar currentCalendar];
    // Create the end date components
    NSDateComponents *oneDayFromNowComponents = [[NSDateComponents alloc] init];
    oneDayFromNowComponents.day = 1;
    NSDate *oneDayFromNow = [calendar dateByAddingComponents:oneDayFromNowComponents
                                                      toDate:[NSDate date]
                                                     options:0];
    // Create the predicate from the event store's instance method
    NSPredicate *predicate = [store predicateForEventsWithStartDate:[NSDate date]
                                                            endDate:oneDayFromNow
                                                          calendars:nil];
    
    // Fetch all events that match the predicate
    NSArray *events = [store eventsMatchingPredicate:predicate];
    calendar_temp_eventscount = events.count;
    for (int z = 0; z<4; z++)
    {
        if (calendar_temp_eventscount>z) {
            calendar_temp_startTime[z] = [[events objectAtIndex:z] startDate];
            calendar_temp_eventName[z] = [[events objectAtIndex:z] title];
        } else {
            calendar_temp_startTime[z] = nil;
            calendar_temp_eventName[z] = @"";
        }
    }

    NSLog(@"Calendar Done Loading");
    [reloading_done setObject:[NSNumber numberWithBool:TRUE] forKey:@"calendar"];
    [self endReload];
}

- (void) updateReminders
{
    EKEventStore *store = [[EKEventStore alloc] init];
    [store requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
        // handle access here
    }];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSArray *multicalendar = [[NSArray alloc] init];
    [multicalendar arrayByAddingObject:calendar];
    NSPredicate *predicate = [store predicateForIncompleteRemindersWithDueDateStarting:nil ending:nil calendars:multicalendar];
    
    for (int z = 0; z<4; z++) {
        reminders_temp_taskName[z] = @"";
    }
    
    x=0;
    reminders_temp_taskscount = 0;
    
    [store fetchRemindersMatchingPredicate:predicate completion:^(NSArray *reminders) {
        for (EKReminder *reminder in reminders) {
            reminders_temp_taskscount = reminders.count;
            for (int z = 0; z<4; z++) {
                if (reminders_temp_taskscount>z && x==z) {
                    reminders_temp_taskName[z] = reminder.title;
                }
            }
            x++;
        }
        NSLog(@"Reminders Done Loading");
        [reloading_done setObject:[NSNumber numberWithBool:TRUE] forKey:@"reminders"];
        [self endReload];
    }];
}

- (void) updateWeather
{
    _weatherAPI = [[OWMWeatherAPI alloc] initWithAPIKey:@"c759751560a1f818010e324109b1c11e"];
    [_weatherAPI setLangWithPreferedLanguage];
    [_weatherAPI setTemperatureFormat:kOWMTempFahrenheit];
    
    [_weatherAPI currentWeatherByCoordinate:self.dataModel.locationed withCallback:^(NSError *error, NSDictionary *result) {
        if (error) {
            // Handle the error
            return;
        }
        
        weather_temperature = [NSMutableString stringWithFormat:@"%.1f°F",
                [result[@"main"][@"temp"] floatValue] ];
        weather_description = result[@"weather"][0][@"description"];
        weather_city = result[@"name"];
        NSLog(@"Weather Updated: %@",weather_temperature);
        
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSHourCalendarUnit fromDate:result[@"dt"]];
        NSInteger hour = [components hour];
        BOOL isItDay = FALSE;
        if (hour > 7 && hour < 20) {
            isItDay = TRUE;
        }
        
        
        
        if ([weather_description rangeOfString:@"snow"].location != NSNotFound || [weather_description rangeOfString:@"Snow"].location != NSNotFound) {
            weather_icon[0] = [UIImage imageNamed:@"Weather-Snow-icon.png"];
        } else if ([weather_description rangeOfString:@"storm"].location != NSNotFound || [weather_description rangeOfString:@"Storm"].location != NSNotFound) {
            weather_icon[0] = [UIImage imageNamed:@"Weather-Storm-icon.png"];
        } else if ([weather_description rangeOfString:@"light rain"].location != NSNotFound || [weather_description rangeOfString:@"Light Rain"].location != NSNotFound|| [weather_description rangeOfString:@"light Rain"].location != NSNotFound || [weather_description rangeOfString:@"Light rain"].location != NSNotFound) {
            weather_icon[0] = [UIImage imageNamed:@"Weather-Little-rain-icon.png"];
        } else if ([weather_description rangeOfString:@"rain"].location != NSNotFound || [weather_description rangeOfString:@"Rain"].location != NSNotFound) {
            weather_icon[0] = [UIImage imageNamed:@"Weather-Downpour-icon.png"];
        } else if ([weather_description rangeOfString:@"clear"].location != NSNotFound || [weather_description rangeOfString:@"Clear"].location != NSNotFound) {
            if (isItDay) {
                weather_icon[0] = [UIImage imageNamed:@"Weather-Sun.png"];
            } else {
                weather_icon[0] = [UIImage imageNamed:@"moon.png"];
            }
            
        } else if ([weather_description rangeOfString:@"few clouds"].location != NSNotFound || [weather_description rangeOfString:@"Few Clouds"].location != NSNotFound || [weather_description rangeOfString:@"Few clouds"].location != NSNotFound || [weather_description rangeOfString:@"few Clouds"].location != NSNotFound) {
            if (isItDay) {
                weather_icon[0] = [UIImage imageNamed:@"Weather-Partly-cloudy-day-icon.png"];
            } else {
                weather_icon[0] = [UIImage imageNamed:@"partlycloudynight.png"];
            }
        } else {
            weather_icon[0] = [UIImage imageNamed:@"Weather-Clouds-icon.png"];
        }
        
        NSLog(@"Weather Now Done Loading");
        [reloading_done setObject:[NSNumber numberWithBool:TRUE] forKey:@"weathernow"];
        [self endReload];
        
    }];
    
    [_weatherAPI forecastWeatherByCoordinate:self.dataModel.locationed withCallback:^(NSError *error, NSDictionary *result) {
        
        if (error) {
            // Handle the error;
            return;
        }
        
        NSArray *forecast = result[@"list"];
        NSDictionary *dayforecast;
        NSString *daydescription;
        
        [formatter setDateStyle:NSDateFormatterNoStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        //[[[formatter stringFromDate:[NSDate date]] stringByReplacingOccurrencesOfString:@" AM" withString:@"am"] stringByReplacingOccurrencesOfString:@" PM" withString:@"pm"];
        //°F
        
        for (int y = 0; y < 5; y++) {
            dayforecast = [forecast objectAtIndex:y];
            daydescription = dayforecast[@"weather"][0][@"main"];
            NSLog(@"%@",daydescription);
            weather_times[y+1] = [[[formatter stringFromDate:dayforecast[@"dt"]] stringByReplacingOccurrencesOfString:@":00 AM" withString:@"a"] stringByReplacingOccurrencesOfString:@":00 PM" withString:@"p"];
            if ([daydescription rangeOfString:@"snow"].location != NSNotFound || [daydescription rangeOfString:@"Snow"].location != NSNotFound) {
                weather_icon[y+1] = [UIImage imageNamed:@"Weather-Snow-icon.png"];
            } else if ([daydescription rangeOfString:@"storm"].location != NSNotFound || [daydescription rangeOfString:@"Storm"].location != NSNotFound) {
                weather_icon[y+1] = [UIImage imageNamed:@"Weather-storm-icon.png"];
            } else if ([daydescription rangeOfString:@"light rain"].location != NSNotFound || [daydescription rangeOfString:@"Light Rain"].location != NSNotFound|| [daydescription rangeOfString:@"light Rain"].location != NSNotFound || [daydescription rangeOfString:@"Light rain"].location != NSNotFound) {
                weather_icon[y+1] = [UIImage imageNamed:@"Weather-Little-rain-icon.png"];
            } else if ([daydescription rangeOfString:@"rain"].location != NSNotFound || [daydescription rangeOfString:@"Rain"].location != NSNotFound) {
                weather_icon[y+1] = [UIImage imageNamed:@"Weather-Downpour-icon.png"];
            } else if ([daydescription rangeOfString:@"clear"].location != NSNotFound || [daydescription rangeOfString:@"Clear"].location != NSNotFound) {
                if (([weather_times[y+1] isEqualToString:@"11p"]) || ([weather_times[y+1] isEqualToString:@"2a"]) || ([weather_times[y+1] isEqualToString:@"5a"])) {
                    weather_icon[y+1] = [UIImage imageNamed:@"moon.png"];
                } else {
                    weather_icon[y+1] = [UIImage imageNamed:@"Weather-Sun.png"];
                }
            } else if ([daydescription rangeOfString:@"few clouds"].location != NSNotFound || [daydescription rangeOfString:@"Few Clouds"].location != NSNotFound || [daydescription rangeOfString:@"Few clouds"].location != NSNotFound || [daydescription rangeOfString:@"few Clouds"].location != NSNotFound) {
                if (([weather_times[y+1] isEqualToString:@"11p"]) || ([weather_times[y+1] isEqualToString:@"2a"]) || ([weather_times[y+1] isEqualToString:@"5a"])) {
                    weather_icon[y+1] = [UIImage imageNamed:@"partlycloudynight.png"];
                } else {
                    weather_icon[y+1] = [UIImage imageNamed:@"Weather-Partly-cloudy-day-icon.png"];
                }
            } else {
                weather_icon[y+1] = [UIImage imageNamed:@"Weather-Clouds-icon.png"];
            }
            weather_temps[y+1] = [NSString stringWithFormat:@"%.f",
                                        [dayforecast[@"main"][@"temp"] floatValue] ];
        }
        
        NSLog(@"Weather Future Done Loading");
        [reloading_done setObject:[NSNumber numberWithBool:TRUE] forKey:@"weatherfuture"];
        [self endReload];
    }];
}

- (void) updatePhotos
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    photolocation = @"";
    
    // Enumerate just the photos and videos group by using ALAssetsGroupSavedPhotos.
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        // Within the group enumeration block, filter to enumerate just photos.
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        
        // Chooses the photo at the last index
        [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:([group numberOfAssets]-1)]
                                options:0
                             usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
                                 // The end of the enumeration is signaled by asset == nil.
                                 if (alAsset) {
                                     ALAssetRepresentation *representation = [alAsset defaultRepresentation];
                                     UIImageOrientation orientation = UIImageOrientationUp;
                                     NSNumber* orientationValue = [alAsset valueForProperty:@"ALAssetPropertyOrientation"];
                                     photodate = [alAsset valueForProperty:@"ALAssetPropertyDate"];
                                     CLLocation *locationdata = [alAsset valueForProperty:@"ALAssetPropertyLocation"];
                                     CLGeocoder *geocoder = [[CLGeocoder alloc] init];
                                     [geocoder reverseGeocodeLocation:locationdata completionHandler:^(NSArray *placemarks, NSError *error) {
                                         NSLog(@"Finding address");
                                         if (error) {
                                             NSLog(@"Error %@", error.description);
                                         } else {
                                             CLPlacemark *placemark = [placemarks lastObject];
                                             photolocation = [NSString stringWithFormat:@"%@, %@", placemark.locality, placemark.administrativeArea];
                                         }
                                         if (loadingStatus==FALSE) {
                                             [self.tableView reloadData];
                                         }
                                     }];
                                     if (orientationValue != nil) {
                                         orientation = [orientationValue intValue];
                                     }
                                     CGFloat scale  = 1;
                                     myphoto = [UIImage imageWithCGImage:[representation fullResolutionImage] scale:scale orientation:orientation];
                                 }
                                 //NSLog(@"Photos about to end updating");
                                 //dispatch_async(dispatch_get_main_queue(), ^(void){
                                 //    if (![reloading_done objectForKey:@"photos"]) {
                                         NSLog(@"Photos Done Loading");
                                         [reloading_done setObject:[NSNumber numberWithBool:TRUE] forKey:@"photos"];
                                         [self endReload];
                                 //    }
                                 //});
                             }];
    }
                         failureBlock: ^(NSError *error) {
                             // Typically you should handle an error more gracefully than this.
                             NSLog(@"No groups");
                         }];
}

/*
 Twitter Stuff
 */
- (BOOL) userHasAccessToTwitter
{
    return [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
}

- (void) getTwitterInfo
{
    temp_twitter_feed = [[NSMutableArray alloc] init];
    if ([self userHasAccessToTwitter]) {
        ACAccountStore *accountStore = [[ACAccountStore alloc] init];
        ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
            if (granted) {
                NSArray *accounts = [accountStore accountsWithAccountType:accountType];
                
                //Check if the user has setup at least one twitter account
                if (accounts.count > 0) {
                    ACAccount *twitterAccount = [accounts objectAtIndex:0];
                    
                    //Creating a request to get the info about a user on Twitter
                    NSDictionary *params = @{ @"count" : @"8"};
                    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com" @"/1.1/statuses/home_timeline.json"];
                    SLRequest *twitterInfoRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:url parameters:params];
                    [twitterInfoRequest setAccount:twitterAccount];
                    
                    //Making the request
                    [twitterInfoRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if ([urlResponse statusCode] == 429) {
                                return;
                            }
                            if (error) {
                                NSLog(@"Error: %@", error.localizedDescription);
                                return;
                            }
                            if (responseData) {
                                NSError *jsonError;
                                
                                NSArray *TWData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&jsonError];
                                
                                for (NSDictionary *tweet in TWData) {
                                    NSMutableDictionary *onetweet = [[NSMutableDictionary alloc] init];
                                    [onetweet setObject:[tweet objectForKey:@"text"] forKey:@"content"];
                                    [onetweet setObject:[[tweet objectForKey:@"user"] objectForKey:@"screen_name"] forKey:@"username"];
                                    [onetweet setObject:[[tweet objectForKey:@"user"] objectForKey:@"name"] forKey:@"realname"];
                                    NSMutableString *twitterimageurl = [[tweet objectForKey:@"user"] objectForKey:@"profile_image_url"];
                                    [onetweet setObject:[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:twitterimageurl]]] forKey:@"image"];
                                    
                                    NSString *id = [tweet objectForKey:@"id_str"];
                                    NSString *screen_name = [[tweet objectForKey:@"user"] objectForKey:@"screen_name"];
                                    NSURL *twitterurl = [NSURL URLWithString:[@"twitter://status?id=" stringByAppendingString:id]];
                                    NSString *partial_url = [@"http://twitter.com/" stringByAppendingString:screen_name];
                                    NSString *partial_url2 = [partial_url stringByAppendingString:@"/status/"];
                                    NSString *fullurl = [partial_url2 stringByAppendingString:id];

                                    [onetweet setObject:twitterurl forKey:@"twitterurl"];
                                    [onetweet setObject:fullurl forKey:@"fullurl"];

                                    [temp_twitter_feed addObject:onetweet];
                                    NSLog(@"Tweet added");
                                    
                                }
                                NSLog(@"Twitter Done Loading");
                                [reloading_done setObject:[NSNumber numberWithBool:TRUE] forKey:@"twitter"];
                                [self endReload];
                            }
                        });
                    }];
                }
            } else {
                NSLog(@"No access granted");
            }
        }];
    }
}

- (void) getMailInfo
{
    NSLog(@"Start getting mail");
    
    emails = [[NSMutableArray alloc] init];
    emails_parsed = 0;
    
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
    
    if ([signIn hasAuthInKeychain]) {
        NSLog(@"Trying silent authentication");
        [signIn trySilentAuthentication];
    } else {
        NSLog(@"Mail Done Loading");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't Connect to Gmail"
                                                        message:@"Please check your email settings"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [reloading_done setObject:[NSNumber numberWithBool:TRUE] forKey:@"mail"];
        [self endReload];
    }
}

- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error {
    NSLog(@"Received error %@ and auth object %@",error, auth);
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't Connect to Gmail"
                                                        message:@"Please check your email settings"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [reloading_done setObject:[NSNumber numberWithBool:TRUE] forKey:@"mail"];
        [self endReload];
    } else {
        [self getActualMailInfo:auth];
    }
}

- (void) getActualMailInfo:(GTMOAuth2Authentication*)auth
{
    NSLog(@"getting actual mail info");
    NSLog(@"User email: %@", [auth userEmail]);
    NSLog(@"Access token: %@", [auth accessToken]);
    if (session == nil) {
        session = [[MCOIMAPSession alloc] init];
        emails_session_created = [NSDate date];
    } else {
        NSTimeInterval theinterval = [[NSDate date] timeIntervalSinceDate:emails_session_created];
        NSLog(@"Time since session created in seconds: %.0f",theinterval);
        if (theinterval>300.0) {
            session = [[MCOIMAPSession alloc] init];
            emails_session_created = [NSDate date];
        }
    }
    [session setAuthType:MCOAuthTypeXOAuth2];
    [session setOAuth2Token:[auth accessToken]];
    [session setUsername:[auth userEmail]];
    [session setHostname:@"imap.gmail.com"];
    [session setPort:993];
    [session setConnectionType:MCOConnectionTypeTLS];
    MCOIMAPMessagesRequestKind requestKind = MCOIMAPMessagesRequestKindHeaders|MCOIMAPMessagesRequestKindFlags;
    NSString *folder = @"INBOX";
    MCOIMAPFolderInfo *info = [MCOIMAPFolderInfo info];
    
    MCOIMAPFolderInfoOperation *folderInfo = [session folderInfoOperation:folder];
    
    [folderInfo start:^(NSError *error, MCOIMAPFolderInfo *info) {
        NSLog(@"Starting email parsing");
        int numberOfMessages = 15;
        if (numberOfMessages>info.messageCount) {
            numberOfMessages = info.messageCount;
        }
        
        numberOfMessages-=1;
        MCOIndexSet *numbers = [MCOIndexSet indexSetWithRange:MCORangeMake([info messageCount] - numberOfMessages, numberOfMessages)];
        
        MCOIMAPFetchMessagesOperation *fetchOperation = [session fetchMessagesByNumberOperationWithFolder:folder
                                                                                              requestKind:requestKind
                                                                                                  numbers:numbers];
        
        [fetchOperation start:^(NSError *error, NSArray *messages, MCOIndexSet *vanishedMessages) {
            for (int i  = messages.count-1; i>=0; i--) {
                message = [messages objectAtIndex:i];
                if(message.flags==0 && emails.count<2) {
                    NSLog(@"Starting more email parsing");
                    MCOIMAPFetchContentOperation *operation = [session fetchMessageByUIDOperationWithFolder:folder uid:message.uid];
                    
                    [operation start:^(NSError *error, NSData *data) {
                        MCOMessageParser *messageParser = [[MCOMessageParser alloc] initWithData:data];
                        
                        NSString *text = [messageParser plainTextRendering];
                        
                        //From field
                        NSRange from =[text rangeOfString:@"From: "];
                        NSString *fromString = [text substringWithRange:NSMakeRange(from.location + from.length, [text rangeOfString:@"\n"].location -from.location -from.length)];
                        NSString *fromCleanedString = [[NSString alloc] init];
                        NSString *fromName = [[NSString alloc] init];
                        NSString *fromEmail = [[NSString alloc] init];
                        if([fromString rangeOfString:@"<"].location!= NSNotFound) {
                            if([fromString rangeOfString:@"\""].location!=NSNotFound)
                                fromCleanedString = [fromString stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                            else
                                fromCleanedString = fromString;
                            fromName = [fromCleanedString substringWithRange:NSMakeRange(0,[fromCleanedString rangeOfString:@"<"].location-1)];
                            fromEmail = [fromCleanedString substringWithRange:NSMakeRange([fromCleanedString rangeOfString:@"<"].location, [fromCleanedString rangeOfString:@">"].location - [fromCleanedString rangeOfString:@"<"].location+1)];
                        }else{
                            fromEmail = fromString;
                            fromCleanedString = fromString;
                            fromName = fromEmail;
                        }
                        
                        //Subject field
                        NSString *text2 = [text substringFromIndex:fromCleanedString.length+7];
                        BOOL blank = false;
                        BOOL blank2 = false;
                        NSString *subjectString;
                        NSString *text3;
                        if([text2 rangeOfString:@"Subject: "].location!=NSNotFound) {
                            NSRange subject =[text2 rangeOfString:@"Subject: "];
                            text3 = [text2 substringFromIndex:subject.location];
                            NSRange subject2 =[text3 rangeOfString:@"Subject: "];
                            subjectString = [NSString stringWithString:[text3 substringWithRange:NSMakeRange(subject2.location + subject2.length, [text3 rangeOfString:@"\n"].location -subject2.location -subject2.length)]];
                        }else {
                            blank2=true;
                            subjectString=@"(No Subject)";
                            NSRange subject = [text2 rangeOfString:@"Subject:"];
                            text3 = [text2 substringFromIndex:subject.location];
                        }
                        if([subjectString isEqualToString:@"No Subject"]) {
                            subjectString = @"(No Subject)";
                            blank=true;
                        }
                        subjectString = [subjectString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        
                        //Message Body
                        NSString *body = [[messageParser plainTextBodyRendering] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        
                        //Date field
                        NSString *text4;
                        if(blank2)
                            text4 = [text3 substringFromIndex:9];
                        else {
                            if (blank)
                                text4 = [text3 substringFromIndex:subjectString.length+8];
                            else
                                text4 = [text3 substringFromIndex:subjectString.length+10];
                        }
                        NSRange date = [text4 rangeOfString:@"Date: "];
                        NSString *dateString = [text4 substringWithRange:NSMakeRange(date.location + date.length, [text4 rangeOfString:@"\n"].location -date.location -date.length)];

                        NSString *month = [dateString substringWithRange:NSMakeRange(0,3)];
                        NSString *day = [dateString substringWithRange:NSMakeRange([dateString rangeOfString:@" "].location+1, [dateString rangeOfString:@","].location -[dateString rangeOfString:@" "].location-1)];
                        NSString *year = [dateString substringWithRange:NSMakeRange([dateString rangeOfString:@","].location +2,4)];
                        NSString *hour = [dateString substringWithRange:NSMakeRange([dateString rangeOfString:@"at "].location+3,[dateString rangeOfString:@":"].location -[dateString rangeOfString:@"at "].location-3)];
                        NSString *minute = [dateString substringWithRange:NSMakeRange([dateString rangeOfString:@":"].location+1,2)];
                        NSString *AMPM = [dateString substringWithRange:NSMakeRange(dateString.length-6,2)];
                        int hours = hour.integerValue;
                        if([AMPM isEqualToString:@"PM"] && hours!=12)
                            hours += 12;
                        NSDateComponents *comps = [[NSDateComponents alloc] init];
                        [comps setCalendar:[NSCalendar currentCalendar]];
                        if([month isEqualToString:@"Jan"]) {
                            month = @"01";
                        }else if ([month isEqualToString:@"Feb"]) {
                            month = @"02";
                        }else if ([month isEqualToString:@"Mar"]) {
                            month = @"03";
                        }else if ([month isEqualToString:@"Apr"]) {
                            month = @"04";
                        }else if ([month isEqualToString:@"May"]) {
                            month = @"05";
                        }else if ([month isEqualToString:@"Jun"]) {
                            month = @"06";
                        }else if ([month isEqualToString:@"Jul"]) {
                            month = @"07";
                        }else if ([month isEqualToString:@"Aug"]) {
                            month = @"08";
                        }else if ([month isEqualToString:@"Sep"]) {
                            month = @"09";
                        }else if ([month isEqualToString:@"Oct"]) {
                            month = @"10";
                        }else if ([month isEqualToString:@"Nov"]) {
                            month = @"11";
                        }else if ([month isEqualToString:@"Dec"]) {
                            month = @"12";
                        }
                        [comps setDay:day.integerValue];
                        [comps setMonth:month.integerValue];
                        [comps setHour:hours];
                        [comps setMinute:minute.integerValue];
                        [comps setYear:year.integerValue];
                        NSDate *yesterday = [NSDate dateWithTimeIntervalSinceNow:-86400];
                        NSDateComponents *yestcomp = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute fromDate:yesterday];
                        NSString *dateText = @" ";
                        //Within 24 hours
                        if([self date1:yestcomp date2:comps]) {
                            //Yesterday
                            if(yestcomp.day == comps.day && yestcomp.month == comps.month && yestcomp.year == comps.year) {
                                dateText = @"Yesterday";
                                //Today
                            }else {
                                if([AMPM isEqualToString:@"PM"]) {
                                    if(comps.hour==12) {
                                        if(comps.minute<10)
                                            dateText = [NSString stringWithFormat:@"%i:0%i PM", 12,comps.minute];
                                        else
                                            dateText = [NSString stringWithFormat:@"%i:%i PM", 12,comps.minute];
                                    }else{
                                        if(comps.minute<10)
                                            dateText = [NSString stringWithFormat:@"%i:0%i PM", comps.hour-12,comps.minute];
                                        else
                                            dateText = [NSString stringWithFormat:@"%i:%i PM", comps.hour-12,comps.minute];
                                    }
                                }else {
                                    if(comps.hour==0) {
                                        if(comps.minute<10)
                                            dateText = [NSString stringWithFormat:@"%i:0%i AM", 12,comps.minute];
                                        else
                                            dateText = [NSString stringWithFormat:@"%i:%i AM", 12,comps.minute];
                                    }else {
                                        if(comps.minute<10)
                                            dateText = [NSString stringWithFormat:@"%i:0%i AM", comps.hour,comps.minute];
                                        else
                                            dateText = [NSString stringWithFormat:@"%i:%i AM", comps.hour,comps.minute];
                                    }
                                }
                            }
                        }
                        NSDictionary *emailInfo = @{@"from": fromName,
                                                    @"email": fromEmail,
                                                    @"subject": subjectString,
                                                    @"date": dateText,
                                                    @"body": body};
                        if(![dateText isEqualToString:@" "]) {
                            [emails addObject:emailInfo];
                            NSLog(@"Email added!");
                        } else {
                            NSLog(@"Email not in timeframe");
                        }
                        emails_parsed++;
                        NSLog(@"Subject: %@", [emailInfo objectForKey:@"subject"]);
                        NSLog(@"Emails parsed: %d", emails_parsed);
                        
                        if (emails_parsed >= numberOfMessages) {
                            NSLog(@"Mail Done Loading");
                            dispatch_async(dispatch_get_main_queue(), ^(void){
                                [reloading_done setObject:[NSNumber numberWithBool:TRUE] forKey:@"mail"];
                                [self endReload];
                            });
                        }
                    }];
                } else {
                    emails_parsed++;
                    NSLog(@"(this not) Emails parsed: %d", emails_parsed);
                    if (emails_parsed >= numberOfMessages) {
                        dispatch_async(dispatch_get_main_queue(), ^(void){
                            NSLog(@"Mail Done Loading");
                            [reloading_done setObject:[NSNumber numberWithBool:TRUE] forKey:@"mail"];
                            [self endReload];
                        });
                    }
                }
            }
        }];
    }];
    
}

//true if date2 is after date1. Assumes date2 can be 24 hours at max after date 1
-(BOOL)date1:(NSDateComponents *)comp1 date2:(NSDateComponents *)comp2 {
    if(comp1.year>comp2.year)
        return false;
    if(comp1.month>comp2.month && comp1.year==comp2.year)
        return false;
    if(comp1.day>comp2.day && comp1.month==comp2.month && comp1.year==comp2.year)
        return false;
    if(comp1.hour>comp2.hour && comp1.day==comp2.day && comp1.month==comp2.month && comp1.year ==comp2.year)
        return false;
    if(comp1.minute>comp2.minute && comp1.hour==comp2.hour && comp1.day==comp2.day && comp1.month==comp2.month && comp1.year==comp2.year)
        return false;
    
    return true;
}

- (void) getImportantTwitterInfo
{
    importanttwitter_amount = 0;
    importanttwitter_feed = [[NSMutableArray alloc] init];
    if ([self userHasAccessToTwitter]) {
        ACAccountStore *accountStore = [[ACAccountStore alloc] init];
        ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
            if (granted) {
                NSArray *accounts = [accountStore accountsWithAccountType:accountType];
                
                //Check if the user has setup at least one twitter account
                if (accounts.count > 0) {
                    ACAccount *twitterAccount = [accounts objectAtIndex:0];
                    
                    ////Accessing mentions
                    NSDictionary *params2 = @{@"count" : @"100"};
                    NSURL *mention_url = [NSURL URLWithString:@"https://api.twitter.com" @"/1.1/statuses/mentions_timeline.json"];
                    SLRequest *twitterInfoRequest2 = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:mention_url parameters:params2];
                    [twitterInfoRequest2 setAccount:twitterAccount];
                    
                    // Making the request
                    
                    [twitterInfoRequest2 performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            // Check if we reached the reate limit
                            
                            if ([urlResponse statusCode] == 429) {
                                return;
                            }
                            
                            // Check if there was an error
                            
                            if (error) {
                                NSLog(@"Error: %@", error.localizedDescription);
                                return;
                            }
                            
                            // Check if there is some response data
                            
                            if (responseData) {
                                NSError *jsonError;
                                NSArray *TWData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&jsonError];
                                for(NSDictionary *tweet in TWData)
                                {
                                    NSString *text = [tweet objectForKey:@"created_at"];
                                    
                                    //get date of tweet
                                    NSDateComponents *comps = [[NSDateComponents alloc] init];
                                    [comps setCalendar:[NSCalendar currentCalendar]];
                                    NSString *month = [text substringWithRange:NSMakeRange(4,3)];
                                    if([month isEqualToString:@"Jan"]) {
                                        month = @"01";
                                    } else if ([month isEqualToString:@"Feb"]) {
                                        month = @"02";
                                    } else if ([month isEqualToString:@"Mar"]) {
                                        month = @"03";
                                    } else if ([month isEqualToString:@"Apr"]) {
                                        month = @"04";
                                    } else if ([month isEqualToString:@"May"]) {
                                        month = @"05";
                                    } else if ([month isEqualToString:@"Jun"]) {
                                        month = @"06";
                                    } else if ([month isEqualToString:@"Jul"]) {
                                        month = @"07";
                                    } else if ([month isEqualToString:@"Aug"]) {
                                        month = @"08";
                                    } else if ([month isEqualToString:@"Sep"]) {
                                        month = @"09";
                                    } else if ([month isEqualToString:@"Oct"]) {
                                        month = @"10";
                                    } else if ([month isEqualToString:@"Nov"]) {
                                        month = @"11";
                                    } else if ([month isEqualToString:@"Dec"]) {
                                        month = @"12";
                                    }
                                    NSString *day = [text substringWithRange:NSMakeRange(8,2)];
                                    NSString *year = [text substringWithRange:NSMakeRange(26,4)];
                                    NSString *hour = [text substringWithRange:NSMakeRange(11,2)];
                                    NSString *minute = [text substringWithRange:NSMakeRange(14,2)];
                                    [comps setDay:day.integerValue];
                                    [comps setMonth:month.integerValue];
                                    [comps setYear:year.integerValue];
                                    [comps setHour:hour.integerValue];
                                    [comps setMinute:minute.integerValue];
                                    NSDate *tweetDate = [[NSCalendar currentCalendar] dateFromComponents:comps];
                                    NSTimeInterval timeZoneSeconds = [[NSTimeZone localTimeZone] secondsFromGMT];
                                    NSDate *localTweetDate = [tweetDate dateByAddingTimeInterval:timeZoneSeconds];
                                    NSDateComponents *comps2 = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute fromDate:localTweetDate];
                                    
                                    //Get time one day ago
                                    NSDate *yesterday = [NSDate dateWithTimeIntervalSinceNow:-86400];
                                    NSDateComponents *yestcomp = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute fromDate:yesterday];
                                    
                                    //compare dates
                                    if([self date1:yestcomp date2:comps2]) {
                                        NSMutableDictionary *onetweet = [[NSMutableDictionary alloc] init];
                                        [onetweet setObject:[tweet objectForKey:@"text"] forKey:@"content"];
                                        [onetweet setObject:[[tweet objectForKey:@"user"] objectForKey:@"screen_name"] forKey:@"username"];
                                        [onetweet setObject:[[tweet objectForKey:@"user"] objectForKey:@"name"] forKey:@"realname"];
                                        NSMutableString *twitterimageurl = [[tweet objectForKey:@"user"] objectForKey:@"profile_image_url"];
                                        [onetweet setObject:[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:twitterimageurl]]] forKey:@"image"];
                                        
                                        NSString *id = [tweet objectForKey:@"id_str"];
                                        NSString *screen_name = [[tweet objectForKey:@"user"] objectForKey:@"screen_name"];
                                        NSURL *twitterurl = [NSURL URLWithString:[@"twitter://status?id=" stringByAppendingString:id]];
                                        NSString *partial_url = [@"http://twitter.com/" stringByAppendingString:screen_name];
                                        NSString *partial_url2 = [partial_url stringByAppendingString:@"/status/"];
                                        NSString *fullurl = [partial_url2 stringByAppendingString:id];
                                        
                                        [onetweet setObject:twitterurl forKey:@"twitterurl"];
                                        [onetweet setObject:fullurl forKey:@"fullurl"];
                                        
                                        [importanttwitter_feed addObject:onetweet];
                                        importanttwitter_amount++;
                                        NSLog(@"Important tweet added");
                                        NSLog(@"%@",id);
                                    }
                                    NSLog(@"Important Twitter Done Loading");
                                    [reloading_done setObject:[NSNumber numberWithBool:TRUE] forKey:@"importanttwitter"];
                                    [self endReload];
                                }
                            }
                        });
                    }];
                }
            } else {
                NSLog(@"No access granted");
            }
        }];
    }
}

- (void)getFacebookInfo
{
    temp_facebook_feed = [[NSMutableArray alloc] init];
    temp_important_facebook_feed = [[NSMutableArray alloc] init];
    
    __block NSString *username = [[NSString alloc] init];
    [FBRequestConnection startWithGraphPath:@"/me"
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection,id result,NSError *error) {
                              username = [result objectForKey:@"name"];
                          }];
    
    
    //home feed
    NSLog(@"Begin loading facebook");
    [FBRequestConnection startWithGraphPath:@"/me/home"
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection,id result,NSError *error) {
                              for(NSDictionary *dict in [result objectForKey:@"data"]) {
                                  [self parseFBPost:dict errorLog:error];
                              }
                              [reloading_done setObject:[NSNumber numberWithBool:TRUE] forKey:@"facebook"];
                              NSLog(@"End loading facebook");
                              [self endReload];
                          }];
    
    //user feed
    [FBRequestConnection startWithGraphPath:@"/me/feed"
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection,id result,NSError *error) {
                              for(NSDictionary *dict in [result objectForKey:@"data"]) {
                                  //Check if post is not from user
                                  if(![username isEqualToString:[[dict objectForKey:@"from"] objectForKey:@"name"]]) {
                                      //Get post date
                                      NSString *time =[dict objectForKey:@"created_time"];
                                      NSDate *localPostDate = [self timeParse:time];
                                      NSDateComponents *comps = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute fromDate:localPostDate];
                                      
                                      //Get time one day ago
                                      NSDate *yesterday = [NSDate dateWithTimeIntervalSinceNow:-86400];
                                      NSDateComponents *yestcomp = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute fromDate:yesterday];
                                      
                                      //compare dates
                                      if([self date1:yestcomp date2:comps]) {
                                          NSLog(@"valid");
                                          [self parseImportantFBPost:dict errorLog:error];
                                      }
                                  }
                              }
                              [reloading_done setObject:[NSNumber numberWithBool:TRUE] forKey:@"importantfacebook"];
                              NSLog(@"End loading important facebook");
                              [self endReload];
                          }];
}

-(void)parseFBPost:(NSDictionary *)dict errorLog:(NSError *)error {
    if(!error) {
        NSDictionary *name = [dict objectForKey:@"from"];
        
        BOOL goforit = TRUE;
        NSString *tempstatus = [dict objectForKey:@"message"];
        if (tempstatus != nil) {
            if ([tempstatus rangeOfString:@"birthday"].location != NSNotFound) {
                goforit = FALSE;
            }
            if ([tempstatus rangeOfString:@"Birthday"].location != NSNotFound) {
                goforit = FALSE;
            }
        }
        /*if ([dict objectForKey:@"type"] == nil && tempstatus == nil) {
            goforit = FALSE;
        }*/
        if ([[dict objectForKey:@"type"] isEqualToString:@"link"]) {
            goforit = FALSE;
        }
        if (![[dict objectForKey:@"type"] isEqualToString:@"photo"]) {
            if (tempstatus == nil) {
                goforit = FALSE;
            }
        }
        if (goforit) {
        [temp_facebook_feed addObject:[[NSMutableDictionary alloc] init]];
        NSMutableDictionary *currentObject = [temp_facebook_feed objectAtIndex:(temp_facebook_feed.count-1)];
        
        //full name of poster
        NSMutableString *tempname = [[NSMutableString alloc] initWithString:[name objectForKey:@"name"]];
        [currentObject setObject:tempname forKey:@"name"];
        
        
        //profile photo
        NSString *url = [[@"http://graph.facebook.com/" stringByAppendingString:[name objectForKey:@"id"]] stringByAppendingString:@"/picture"];
        [currentObject setObject:url forKey:@"image_url"];
        if (temp_facebook_feed.count<15) {
            [currentObject setObject:[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]] forKey:@"image"];
        }
        
        //object url
        NSString *objecturl = [@"https://www.facebook.com/" stringByAppendingString:[dict objectForKey:@"id"]];
        [currentObject setObject:objecturl forKey:@"url"];
        
        //time- see method for string formatting
        NSString *time =[dict objectForKey:@"created_time"];
        NSDate *temptime = [self timeParse:time];
        [currentObject setObject:temptime forKey:@"time"];
        
        //status text
        if (tempstatus != nil) {
            tempstatus = [tempstatus stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [currentObject setObject:tempstatus forKey:@"status"];
        }
            
        NSLog(@"Object Number: %d",temp_facebook_feed.count-1);
        NSLog(@"%@",[[temp_facebook_feed objectAtIndex:(temp_facebook_feed.count-1)] objectForKey:@"name"]);
        //NSLog(@"%@",[[temp_facebook_feed objectAtIndex:(temp_facebook_feed.count-1)] objectForKey:@"status"]);
        
        if ([[dict objectForKey:@"type"] isEqualToString:@"link"]) {
            NSLog(@"link");
            /*[currentObject setObject:@"link" forKey:@"type"];
            //link name (e.g. article title)
            NSString *link_title = [dict objectForKey:@"name"];
            [currentObject setObject:link_title forKey:@"link_title"];
            //display link (e.g. www.cnbc.com)
            NSString *link_display = [dict objectForKey:@"caption"];
            [currentObject setObject:link_display forKey:@"link_display"];
            //actual link
            NSString *link_link = [dict objectForKey:@"link"];
            [currentObject setObject:link_link forKey:@"link_link"];
            //picture scraped from link (url)
            NSString *link_imgurl = [dict objectForKey:@"picture"];
            if (temp_facebook_feed.count<9) {
                [currentObject setObject:[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:link_imgurl]]] forKey:@"link_image"];
            }
            //description of article/first few lines of article
            NSString *link_description = [dict objectForKey:@"description"];
            [currentObject setObject:link_description forKey:@"link_description"];
            */
        }
        if([[dict objectForKey:@"type"] isEqualToString:@"photo"]) {
            NSLog(@"photo");
            [currentObject setObject:@"photo" forKey:@"type"];
            //url
            NSString *link = [dict objectForKey:@"picture"];
            NSMutableArray *list = [NSMutableArray array];
            int index1 = 0;
            int index2 = 0;
            for (int i=link.length-1; i>=0; i--) {
                NSString *substring  = [link substringWithRange:NSMakeRange(i, 1)];
                if([substring isEqualToString:@"/"]) {
                    index1 = i;
                    break;
                }
            }
            NSString *link2 = [link substringToIndex:index1];
            for (int i=link2.length-1; i>=0; i--) {
                NSString *substring  = [link2 substringWithRange:NSMakeRange(i, 1)];
                if([substring isEqualToString:@"/"]) {
                    index2 = i;
                    break;
                }
            }
            NSString *link3 = [link2 substringToIndex:index2];
            NSString *link4 = [link substringFromIndex:index1];
            NSString *link5 = [link3 stringByAppendingString:link4];
            NSString *photo_imgurl = [[link5 substringToIndex:link5.length-5] stringByAppendingString:@"n.jpg"];
            UIImage *thefbimage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:photo_imgurl]]];
            if (temp_facebook_feed.count<15 && thefbimage!=nil) {
                [currentObject setObject:thefbimage forKey:@"photo_image"];
            } else {
                goforit = FALSE;
            }
            //album name
            NSString *photo_album = [dict objectForKey:@"name"];
            if (photo_album != nil) {
                [currentObject setObject:photo_album forKey:@"photo_album"];
            }
        }
        
        //number of comments
        NSArray *commentdata = [[dict objectForKey:@"comments"] objectForKey:@"data"];
        int comments = [commentdata count];
        [currentObject setObject:[NSNumber numberWithInt:comments] forKey:@"comments"];
        //number of likes
        NSArray *likedata = [[dict objectForKey:@"likes"] objectForKey:@"data"];
        int likes = [likedata count];
        [currentObject setObject:[NSNumber numberWithInt:likes] forKey:@"likes"];
        if (goforit == FALSE) {
            [temp_facebook_feed removeObjectAtIndex:temp_facebook_feed.count-1];
        }
        }
        ///add the object to the feed here
    }else {
        NSLog(@"%@",error);
    }
}

-(void)parseImportantFBPost:(NSDictionary *)dict errorLog:(NSError *)error {
    if(!error) {
        NSDictionary *name = [dict objectForKey:@"from"];
        
        BOOL goforit = TRUE;
        NSString *tempstatus = [dict objectForKey:@"message"];
        if (tempstatus != nil) {
            if ([tempstatus rangeOfString:@"birthday"].location != NSNotFound) {
                goforit = FALSE;
            }
            if ([tempstatus rangeOfString:@"Birthday"].location != NSNotFound) {
                goforit = FALSE;
            }
        }
        /*if ([dict objectForKey:@"type"] == nil && tempstatus == nil) {
         goforit = FALSE;
         }*/
        if ([[dict objectForKey:@"type"] isEqualToString:@"link"]) {
            goforit = FALSE;
        }
        if (![[dict objectForKey:@"type"] isEqualToString:@"photo"]) {
            if (tempstatus == nil) {
                goforit = FALSE;
            }
        }
        if (goforit) {
            [temp_important_facebook_feed addObject:[[NSMutableDictionary alloc] init]];
            NSMutableDictionary *currentObject = [temp_important_facebook_feed objectAtIndex:(temp_important_facebook_feed.count-1)];
            
            //full name of poster
            NSMutableString *tempname = [[NSMutableString alloc] initWithString:[name objectForKey:@"name"]];
            [currentObject setObject:tempname forKey:@"name"];
            
            
            //profile photo
            NSString *url = [[@"http://graph.facebook.com/" stringByAppendingString:[name objectForKey:@"id"]] stringByAppendingString:@"/picture"];
            [currentObject setObject:url forKey:@"image_url"];
            if (temp_important_facebook_feed.count<15) {
                [currentObject setObject:[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]] forKey:@"image"];
            }
            
            //object url
            NSString *objecturl = [@"https://www.facebook.com/" stringByAppendingString:[dict objectForKey:@"id"]];
            [currentObject setObject:objecturl forKey:@"url"];
            
            //time- see method for string formatting
            NSString *time =[dict objectForKey:@"created_time"];
            NSDate *temptime = [self timeParse:time];
            [currentObject setObject:temptime forKey:@"time"];
            
            //status text
            if (tempstatus != nil) {
                tempstatus = [tempstatus stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                [currentObject setObject:tempstatus forKey:@"status"];
            }
            
            NSLog(@"Object Number: %d",temp_important_facebook_feed.count-1);
            NSLog(@"%@",[[temp_important_facebook_feed objectAtIndex:(temp_important_facebook_feed.count-1)] objectForKey:@"name"]);
            //NSLog(@"%@",[[temp_facebook_feed objectAtIndex:(temp_facebook_feed.count-1)] objectForKey:@"status"]);
            
            if ([[dict objectForKey:@"type"] isEqualToString:@"link"]) {
                NSLog(@"link");
                /*[currentObject setObject:@"link" forKey:@"type"];
                 //link name (e.g. article title)
                 NSString *link_title = [dict objectForKey:@"name"];
                 [currentObject setObject:link_title forKey:@"link_title"];
                 //display link (e.g. www.cnbc.com)
                 NSString *link_display = [dict objectForKey:@"caption"];
                 [currentObject setObject:link_display forKey:@"link_display"];
                 //actual link
                 NSString *link_link = [dict objectForKey:@"link"];
                 [currentObject setObject:link_link forKey:@"link_link"];
                 //picture scraped from link (url)
                 NSString *link_imgurl = [dict objectForKey:@"picture"];
                 if (temp_facebook_feed.count<9) {
                 [currentObject setObject:[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:link_imgurl]]] forKey:@"link_image"];
                 }
                 //description of article/first few lines of article
                 NSString *link_description = [dict objectForKey:@"description"];
                 [currentObject setObject:link_description forKey:@"link_description"];
                 */
            }
            if([[dict objectForKey:@"type"] isEqualToString:@"photo"]) {
                NSLog(@"photo");
                [currentObject setObject:@"photo" forKey:@"type"];
                //url
                NSString *link = [dict objectForKey:@"picture"];
                NSMutableArray *list = [NSMutableArray array];
                int index1 = 0;
                int index2 = 0;
                for (int i=link.length-1; i>=0; i--) {
                    NSString *substring  = [link substringWithRange:NSMakeRange(i, 1)];
                    if([substring isEqualToString:@"/"]) {
                        index1 = i;
                        break;
                    }
                }
                NSString *link2 = [link substringToIndex:index1];
                for (int i=link2.length-1; i>=0; i--) {
                    NSString *substring  = [link2 substringWithRange:NSMakeRange(i, 1)];
                    if([substring isEqualToString:@"/"]) {
                        index2 = i;
                        break;
                    }
                }
                NSString *link3 = [link2 substringToIndex:index2];
                NSString *link4 = [link substringFromIndex:index1];
                NSString *link5 = [link3 stringByAppendingString:link4];
                NSString *photo_imgurl = [[link5 substringToIndex:link5.length-5] stringByAppendingString:@"n.jpg"];
                UIImage *thefbimage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:photo_imgurl]]];
                if (temp_important_facebook_feed.count<15 && thefbimage!=nil) {
                    [currentObject setObject:thefbimage forKey:@"photo_image"];
                } else {
                    goforit = FALSE;
                }
                //album name
                NSString *photo_album = [dict objectForKey:@"name"];
                if (photo_album != nil) {
                    [currentObject setObject:photo_album forKey:@"photo_album"];
                }
            }
            
            //number of comments
            NSArray *commentdata = [[dict objectForKey:@"comments"] objectForKey:@"data"];
            int comments = [commentdata count];
            [currentObject setObject:[NSNumber numberWithInt:comments] forKey:@"comments"];
            //number of likes
            NSArray *likedata = [[dict objectForKey:@"likes"] objectForKey:@"data"];
            int likes = [likedata count];
            [currentObject setObject:[NSNumber numberWithInt:likes] forKey:@"likes"];
            if (goforit == FALSE) {
                [temp_important_facebook_feed removeObjectAtIndex:temp_important_facebook_feed.count-1];
            }
        }
        ///add the object to the feed here
    }else {
        NSLog(@"%@",error);
    }
}

-(NSDate *)timeParse:(NSString *)time {
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setCalendar:[NSCalendar currentCalendar]];
    NSString *month = [time substringWithRange:NSMakeRange(5,2)];
    NSString *day = [time substringWithRange:NSMakeRange(8,2)];
    NSString *year = [time substringWithRange:NSMakeRange(0,4)];
    NSString *hour = [time substringWithRange:NSMakeRange(11,2)];
    NSString *minute = [time substringWithRange:NSMakeRange(14,2)];
    [comps setDay:day.integerValue];
    [comps setMonth:month.integerValue];
    [comps setYear:year.integerValue];
    [comps setHour:hour.integerValue];
    [comps setMinute:minute.integerValue];
    NSDate *postDate = [[NSCalendar currentCalendar] dateFromComponents:comps];
    NSTimeInterval timeZoneSeconds = [[NSTimeZone systemTimeZone] secondsFromGMT];
    NSDate *localPostDate = [postDate dateByAddingTimeInterval:timeZoneSeconds];
    
    //formatting to print in local time
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:localPostDate];
    
    return localPostDate;
}

#pragma mark - Parsing

- (void)getArticleInfo
{
    NSString *tempurl;
    NSString *tempsource;
    int tempamt = 14/total_types+1;
    if (tempamt<3) {
        tempamt = 3;
    }
    NSLog(@"Beginning to Parse");
    epiccount = self.dataModel.source_list.count;
    int tempcount = epiccount;
    for (int p = 0; p<tempcount; p++) {
        if (loadingStatus) {
            NSLog(@"Added Parser");
            tempurl = [[self.dataModel.source_list objectAtIndex:p] objectForKey:@"url"];
            tempsource = [[self.dataModel.source_list objectAtIndex:p] objectForKey:@"title"];
            [parsers addObject:[[RSSParser alloc] init]];
            [[parsers objectAtIndex:p] setDelegate:self];
            [[parsers objectAtIndex:p] startParse:tempurl sourceName:tempsource amountToParse:tempamt];
        }
    }
}

- (void)RSSParserDidReturnFeed:(NSMutableArray *)returnedFeed
{
    [temp_feeds addObject:returnedFeed];
    
    //Update the progress bar
    progress_loaded++;
    progress = ((float)progress_loaded)/((float)progress_total_to_load);
    NSLog(@"Progress loaded: %d", progress_loaded);
    NSLog(@"Progress total: %d", progress_total_to_load);
    dispatch_async(dispatch_get_main_queue(), ^(void){
        theProgress.progress = progress;
    });
    NSLog(@"Progress: %f", progress);
    
    //If done parsing, let the engine know that
    epiccount--;
    NSLog(@"Received Parser Result. Epiccount: %d", epiccount);
    if (epiccount == 0 && loadingStatus) {
        NSLog(@"Parser Done Loading");
        parse_done = TRUE;
        //progress_loaded--;
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [self endReload];
        });
    }
}

- (void)destroyAllParsers
{
    for (int v = 0; v<parsers.count; v++) {
        NSLog(@"Parser destroyed");
        [[parsers objectAtIndex:v] destroyParse];
    }
}


#pragma mark - Segways

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (playing == TRUE) {
        playing = FALSE;
        [speechSynthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    }
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        int segue_articlenumber = [[article_index objectAtIndex:[[article_number_at objectAtIndex:indexPath.row] intValue]] intValue];
        int seque_sourcenumber = [[article_type objectAtIndex:[[article_number_at objectAtIndex:indexPath.row] intValue]] intValue];
        NSString *string = [[[rssfeed_array objectAtIndex:seque_sourcenumber] objectAtIndex: segue_articlenumber] objectForKey: @"link"];
        string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *news_identifier = [[[rssfeed_array objectAtIndex:seque_sourcenumber] objectAtIndex: segue_articlenumber] objectForKey: @"source"];
        NSLog(@"Opening: %@", string);
        NSLog(@"Well that's done");
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"module_open"     // Event category (required)
                                                              action:@"news_open"  // Event action (required)
                                                               label:news_identifier          // Event label
                                                               value:nil] build]];    // Event value
        [[segue destinationViewController] setUrl:string];
    }
    if ([[segue identifier] isEqualToString:@"twitterDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        //[[UIApplication sharedApplication] openURL:[[twitter_feed objectAtIndex:[[article_number_at objectAtIndex:indexPath.row] intValue]] objectForKey:@"twitterurl"]];
        int tweetnumber = [[article_index objectAtIndex:[[article_number_at objectAtIndex:indexPath.row] intValue]] intValue];
        NSString *string = [[twitter_feed objectAtIndex:tweetnumber] objectForKey:@"fullurl"];
        if ([[feedarray objectAtIndex:indexPath.row] intValue] == 7) {
            string = [[importanttwitter_feed objectAtIndex:0] objectForKey:@"fullurl"];
        }
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"module_open"     // Event category (required)
                                                              action:@"twitter_open"  // Event action (required)
                                                               label:nil          // Event label
                                                               value:nil] build]];    // Event value
        [[segue destinationViewController] setUrl:string];
    }
    if ([[segue identifier] isEqualToString:@"facebookDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        //[[UIApplication sharedApplication] openURL:[[twitter_feed objectAtIndex:[[article_number_at objectAtIndex:indexPath.row] intValue]] objectForKey:@"twitterurl"]];
        int facebooknumber = [[article_index objectAtIndex:[[article_number_at objectAtIndex:indexPath.row] intValue]] intValue];
        NSString *string = [[facebook_feed objectAtIndex:facebooknumber] objectForKey:@"url"];
        [[segue destinationViewController] setUrl:string];
    }
    if ([segue.identifier isEqualToString:@"settingsSegway"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        APPSettingsViewController *controller = (APPSettingsViewController *)navigationController.topViewController;
        controller.data = sender;
    }
    if ([segue.identifier isEqualToString:@"shareSegway"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        APPShareViewController *controller = (APPShareViewController *)navigationController.topViewController;
        controller.sharedObject = sender;
    }
}

- (IBAction)fblogin
{
    //[self performSegueWithIdentifier:@"customizeSegway" sender:self.dataModel];
    //[self getFacebookInfo];
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        
        // Close the session and remove the access token from the cache
        // The session state handler (in the app delegate) will be called automatically
        [FBSession.activeSession closeAndClearTokenInformation];
        
        // If the session state is not any of the two "open" states when the button is clicked
    } else {
        // Open a session showing the user the login UI
        // You must ALWAYS ask for public_profile permissions when opening a session
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"read_stream"]
                                           allowLoginUI:YES
                                      completionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {
             // Retrieve the app delegate
             //AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
             // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
             //[appDelegate sessionStateChanged:session state:state error:error];
         }];
    }
}

- (IBAction)edit
{
    if (loadingStatus) {
        loadingStatus = FALSE;
        NSLog(@"Reload Terminated");
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"reloading"     // Event category (required)
                                                              action:@"terminated"  // Event action (required)
                                                               label:nil          // Event label
                                                               value:nil] build]];    // Event value
        [self.refreshControl endRefreshing];
        
        NSLog(@"Removing loadbar");
        //Remove Loadbar
        [theProgress setProgress:0.01 animated:NO];
        progress = 0.01;
        [feedarray removeObjectAtIndex:0];
        [article_number_at removeObjectAtIndex:0];
        moduleamount--;
        
        self.dataModel.initialrun = [NSNumber numberWithBool:FALSE];
        NSLog(@"If view is unpopulated, add a message");
        if (firstrun) {
            [feedarray addObject:[NSNumber numberWithInt:98]];
            [feedarray addObject:[NSNumber numberWithInt:11]];
            moduleamount = 2;
        }
        
        dispatch_async(myQueue, ^{
            [self destroyAllParsers];
        });
        
        NSLog(@"Nuke and reload data");
        [self nuke];
        [self.tableView reloadData];
    }
    [self performSegueWithIdentifier:@"settingsSegway" sender:self.dataModel];
}


#pragma mark - Speech

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterancez {
    if (playing == TRUE) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentCell inSection:0];
        if (indexPath.row>=[self.tableView numberOfRowsInSection:0]) {
            playing = FALSE;
        } else {
            [self.tableView scrollToRowAtIndexPath:indexPath
                         atScrollPosition:UITableViewScrollPositionTop
                                 animated:YES];
            [self talk];
        }
    }
}

- (void)talk
{
    NSString *string = @"";
    
    if ([[feedarray objectAtIndex:currentCell] intValue] == 0) {
        //Time
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSHourCalendarUnit fromDate:[NSDate date]];
        NSInteger hour = [components hour];
        if ((hour >= 0 && hour <= 2) || hour>=18) {
            string = @"Good evening! ";
        }
        if (hour > 2 && hour < 12) {
            string = @"Good morning! ";
        }
        if (hour <= 12 && hour < 18) {
            string = @"Good afternoon! ";
        }
    }
    if ([[feedarray objectAtIndex:currentCell] intValue] == 1) {
        //Calendar
        if (calendar_eventscount == 1) {
            string = [NSString stringWithFormat:@"Your schedule is looking light today: First you have %@",calendar_eventName1];
        } else {
            string = [NSString stringWithFormat:@"You've got a few calendar events today. First is: %@, Second: %@, ",calendar_eventName1,calendar_eventName2];
            if (calendar_eventscount > 2) {
                NSString *string2 = [NSString stringWithFormat:@"Third: %@, ",calendar_eventName3];
                string = [string stringByAppendingString:string2];
            }
            if (calendar_eventscount > 3) {
                NSString *string2 = [NSString stringWithFormat:@"Fourth: %@, ",calendar_eventName4];
                string = [string stringByAppendingString:string2];
            }
        }
    }
    if ([[feedarray objectAtIndex:currentCell] intValue] == 2) {
        //Reminders
        if (reminders_taskscount == 1) {
            string = [NSString stringWithFormat:@"You've got one reminder today: %@",reminders_taskName1];
        } else {
            string = [NSString stringWithFormat:@"You've got a few reminders today. First is: %@, Second: %@, ",reminders_taskName1,reminders_taskName2];
            if (reminders_taskscount > 2) {
                NSString *string2 = [NSString stringWithFormat:@"Third: %@, ",reminders_taskName3];
                string = [string stringByAppendingString:string2];
            }
            if (reminders_taskscount > 3) {
                NSString *string2 = [NSString stringWithFormat:@"Fourth: %@, ",reminders_taskName4];
                string = [string stringByAppendingString:string2];
            }
        }
        
    }
    if ([[feedarray objectAtIndex:currentCell] intValue] == 3) {
        //Weather
        string = @"The weather temperature right now is ";
        string = [string stringByAppendingString:weather_temperature];
        string = [string stringByAppendingString:@", here are the temperatures for the next few hours. "];
    }
    if ([[feedarray objectAtIndex:currentCell] intValue] == 4) {
        //Stocks
        string = @"The stock market is on to a good start with the Dow up 27 and the S and P up 4.";
    }
    if ([[feedarray objectAtIndex:currentCell] intValue] == 5) {
        //Photos
        string = @"You took a nice photo yesterday. Here it is. ";
    }
    if ([[feedarray objectAtIndex:currentCell] intValue] == 6) {
        //Mail
        
        if (emails_real.count == 1) {
            string = [NSString stringWithFormat:@"You have 1 unread messages from the past day. This email is from %@, and the subject is %@. ",[[emails_real objectAtIndex:0] objectForKey:@"from"], [[emails_real objectAtIndex:0] objectForKey:@"subject"]];
        } else {
            string = [NSString stringWithFormat:@"You have a few unread messages from the past day. The most recent email is from %@, and the subject is %@. ",[[emails_real objectAtIndex:0] objectForKey:@"from"], [[emails_real objectAtIndex:0] objectForKey:@"subject"]];
            NSString *string2 = [NSString stringWithFormat:@"Another recent email is from %@, and the subject is %@. ",[[emails_real objectAtIndex:1] objectForKey:@"from"], [[emails_real objectAtIndex:1] objectForKey:@"subject"]];
            string = [string stringByAppendingString:string2];
        }
    }
    if ([[feedarray objectAtIndex:currentCell] intValue] == 7  && importanttwitter_amount>0) {
        //Twitter
        string = @"You have been mentioned in a twitter post";
    }
    if ([[feedarray objectAtIndex:currentCell] intValue] == 10) {
        if ([[article_type objectAtIndex:[[article_number_at objectAtIndex:currentCell] intValue]] intValue] == -1) {
            //Twitter
            int tweetnumber = [[article_index objectAtIndex:[[article_number_at objectAtIndex:currentCell] intValue]] intValue];
            NSString *tempstring = [[[twitter_feed objectAtIndex:tweetnumber] objectForKey:@"realname"] stringByAppendingString:@" tweeted, "];
            string = [tempstring stringByAppendingString:[[twitter_feed objectAtIndex:tweetnumber] objectForKey:@"content"]];
        } else if ([[article_type objectAtIndex:[[article_number_at objectAtIndex:currentCell] intValue]] intValue] == -2) {
            //Facebook
            int fbnumber = [[article_index objectAtIndex:[[article_number_at objectAtIndex:currentCell] intValue]] intValue];
            NSString *tempstring = [[[facebook_feed objectAtIndex:fbnumber] objectForKey:@"name"] stringByAppendingString:@" posted on Facebook, "];
            string = [tempstring stringByAppendingString:[[facebook_feed objectAtIndex:fbnumber] objectForKey:@"status"]];
        } else {
            int articleNumber = [[article_type objectAtIndex:[[article_number_at objectAtIndex:currentCell] intValue]] intValue];
            NSMutableDictionary *currentArticle = [[rssfeed_array objectAtIndex:articleNumber] objectAtIndex:[[article_index objectAtIndex:[[article_number_at objectAtIndex:currentCell] intValue]] intValue]];
            //Article
            string = [[currentArticle objectForKey:@"source"] stringByAppendingString:@"published an article, "];
            string = [string stringByAppendingString:[currentArticle objectForKey:@"title"]];
        }
    }
    
    
    utterance = [[AVSpeechUtterance alloc] initWithString:string];
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"];
    utterance.rate = AVSpeechUtteranceMaximumSpeechRate*0.25;
    
    currentCell++;
    [speechSynthesizer speakUtterance:utterance];
}

- (IBAction)play
{
    if (playing == FALSE) {
        NSArray *paths = [self.tableView indexPathsForVisibleRows];
        NSIndexPath *currentindex = [paths objectAtIndex:0];
        currentCell = currentindex.row;
        if (currentCell != 0) {
            currentCell++;
        }
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:currentCell inSection:0]
                              atScrollPosition:UITableViewScrollPositionTop
                                      animated:YES];
        [self talk];
        self.playButton.title = @"Stop";
        playing = TRUE;
    } else {
        playing = FALSE;
        self.playButton.title = @"Play";
        [speechSynthesizer stopSpeakingAtBoundary:AVSpeechBoundaryWord];
    }
}

@end
