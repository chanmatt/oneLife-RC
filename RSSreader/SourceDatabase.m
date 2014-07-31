//
//  SourceDatabase.m
//  oneLife
//
//  Created by Matthew Chan on 7/6/14.
//  Copyright (c) 2014 Matthew Chan. All rights reserved.
//

#import "SourceDatabase.h"


@implementation SourceDatabase

- (id)init
{
    self = [super init];
    self.source_database = [[NSMutableArray alloc] init];
    NSMutableDictionary *temp_source_info = [[NSMutableDictionary alloc] init];
    
    temp_source_info = [[NSMutableDictionary alloc] init];
    [temp_source_info setObject:@"Al Jazeera America" forKey:@"title"];
    [temp_source_info setObject:@"aljazeera" forKey:@"identifier"];
    [temp_source_info setObject:@"http://america.aljazeera.com/content/ajam/articles.rss" forKey:@"url"];
    [temp_source_info setObject:@"News.png" forKey:@"icon"];
    [temp_source_info setObject:@"News" forKey:@"category"];
    [self.source_database addObject:temp_source_info];
    
    temp_source_info = [[NSMutableDictionary alloc] init];
    [temp_source_info setObject:@"BBC America" forKey:@"title"];
    [temp_source_info setObject:@"bbcamerica" forKey:@"identifier"];
    [temp_source_info setObject:@"http://feeds.bbci.co.uk/news/rss.xml" forKey:@"url"];
    [temp_source_info setObject:@"News.png" forKey:@"icon"];
    [temp_source_info setObject:@"News" forKey:@"category"];
    [self.source_database addObject:temp_source_info];
    
    temp_source_info = [[NSMutableDictionary alloc] init];
    [temp_source_info setObject:@"CNN Top Stories" forKey:@"title"];
    [temp_source_info setObject:@"cnn" forKey:@"identifier"];
    [temp_source_info setObject:@"http://rss.cnn.com/rss/cnn_topstories.rss" forKey:@"url"];
    [temp_source_info setObject:@"News.png" forKey:@"icon"];
    [temp_source_info setObject:@"News" forKey:@"category"];
    [self.source_database addObject:temp_source_info];
    
    temp_source_info = [[NSMutableDictionary alloc] init];
    [temp_source_info setObject:@"EatingWell Blog" forKey:@"title"];
    [temp_source_info setObject:@"eatingwell" forKey:@"identifier"];
    [temp_source_info setObject:@"http://feeds.feedburner.com/EatingwellBlogs-AllBlogPosts?format=xml" forKey:@"url"];
    [temp_source_info setObject:@"Food.png" forKey:@"icon"];
    [temp_source_info setObject:@"Food" forKey:@"category"];
    [self.source_database addObject:temp_source_info];
    
    temp_source_info = [[NSMutableDictionary alloc] init];
    [temp_source_info setObject:@"ESPN Top Headlines" forKey:@"title"];
    [temp_source_info setObject:@"espntop" forKey:@"identifier"];
    [temp_source_info setObject:@"http://sports.espn.go.com/espn/rss/news" forKey:@"url"];
    [temp_source_info setObject:@"Sports.png" forKey:@"icon"];
    [temp_source_info setObject:@"Sports" forKey:@"category"];
    [self.source_database addObject:temp_source_info];
    
    temp_source_info = [[NSMutableDictionary alloc] init];
    [temp_source_info setObject:@"ESPN Football" forKey:@"title"];
    [temp_source_info setObject:@"espnnfl" forKey:@"identifier"];
    [temp_source_info setObject:@"http://sports.espn.go.com/espn/rss/nfl/news" forKey:@"url"];
    [temp_source_info setObject:@"Sports.png" forKey:@"icon"];
    [temp_source_info setObject:@"Sports" forKey:@"category"];
    [self.source_database addObject:temp_source_info];
    
    temp_source_info = [[NSMutableDictionary alloc] init];
    [temp_source_info setObject:@"ESPN Baseball" forKey:@"title"];
    [temp_source_info setObject:@"espnmlb" forKey:@"identifier"];
    [temp_source_info setObject:@"http://sports.espn.go.com/espn/rss/mlb/news" forKey:@"url"];
    [temp_source_info setObject:@"Sports.png" forKey:@"icon"];
    [temp_source_info setObject:@"Sports" forKey:@"category"];
    [self.source_database addObject:temp_source_info];
    
    temp_source_info = [[NSMutableDictionary alloc] init];
    [temp_source_info setObject:@"ESPN Basketball" forKey:@"title"];
    [temp_source_info setObject:@"espnnba" forKey:@"identifier"];
    [temp_source_info setObject:@"http://sports.espn.go.com/espn/rss/nba/news" forKey:@"url"];
    [temp_source_info setObject:@"Sports.png" forKey:@"icon"];
    [temp_source_info setObject:@"Sports" forKey:@"category"];
    [self.source_database addObject:temp_source_info];
    
    temp_source_info = [[NSMutableDictionary alloc] init];
    [temp_source_info setObject:@"ESPN Hockey" forKey:@"title"];
    [temp_source_info setObject:@"espnnhl" forKey:@"identifier"];
    [temp_source_info setObject:@"http://sports.espn.go.com/espn/rss/nhl/news" forKey:@"url"];
    [temp_source_info setObject:@"Sports.png" forKey:@"icon"];
    [temp_source_info setObject:@"Sports" forKey:@"category"];
    [self.source_database addObject:temp_source_info];
    
    temp_source_info = [[NSMutableDictionary alloc] init];
    [temp_source_info setObject:@"The Economist" forKey:@"title"];
    [temp_source_info setObject:@"economist" forKey:@"identifier"];
    [temp_source_info setObject:@"http://www.economist.com/media/rss/economist.xml" forKey:@"url"];
    [temp_source_info setObject:@"Business.png" forKey:@"icon"];
    [temp_source_info setObject:@"Business" forKey:@"category"];
    [self.source_database addObject:temp_source_info];
    
    temp_source_info = [[NSMutableDictionary alloc] init];
    [temp_source_info setObject:@"Fast Company" forKey:@"title"];
    [temp_source_info setObject:@"fastco" forKey:@"identifier"];
    [temp_source_info setObject:@"http://www.fastcompany.com/rss.xml" forKey:@"url"];
    [temp_source_info setObject:@"Business.png" forKey:@"icon"];
    [temp_source_info setObject:@"Business" forKey:@"category"];
    [self.source_database addObject:temp_source_info];
    
    temp_source_info = [[NSMutableDictionary alloc] init];
    [temp_source_info setObject:@"Fox News" forKey:@"title"];
    [temp_source_info setObject:@"fox" forKey:@"identifier"];
    [temp_source_info setObject:@"http://feeds.foxnews.com/foxnews/latest" forKey:@"url"];
    [temp_source_info setObject:@"News.png" forKey:@"icon"];
    [temp_source_info setObject:@"News" forKey:@"category"];
    [self.source_database addObject:temp_source_info];
    
    temp_source_info = [[NSMutableDictionary alloc] init];
    [temp_source_info setObject:@"Financial Times US" forKey:@"title"];
    [temp_source_info setObject:@"ftUS" forKey:@"identifier"];
    [temp_source_info setObject:@"http://www.ft.com/rss/home/us" forKey:@"url"];
    [temp_source_info setObject:@"Business.png" forKey:@"icon"];
    [temp_source_info setObject:@"Business" forKey:@"category"];
    [self.source_database addObject:temp_source_info];
    
    temp_source_info = [[NSMutableDictionary alloc] init];
    [temp_source_info setObject:@"Financial Times World" forKey:@"title"];
    [temp_source_info setObject:@"ftWorld" forKey:@"identifier"];
    [temp_source_info setObject:@"http://www.ft.com/rss/world" forKey:@"url"];
    [temp_source_info setObject:@"Business.png" forKey:@"icon"];
    [temp_source_info setObject:@"Business" forKey:@"category"];
    [self.source_database addObject:temp_source_info];
    
    temp_source_info = [[NSMutableDictionary alloc] init];
    [temp_source_info setObject:@"Forbes" forKey:@"title"];
    [temp_source_info setObject:@"forbes" forKey:@"identifier"];
    [temp_source_info setObject:@"http://www.forbes.com/business/index.xml" forKey:@"url"];
    [temp_source_info setObject:@"Business.png" forKey:@"icon"];
    [temp_source_info setObject:@"Business" forKey:@"category"];
    [self.source_database addObject:temp_source_info];
    
    temp_source_info = [[NSMutableDictionary alloc] init];
    [temp_source_info setObject:@"Gizmodo" forKey:@"title"];
    [temp_source_info setObject:@"gizmodo" forKey:@"identifier"];
    [temp_source_info setObject:@"http://gizmodo.com/excerpts.xml" forKey:@"url"];
    [temp_source_info setObject:@"Technology.png" forKey:@"icon"];
    [temp_source_info setObject:@"Technology" forKey:@"category"];
    [self.source_database addObject:temp_source_info];
    
    temp_source_info = [[NSMutableDictionary alloc] init];
    [temp_source_info setObject:@"GQ" forKey:@"title"];
    [temp_source_info setObject:@"gq" forKey:@"identifier"];
    [temp_source_info setObject:@"http://www.gq.com/services/rss/feeds/latest.xml" forKey:@"url"];
    [temp_source_info setObject:@"Fashion.png" forKey:@"icon"];
    [temp_source_info setObject:@"Fashion" forKey:@"category"];
    [self.source_database addObject:temp_source_info];
    
    temp_source_info = [[NSMutableDictionary alloc] init];
    [temp_source_info setObject:@"Lifehacker" forKey:@"title"];
    [temp_source_info setObject:@"lifehack" forKey:@"identifier"];
    [temp_source_info setObject:@"http://feeds.gawker.com/lifehacker/full" forKey:@"url"];
    [temp_source_info setObject:@"Productivity.png" forKey:@"icon"];
    [temp_source_info setObject:@"Productivity" forKey:@"category"];
    [self.source_database addObject:temp_source_info];
    
    temp_source_info = [[NSMutableDictionary alloc] init];
    [temp_source_info setObject:@"New York Times" forKey:@"title"];
    [temp_source_info setObject:@"nytimes" forKey:@"identifier"];
    [temp_source_info setObject:@"http://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml" forKey:@"url"];
    [temp_source_info setObject:@"News.png" forKey:@"icon"];
    [temp_source_info setObject:@"News" forKey:@"category"];
    [self.source_database addObject:temp_source_info];
    
    temp_source_info = [[NSMutableDictionary alloc] init];
    [temp_source_info setObject:@"Penn Pal Runner Blog" forKey:@"title"];
    [temp_source_info setObject:@"pennpalrunner" forKey:@"identifier"];
    [temp_source_info setObject:@"http://pennpalrunner.wordpress.com/feed/" forKey:@"url"];
    [temp_source_info setObject:@"Running.png" forKey:@"icon"];
    [temp_source_info setObject:@"Fitness" forKey:@"category"];
    [self.source_database addObject:temp_source_info];
    
    /*temp_source_info = [[NSMutableDictionary alloc] init];
    [temp_source_info setObject:@"Serious Eats" forKey:@"title"];
    [temp_source_info setObject:@"seriouseats" forKey:@"identifier"];
    [temp_source_info setObject:@"http://feeds.feedburner.com/seriouseatsfeaturesvideos" forKey:@"url"];
    [temp_source_info setObject:@"Food.png" forKey:@"icon"];
    [temp_source_info setObject:@"Food" forKey:@"category"];
    [self.source_database addObject:temp_source_info];*/
    
    temp_source_info = [[NSMutableDictionary alloc] init];
    [temp_source_info setObject:@"Tech Crunch" forKey:@"title"];
    [temp_source_info setObject:@"techcrunch" forKey:@"identifier"];
    [temp_source_info setObject:@"http://feeds.feedburner.cåom/TechCrunch/" forKey:@"url"];
    [temp_source_info setObject:@"Technology.png" forKey:@"icon"];
    [temp_source_info setObject:@"Technology" forKey:@"category"];
    [self.source_database addObject:temp_source_info];
    
    /*temp_source_info = [[NSMutableDictionary alloc] init];
    [temp_source_info setObject:@"Teen Vogue" forKey:@"title"];
    [temp_source_info setObject:@"teenvogue" forKey:@"identifier"];
    [temp_source_info setObject:@"http://www.teenvogue.com/services/rss/feeds/composite.xml" forKey:@"url"];
    [temp_source_info setObject:@"Fashion.png" forKey:@"icon"];
    [temp_source_info setObject:@"Fashion" forKey:@"category"];
    [self.source_database addObject:temp_source_info];*/
    
    temp_source_info = [[NSMutableDictionary alloc] init];
    [temp_source_info setObject:@"Thought Catalog" forKey:@"title"];
    [temp_source_info setObject:@"thoughtcatalog" forKey:@"identifier"];
    [temp_source_info setObject:@"http://feeds.feedburner.com/ThoughtCatalog" forKey:@"url"];
    [temp_source_info setObject:@"Experiment.png" forKey:@"icon"];
    [temp_source_info setObject:@"Creative" forKey:@"category"];
    [self.source_database addObject:temp_source_info];
    
    temp_source_info = [[NSMutableDictionary alloc] init];
    [temp_source_info setObject:@"Wall Street Journal" forKey:@"title"];
    [temp_source_info setObject:@"wsj" forKey:@"identifier"];
    [temp_source_info setObject:@"http://online.wsj.com/xml/rss/3_7014.xml" forKey:@"url"];
    [temp_source_info setObject:@"News.png" forKey:@"icon"];
    [temp_source_info setObject:@"News" forKey:@"category"];
    [self.source_database addObject:temp_source_info];
    
    temp_source_info = [[NSMutableDictionary alloc] init];
    [temp_source_info setObject:@"Washington Post Politics" forKey:@"title"];
    [temp_source_info setObject:@"washpostpolitics" forKey:@"identifier"];
    [temp_source_info setObject:@"http://feeds.washingtonpost.com/rss/rss_election-2012" forKey:@"url"];
    [temp_source_info setObject:@"Politics.png" forKey:@"icon"];
    [temp_source_info setObject:@"Politics" forKey:@"category"];
    [self.source_database addObject:temp_source_info];
    
    //Categories
    self.categories = [[NSMutableArray alloc] init];
    NSMutableDictionary *temp_category = [[NSMutableDictionary alloc] init];
    [temp_category setObject:@"Business" forKey:@"name"];
    [temp_category setObject:@"Business.png" forKey:@"icon"];
    [self.categories addObject:temp_category];
    
    temp_category = [[NSMutableDictionary alloc] init];
    [temp_category setObject:@"Creative" forKey:@"name"];
    [temp_category setObject:@"Experiment.png" forKey:@"icon"];
    [self.categories addObject:temp_category];
    
    temp_category = [[NSMutableDictionary alloc] init];
    [temp_category setObject:@"Food" forKey:@"name"];
    [temp_category setObject:@"Food.png" forKey:@"icon"];
    [self.categories addObject:temp_category];
    
    temp_category = [[NSMutableDictionary alloc] init];
    [temp_category setObject:@"Fashion" forKey:@"name"];
    [temp_category setObject:@"Fashion.png" forKey:@"icon"];
    [self.categories addObject:temp_category];
    
    temp_category = [[NSMutableDictionary alloc] init];
    [temp_category setObject:@"Fitness" forKey:@"name"];
    [temp_category setObject:@"Fitness.png" forKey:@"icon"];
    [self.categories addObject:temp_category];
    
    temp_category = [[NSMutableDictionary alloc] init];
    [temp_category setObject:@"News" forKey:@"name"];
    [temp_category setObject:@"TheNews.png" forKey:@"icon"];
    [self.categories addObject:temp_category];
    
    temp_category = [[NSMutableDictionary alloc] init];
    [temp_category setObject:@"Photography" forKey:@"name"];
    [temp_category setObject:@"Camera.png" forKey:@"icon"];
    [self.categories addObject:temp_category];
    
    temp_category = [[NSMutableDictionary alloc] init];
    [temp_category setObject:@"Politics" forKey:@"name"];
    [temp_category setObject:@"Politics.png" forKey:@"icon"];
    [self.categories addObject:temp_category];
    
    temp_category = [[NSMutableDictionary alloc] init];
    [temp_category setObject:@"Productivity" forKey:@"name"];
    [temp_category setObject:@"Productivity.png" forKey:@"icon"];
    [self.categories addObject:temp_category];
    
    temp_category = [[NSMutableDictionary alloc] init];
    [temp_category setObject:@"Sports" forKey:@"name"];
    [temp_category setObject:@"Sports.png" forKey:@"icon"];
    [self.categories addObject:temp_category];
    
    temp_category = [[NSMutableDictionary alloc] init];
    [temp_category setObject:@"Technology" forKey:@"name"];
    [temp_category setObject:@"Technology.png" forKey:@"icon"];
    [self.categories addObject:temp_category];
    
    return self;
}

@end