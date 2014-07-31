//
//  RSSParser.h
//  oneLife
//
//  Created by Matthew Chan on 7/27/14.
//  Copyright (c) 2014 Matthew Chan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RSSParser;

@protocol RSSParserClassDelegate

-(void)RSSParserDidReturnFeed:(NSMutableArray *)returnedFeed;

@end

@interface RSSParser : NSObject <NSXMLParserDelegate> {
    
}

@property (nonatomic, assign) id delegate;

-(void)startParse:(NSString *)url sourceName:(NSString *)name amountToParse:(int)amt;
-(void)destroyParse;

@end
