//
//  PFBadgesLookup.h
//  BACHome
//
//  Created by Chase Gorectke on 1/18/14.
//  Copyright (c) 2014 Revision Works, LLC. All rights reserved.
//

#import <Parse/Parse.h>

@interface PFBadgesLookup : PFObject <PFSubclassing>

// Parse specific subclass
+(NSString *)parseClassName;

// Custom convenience methods
-(id)initWithDefaults;
-(void)setName:(NSString *)name;
-(NSString *)name;
-(void)setDescription:(NSString *)description;
-(NSString *)description;

@end
