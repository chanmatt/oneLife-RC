//
//  RSSParser.m
//  oneLife
//
//  Created by Matthew Chan on 7/27/14.
//  Copyright (c) 2014 Matthew Chan. All rights reserved.
//

#import "RSSParser.h"

@interface RSSParser () {
    NSMutableDictionary *parsed_item;
    NSMutableString *parsed_title;
    NSMutableString *parsed_link;
    NSMutableString *parsed_description;
    NSMutableString *parsed_imageurl;
    NSString *parsed_source;
    NSString *parsed_element;
    
    int number_want;
    NSXMLParser *theparser;
    NSMutableArray *return_feed;
}

@end

@implementation RSSParser

@synthesize delegate;

- (id)init
{
    self = [super init];
    return self;
}

-(void)startParse:(NSString *)url sourceName:(NSString *)name amountToParse:(int)amt
{
    NSLog(@"Parsing the url: %@",url);
    parsed_source = name;
    return_feed = [[NSMutableArray alloc] init];
    number_want = amt;
    theparser = [[NSXMLParser alloc] initWithContentsOfURL:[[NSURL alloc] initWithString:url]];
    [theparser setDelegate:self];
    [theparser setShouldResolveExternalEntities:NO];
    [theparser parse];
}

#pragma mark - Parsing

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    parsed_element = elementName;
    if ([parsed_element isEqualToString:@"item"]) {
        parsed_item    = [[NSMutableDictionary alloc] init];
        parsed_title   = [[NSMutableString alloc] initWithString:@""];
        parsed_link    = [[NSMutableString alloc] initWithString:@""];
        parsed_imageurl    = [[NSMutableString alloc] initWithString:@""];
        parsed_description    = [[NSMutableString alloc] initWithString:@""];
        //[parsed_imageurl appendString:@"http://www.wwubap.org/wp-content/uploads/2012/03/no-available-image.png"];
    }
    
    if ([parsed_element isEqualToString:@"media:content"]) {
        parsed_imageurl = attributeDict[@"url"];
    }
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:@"item"]) {
        UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:parsed_imageurl]]];
        if (image != nil) {
            //image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://www.wwubap.org/wp-content/uploads/2012/03/no-available-image.png"]]];
            [parsed_item setObject:image forKey:@"image"];
        }
        [parsed_item setObject:[self flattenHTML:parsed_title] forKey:@"title"];
        [parsed_item setObject:parsed_link forKey:@"link"];
        [parsed_item setObject:[self flattenHTML:parsed_description] forKey:@"description"];
        [parsed_item setObject:parsed_imageurl forKey:@"imageurl"];
        [parsed_item setObject:parsed_source forKey:@"source"];
        [return_feed addObject:[parsed_item copy]];
        NSLog(@"Article #%lu Added", (unsigned long)[return_feed count]);
        NSLog(@"Requested: %d",number_want);
        if([return_feed count]>=number_want) {
            [parser abortParsing];
            [delegate RSSParserDidReturnFeed:return_feed];
        }
    } 
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if ([parsed_element isEqualToString:@"title"]) {
        [parsed_title appendString:string];
    } else if ([parsed_element isEqualToString:@"link"]) {
        [parsed_link appendString:string];
    } else if ([parsed_element isEqualToString:@"description"]) {
        [parsed_description appendString:string];
    }
}

- (NSString *)flattenHTML:(NSString *)html {
    
    NSScanner *theScanner;
    NSString *text = nil;
    
    theScanner = [NSScanner scannerWithString:html];
    
    while ([theScanner isAtEnd] == NO) {
        
        // find start of tag
        [theScanner scanUpToString:@"<" intoString:NULL] ;
        
        // find end of tag
        [theScanner scanUpToString:@">" intoString:&text] ;
        
        // replace the found tag with a space
        //(you can filter multi-spaces out later if you wish)
        html = [html stringByReplacingOccurrencesOfString:
                [ NSString stringWithFormat:@"%@>", text]
                                               withString:@""];
        
    } // while //
    
    html = [html stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    html = [html stringByReplacingOccurrencesOfString:@"&#34;" withString:@"\""];
    html = [html stringByReplacingOccurrencesOfString:@"&#8217;" withString:@"'"];
    html = [html stringByReplacingOccurrencesOfString:@"&#8211;" withString:@"-"];
    html = [html stringByReplacingOccurrencesOfString:@"&#8230;" withString:@"..."];
    html = [html stringByReplacingOccurrencesOfString:@"&#39;" withString:@"'"];
    html = [html stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return html;
    
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    
}

- (void)destroyParse{
    [theparser abortParsing];
}


@end
