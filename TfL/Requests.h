//
//  Requests.h
//  TfL
//
//  Created by Mijin Cho on 31/01/2015.
//  Copyright (c) 2015 Mijin Cho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface Requests : NSObject
{
    
}
+ (NSArray*) getPlace:(float)lat lon:(float)lon radius:(int)radius categories:(NSString*)categories;



@end