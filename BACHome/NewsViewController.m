//
//  NewsViewController.m
//  BACHome
//
//  Created by Chase Gorectke on 1/17/14.
//  Copyright (c) 2014 Revision Works, LLC. All rights reserved.
//

#import "NewsViewController.h"

@interface NewsViewController() <UINavigationControllerDelegate>
@property (nonatomic, strong) NSMutableArray *newsArray;
-(IBAction)barsPressed:(id)sender;
-(IBAction)toastsPressed:(id)sender;
-(IBAction)profilePressed:(id)sender;
-(IBAction)settingsPressed:(id)sender;
@end

@implementation NewsViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    _newsArray = [[NSMutableArray alloc] init];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated {
    if (self.transitioning) {
        [super viewWillAppear:animated];
        
    }
}

-(void)viewDidAppear:(BOOL)animated {
    if (self.transitioning) {
        if (![PFUser currentUser]) {
            UIViewController *loginController = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginView"];
            [self.flowController flowToViewController:loginController withAnimation:kCGFlowAnimationSlideUp completion:^(BOOL finished){}];
        }
        [super viewDidAppear:animated];
    }
}

#pragma mark - Button Delegate

-(IBAction)barsPressed:(id)sender {
    UIViewController *destController = [self.storyboard instantiateViewControllerWithIdentifier:@"BarsView"];
    [self.flowController flowToViewController:destController withAnimation:kCGFlowAnimationSlideUp completion:^(BOOL finished){}];
}

-(IBAction)toastsPressed:(id)sender {
    UIViewController *destController = [self.storyboard instantiateViewControllerWithIdentifier:@"ToastsView"];
    [self.flowController flowToViewController:destController withAnimation:kCGFlowAnimationSlideUp completion:^(BOOL finished){}];
}

-(IBAction)profilePressed:(id)sender {
    UIViewController *destController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileView"];
    [self.flowController flowToViewController:destController withAnimation:kCGFlowAnimationSlideUp completion:^(BOOL finished){}];
}

-(IBAction)settingsPressed:(id)sender {
    UIViewController *destController = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsView"];
    [self.flowController flowToViewController:destController withAnimation:kCGFlowAnimationSlideUp completion:^(BOOL finished){}];
}

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [_newsArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"NewsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
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

#pragma mark - CGInteractiveTransitionDelegate methods

-(void)proceedToNextViewControllerWithTransition:(kCGFlowInteractionType)type {
    UIViewController *destController;
    if (type == kCGFlowInteractionSwipeLeft) {
        destController = [self.storyboard instantiateViewControllerWithIdentifier:@"NotificationsView"];
        [self.flowController flowInteractivelyToViewController:destController withAnimation:kCGFlowAnimationSlideLeft completion:^(BOOL finished){}];
    } else if (type == kCGFlowInteractionSwipeRight) {
        destController = [self.storyboard instantiateViewControllerWithIdentifier:@"FriendsView"];
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