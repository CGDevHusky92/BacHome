//
//  PFFriends.m
//  BACHome
//
//  Created by Chase Gorectke on 1/18/14.
//  Copyright (c) 2014 Revision Works, LLC. All rights reserved.
//

#import <Parse/PFObject+Subclass.h>
#import "PFFriends.h"

@implementation PFFriends

+(NSString *)parseClassName {
  	return @"Friends";
}

-(id)initWithDefaults {
    self = [super init];
    if (self) {
        // Set defaults here
        if ([PFUser currentUser]) {
            [self setMe:[[PFUser currentUser] username]];
        }
    }
    return self;
}

-(void)setYou:(NSString *)you {
    [self setObject:you forKey:@"you"];
}

-(NSString *)you {
    return [self objectForKey:@"you"];
}

-(void)setMe:(NSString *)me {
    [self setObject:me forKey:@"me"];
}

-(NSString *)me {
    return [self objectForKey:@"me"];
}

@end
