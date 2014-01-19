//
//  PFDrinksLookup.m
//  BACHome
//
//  Created by Chase Gorectke on 1/18/14.
//  Copyright (c) 2014 Revision Works, LLC. All rights reserved.
//

#import <Parse/PFObject+Subclass.h>
#import "PFDrinksLookup.h"

@implementation PFDrinksLookup

+(NSString *)parseClassName {
  	return @"DrinksLookup";
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

-(void)setStdDrink:(float)stdDrink {
    [self setObject:[NSNumber numberWithFloat:stdDrink] forKey:@"stdDrink"];
}

-(float)stdDrink {
    return [[self objectForKey:@"stdDrink"] floatValue];
}

@end
