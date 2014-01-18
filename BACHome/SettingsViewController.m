//
//  SettingsViewController.m
//  BACHome
//
//  Created by Chase Gorectke on 1/17/14.
//  Copyright (c) 2014 Revision Works, LLC. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController()
-(IBAction)donePressed:(id)sender;
@end

@implementation SettingsViewController

-(void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

#pragma mark - Button Delegate

-(IBAction)donePressed:(id)sender {
    UIViewController *destController = [self.storyboard instantiateViewControllerWithIdentifier:@"CGFlowInitialScene"];
    [self.flowController flowToViewController:destController withAnimation:kCGFlowAnimationSlideDown completion:^(BOOL finished){}];
}

#pragma mark - Memory Methods

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end