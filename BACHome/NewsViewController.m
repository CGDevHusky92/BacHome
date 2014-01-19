//
//  NewsViewController.m
//  BACHome
//
//  Created by Chase Gorectke on 1/17/14.
//  Copyright (c) 2014 Revision Works, LLC. All rights reserved.
//

#import "NewsViewController.h"
#import "NSString+FontAwesome.h"
#import "PFToasts.h"
#import "PFFriends.h"

@interface NewsViewController() <UINavigationControllerDelegate>
@property (nonatomic, weak) IBOutlet UIBarButtonItem *barsButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *toastButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *profileButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *sosButton;
@property (nonatomic, strong) NSMutableArray *newsArray;
-(IBAction)barsPressed:(id)sender;
-(IBAction)toastsPressed:(id)sender;
-(IBAction)profilePressed:(id)sender;
-(IBAction)sosPressed:(id)sender;
@end

@implementation NewsViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    _newsArray = [[NSMutableArray alloc] init];
    NSDictionary *fontDic = [NSDictionary dictionaryWithObject:[UIFont fontWithName:kFontAwesomeFamilyName size:20.0] forKey:NSFontAttributeName];
    [_barsButton setTitleTextAttributes:fontDic forState:UIControlStateNormal];
    [_toastButton setTitleTextAttributes:fontDic forState:UIControlStateNormal];
    [_profileButton setTitleTextAttributes:fontDic forState:UIControlStateNormal];
    [_sosButton setTitleTextAttributes:fontDic forState:UIControlStateNormal];
    
    [_barsButton setTitle:[NSString fontAwesomeIconStringForEnum:FABeer]];
    [_toastButton setTitle:[NSString fontAwesomeIconStringForEnum:FAGlass]];
    [_profileButton setTitle:[NSString fontAwesomeIconStringForEnum:FAUsers]];
    [_sosButton setTitle:[NSString fontAwesomeIconStringForEnum:FAExclamationTriangle]];
    [self generateNewsFeedData];
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
    [self.flowController flowModalViewController:destController completion:^(BOOL finished){}];
}

-(IBAction)profilePressed:(id)sender {
    UIViewController *destController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileView"];
    [self.flowController flowToViewController:destController withAnimation:kCGFlowAnimationSlideUp completion:^(BOOL finished){}];
}

-(IBAction)sosPressed:(id)sender {
    
}

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_newsArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"NewsCell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithWhite:0.99 alpha:0.99];
    cell.layer.masksToBounds = NO;
    cell.layer.shadowOffset = CGSizeMake(-5, 10);
    cell.layer.shadowRadius = 3;
    cell.layer.shadowOpacity = 0.5;
    cell.layer.shadowPath = [UIBezierPath bezierPathWithRect:cell.bounds].CGPath;
    
    // Configure the cell...
    PFToasts *toast = [_newsArray objectAtIndex:[indexPath row]];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:100];
    UILabel *name = (UILabel *)[cell viewWithTag:101];
    UILabel *drinkBar = (UILabel *)[cell viewWithTag:102];
    UILabel *toastQuote = (UILabel *)[cell viewWithTag:103];
    
    imageView.layer.cornerRadius = 20.0f;
    imageView.layer.masksToBounds = YES;
    imageView.image = [UIImage imageNamed:@"TableIcon"];
    name.text = toast.username;
    drinkBar.text = [NSString stringWithFormat:@"Drinking %@ @ %@", toast.drink, toast.bar];
    toastQuote.text = toast.toast;
    
    return cell;
}

-(void)generateNewsFeedData {
    if ([PFUser currentUser]) {
        PFQuery *friendQuery = [PFQuery queryWithClassName:@"Friends"];
        [friendQuery whereKey:@"me" equalTo:[[PFUser currentUser] username]];
        friendQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
        [friendQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
            if (!error) {
                NSMutableArray *tempArray = [[NSMutableArray alloc] init];
                [tempArray addObject:[[PFUser currentUser] username]];
                for (PFFriends *friend in objects) {
                    [tempArray addObject:[friend you]];
                }
                PFQuery *toastQuery = [PFQuery queryWithClassName:@"Toasts"];
                [toastQuery whereKey:@"username" containedIn:tempArray];
                toastQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
                [toastQuery findObjectsInBackgroundWithBlock:^(NSArray *newObjects, NSError *error){
                    if (!error) {
                        [_newsArray removeAllObjects];
                        _newsArray = [[newObjects sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO], nil]] mutableCopy];
                        [self.collectionView reloadData];
                    } else {
                        NSLog(@"Error: %@", [error localizedDescription]);
                    }
                }];
            } else {
                NSLog(@"Error: %@", [error localizedDescription]);
            }
        }];
    }
}

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