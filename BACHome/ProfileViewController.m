//
//  ProfileViewController.m
//  BACHome
//
//  Created by Chase Gorectke on 1/17/14.
//  Copyright (c) 2014 Revision Works, LLC. All rights reserved.
//

#import <Parse/Parse.h>
#import "ProfileViewController.h"

@interface ProfileViewController()
@property (nonatomic, weak) IBOutlet UITextField *firstField;
@property (nonatomic, weak) IBOutlet UITextField *lastField;
@property (nonatomic, weak) IBOutlet UITextField *userField;
@property (nonatomic, weak) IBOutlet UITextField *emailField;
@property (nonatomic, weak) IBOutlet UITextField *weightField;
@property (nonatomic, weak) IBOutlet UITextField *areaField;
@property (nonatomic, weak) IBOutlet UITextField *threeField;
@property (nonatomic, weak) IBOutlet UITextField *fourField;
@property (nonatomic, weak) IBOutlet UISegmentedControl *genderSegment;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *userLabel;
@property (nonatomic, weak) IBOutlet UILabel *emailLabel;
@property (nonatomic, weak) IBOutlet UILabel *phoneLabel;
@property (nonatomic, weak) IBOutlet UILabel *weightLabel;
@property (nonatomic, weak) IBOutlet UILabel *genderLabel;
@property (nonatomic, weak) IBOutlet UILabel *topDrinkLabel;
@property (nonatomic, weak) IBOutlet UILabel *badgesLabel;
@property (nonatomic, weak) IBOutlet UILabel *nameDLabel;
@property (nonatomic, weak) IBOutlet UILabel *userDLabel;
@property (nonatomic, weak) IBOutlet UILabel *emailDLabel;
@property (nonatomic, weak) IBOutlet UILabel *phoneDLabel;
@property (nonatomic, weak) IBOutlet UILabel *weightDLabel;
@property (nonatomic, weak) IBOutlet UILabel *genderDLabel;
@property (nonatomic, weak) IBOutlet UILabel *topDrinkDLabel;
@property (nonatomic, weak) IBOutlet UILabel *badgesDLabel;
@property (nonatomic, weak) IBOutlet UILabel *lParenLabel;
@property (nonatomic, weak) IBOutlet UILabel *rParenLabel;
@property (nonatomic, weak) IBOutlet UILabel *dashLabel;
@property (nonatomic, weak) IBOutlet UIImageView *placeImage;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *editButton;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIBarButtonItem *doneEditButton;
-(IBAction)donePressed:(id)sender;
-(IBAction)editPressed:(id)sender;
-(IBAction)settingsPressed:(id)sender;
@end

@implementation ProfileViewController

-(void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _doneEditButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneEditPressed:)];
    [self refreshLabels];
}

#pragma mark - Button Delegate

-(IBAction)donePressed:(id)sender {
    UIViewController *destController = [self.storyboard instantiateViewControllerWithIdentifier:@"CGFlowInitialScene"];
    [self.flowController flowToViewController:destController withAnimation:kCGFlowAnimationSlideDown completion:^(BOOL finished){}];
}

