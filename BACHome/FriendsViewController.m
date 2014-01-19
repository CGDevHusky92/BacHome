//
//  FriendsViewController.m
//  BACHome
//
//  Created by Chase Gorectke on 1/17/14.
//  Copyright (c) 2014 Revision Works, LLC. All rights reserved.
//

#import "FriendsViewController.h"
#import "PFFriends.h"
#import "PFToasts.h"
#import "PFDrinksLookup.h"
#import "NSString+FontAwesome.h"

@interface FriendsViewController() <UISearchBarDelegate, UISearchDisplayDelegate>
@property (nonatomic, strong) NSMutableArray *friendsArray;
@property (nonatomic, strong) NSMutableArray *bacArray;
@property (nonatomic, strong) NSMutableArray *searchArray;
@property (assign) int selectedIndex;
@property (atomic) BOOL searching;
-(IBAction)callPressed:(id)sender;
-(IBAction)textPressed:(id)sender;
-(IBAction)ddPressed:(id)sender;
-(IBAction)profilePressed:(id)sender;
@end

@implementation FriendsViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    [self.searchDisplayController.searchResultsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"FriendsCell"];
    
    _searching = false;
    _friendsArray = [[NSMutableArray alloc] init];
    _bacArray = [[NSMutableArray alloc] init];
    _searchArray = [[NSMutableArray alloc] init];
    _selectedIndex = -1;
    [self loadCurrentFriends];
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

-(void)dealloc {
    self.tableView.tableHeaderView = nil;
}

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (_searching) {
        return [_searchArray count];
    }
    return [_friendsArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"FriendsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (_searching) {
        cell.textLabel.text = [[_searchArray objectAtIndex:[indexPath row]] objectForKey:@"username"];
        cell.detailTextLabel.text = @"";
        cell.imageView.image = [UIImage imageNamed:@"TableIcon"];
    } else {
        UIImageView *image = (UIImageView *)[cell viewWithTag:100];
        UILabel *nameLabel = (UILabel *)[cell viewWithTag:101];
        UILabel *detailLabel = (UILabel *)[cell viewWithTag:102];
        UIButton *callButton = (UIButton *)[cell viewWithTag:103];
        UIButton *textButton = (UIButton *)[cell viewWithTag:104];
        UIButton *ddButton = (UIButton *)[cell viewWithTag:105];
        UIButton *profileButton = (UIButton *)[cell viewWithTag:106];
        
        image.image = [UIImage imageNamed:@"TableIcon"];
        [callButton.titleLabel setFont:[UIFont fontWithName:kFontAwesomeFamilyName size:24.0]];
        [callButton setTitle:[NSString fontAwesomeIconStringForEnum:FAPhoneSquare] forState:UIControlStateNormal];
        [callButton addTarget:self action:@selector(callPressed:) forControlEvents:UIControlEventTouchUpInside];
        [textButton.titleLabel setFont:[UIFont fontWithName:kFontAwesomeFamilyName size:24.0]];
        [textButton setTitle:[NSString fontAwesomeIconStringForEnum:FAComment] forState:UIControlStateNormal];
        [textButton addTarget:self action:@selector(textPressed:) forControlEvents:UIControlEventTouchUpInside];
        [ddButton.titleLabel setFont:[UIFont fontWithName:kFontAwesomeFamilyName size:24.0]];
        [ddButton setTitle:[NSString fontAwesomeIconStringForEnum:FACloudUpload] forState:UIControlStateNormal];
        [ddButton addTarget:self action:@selector(ddPressed:) forControlEvents:UIControlEventTouchUpInside];
        [profileButton.titleLabel setFont:[UIFont fontWithName:kFontAwesomeFamilyName size:24.0]];
        [profileButton setTitle:[NSString fontAwesomeIconStringForEnum:FAUser] forState:UIControlStateNormal];
        [profileButton addTarget:self action:@selector(profilePressed:) forControlEvents:UIControlEventTouchUpInside];
        
        nameLabel.text = [[_friendsArray objectAtIndex:[indexPath row]] objectForKey:@"username"];
        if ([_bacArray objectAtIndex:[indexPath row]]) {
            detailLabel.text = [NSString stringWithFormat:@"%0.2f%%", [[_bacArray objectAtIndex:[indexPath row]] floatValue]];
        } else {
            detailLabel.text = @"0.00%";
        }
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!_searching && _selectedIndex == [indexPath row]) {
        return 88.0;
    }
    return 44.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_searching) {
        // Create and add new friend
        PFFriends *friend = [[PFFriends alloc] initWithDefaults];
        [friend setYou:[[_searchArray objectAtIndex:[indexPath row]] objectForKey:@"username"]];
        [friend saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
            if (succeeded) {
                _searching = false;
                [self loadCurrentFriends];
            } else {
                NSLog(@"Error: %@", [error localizedDescription]);
            }
        }];
        [self.searchDisplayController setActive:NO animated:YES];
    } else {
        // open menu call text dd profile
        if (indexPath.row == _selectedIndex) {
            _selectedIndex = -1;
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            return;
        }
        if (_selectedIndex >= 0) {
            NSIndexPath *previousPath = [NSIndexPath indexPathForRow:_selectedIndex inSection:[indexPath section]];
            _selectedIndex = (int)indexPath.row;
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:previousPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        //Finally set the selected index to the new selection and reload it to expand
        _selectedIndex = (int)indexPath.row;
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
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

-(void)loadCurrentFriends {
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
                    [_bacArray removeAllObjects];
                    [_friendsArray removeAllObjects];
                    _friendsArray = [[objects sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"username" ascending:YES], nil]] mutableCopy];
                    for (PFUser *friend in _friendsArray) {
                        [_bacArray addObject:[NSNumber numberWithFloat:0.0]];
                    }
                    for (PFUser *friend in _friendsArray) {
                        [self determineBACOfFriend:friend];
                    }
                    [self.tableView reloadData];
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
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
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
                        if ([[[PFUser currentUser] objectForKey:@"gender"] isEqualToString:@"male"]) { bw *= .58; }
                        else { bw *= .49; }
                        top /= bw; top -= hours;
                        for (int i = 0; i < [_friendsArray count]; i++) {
                            if ([[[_friendsArray objectAtIndex:i] objectForKey:@"username"] isEqualToString:[friend username]]) {
                                [_bacArray replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:fabs(top)]];
                                break;
                            }
                        }
                        [self.tableView reloadData];
                    } else {
                        NSLog(@"Error: %@", [error localizedDescription]);
                    }
                }];
            }
        } else {
            NSLog(@"Error: %@", [error localizedDescription]);
        }
    }];
}

