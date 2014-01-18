//
//  PFFriend.h
//  BACHome
//
//  Created by Chase Gorectke on 1/18/14.
//  Copyright (c) 2014 Revision Works, LLC. All rights reserved.
//

#import <Parse/Parse.h>

@interface PFFriend : PFObject <PFSubclassing>
// Parse specific subclass
+(NSString *)parseClassName;

// Custom convenience methods
-(id)initWithDefaults;
-(void)setYou:(NSString *)you;
-(NSString *)you;
-(void)setI:(NSString *)i;
-(NSString *)i;
@end
