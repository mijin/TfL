//
//  Global.h
//  TfL
//
//  Created by Mijin Cho on 31/01/2015.
//  Copyright (c) 2015 Mijin Cho. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Global : NSObject

@property (nonatomic, strong) NSMutableArray *places;

@property (nonatomic, strong) NSMutableArray *busArray; /*save annotations for bus */
@property (nonatomic, strong) NSMutableArray *tubeArray; /*save annotations for tube */
@property (nonatomic, strong) NSMutableArray *tramArray;  /*save annotations for tram */

+(id)Global;
+(Global*)sharedInstance;

@end
