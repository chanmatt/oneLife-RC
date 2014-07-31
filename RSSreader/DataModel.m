//
//  DataModel.m
//  RSSreader
//
//  Created by Matthew Chan on 6/17/14.
//  Copyright (c) 2014 Matthew Chan. All rights reserved.
//

#import "DataModel.h"


@implementation DataModel

- (id)init
{ 
    self = [super init];
    [self loadItems];
    
    self.chosen_category = [[NSMutableString alloc] initWithString:@""];
    self.changed = FALSE;
    self.emailchanged = FALSE;
    self.locationed = CLLocationCoordinate2DMake(37.774929500000000000, -122.419415500000010000);
    return self;
}

// Get document directory
- (NSString *)documentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSLog(@"The directory is: %@" , documentsDirectory);
    return documentsDirectory;
}

// Get data file path
- (NSString *)dataFilePath
{
    return [[self documentsDirectory] stringByAppendingPathComponent:@"savedfile.plist"];
}

// Save choices
- (void)saveItems
{
    NSLog(@"Saving Items");
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:self.choices forKey:@"WidgetChoices"];
    [archiver encodeObject:self.source_list forKey:@"ArticleChoices"];
    [archiver encodeObject:self.initialrun forKey:@"Run"];
    [archiver finishEncoding];
    [data writeToFile:[self dataFilePath] atomically:YES];
}

// Load choices
- (void)loadItems
{
    NSString *path = [self dataFilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSLog(@"Loading items from file");
        NSData *data = [[NSData alloc] initWithContentsOfFile:path];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        self.choices = [[NSMutableDictionary alloc] init];
        self.source_list = [[NSMutableArray alloc] init];
        self.email_address = [[NSMutableString alloc] init];
        self.email_password = [[NSMutableString alloc] init];
        self.initialrun = [[NSNumber alloc] init];
        self.choices = [unarchiver decodeObjectForKey:@"WidgetChoices"];
        self.source_list = [unarchiver decodeObjectForKey:@"ArticleChoices"];
        self.initialrun = [unarchiver decodeObjectForKey:@"Run"];
        [unarchiver finishDecoding];
    } else {
        //Defaults
        NSLog(@"Defaults");
        self.choices = [[NSMutableDictionary alloc] init];
        [self.choices setValue:[NSNumber numberWithBool:FALSE] forKey:@"time"];
        [self.choices setValue:[NSNumber numberWithBool:FALSE] forKey:@"help"];
        [self.choices setValue:[NSNumber numberWithBool:FALSE] forKey:@"calendar"];
        [self.choices setValue:[NSNumber numberWithBool:FALSE] forKey:@"reminders"];
        [self.choices setValue:[NSNumber numberWithBool:FALSE] forKey:@"weather"];
        [self.choices setValue:[NSNumber numberWithBool:FALSE] forKey:@"stocks"];
        [self.choices setValue:[NSNumber numberWithBool:FALSE] forKey:@"photos"];
        [self.choices setValue:[NSNumber numberWithBool:FALSE] forKey:@"mail"];
        
        [self.choices setValue:[NSNumber numberWithBool:FALSE] forKey:@"facebook"];
        [self.choices setValue:[NSNumber numberWithBool:FALSE] forKey:@"twitter"];
        [self.choices setValue:[NSNumber numberWithBool:FALSE] forKey:@"googleplus"];
        [self.choices setValue:[NSNumber numberWithBool:FALSE] forKey:@"instagram"];
        [self.choices setValue:[NSNumber numberWithBool:FALSE] forKey:@"pinterest"];
        
        self.initialrun = [[NSNumber alloc] initWithBool:TRUE];
        
        self.source_list = [[NSMutableArray alloc] init];
        NSMutableDictionary *newSource = [[NSMutableDictionary alloc] init];
        [newSource setObject:@"New York Times" forKey:@"title"];
        [newSource setObject:@"nytimes" forKey:@"identifier"];
        [newSource setObject:@"http://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml" forKey:@"url"];
        [newSource setObject:@"News.png" forKey:@"icon"];
        [self.source_list addObject:newSource];
        
        newSource = [[NSMutableDictionary alloc] init];
        [newSource setObject:@"Washington Post Politics" forKey:@"title"];
        [newSource setObject:@"washpostpolitics" forKey:@"identifier"];
        [newSource setObject:@"http://feeds.washingtonpost.com/rss/rss_election-2012" forKey:@"url"];
        [newSource setObject:@"Politics.png" forKey:@"icon"];
        [self.source_list addObject:newSource];
        
        newSource = [[NSMutableDictionary alloc] init];
        [newSource setObject:@"EatingWell Blog" forKey:@"title"];
        [newSource setObject:@"eatingwell" forKey:@"identifier"];
        [newSource setObject:@"http://feeds.feedburner.com/EatingwellBlogs-AllBlogPosts?format=xml" forKey:@"url"];
        [newSource setObject:@"Food.png" forKey:@"icon"];
        [self.source_list addObject:newSource];
        
    }
}


- (int)determineExist:(NSString *)theString
{
    int result = -1;
    for (int x = 0; x<self.source_list.count; x++) {
        if ([theString isEqualToString:[[self.source_list objectAtIndex:x] objectForKey:@"identifier"]]) {
            result = x;
        }
    }
    return result;
}

- (void)addSource:(NSMutableDictionary *)theSource
{
    [self.source_list addObject:theSource];
}

@end
