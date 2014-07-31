//
//  DataModel.h
//  RSSreader
//
//  Created by Matthew Chan on 6/17/14.
//  Copyright (c) 2014 Matthew Chan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface DataModel : NSObject

@property (nonatomic, strong) NSMutableDictionary *choices;
@property (nonatomic, strong) NSMutableArray *source_list;
@property (nonatomic, strong) NSMutableString *chosen_category;

@property (nonatomic, strong) NSMutableString *email_address;
@property (nonatomic, strong) NSMutableString *email_password;

@property (nonatomic, strong) NSNumber *initialrun;

@property (nonatomic, assign) CLLocationCoordinate2D locationed;
@property (nonatomic, assign) BOOL changed;
@property (nonatomic, assign) BOOL emailchanged;

- (int)determineExist:(NSString *)theString;
- (void)addSource:(NSMutableDictionary *)theSource;
- (void)saveItems;

@end
