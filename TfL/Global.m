//
//  Gobal.m
//  TfL
//
//  Created by Mijin Cho on 31/01/2015.
//  Copyright (c) 2015 Mijin Cho. All rights reserved.
//

#import "Global.h"


@implementation Global


static Global *instance = nil;
+(Global*)sharedInstance
{
    if (instance == nil)
    {
        instance = [[super allocWithZone:NULL] init];
    }
    return instance;
}

-(id)init
{
    if(self = [super init])
    {
        
        
        _busArray = [NSMutableArray new];
        _tubeArray = [NSMutableArray new];
        _tramArray = [NSMutableArray new];
        
        _places = [NSMutableArray new];
    }
    return self;
}

+(id)Global {
    return [[self alloc]init];
}
@end
