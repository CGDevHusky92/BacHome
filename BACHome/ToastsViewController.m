//
//  ToastsViewController.m
//  BACHome
//
//  Created by Chase Gorectke on 1/17/14.
//  Copyright (c) 2014 Revision Works, LLC. All rights reserved.
//

#import "ToastsViewController.h"
#import "PFToasts.h"

#import "NSString+FontAwesome.h"

@interface ToastsViewController() <UIPickerViewDataSource, UIPickerViewDelegate>
@property (nonatomic, weak) IBOutlet UIButton *drinksButton;
@property (nonatomic, weak) IBOutlet UIButton *barsButton;
@property (nonatomic, weak) IBOutlet UIButton *postButton;
@property (nonatomic, weak) IBOutlet UITextView *toastField;
@property (nonatomic, weak) IBOutlet UIPickerView *pickerWheel;

@property (nonatomic, strong) NSMutableArray *drinksArray;
@property (nonatomic, strong) NSMutableArray *barsArray;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) NSString *drink;
@property (nonatomic, strong) NSString *bars;
@property (assign) BOOL drinkFlag;
@property (assign) BOOL pickerShown;
-(IBAction)cancelPressed:(id)sender;
-(IBAction)drinksPressed:(id)sender;
-(IBAction)barsPressed:(id)sender;
-(IBAction)postPressed:(id)sender;
@end

@implementation ToastsViewController

-(void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _drinkFlag = true;
    _pickerShown = false;
    _drinksArray = [[NSMutableArray alloc] init];
    _barsArray = [[NSMutableArray alloc] init];
    
    [_drinksButton.titleLabel setFont:[UIFont fontWithName:kFontAwesomeFamilyName size:28.0]];
    [_drinksButton setTitle:[NSString fontAwesomeIconStringForEnum:FABeer] forState:UIControlStateNormal];
    [_barsButton.titleLabel setFont:[UIFont fontWithName:kFontAwesomeFamilyName size:28.0]];
    [_barsButton setTitle:[NSString fontAwesomeIconStringForEnum:FAMapMarker] forState:UIControlStateNormal];
    [_postButton.titleLabel setFont:[UIFont fontWithName:kFontAwesomeFamilyName size:28.0]];
    [_postButton setTitle:[NSString fontAwesomeIconStringForEnum:FAPencilSquareO] forState:UIControlStateNormal];
    
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
    [_tapGesture setNumberOfTapsRequired:1];
    [_tapGesture setCancelsTouchesInView:NO];
    [self.presentingViewController.view addGestureRecognizer:_tapGesture];
    
    [self generateDrinkList];
    [self generateBarList];
}

#pragma mark - Button Delegate

-(IBAction)cancelPressed:(id)sender {
    [self.presentingViewController.view removeGestureRecognizer:_tapGesture];
    [self.flowController flowDismissModalViewControllerWithCompletion:^(BOOL finished){}];
}

-(IBAction)drinksPressed:(id)sender {
    if (!_pickerShown) {
        // Pull out
        _drinkFlag = true;
        [self.pickerWheel reloadComponent:0];
        [UIView animateWithDuration:0.4 delay:0.0 options:0 animations:^{
            self.navigationController.view.frame = CGRectMake(self.navigationController.view.frame.origin.x, self.navigationController.view.frame.origin.y - (self.pickerWheel.frame.size.height / 2), self.navigationController.view.frame.size.width, self.navigationController.view.frame.size.height + self.pickerWheel.frame.size.height);
        } completion:^(BOOL finished) {
            _pickerShown = YES;
        }];
    } else {
        if (!_drinkFlag) {
            _drinkFlag = true;
            [self.pickerWheel reloadComponent:0];
        } else {
            // Put away
            _drinkFlag = true;
            [self.pickerWheel reloadComponent:0];
            [UIView animateWithDuration:0.4 delay:0.0 options:0 animations:^{
                self.navigationController.view.frame = CGRectMake(self.navigationController.view.frame.origin.x, self.navigationController.view.frame.origin.y + (self.pickerWheel.frame.size.height / 2), self.navigationController.view.frame.size.width, self.navigationController.view.frame.size.height - self.pickerWheel.frame.size.height);
            } completion:^(BOOL finished) {
                _pickerShown = NO;
            }];
        }
    }
}

