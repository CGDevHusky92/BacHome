//
//  PFBadgesLookup.m
//  BACHome
//
//  Created by Chase Gorectke on 1/18/14.
//  Copyright (c) 2014 Revision Works, LLC. All rights reserved.
//

#import <Parse/PFObject+Subclass.h>
#import "PFBadgesLookup.h"

@implementation PFBadgesLookup

+(NSString *)parseClassName {
  	return @"BadgesLookup";
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

-(void)setDescription:(NSString *)description {
	[self setObject:description forKey:@"description"];
}

-(NSString *)description {
	return [self objectForKey:@"description"];
}

@end
