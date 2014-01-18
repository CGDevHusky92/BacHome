//
//  PFFriend.m
//  BACHome
//
//  Created by Chase Gorectke on 1/18/14.
//  Copyright (c) 2014 Revision Works, LLC. All rights reserved.
//

#import <Parse/PFObject+Subclass.h>
#import "PFFriend.h"

@implementation PFFriend

+(NSString *)parseClassName {
  	return @"Friend";
}

-(id)initWithDefaults {
    self = [super init];
    if (self) {
        // Set defaults here
    }
    return self;
}

-(void)setYou:(NSString *)you {
    [self setObject:you forKey:@"you"];
}

-(NSString *)you {
    return [self objectForKey:@"you"];
}

-(void)setI:(NSString *)i {
    [self setObject:i forKey:@"i"];
}

-(NSString *)i {
    return [self objectForKey:@"i"];
}

@end