-(IBAction)barsPressed:(id)sender {
    if (!_pickerShown) {
        // Pull out
        _drinkFlag = NO;
        [self.pickerWheel reloadComponent:0];
        [UIView animateWithDuration:0.4 delay:0.0 options:0 animations:^{
            self.navigationController.view.frame = CGRectMake(self.navigationController.view.frame.origin.x, self.navigationController.view.frame.origin.y - (self.pickerWheel.frame.size.height / 2), self.navigationController.view.frame.size.width, self.navigationController.view.frame.size.height + self.pickerWheel.frame.size.height);
        } completion:^(BOOL finished) {
            _pickerShown = YES;
        }];
    } else {
        if (_drinkFlag) {
            _drinkFlag = false;
            [self.pickerWheel reloadComponent:0];
        } else {
            // Put away
            _drinkFlag = NO;
            [self.pickerWheel reloadComponent:0];
            [UIView animateWithDuration:0.4 delay:0.0 options:0 animations:^{
                self.navigationController.view.frame = CGRectMake(self.navigationController.view.frame.origin.x, self.navigationController.view.frame.origin.y + (self.pickerWheel.frame.size.height / 2), self.navigationController.view.frame.size.width, self.navigationController.view.frame.size.height - self.pickerWheel.frame.size.height);
            } completion:^(BOOL finished) {
                _pickerShown = YES;
            }];
        }
    }
}

-(IBAction)postPressed:(id)sender {
    if ((_toastField && ![[_toastField text] isEqualToString:@""]) && (_bars && ![_bars isEqualToString:@""]) && (_drink && ![_drink isEqualToString:@""])) {
        PFToasts *newToast = [[PFToasts alloc] initWithDefaults];
        [newToast setToast:[_toastField text]];
        [newToast setBar:_bars];
        [newToast setDrink:_drink];
        [newToast saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
            if (!succeeded) {
                NSLog(@"Error: %@", [error localizedDescription]);
                [newToast saveEventually];
            }
        }];
        [self.presentingViewController.view removeGestureRecognizer:_tapGesture];
        [self.flowController flowDismissModalViewControllerWithCompletion:^(BOOL finished){}];
    }
}

#pragma mark - Parse Data Generation

-(void)generateDrinkList {
    PFQuery *drinkQuery = [PFQuery queryWithClassName:@"DrinksLookup"];
    [drinkQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error) {
            _drinksArray = [[objects sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES], nil]] mutableCopy];
            if (_drinkFlag) {
                [self.pickerWheel reloadComponent:0];
            }
        } else {
            NSLog(@"Error: %@", [error localizedDescription]);
        }
    }];
}

-(void)generateBarList {
    PFQuery *barQuery = [PFQuery queryWithClassName:@"BarsLookup"];
    [barQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error) {
            _barsArray = [[objects sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES], nil]] mutableCopy];
            if (!_drinkFlag) {
                [self.pickerWheel reloadComponent:0];
            }
        } else {
            NSLog(@"Error: %@", [error localizedDescription]);
        }
    }];
}

#pragma mark - Picker Delegate

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (_drinkFlag) {
        return [_drinksArray count];
    }
    return [_barsArray count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (_drinkFlag) {
        return [[_drinksArray objectAtIndex:row] objectForKey:@"name"];
    } else {
        return [[_barsArray objectAtIndex:row] objectForKey:@"name"];
    }
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (_drinkFlag) {
        _drink = [[_drinksArray objectAtIndex:row] objectForKey:@"name"];
    } else {
        _bars = [[_barsArray objectAtIndex:row] objectForKey:@"name"];
    }
}

#pragma mark - Tap Methods

-(void)tapView:(id)sender {
    if ([_toastField isFirstResponder]) {
        [_toastField resignFirstResponder];
    } else {
        [self.presentingViewController.view removeGestureRecognizer:_tapGesture];
        [self.flowController flowDismissModalViewControllerWithCompletion:^(BOOL finished){}];
    }
    
}

#pragma mark - Memory Methods

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
