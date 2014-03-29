//
//  BarsViewController.m
//  BACHome
//
//  Created by Chase Gorectke on 1/17/14.
//  Copyright (c) 2014 Revision Works, LLC. All rights reserved.
//

#import <Parse/Parse.h>
#import "BarsViewController.h"
#import "PFBarsLookup.h"

@interface BarsViewController()
@property (nonatomic, strong) NSMutableArray *barsArray;
-(IBAction)addPressed:(id)sender;
-(IBAction)donePressed:(id)sender;
@end

@implementation BarsViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    _barsArray = [[NSMutableArray alloc] init];
    self.collectionView.alwaysBounceVertical = YES;
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(startRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:refreshControl];
    [self generateBarData];
	// Do any additional setup after loading the view.
}

-(void)startRefresh:(id)sender {
    [self generateBarData];
    [sender endRefreshing];
}

#pragma mark - UICollectionViewDelegate

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_barsArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"BarCells";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithWhite:0.99 alpha:0.99];
    cell.layer.masksToBounds = NO;
    cell.layer.shadowOffset = CGSizeMake(-5, 10);
    cell.layer.shadowRadius = 3;
    cell.layer.shadowOpacity = 0.5;
    cell.layer.shadowPath = [UIBezierPath bezierPathWithRect:cell.bounds].CGPath;
    
    // Configure the cell...
    PFBarsLookup *bar = [_barsArray objectAtIndex:[indexPath row]];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:100];
    UILabel *barName = (UILabel *)[cell viewWithTag:101];
    UILabel *barDescription = (UILabel *)[cell viewWithTag:102];
    
    barName.text = [bar name];
    barDescription.text = [bar description];
    
    imageView.layer.cornerRadius = 20.0f;
    imageView.layer.masksToBounds = YES;
    imageView.image = [UIImage imageNamed:@"TableIcon"];
    
    return cell;
}

#pragma mark - Button Delegate

-(IBAction)addPressed:(id)sender {
    
}

-(IBAction)donePressed:(id)sender {
    UIViewController *destController = [self.storyboard instantiateViewControllerWithIdentifier:@"CGFlowInitialScene"];
    [self.flowController flowToViewController:destController withAnimation:kCGFlowAnimationSlideDown andDuration:0.4 completion:^(BOOL finished){}];
}

-(void)generateBarData {
    PFQuery *barQuery = [PFQuery queryWithClassName:@"BarsLookup"];
    [barQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error) {
            _barsArray = [[objects sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES], nil]] mutableCopy];
            [self.collectionView reloadData];
        } else {
            NSLog(@"Error: %@", [error localizedDescription]);
        }
    }];
}

#pragma mark - Memory Methods

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end