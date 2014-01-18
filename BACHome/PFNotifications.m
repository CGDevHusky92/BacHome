//
//  PFNotifications.m
//  BACHome
//
//  Created by Chase Gorectke on 1/18/14.
//  Copyright (c) 2014 Revision Works, LLC. All rights reserved.
//

#import <Parse/PFObject+Subclass.h>
#import "PFNotifications.h"

@implementation PFNotifications

+(NSString *)parseClassName {
  	return @"Notifications";
}

-(id)initWithDefaults {
    self = [super init];
    if (self) {
        // Set defaults here
    }
    return self;
}

-(void)setSender:(NSString *)sender {
    [self setObject:sender forKey:@"sender"];
}

-(NSString *)sender {
    return [self objectForKey:@"sender"];
}

-(void)setReceiver:(NSString *)receiver {
    [self setObject:receiver forKey:@"receiver"];
}

-(NSString *)receiver {
    return [self objectForKey:@"receiver"];
}

-(void)setType:(NSString *)type {
    [self setObject:type forKey:@"type"];
}

-(NSString *)type {
    return [self objectForKey:@"type"];
}

@end
