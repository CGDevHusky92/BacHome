//
//  CreateAccountViewController.m
//  ThisOrThat
//
//  Created by Chase Gorectke on 7/23/13.
//  Copyright Revision Works 2013
//  Engineering A Better World
//

#import <Parse/Parse.h>
#import "CreateAccountViewController.h"
#import "CGFlowController.h"

@interface CreateAccountViewController() <UITextFieldDelegate>
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UITextField *passField;
@property (nonatomic, weak) IBOutlet UITextField *emailField;
@property (nonatomic, weak) IBOutlet UIButton *createButton;
@property (nonatomic, weak) IBOutlet UIButton *backButton;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityWheel;
-(IBAction)createPressed:(id)sender;
@end

@implementation CreateAccountViewController
@synthesize userField=_userField;

-(void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIColor *color = [UIColor whiteColor];
    NSString *userText = @"Username";
    NSString *passText = @"Password";
    NSString *emailText = @"Email Address";
    _userField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:userText attributes:@{NSForegroundColorAttributeName: color}];
    _passField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:passText attributes:@{NSForegroundColorAttributeName: color}];
    _emailField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:emailText attributes:@{NSForegroundColorAttributeName: color}];
    
    [_titleLabel setFont:[UIFont systemFontOfSize:24.0]];
}

-(IBAction)createPressed:(id)sender {
    [_activityWheel startAnimating];
    
    [_createButton setEnabled:NO];
    [_backButton setEnabled:NO];
    [_userField resignFirstResponder];
    [_passField resignFirstResponder];
    [_emailField resignFirstResponder];
    
    UIAlertView *alert;
    PFUser *user = [PFUser user];
    
    int check = 0;
    
    if ([[_userField text] isEqualToString:@""] || [[_userField text] length] > 16) {
        check += 1;
    }
    
    if ([[_passField text] isEqualToString:@""] || [[_passField text] length] > 16) {
        check += 3;
    }
    
    if ([[_emailField text] isEqualToString:@""]) {
        check += 5;
    }
    
    switch (check) {
        case 0: {
            // Create Account
            user.username = [_userField text];
            user.password = [_passField text];
            user.email = [_emailField text];
            [user setObject:[NSDate date] forKey:@"last_updated"];
            [user setObject:[NSNumber numberWithInt:0] forKey:@"num_sent"];
            [user setObject:[NSNumber numberWithInt:0] forKey:@"num_received"];
            [user setObject:@"" forKey:@"phone"];
            [user setObject:@"" forKey:@"f_name"];
            [user setObject:@"" forKey:@"l_name"];
            [user setObject:[NSNumber numberWithBool:NO] forKey:@"fb_user"];
            [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    [_activityWheel startAnimating];
                    [_userField setText:@""];
                    [_passField setText:@""];
                    [_emailField setText:@""];
                    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge| UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound];
                    [self dismissView:self];
                } else {
                    NSString *errorString = [[error userInfo] objectForKey:@"error"];
                    NSInteger code = [error code];
                    NSLog(@"Error: %@, %ld", errorString, code);
                    if (code == 125) {
                        [_activityWheel stopAnimating];
                        [_emailField becomeFirstResponder];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Email" message:@"Please use a real/different email address" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                        [alert show];
                    } else if (code == 202) {
                        [_activityWheel stopAnimating];
                        [_userField becomeFirstResponder];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Username" message:[NSString stringWithFormat:@"Username %@ already taken", user.username] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                        [alert show];
                    } else if (code == 203) {
                        [_activityWheel stopAnimating];
                        [_emailField becomeFirstResponder];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Email" message:[NSString stringWithFormat:@"Email address %@ already taken", user.email] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                        [alert show];
                    }
                }
                [_createButton setEnabled:YES];
                [_backButton setEnabled:YES];
            }];
        }
            break;
        case 1:
            // Error no username chosen
            [_activityWheel stopAnimating];
            [_userField becomeFirstResponder];
            alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Either No Username Entered Or It Has Too Many Characters" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            [_createButton setEnabled:YES];
            [_backButton setEnabled:YES];
            break;
        case 3:
            // Error no password chosen
            [_activityWheel stopAnimating];
            [_passField becomeFirstResponder];
            alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Either No Password Entered Or It Has Too Many Characters" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            [_createButton setEnabled:YES];
            [_backButton setEnabled:YES];
            break;
        case 4:
            // Error no username or password chosen
            [_activityWheel stopAnimating];
            [_userField becomeFirstResponder];
            alert = [[UIAlertView alloc] initWithTitle:@" Multiple Errors" message:@"Either No Username Entered Or It Has Too Many Characters, Either No Password Entered Or It Has Too Many Characters" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            [_createButton setEnabled:YES];
            [_backButton setEnabled:YES];
            break;
        case 5:
            // Error no email chosen
            [_activityWheel stopAnimating];
            [_emailField becomeFirstResponder];
            alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No Email Entered" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            [_createButton setEnabled:YES];
            [_backButton setEnabled:YES];
            break;
        case 6:
            // Error no username or email chosen
            [_activityWheel stopAnimating];
            [_userField becomeFirstResponder];
            alert = [[UIAlertView alloc] initWithTitle:@"Multiple Errors" message:@"Either No Username Or It Has Too Many Characters, No Email Entered" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            [_createButton setEnabled:YES];
            [_backButton setEnabled:YES];
            break;
        case 8:
            // Error no password or email chosen
            [_activityWheel stopAnimating];
            [_passField becomeFirstResponder];
            alert = [[UIAlertView alloc] initWithTitle:@"Multiple Errors" message:@"No Password Or It Has Too Many Characters, No Email Entered" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            [_createButton setEnabled:YES];
            [_backButton setEnabled:YES];
            break;
        case 9:
            // Error no username, password, or email chosen
            [_activityWheel stopAnimating];
            [_userField becomeFirstResponder];
            alert = [[UIAlertView alloc] initWithTitle:@"Multiple Errors" message:@"Either No Username Or It Has Too Many Characters, Either No Password Or It Has Too Many Characters, And No Email Entered" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            [_createButton setEnabled:YES];
            [_backButton setEnabled:YES];
            break;
        default:
            [_activityWheel stopAnimating];
            [_createButton setEnabled:YES];
            [_backButton setEnabled:YES];
            NSLog(@"Error: Unknown Error Code %d", check);
            break;
    }
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
        [_emailField becomeFirstResponder];
    } else if (textField == _emailField) {
        [self createPressed:textField];
    }
    return YES;
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