#pragma mark - UISearchBar Delegate

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    PFQuery *rulesQuery = [PFUser query];
    [rulesQuery whereKey:@"username" notEqualTo:[[PFUser currentUser] username]];
    for (PFUser *friend in _friendsArray) {
        [rulesQuery whereKey:@"username" notEqualTo:[friend username]];
    }
    [rulesQuery whereKey:@"username" equalTo:[searchBar text]];
    [rulesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error) {
            [_searchArray removeAllObjects];
            _searchArray = [[objects sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"username" ascending:YES], nil]] mutableCopy];
            [self.searchDisplayController.searchResultsTableView reloadData];
        } else {
            NSLog(@"Error: %@", [error localizedDescription]);
        }
    }];
}

-(void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    if (_selectedIndex != -1) {
        [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:_selectedIndex inSection:0]];
    }
    _searching = true;
}

-(void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    [_searchArray removeAllObjects];
    _searching = false;
    [self.tableView reloadData];
}

#pragma mark - TableCellButtonDelegate

-(IBAction)callPressed:(id)sender {
    NSLog(@"Call Pressed");
}

-(IBAction)textPressed:(id)sender {
    NSLog(@"Text Pressed");
}

-(IBAction)ddPressed:(id)sender {
    NSLog(@"DD Pressed");
}

-(IBAction)profilePressed:(id)sender {
    NSLog(@"Profile Pressed");
}

#pragma mark - CGInteractiveTransitionDelegate methods

-(void)proceedToNextViewControllerWithTransition:(kCGFlowInteractionType)type {
    UIViewController *destController;
    if (type == kCGFlowInteractionSwipeLeft) {
        destController = [self.storyboard instantiateViewControllerWithIdentifier:@"CGFlowInitialScene"];
        [self.flowController flowInteractivelyToViewController:destController withAnimation:kCGFlowAnimationSlideLeft completion:^(BOOL finished){}];
    }
}

#pragma mark - Memory Methods

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end