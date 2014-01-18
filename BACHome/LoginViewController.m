//
//  LoginViewController.m
//  ThisOrThat
//
//  Created by Chase Gorectke on 7/23/13.
//  Copyright Revision Works 2013
//  Engineering A Better World
//

#import <Parse/Parse.h>
#import "LoginViewController.h"

@interface LoginViewController() <UIAlertViewDelegate, UITextFieldDelegate>
@property (nonatomic, weak) IBOutlet UILabel *loginLabel;
@property (nonatomic, weak) IBOutlet UITextField *userField;
@property (nonatomic, weak) IBOutlet UITextField *passField;
@property (nonatomic, weak) IBOutlet UIButton *loginButton;
@property (nonatomic, weak) IBOutlet UIButton *createButton;
@property (nonatomic, weak) IBOutlet UIButton *forgotButton;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityWheel;
-(IBAction)loginPressed:(id)sender;
-(IBAction)createPressed:(id)sender;
-(IBAction)forgotPressed:(id)sender;
-(void)dismissView:(id)sender;
@end

@implementation LoginViewController

-(void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - UIViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
-(void)viewDidLoad {
    [super viewDidLoad];
    
    UIColor *color = [UIColor whiteColor];
    NSString *userText = @"Username";
    NSString *passText = @"Password";
    _userField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:userText attributes:@{NSForegroundColorAttributeName: color}];
    [_loginLabel setFont:[UIFont systemFontOfSize:26.0]];
    
    _passField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:passText attributes:@{NSForegroundColorAttributeName: color}];
}

-(void)viewDidAppear:(BOOL)animated {
    if (self.transitioning) {
        [super viewDidAppear:animated];
    }
}

-(IBAction)loginPressed:(id)sender {
    [_loginButton setEnabled:NO];
    [_forgotButton setEnabled:NO];
    [_createButton setEnabled:NO];
    [_activityWheel startAnimating];
    [_userField resignFirstResponder];
    [_passField resignFirstResponder];
    [PFUser logInWithUsernameInBackground:[_userField text] password:[_passField text] block:^(PFUser *user, NSError *error) {
        if (user) {
            // Do stuff after successful login.
            [_userField setText:@""];
            [_passField setText:@""];
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
            
            [_activityWheel stopAnimating];
            [self dismissView:self];
        } else {
            [_userField becomeFirstResponder];
            [_activityWheel stopAnimating];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Failed" message:@"Unrecognized username/password combination. You can reset your password below." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            NSLog(@"Error: %@", [error localizedDescription]);
        }
        [_loginButton setEnabled:YES];
        [_forgotButton setEnabled:YES];
        [_createButton setEnabled:YES];
    }];
}

-(IBAction)createPressed:(id)sender {
    [_userField resignFirstResponder];
    [_passField resignFirstResponder];
    
    UIViewController *createController = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateAccountView"];
//    [self.flowController flowToViewController:createController withAnimation:kCGFlowAnimationSlideLeft completion:^(BOOL finished){}];
    [self.navigationController pushViewController:createController animated:YES];
}

-(IBAction)forgotPressed:(id)sender {
    [_userField resignFirstResponder];
    [_passField resignFirstResponder];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Forgotten Password" message:@"Please Enter your email" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [[alert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeEmailAddress];
    [[alert textFieldAtIndex:0] setPlaceholder:@"example@gmail.com"];
    [[alert textFieldAtIndex:0] setBackgroundColor:[UIColor whiteColor]];
    [[alert textFieldAtIndex:0] setTextAlignment:NSTextAlignmentCenter];
    [[alert textFieldAtIndex:0] becomeFirstResponder];
    [alert show];
}

-(void)dismissView:(id)sender {
    UIViewController *newsController = [self.storyboard instantiateViewControllerWithIdentifier:@"CGFlowInitialScene"];
    [self.flowController flowToViewController:newsController withAnimation:kCGFlowAnimationSlideDown completion:^(BOOL finished){}];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    if (textField == _userField) {
        [_passField becomeFirstResponder];
    } else if (textField == _passField) {
        [self loginPressed:textField];
    }
    
    return YES;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [[alertView textFieldAtIndex:0] resignFirstResponder];
        [PFUser requestPasswordResetForEmailInBackground:[[[alertView textFieldAtIndex:0] text] description]];
    }
}

@end
