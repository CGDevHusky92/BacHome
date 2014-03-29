//
//  SOSViewController.m
//  BacHome
//
//  Created by Chase Gorectke on 1/19/14.
//  Copyright (c) 2014 Revision Works, LLC. All rights reserved.
//

#import <Parse/Parse.h>
#import "SOSViewController.h"
#import "PFToasts.h"
#import "PFFriends.h"
#import "PFDrinksLookup.h"

@interface SOSViewController()
@property (nonatomic, strong) NSMutableArray *sosFriends;
@end

@implementation SOSViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    _sosFriends = [[NSMutableArray alloc] init];
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(startRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    [self generateSosFriends];
}

-(void)dealloc {
    self.tableView.tableHeaderView = nil;
}

-(void)startRefresh:(id)sender {
    [self generateSosFriends];
    [sender endRefreshing];
}

-(IBAction)donePressed:(id)sender {
    UIViewController *destController = [self.storyboard instantiateViewControllerWithIdentifier:@"CGFlowInitialScene"];
    [self.flowController flowToViewController:destController withAnimation:kCGFlowAnimationSlideDown andDuration:0.4 completion:^(BOOL finished){}];
}

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [_sosFriends count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SOSCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [[_sosFriends objectAtIndex:[indexPath row]] objectForKey:@"username"];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // Create our Installation query
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"username" equalTo:[[_sosFriends objectAtIndex:[indexPath row]] objectForKey:@"username"]];
    
    // Send push notification to query
    [PFPush sendPushMessageToQueryInBackground:pushQuery withMessage:[NSString stringWithFormat:@"%@ it looks like %@ is in need of a designated driver. Could you help them out? Tap to respond.", [[_sosFriends objectAtIndex:[indexPath row]] objectForKey:@"username"], [[PFUser currentUser] username]]];
}

-(void)generateSosFriends {
    PFQuery *meQuery = [PFQuery queryWithClassName:@"Friends"];
    [meQuery whereKey:@"me" equalTo:[[PFUser currentUser] username]];
    meQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [meQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error) {
            NSMutableArray *tempFriends = [[NSMutableArray alloc] init];
            for (PFFriends *friend in objects) {
                [tempFriends addObject:[friend you]];
            }
            PFQuery *friendQuery = [PFUser query];
            [friendQuery whereKey:@"username" containedIn:tempFriends];
            friendQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
            [friendQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
                if (!error) {
                    for (PFUser *friend in objects) {
                        [self determineBACOfFriend:friend];
                    }
                } else {
                    NSLog(@"Error: %@", [error localizedDescription]);
                }
            }];
        } else {
            NSLog(@"Error: %@", [error localizedDescription]);
        }
    }];
}

-(void)determineBACOfFriend:(PFUser *)friend {
    NSDate *now = [NSDate date];
    NSDate *nowMinusTen = [now dateByAddingTimeInterval:-10*60*60];
    PFQuery *userQuery = [PFQuery queryWithClassName:@"Toasts"];
    [userQuery whereKey:@"username" equalTo:[friend username]];
    [userQuery whereKey:@"createdAt" greaterThanOrEqualTo:nowMinusTen];
    userQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    
    PFQuery *nonDrink = [PFQuery queryWithClassName:@"Toasts"];
    [nonDrink whereKey:@"username" equalTo:[friend username]];
    [nonDrink whereKey:@"createdAt" lessThan:nowMinusTen];
    
    PFQuery *orQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:userQuery, nonDrink, nil]];
    [orQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects && [objects count] == 0) {
            if (![_sosFriends containsObject:friend]) {
                BOOL exists = NO;
                for (PFUser *aFriend in _sosFriends) {
                    if ([[aFriend username] isEqualToString:[friend username]]) {
                        exists = YES;
                        break;
                    }
                }
                if (!exists) {
                    [_sosFriends addObject:friend];
                }
            }
        }
        
        if (!error) {
            NSMutableArray *sortTime = [[objects sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO], nil]] mutableCopy];
            PFToasts *lastToast = [sortTime lastObject];
            if (lastToast) {
                NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                NSDateComponents *components = [gregorian components:NSHourCalendarUnit fromDate:[lastToast createdAt] toDate:[NSDate date] options:0];
                __block NSInteger timeHours = [components hour];
                
                NSMutableArray *drinkArray = [[NSMutableArray alloc] init];
                for (PFToasts *toast in sortTime) {
                    [drinkArray addObject:[toast drink]];
                }
                PFQuery *drinkQuery = [PFQuery queryWithClassName:@"DrinksLookup"];
                [drinkQuery whereKey:@"name" containedIn:drinkArray];
                drinkQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
                [drinkQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
                    if (!error) {
                        float std = 0.0, hours = 0.0, top = 0.0, bw = 0.0;
                        for (PFDrinksLookup *drinks in objects) {
                            std += [drinks stdDrink];
                        }
                        hours = (.017 * timeHours); top = (.806 * 1.2 * std);
                        bw = ([[friend objectForKey:@"weight"] floatValue] / 2.2046);
                        if ([[friend objectForKey:@"gender"] isEqualToString:@"male"]) { bw *= .58; }
                        else { bw *= .49; }
                        top /= bw; top -= hours;
                        
                        if (fabs(top) <= 0.02) {
                            if (![_sosFriends containsObject:friend]) {
                                BOOL exists = NO;
                                for (PFUser *aFriend in _sosFriends) {
                                    if ([[aFriend username] isEqualToString:[friend username]]) {
                                        exists = YES;
                                        break;
                                    }
                                }
                                if (!exists) {
                                    [_sosFriends addObject:friend];
                                }
                            }
                        }
                        [self.tableView reloadData];
                    } else {
//                        NSLog(@"Error: %@", [error localizedDescription]);
                    }
                }];
            }
        } else {
//            NSLog(@"Error: %@", [error localizedDescription]);
        }
    }];
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
