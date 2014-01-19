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

@interface NotificationsViewController() <UINavigationControllerDelegate>
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

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_notificationsArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"NotificationCell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor colorWithWhite:0.99 alpha:0.99];
    cell.layer.masksToBounds = NO;
    cell.layer.shadowOffset = CGSizeMake(-5, 10);
    cell.layer.shadowRadius = 5;
    cell.layer.shadowOpacity = 0.5;
    cell.layer.shadowPath = [UIBezierPath bezierPathWithRect:cell.bounds].CGPath;
    
    // Configure the cell...
    PFNotifications *notification = [_notificationsArray objectAtIndex:[indexPath row]];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:100];
    UILabel *message = (UILabel *)[cell viewWithTag:101];
    
    imageView.layer.cornerRadius = 20.0f;
    imageView.layer.masksToBounds = YES;
    imageView.image = [UIImage imageNamed:@"TableIcon"];
    
    // Configure the cell...
    if ([[notification type] isEqualToString:@"sos"]) {
        message.text = [NSString stringWithFormat:@"%@ it looks like %@ is in need of a designated driver. Could you help them out? Tap to respond.", [[PFUser currentUser] username], notification.sender];
    } else if ([[notification type] isEqualToString:@"warning"]) {
        message.text = @"Hey it looks like you need a designated driver! Tap for some help!";
    } else if ([[notification type] isEqualToString:@"friend"]) {
        message.text = [NSString stringWithFormat:@"Hey %@ is following you now! Tap to follow them back.", [notification sender]];
    } else if ([[notification type] isEqualToString:@"badge"]) {
        message.text = @"Congratulations! You received a badge!";
    }
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PFNotifications *notification = [_notificationsArray objectAtIndex:[indexPath row]];
    if ([[notification type] isEqualToString:@"sos"]) {
        
    } else if ([[notification type] isEqualToString:@"warning"]) {
        
    } else if ([[notification type] isEqualToString:@"friend"]) {
        
    }
}

#pragma mark - General Parse calls

-(void)generateListOfNotifications {
    PFQuery *notificationQuery = [PFQuery queryWithClassName:@"Notifications"];
    [notificationQuery whereKey:@"receiver" equalTo:[[PFUser currentUser] username]];
    notificationQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [notificationQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error) {
            [_notificationsArray removeAllObjects];
            _notificationsArray = [[objects sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO], nil]] mutableCopy];
            [self.collectionView reloadData];
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

#pragma mark - UINavigationControllerDelegate

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([viewController isEqual:self]) {
        [viewController viewWillAppear:animated];
    } else if ([viewController conformsToProtocol:@protocol(UINavigationControllerDelegate)]) {
        // Set the navigation controller delegate to the passed-in view controller and call the UINavigationViewControllerDelegate method on the new delegate.
        [navigationController setDelegate:(id<UINavigationControllerDelegate>)viewController];
        [[navigationController delegate] navigationController:navigationController willShowViewController:viewController animated:YES];
    }
}

-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([viewController isEqual:self]) {
        [self viewDidAppear:animated];
    }
}

#pragma mark - Memory Methods

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end