-(IBAction)editPressed:(id)sender {
    UINavigationItem *doneItem = [[UINavigationItem alloc] initWithTitle:@"Profile"];
    doneItem.hidesBackButton = YES;
    doneItem.leftBarButtonItem = _doneEditButton;
    [self.navigationController.navigationBar pushNavigationItem:doneItem animated:NO];
    [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        [_placeImage setCenter:CGPointMake(_placeImage.center.x - 89, _placeImage.center.y)];
        [_nameLabel setAlpha:0.0];
        [_nameDLabel setAlpha:0.0];
        [_userLabel setAlpha:0.0];
        [_userDLabel setAlpha:0.0];
        [_emailLabel setAlpha:0.0];
        [_emailDLabel setAlpha:0.0];
        [_phoneLabel setAlpha:0.0];
        [_phoneDLabel setAlpha:0.0];
        [_weightLabel setAlpha:0.0];
        [_genderLabel setAlpha:0.0];
        [_topDrinkLabel setAlpha:0.0];
        [_badgesLabel setAlpha:0.0];
        [_weightDLabel setAlpha:0.0];
        [_genderDLabel setAlpha:0.0];
        [_topDrinkDLabel setAlpha:0.0];
        [_badgesDLabel setAlpha:0.0];
    } completion:^(BOOL finished){
        [_firstField setHidden:NO];
        [_lastField setHidden:NO];
        [_userField setHidden:NO];
        [_emailField setHidden:NO];
        [_weightField setHidden:NO];
        [_lParenLabel setHidden:NO];
        [_areaField setHidden:NO];
        [_rParenLabel setHidden:NO];
        [_threeField setHidden:NO];
        [_dashLabel setHidden:NO];
        [_fourField setHidden:NO];
        [_genderSegment setHidden:NO];
        [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            [_firstField setAlpha:1.0];
            [_lastField setAlpha:1.0];
            [_userField setAlpha:1.0];
            [_emailField setAlpha:1.0];
            [_weightField setAlpha:1.0];
            [_lParenLabel setAlpha:1.0];
            [_areaField setAlpha:1.0];
            [_rParenLabel setAlpha:1.0];
            [_threeField setAlpha:1.0];
            [_dashLabel setAlpha:1.0];
            [_fourField setAlpha:1.0];
            [_genderSegment setAlpha:1.0];
        } completion:^(BOOL finished){}];
    }];
}

-(IBAction)settingsPressed:(id)sender {
    UIViewController *destController = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsView"];
    [self.flowController flowToViewController:destController withAnimation:kCGFlowAnimationSlideUp completion:^(BOOL finished){}];
}

#pragma mark - View Delegate

-(void)refreshLabels {
    [UIView animateWithDuration:0.0 delay:0.0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        if (![[[PFUser currentUser] objectForKey:@"f_name"] isEqualToString:@""]) {
            [_firstField setText:[[PFUser currentUser] objectForKey:@"f_name"]];
        }
        if (![[[PFUser currentUser] objectForKey:@"l_name"] isEqualToString:@""]) {
            [_lastField setText:[[PFUser currentUser] objectForKey:@"l_name"]];
        }
        
        if (![[[PFUser currentUser] objectForKey:@"f_name"] isEqualToString:@""] || ![[[PFUser currentUser] objectForKey:@"l_name"] isEqualToString:@""]) {
            if (![[[PFUser currentUser] objectForKey:@"f_name"] isEqualToString:@""] && ![[[PFUser currentUser] objectForKey:@"l_name"] isEqualToString:@""]) {
                [_nameLabel setText:[NSString stringWithFormat:@"%@ %@", [[PFUser currentUser] objectForKey:@"f_name"], [[PFUser currentUser] objectForKey:@"l_name"]]];
            } else if (![[[PFUser currentUser] objectForKey:@"f_name"] isEqualToString:@""]) {
                [_nameLabel setText:[[PFUser currentUser] objectForKey:@"f_name"]];
            } else if (![[[PFUser currentUser] objectForKey:@"l_name"] isEqualToString:@""]) {
                [_nameLabel setText:[[PFUser currentUser] objectForKey:@"l_name"]];
            }
        } else {
            // move all other labels up
            [_nameLabel setText:@"No Name"];
        }
        
        if (![[[PFUser currentUser] objectForKey:@"phone"] isEqualToString:@""]) {
            [_areaField setText:[[[PFUser currentUser] objectForKey:@"phone"] substringToIndex:3]];
            [_threeField setText:[[[PFUser currentUser] objectForKey:@"phone"] substringWithRange:NSMakeRange(3, 3)]];
            [_fourField setText:[[[PFUser currentUser] objectForKey:@"phone"] substringFromIndex:6]];
            [_phoneLabel setText:[NSString stringWithFormat:@"(%@) %@-%@",[[[PFUser currentUser] objectForKey:@"phone"] substringToIndex:3], [[[PFUser currentUser] objectForKey:@"phone"] substringWithRange:NSMakeRange(3, 3)], [[[PFUser currentUser] objectForKey:@"phone"] substringFromIndex:6]]];
        } else {
            [_phoneLabel setText:@"No Phone"];
        }
        
        if (![[[PFUser currentUser] email] isEqualToString:@""]) {
            [_emailField setText:[[PFUser currentUser] email]];
            [_emailLabel setText:[[PFUser currentUser] email]];
        } else {
            [_emailLabel setText:@"No Email"];
        }
        
        if ([[PFUser currentUser] objectForKey:@"weight"]) {
            [_weightField setText:[NSString stringWithFormat:@"%d", [[[PFUser currentUser] objectForKey:@"weight"] intValue]]];
            [_weightLabel setText:[NSString stringWithFormat:@"%d", [[[PFUser currentUser] objectForKey:@"weight"] intValue]]];
        } else {
            [_emailLabel setText:@"No Weight"];
        }
        
        if (![[[PFUser currentUser] objectForKey:@"gender"] isEqualToString:@""]) {
            [_weightField setText:[[PFUser currentUser] objectForKey:@"gender"]];
            [_weightLabel setText:[[PFUser currentUser] objectForKey:@"gender"]];
        } else {
            [_emailLabel setText:@"No Gender"];
        }
        
#warning top drink as call
        [_topDrinkLabel setText:@"No Top Drink"];
        
#warning badges with string
        [_badgesLabel setText:@"No Badges"];
        
        if (![[[PFUser currentUser] username] isEqualToString:@""]) {
            [_userField setText:[[PFUser currentUser] username]];
            [_userLabel setText:[[PFUser currentUser] username]];
        }
    } completion:^(BOOL finished){}];
}

