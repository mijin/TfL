//
//  Requests.m
//  TfL
//
//  Created by Mijin Cho on 31/01/2015.
//  Copyright (c) 2015 Mijin Cho. All rights reserved.
//

#import "Requests.h"

#define TEST 0

static NSString * const app_id = @"bb90a5c6";
static NSString * const app_key = @"e1561b91652049957ebb52d0742596bc";

@implementation Requests

+ (NSArray*) getPlace:(float)lat lon:(float)lon radius:(int)radius categories:(NSString*)categories
{
    NSError* err = nil;
    
    NSString* url = [NSString stringWithFormat:
                     @"http://api.tfl.gov.uk/Place?lat=%f&lon=%f&radius=%d&categories=%@&includeChildren=False&type=&app_id=%@&app_key=%@",
                     lat,lon,radius,categories,app_id,app_key];
    if(TEST) {
        url=  @"http://api.tfl.gov.uk/Place?lat=51.549897&lon=-0.098063&radius=500&categories=stop&includeChildren=False&type=&app_id=bb90a5c6&app_key=e1561b91652049957ebb52d0742596bc";
    }
    NSDictionary* results = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]
                                                            options:kNilOptions
                                                              error:&err];
    
    NSLog(@"restuls %@",[results objectForKey:@"places"]);
    
    return [results objectForKey:@"places"];
}


@end
