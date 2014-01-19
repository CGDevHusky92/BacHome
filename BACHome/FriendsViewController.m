//
//  FriendsViewController.m
//  BACHome
//
//  Created by Chase Gorectke on 1/17/14.
//  Copyright (c) 2014 Revision Works, LLC. All rights reserved.
//

#import "FriendsViewController.h"
#import "PFFriends.h"
#import "NSString+FontAwesome.h"

@interface FriendsViewController() <UISearchBarDelegate, UISearchDisplayDelegate>
@property (nonatomic, strong) NSMutableArray *friendsArray;
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
    
    _searching = false;
    _friendsArray = [[NSMutableArray alloc] init];
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
    
    UIImageView *image = (UIImageView *)[cell viewWithTag:100];
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:101];
    UILabel *detailLabel = (UILabel *)[cell viewWithTag:102];
    
    image.layer.cornerRadius = 20.0f;
    image.layer.masksToBounds = YES;
    image.image = [UIImage imageNamed:@"TableIcon"];
    
    if (_searching) {
        nameLabel.text = [[_searchArray objectAtIndex:[indexPath row]] objectForKey:@"username"];
        detailLabel.text = @"";
    } else {
        UIButton *callButton = (UIButton *)[cell viewWithTag:103];
        UIButton *textButton = (UIButton *)[cell viewWithTag:104];
        UIButton *ddButton = (UIButton *)[cell viewWithTag:105];
        UIButton *profileButton = (UIButton *)[cell viewWithTag:106];
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
        detailLabel.text = [NSString stringWithFormat:@"%0.2f%%", [self determineBACOfFriend:[_friendsArray objectAtIndex:[indexPath row]]]];
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
                    [_friendsArray removeAllObjects];
                    _friendsArray = [[objects sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"username" ascending:YES], nil]] mutableCopy];
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

-(CGFloat)determineBACOfFriend:(PFObject *)friend {
    
    return 0.0;
}

#pragma mark - UISearchBar Delegate

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    PFQuery *rulesQuery = [PFUser query];
    [rulesQuery whereKey:@"username" notEqualTo:[[PFUser currentUser] username]];
    for (PFFriends *friend in _friendsArray) {
        [rulesQuery whereKey:@"username" notEqualTo:[friend you]];
    }
    
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"username" equalTo:[searchBar text]];
    
    PFQuery *finalQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:rulesQuery, userQuery, nil]];
    [finalQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error) {
            if (self) {
                [_searchArray removeAllObjects];
                _searchArray = [[objects sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"username" ascending:YES], nil]] mutableCopy];
                [self.searchDisplayController.searchResultsTableView reloadData];
            }
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