-(void)save {
    BOOL save = false;
    if (![[[PFUser currentUser] objectForKey:@"f_name"] isEqualToString:[_firstField text]] && ![[_firstField text] isEqualToString:@""]) {
        save = true;
        [[PFUser currentUser] setObject:[_firstField text] forKey:@"f_name"];
    }
    if (![[[PFUser currentUser] objectForKey:@"l_name"] isEqualToString:[_lastField text]] && ![[_lastField text] isEqualToString:@""]) {
        save = true;
        [[PFUser currentUser] setObject:[_lastField text] forKey:@"l_name"];
    }
    if (![[[PFUser currentUser] objectForKey:@"phone"] isEqualToString:[NSString stringWithFormat:@"%@%@%@", [_areaField text], [_threeField text], [_fourField text]]] && ![[NSString stringWithFormat:@"%@%@%@", [_areaField text], [_threeField text], [_fourField text]] isEqualToString:@""]) {
        save = true;
        [[PFUser currentUser] setObject:[NSString stringWithFormat:@"%@%@%@", [_areaField text], [_threeField text], [_fourField text]] forKey:@"phone"];
    }
    if (![[[PFUser currentUser] email] isEqualToString:[_emailField text]] && ![[_emailField text] isEqualToString:@""]) {
        save = true;
        [[PFUser currentUser] setEmail:[_emailField text]];
    }
    
    int newWeight = [[_weightField text] intValue];
    if ([[[PFUser currentUser] objectForKey:@"weight"] intValue] != newWeight) {
        save = true;
        [[PFUser currentUser] setObject:[NSNumber numberWithInt:newWeight] forKey:@"weight"];
    }
    NSString *curGender = [[PFUser currentUser] objectForKey:@"gender"];
    NSString *selGender;
    if ([_genderSegment selectedSegmentIndex] == 0) {
        selGender = @"male";
    } else {
        selGender = @"female";
    }
    if (![curGender isEqualToString:selGender]) {
        save = true;
        [[PFUser currentUser] setObject:selGender forKey:@"gender"];
    }
    
    if (save) {
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
            if (!succeeded) {
                NSLog(@"Error: %@", [error localizedDescription]);
                [[PFUser currentUser] saveEventually];
            }
        }];
    }
}

