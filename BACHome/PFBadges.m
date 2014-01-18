//
//  PFBadges.m
//  BACHome
//
//  Created by Chase Gorectke on 1/18/14.
//  Copyright (c) 2014 Revision Works, LLC. All rights reserved.
//

#import <Parse/PFObject+Subclass.h>
#import "PFBadges.h"

@implementation PFBadges

+(NSString *)parseClassName {
  	return @"Badges";
}

-(id)initWithDefaults {
    self = [super init];
    if (self) {
        // Set defaults here
    }
    return self;
}

-(void)setName:(NSString *)name {
	[self setObject:name forKey:@"name"];
}

-(NSString *)name {
	return [self objectForKey:@"name"];
}

-(void)setUsername:(NSString *)username {
    [self setObject:username forKey:@"username"];
}

-(NSString *)username {
    return [self objectForKey:@"username"];
}

@end
