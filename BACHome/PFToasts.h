//
//  PFToasts.h
//  BACHome
//
//  Created by Chase Gorectke on 1/18/14.
//  Copyright (c) 2014 Revision Works, LLC. All rights reserved.
//

#import <Parse/Parse.h>

@interface PFToasts : PFObject <PFSubclassing>
// Parse specific subclass
+(NSString *)parseClassName;

// Custom convenience methods
-(id)initWithDefaults;
-(void)setUsername:(NSString *)username;
-(NSString *)username;
-(void)setToast:(NSString *)toast;
-(NSString *)toast;
-(void)setDrink:(NSString *)drink;
-(NSString *)drink;
-(void)setBar:(NSString *)bar;
-(NSString *)bar;
@end
