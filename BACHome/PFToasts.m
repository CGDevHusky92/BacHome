//
//  PFToasts.m
//  BACHome
//
//  Created by Chase Gorectke on 1/18/14.
//  Copyright (c) 2014 Revision Works, LLC. All rights reserved.
//

#import <Parse/PFObject+Subclass.h>
#import "PFToasts.h"

@implementation PFToasts

+(NSString *)parseClassName {
  	return @"Toasts";
}

-(id)initWithDefaults {
    self = [super init];
    if (self) {
        // Set defaults here
        [self setUsername:[[PFUser currentUser] username]];
        [self setObject:[NSNumber numberWithLongLong:(long long)[[NSDate date] timeIntervalSince1970]] forKey:@"timeCreated"];
    }
    return self;
}

-(void)setUsername:(NSString *)username {
    [self setObject:username forKey:@"username"];
}

-(NSString *)username {
    return [self objectForKey:@"username"];
}

-(void)setToast:(NSString *)toast {
    [self setObject:toast forKey:@"toast"];
}

-(NSString *)toast {
    return [self objectForKey:@"toast"];
}

-(void)setDrink:(NSString *)drink {
    [self setObject:drink forKey:@"drink"];
}

-(NSString *)drink {
    return [self objectForKey:@"drink"];
}

-(void)setBar:(NSString *)bar {
    [self setObject:bar forKey:@"bar"];
}

-(NSString *)bar {
    return [self objectForKey:@"bar"];
}

@end