-(IBAction)doneEditPressed:(id)sender {
    if ([_firstField isFirstResponder] || [_lastField isFirstResponder] || [_emailField isFirstResponder] || [_areaField isFirstResponder] || [_threeField isFirstResponder] || [_fourField isFirstResponder] || [_weightField isFirstResponder]) {
        [_firstField resignFirstResponder];
        [_lastField resignFirstResponder];
        [_emailField resignFirstResponder];
        [_areaField resignFirstResponder];
        [_threeField resignFirstResponder];
        [_fourField resignFirstResponder];
        [_weightField resignFirstResponder];
    } else {
        [self save];
        UINavigationItem *doneItem = [[UINavigationItem alloc] initWithTitle:@"Profile"];
        doneItem.hidesBackButton = YES;
        doneItem.leftBarButtonItem = _editButton;
        doneItem.rightBarButtonItem = _doneButton;
        [self.navigationController.navigationBar pushNavigationItem:doneItem animated:NO];
        
        [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            [_firstField setAlpha:0.0];
            [_lastField setAlpha:0.0];
            [_userField setAlpha:0.0];
            [_emailField setAlpha:0.0];
            [_weightField setAlpha:0.0];
            [_lParenLabel setAlpha:0.0];
            [_areaField setAlpha:0.0];
            [_rParenLabel setAlpha:0.0];
            [_threeField setAlpha:0.0];
            [_dashLabel setAlpha:0.0];
            [_fourField setAlpha:0.0];
            [_genderSegment setAlpha:0.0];
        } completion:^(BOOL finished){
            [_firstField setHidden:YES];
            [_lastField setHidden:YES];
            [_userField setHidden:YES];
            [_emailField setHidden:YES];
            [_weightField setHidden:YES];
            [_lParenLabel setHidden:YES];
            [_areaField setHidden:YES];
            [_rParenLabel setHidden:YES];
            [_threeField setHidden:YES];
            [_dashLabel setHidden:YES];
            [_fourField setHidden:YES];
            [_genderSegment setHidden:YES];
            [self refreshLabels];
            [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
                [_placeImage setCenter:CGPointMake(_placeImage.center.x + 89, _placeImage.center.y)];
                [_nameLabel setAlpha:1.0];
                [_nameDLabel setAlpha:1.0];
                [_userLabel setAlpha:1.0];
                [_userDLabel setAlpha:1.0];
                [_emailLabel setAlpha:1.0];
                [_emailDLabel setAlpha:1.0];
                [_phoneLabel setAlpha:1.0];
                [_phoneDLabel setAlpha:1.0];
                [_weightLabel setAlpha:1.0];
                [_genderLabel setAlpha:1.0];
                [_topDrinkLabel setAlpha:1.0];
                [_badgesLabel setAlpha:1.0];
                [_weightDLabel setAlpha:1.0];
                [_genderDLabel setAlpha:1.0];
                [_topDrinkDLabel setAlpha:1.0];
                [_badgesDLabel setAlpha:1.0];
            } completion:^(BOOL finished){}];
        }];
    }
}

#pragma mark - Tap Methods

-(void)tapView {
    [_firstField resignFirstResponder];
    [_lastField resignFirstResponder];
    [_emailField resignFirstResponder];
    [_areaField resignFirstResponder];
    [_threeField resignFirstResponder];
    [_fourField resignFirstResponder];
    [_weightField resignFirstResponder];
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView)];
    _tapGesture.numberOfTapsRequired = 1;
    _tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:_tapGesture];
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [self.view removeGestureRecognizer:_tapGesture];
    _tapGesture = nil;
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if (textField == _firstField) {
        [_lastField becomeFirstResponder];
    } else if (textField == _lastField) {
        [_emailField becomeFirstResponder];
    } else if (textField == _emailField) {
        [_weightField becomeFirstResponder];
    } else if (textField == _weightField) {
        [_areaField becomeFirstResponder];
    } else if (textField == _areaField) {
        [_threeField becomeFirstResponder];
    } else if (textField == _threeField) {
        [_fourField becomeFirstResponder];
    } else if (textField == _fourField) {
        [self save];
    }
    return NO;
}

#pragma mark - Memory Methods

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
