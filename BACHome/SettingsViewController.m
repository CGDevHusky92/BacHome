//
//  SettingsViewController.m
//  BACHome
//
//  Created by Chase Gorectke on 1/17/14.
//  Copyright (c) 2014 Revision Works, LLC. All rights reserved.
//

#import <Parse/Parse.h>
#import "SettingsViewController.h"

@interface SettingsViewController()
-(IBAction)donePressed:(id)sender;
-(IBAction)logoutPressed:(id)sender;
@end

@implementation SettingsViewController

-(void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

#pragma mark - Button Delegate

-(IBAction)donePressed:(id)sender {
    UIViewController *destController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileView"];
    [self.flowController flowToViewController:destController withAnimation:kCGFlowAnimationSlideDown andDuration:0.4 completion:^(BOOL finished){}];
}

-(IBAction)logoutPressed:(id)sender {
    [PFUser logOut];
    UIViewController *loginController = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginView"];
    [self.flowController flowToViewController:loginController withAnimation:kCGFlowAnimationSlideUp andDuration:0.4 completion:^(BOOL finished){}];
}

#pragma mark - Memory Methods

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end