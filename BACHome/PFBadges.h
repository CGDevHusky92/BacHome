//
//  PFBadges.h
//  BACHome
//
//  Created by Chase Gorectke on 1/18/14.
//  Copyright (c) 2014 Revision Works, LLC. All rights reserved.
//

#import <Parse/Parse.h>

@interface PFBadges : PFObject <PFSubclassing>

// Parse specific subclass
+(NSString *)parseClassName;

// Custom convenience methods
-(id)initWithDefaults;
-(void)setName:(NSString *)name;
-(NSString *)name;
-(void)setUsername:(NSString *)username;
-(NSString *)username;

@end
