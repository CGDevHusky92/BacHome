//
//  FriendsViewController.m
//  BACHome
//
//  Created by Chase Gorectke on 1/17/14.
//  Copyright (c) 2014 Revision Works, LLC. All rights reserved.
//

#import "FriendsViewController.h"
#import "PFFriends.h"

@interface FriendsViewController() <UISearchBarDelegate, UISearchDisplayDelegate>
//@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSMutableArray *friendsArray;
@property (nonatomic, strong) NSMutableArray *searchArray;
@property (atomic) BOOL searching;
@end

@implementation FriendsViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    //[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"FriendsCell"];
    [self.searchDisplayController.searchResultsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"FriendsCell"];
//    self.searchDisplayController.searchBar
    _searching = false;
    _friendsArray = [[NSMutableArray alloc] init];
    _searchArray = [[NSMutableArray alloc] init];
    
    [self loadCurrentFriends];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated {
    
    
    if (self.transitioning) {
        [super viewWillAppear:animated];
        NSLog(@"hmm");
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSString *name;
    if (_searching) {
        name = [[_searchArray objectAtIndex:[indexPath row]] objectForKey:@"username"];
    } else {
        name = [[_friendsArray objectAtIndex:[indexPath row]] objectForKey:@"you"];
    }
    
    // Configure the cell...
    cell.textLabel.text = name;
    cell.imageView.layer.cornerRadius = 20.0f;
    cell.imageView.layer.masksToBounds = YES;
    
    return cell;
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
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell.frame.size.height < 60) {
            [UIView animateWithDuration:0.1 animations:^{
                cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height * 2);
            }];
        } else {
            [UIView animateWithDuration:0.1 animations:^{
                cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height / 2);
            }];
        }
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
    [meQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error) {
            [_friendsArray removeAllObjects];
            _friendsArray = [[objects sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"you" ascending:YES], nil]] mutableCopy];
            [self.tableView reloadData];
        } else {
            NSLog(@"Error: %@", [error localizedDescription]);
        }
    }];
}

#pragma mark - UISearchBar Delegate

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    PFQuery *userQuery = [PFUser query];
    
#warning exclude self and people that are already friends...
    [userQuery whereKey:@"username" equalTo:[searchBar text]];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
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
    _searching = true;
}

-(void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    [_searchArray removeAllObjects];
    _searching = false;
    [self.tableView reloadData];
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
