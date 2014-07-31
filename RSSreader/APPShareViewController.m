//
//  APPShareViewController.m
//  RSSreader
//
//  Created by Matthew Chan on 6/20/14.
//  Copyright (c) 2014 Matthew Chan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APPShareViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface APPShareViewController () {

NSDateFormatter *formatter;
    int height;
    
}
@end

@implementation APPShareViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"Home Feed"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    //self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:
                                     [UIImage imageNamed:@"defaultbg.png"]];
    formatter = [[NSDateFormatter alloc] init];
    
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
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        if ([[self.sharedObject objectForKey:@"type"] intValue] == 1) {
            //calendar
            if ([[self.sharedObject objectForKey:@"count"] intValue] == 1) {
                height = 58;
                return 58;
            } else if ([[self.sharedObject objectForKey:@"count"] intValue] == 2) {
                height = 92;
                return 92;
            } else if ([[self.sharedObject objectForKey:@"count"] intValue] == 3) {
                height = 126;
                return 126;
            } else {
                height = 160;
                return 160;
            }
        }
        
        if ([[self.sharedObject objectForKey:@"type"] intValue] == 2) {
            //reminder
            if ([[self.sharedObject objectForKey:@"count"] intValue] == 1) {
                height = 58;
                return 58;
            } else if ([[self.sharedObject objectForKey:@"count"] intValue] == 2) {
                height = 92;
                return 92;
            } else if ([[self.sharedObject objectForKey:@"count"] intValue] == 3) {
                height = 126;
                return 126;
            } else {
                height = 160;
                return 160;
            }
        }
        
        if ([[self.sharedObject objectForKey:@"type"] intValue] == 3) {
            //weather
            height = 185;
            return 185;
        }
        
        if ([[self.sharedObject objectForKey:@"type"] intValue] == 4) {
            //stocks
            height = 190;
            return 190;
        }
        
        if ([[self.sharedObject objectForKey:@"type"] intValue] == 5) {
            //photo
            height = 235;
            return 235;
        }
        
        if ([[self.sharedObject objectForKey:@"type"] intValue] == 6) {
            //mail
            height = 222;
            return 222;
        }
        
        if ([[self.sharedObject objectForKey:@"type"] intValue] == 7) {
            //twitter
            height = 143;
            return 143;
        }
        
        if ([[self.sharedObject objectForKey:@"type"] intValue] == 8) {
            //facebook
            height = 143;
            return 143;
        }
            height = 203;
            return 203;
    } else if (indexPath.row == 1 || indexPath.row == 6 || indexPath.row == 7 ) {
        return 51;
    } else {
        return 45;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        if ([[self.sharedObject objectForKey:@"type"] intValue] == 1) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CalendarCell" forIndexPath:indexPath];
            [formatter setDateStyle:NSDateFormatterNoStyle];
            [formatter setTimeStyle:NSDateFormatterShortStyle];
            NSString *tempz;
            
            if ([[self.sharedObject objectForKey:@"count"] intValue]>0) {
            //Calendar: First Event
            UILabel *time1 = (UILabel *)[cell viewWithTag:1];
            UILabel *event1 = (UILabel *)[cell viewWithTag:2];
            tempz = [[formatter stringFromDate:[self.sharedObject objectForKey:@"time1"]] stringByReplacingOccurrencesOfString:@" AM" withString:@"a"];
            tempz = [tempz stringByReplacingOccurrencesOfString:@" PM" withString:@"p"];
            time1.text = tempz;
            event1.text = [self.sharedObject objectForKey:@"event1"];
            }
            
            if ([[self.sharedObject objectForKey:@"count"] intValue]>1) {
            //Calendar: Second Event
            UILabel *time2 = (UILabel *)[cell viewWithTag:3];
            UILabel *event2 = (UILabel *)[cell viewWithTag:4];
            
            tempz = [[formatter stringFromDate:[self.sharedObject objectForKey:@"time2"]] stringByReplacingOccurrencesOfString:@" AM" withString:@"a"];
            tempz = [tempz stringByReplacingOccurrencesOfString:@" PM" withString:@"p"];
            time2.text = tempz;
            event2.text = [self.sharedObject objectForKey:@"event2"];
            }
            
            if ([[self.sharedObject objectForKey:@"count"] intValue]>2) {
            //Calendar: Third Event
            UILabel *time3 = (UILabel *)[cell viewWithTag:5];
            UILabel *event3 = (UILabel *)[cell viewWithTag:6];
            
            tempz = [[formatter stringFromDate:[self.sharedObject objectForKey:@"time3"]] stringByReplacingOccurrencesOfString:@" AM" withString:@"a"];
            tempz = [tempz stringByReplacingOccurrencesOfString:@" PM" withString:@"p"];
            time3.text = tempz;
            event3.text = [self.sharedObject objectForKey:@"event3"];
            }
            
            if ([[self.sharedObject objectForKey:@"count"] intValue]>3) {
            //Calendar: Fourth Event
            UILabel *time4 = (UILabel *)[cell viewWithTag:7];
            UILabel *event4 = (UILabel *)[cell viewWithTag:8];
            
            tempz = [[formatter stringFromDate:[self.sharedObject objectForKey:@"time4"]] stringByReplacingOccurrencesOfString:@" AM" withString:@"a"];
            tempz = [tempz stringByReplacingOccurrencesOfString:@" PM" withString:@"p"];
            time4.text = tempz;
            event4.text = [self.sharedObject objectForKey:@"event4"];
            }
            
            
            UILabel *line = (UILabel *)[cell viewWithTag:20];
            UILabel *back = (UILabel *)[cell viewWithTag:99];
            
            if ([[self.sharedObject objectForKey:@"count"] intValue] == 1) {
                line.frame = CGRectMake(10,11,11,79);
                back.frame = CGRectMake(10,11,300,79);
            } else if ([[self.sharedObject objectForKey:@"count"] intValue] == 2) {
                line.frame = CGRectMake(10,11,11,113);
                back.frame = CGRectMake(10,11,300,113);
            } else if ([[self.sharedObject objectForKey:@"count"] intValue] == 3) {
                line.frame = CGRectMake(10,11,11,147);
                back.frame = CGRectMake(10,11,300,147);
            } else {
                line.frame = CGRectMake(10,11,11,181);
                back.frame = CGRectMake(10,11,300,181);
            }
            return cell;
        } else if ([[self.sharedObject objectForKey:@"type"] intValue] == 2) {
            //REMINDERS
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReminderCell" forIndexPath:indexPath];
            UILabel *reminder1 = (UILabel *)[cell viewWithTag:1];
            reminder1.text = [self.sharedObject objectForKey:@"task1"];
            UILabel *reminder2 = (UILabel *)[cell viewWithTag:2];
            reminder2.text = [self.sharedObject objectForKey:@"task2"];
            UILabel *reminder3 = (UILabel *)[cell viewWithTag:3];
            reminder3.text = [self.sharedObject objectForKey:@"task3"];
            UILabel *reminder4 = (UILabel *)[cell viewWithTag:4];
            reminder4.text = [self.sharedObject objectForKey:@"task4"];
            
            UILabel *line = (UILabel *)[cell viewWithTag:20];
            UILabel *back = (UILabel *)[cell viewWithTag:99];
            UILabel *b1 = (UILabel *)[cell viewWithTag:5];
            UILabel *b2 = (UILabel *)[cell viewWithTag:6];
            UILabel *b3 = (UILabel *)[cell viewWithTag:7];
            UILabel *b4 = (UILabel *)[cell viewWithTag:8];
            
            if ([[self.sharedObject objectForKey:@"count"] intValue] == 1) {
                line.frame = CGRectMake(10,11,11,79);
                back.frame = CGRectMake(10,11,300,79);
                b1.backgroundColor = [UIColor lightGrayColor];
                b2.backgroundColor = [UIColor clearColor];
                b3.backgroundColor = [UIColor clearColor];
                b4.backgroundColor = [UIColor clearColor];
            } else if ([[self.sharedObject objectForKey:@"count"] intValue] == 2) {
                line.frame = CGRectMake(10,11,11,113);
                back.frame = CGRectMake(10,11,300,113);
                b1.backgroundColor = [UIColor lightGrayColor];
                b2.backgroundColor = [UIColor lightGrayColor];
                b3.backgroundColor = [UIColor clearColor];
                b4.backgroundColor = [UIColor clearColor];
            } else if ([[self.sharedObject objectForKey:@"count"] intValue] == 3) {
                line.frame = CGRectMake(10,11,11,147);
                back.frame = CGRectMake(10,11,300,147);
                b1.backgroundColor = [UIColor lightGrayColor];
                b2.backgroundColor = [UIColor lightGrayColor];
                b3.backgroundColor = [UIColor lightGrayColor];
                b4.backgroundColor = [UIColor clearColor];
            } else {
                line.frame = CGRectMake(10,11,11,181);
                back.frame = CGRectMake(10,11,300,181);
                b1.backgroundColor = [UIColor lightGrayColor];
                b2.backgroundColor = [UIColor lightGrayColor];
                b3.backgroundColor = [UIColor lightGrayColor];
                b4.backgroundColor = [UIColor lightGrayColor];
            }
            return cell;
        } else if ([[self.sharedObject objectForKey:@"type"] intValue] == 3) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WeatherCell" forIndexPath:indexPath];
            UILabel *currenttemp = (UILabel *)[cell viewWithTag:2];
            currenttemp.text = [self.sharedObject objectForKey:@"weather_temperature"];;
            UILabel *thecity = (UILabel *)[cell viewWithTag:20];
            thecity.text = [self.sharedObject objectForKey:@"weather_city"];;
            UIImageView *imageViewer = (UIImageView *)[cell viewWithTag:3];
            imageViewer.image = [self.sharedObject objectForKey:@"weather_icon0"];;
            UILabel *currentdescription = (UILabel *)[cell viewWithTag:4];
            currentdescription.text = [self.sharedObject objectForKey:@"weather_description"];;
            
            UIImageView *imageView1 = (UIImageView *)[cell viewWithTag:5];
            imageView1.image = [self.sharedObject objectForKey:@"weather_icon1"];
            UIImageView *imageView2 = (UIImageView *)[cell viewWithTag:6];
            imageView2.image = [self.sharedObject objectForKey:@"weather_icon2"];
            UIImageView *imageView3 = (UIImageView *)[cell viewWithTag:7];
            imageView3.image = [self.sharedObject objectForKey:@"weather_icon3"];
            UIImageView *imageView4 = (UIImageView *)[cell viewWithTag:8];
            imageView4.image = [self.sharedObject objectForKey:@"weather_icon4"];
            UIImageView *imageView5 = (UIImageView *)[cell viewWithTag:9];
            imageView5.image = [self.sharedObject objectForKey:@"weather_icon5"];
            
            UILabel *day1 = (UILabel *)[cell viewWithTag:10];
            UILabel *day2 = (UILabel *)[cell viewWithTag:11];
            UILabel *day3 = (UILabel *)[cell viewWithTag:12];
            UILabel *day4 = (UILabel *)[cell viewWithTag:13];
            UILabel *day5 = (UILabel *)[cell viewWithTag:14];
            
            NSDateFormatter* day = [[NSDateFormatter alloc] init];
            [day setDateFormat: @"EEEE"];
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *oneDayFromNowComponents = [[NSDateComponents alloc] init];
            oneDayFromNowComponents.day = 1;
            NSDate *runningdate = [NSDate date];
            
            day1.text = [[day stringFromDate:runningdate] substringToIndex:3];
            
            runningdate = [calendar dateByAddingComponents:oneDayFromNowComponents
                                                    toDate:runningdate
                                                   options:0];
            
            day2.text = [[day stringFromDate:runningdate] substringToIndex:3];
            runningdate = [calendar dateByAddingComponents:oneDayFromNowComponents
                                                    toDate:runningdate
                                                   options:0];
            
            day3.text = [[day stringFromDate:runningdate] substringToIndex:3];
            
            runningdate = [calendar dateByAddingComponents:oneDayFromNowComponents
                                                    toDate:runningdate
                                                   options:0];
            
            day4.text = [[day stringFromDate:runningdate] substringToIndex:3];
            
            runningdate = [calendar dateByAddingComponents:oneDayFromNowComponents
                                                    toDate:runningdate
                                                   options:0];
            
            day5.text = [[day stringFromDate:runningdate] substringToIndex:3];
            
            return cell;
        } else if ([[self.sharedObject objectForKey:@"type"] intValue] == 4) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StocksCell" forIndexPath:indexPath];
            return cell;
        } else if ([[self.sharedObject objectForKey:@"type"] intValue] == 5) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PhotoCell" forIndexPath:indexPath];
            UIImageView *picView = (UIImageView *)[cell viewWithTag:98];
            UILabel *datelabel = (UILabel *)[cell viewWithTag:2];
            UILabel *locationlabel = (UILabel *)[cell viewWithTag:3];
            [formatter setDateStyle:NSDateFormatterLongStyle];
            [formatter setTimeStyle:NSDateFormatterShortStyle];
            datelabel.text = [formatter stringFromDate:[self.sharedObject objectForKey:@"photo_date"]];
            locationlabel.text = [self.sharedObject objectForKey:@"photo_location"];
            //myphoto = [UIImage imageNamed:@"picsmall.jpg"];
            picView.image = [self.sharedObject objectForKey:@"photo"];
            
            return cell;
        } else if ([[self.sharedObject objectForKey:@"type"] intValue] == 6) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MailCell" forIndexPath:indexPath];
            return cell;
        } else if ([[self.sharedObject objectForKey:@"type"] intValue] == 7) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TwitterCell" forIndexPath:indexPath];
            
            UIImageView *twitterview = (UIImageView *)[cell viewWithTag:3];
            UILabel *field1 = (UILabel *)[cell viewWithTag:1];
            UILabel *field2 = (UILabel *)[cell viewWithTag:2];
            UITextView *twitterlabel = (UITextView *)[cell viewWithTag:4];

            field1.text = [self.sharedObject objectForKey:@"twitter_realname"];
            field2.text = [self.sharedObject objectForKey:@"twitter_username"];
            twitterview.image = [self.sharedObject objectForKey:@"twitter_image"];
            twitterlabel.text = [self.sharedObject objectForKey:@"twitter_content"];
            
            UIFont *font = [UIFont systemFontOfSize:16];
            twitterlabel.font = font;
            
            return cell;
        } else if ([[self.sharedObject objectForKey:@"type"] intValue] == 8) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FacebookCell" forIndexPath:indexPath];
            return cell;
        } else {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewsCell" forIndexPath:indexPath];
            //News Story
            UILabel *storytitle = (UILabel *)[cell viewWithTag:11];
            UITextView *storytext = (UITextView *)[cell viewWithTag:12];
            UILabel *storysource = (UILabel *)[cell viewWithTag:14];
            UIImageView *storyimage = (UIImageView *)[cell viewWithTag:10];
            if ([self.sharedObject objectForKey:@"news_image"] == nil) {
                storyimage.image = nil;
                [storytext setFrame:CGRectMake(28, 81, 275, 105)];
            } else {
                storyimage.image = [self.sharedObject objectForKey:@"news_image"];
                [storytext setFrame:CGRectMake(28, 81, 177, 105)];
            }
            storytitle.text = [self.sharedObject objectForKey:@"news_title"];
            storytext.text = [self.sharedObject objectForKey:@"news_description"];
            storysource.text = [self.sharedObject objectForKey:@"news_source"];
            [storytext setContentOffset:CGPointZero animated:NO];
            storytext.font = [UIFont systemFontOfSize:16];
            return cell;
        }
    } else if (indexPath.row == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"messagecell" forIndexPath:indexPath];
        self.theTextField = (UITextField *) [cell viewWithTag:1];
        self.theTextField.delegate = self;
        return cell;
    } else if (indexPath.row == 2) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"namecell" forIndexPath:indexPath];
        UILabel *namelabel = (UILabel *) [cell viewWithTag:1];
        namelabel.text = @"Emily Doe";
        return cell;
    } else if (indexPath.row == 3) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"namecell" forIndexPath:indexPath];
        UILabel *namelabel = (UILabel *) [cell viewWithTag:1];
        namelabel.text = @"Matt Chan";
        return cell;
    } else if (indexPath.row == 4) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"namecell" forIndexPath:indexPath];
        UILabel *namelabel = (UILabel *) [cell viewWithTag:1];
        namelabel.text = @"Akshay Chandrasekhar";
        return cell;
    } else if (indexPath.row == 5) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"namecell" forIndexPath:indexPath];
        UILabel *namelabel = (UILabel *) [cell viewWithTag:1];
        namelabel.text = @"James Wei";
        return cell;
    } else if (indexPath.row == 6) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addcell" forIndexPath:indexPath];
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"emailcell" forIndexPath:indexPath];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 7) {
        if (self.theTextField != nil) {
            [self.theTextField resignFirstResponder];
        }
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        
        UIGraphicsBeginImageContext(self.view.frame.size);
        [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        image = [self imageByCropping:image toRect:CGRectMake(10, 11, 300, height+31)];
        
        NSData * imageData = UIImageJPEGRepresentation(image, 1.0);
        
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc]init];
        [mail setMailComposeDelegate:self];
        
        if ( [MFMailComposeViewController canSendMail] ) {
            [mail addAttachmentData:imageData mimeType:@"image/jpeg" fileName:@"attachment.jpg"];
         
            [self presentViewController:mail animated:YES completion:nil];
        }
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (UIImage *)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([imageToCrop CGImage], rect);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    return cropped;
}

- (IBAction)cancel
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)share
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end