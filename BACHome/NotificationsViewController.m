//
//  NotificationsViewController.m
//  BACHome
//
//  Created by Chase Gorectke on 1/17/14.
//  Copyright (c) 2014 Revision Works, LLC. All rights reserved.
//

#import <Parse/Parse.h>
#import "NotificationsViewController.h"
#import "PFNotifications.h"

@interface NotificationsViewController()
@property (nonatomic, strong) NSMutableArray *notificationsArray;
@end

@implementation NotificationsViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    _notificationsArray = [[NSMutableArray alloc] init];
    [self generateListOfNotifications];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [_notificationsArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"NotificationCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSString *type = @"";
    PFNotifications *notification = [_notificationsArray objectAtIndex:[indexPath row]];
    if ([[notification type] isEqualToString:@"sos"]) {
        type = @"sos";
    } else if ([[notification type] isEqualToString:@"warning"]) {
        type = @"warning";
    } else if ([[notification type] isEqualToString:@"friend"]) {
        type = @"friend";
    } else if ([[notification type] isEqualToString:@"badge"]) {
        type = @"badge";
    }
    
    cell.textLabel.text = type;
    return cell;
}

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

-(void)generateListOfNotifications {
    PFQuery *notificationQuery = [PFQuery queryWithClassName:@"Notifications"];
    [notificationQuery whereKey:@"receiver" equalTo:[[PFUser currentUser] username]];
    notificationQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [notificationQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error) {
            [_notificationsArray removeAllObjects];
            _notificationsArray = [[objects sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO], nil]] mutableCopy];
            [self.tableView reloadData];
        } else {
            NSLog(@"Error: %@", [error localizedDescription]);
        }
    }];
}

#pragma mark - CGInteractiveTransitionDelegate methods

-(void)proceedToNextViewControllerWithTransition:(kCGFlowInteractionType)type {
    UIViewController *destController;
    if (type == kCGFlowInteractionSwipeRight) {
        destController = [self.storyboard instantiateViewControllerWithIdentifier:@"CGFlowInitialScene"];
        [self.flowController flowInteractivelyToViewController:destController withAnimation:kCGFlowAnimationSlideRight completion:^(BOOL finished){}];
    }
}

#pragma mark - Memory Methods

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end