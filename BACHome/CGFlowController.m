//
//  CGFlowController.m
//  CGFlowTest
//
//  Created by Charles Gorectke on 1/4/14.
//  Copyright (c) 2014 Charles Gorectke. All rights reserved.
//

#import "CGFlowController.h"
#import "objc/runtime.h"

#define willDidMove
#define appearanceTransition

@interface CGFlowController()
@property (nonatomic, weak) UIViewController *statusController;
@property (nonatomic, weak) UIViewController *modalController;
@property (nonatomic, strong) CGFlowInteractor *interactor;
@property (nonatomic, assign) Completion currentCompletion;
@property (nonatomic, assign) kCGFlowAnimationType animationType;
@property (nonatomic, assign) BOOL interactive;
@property (nonatomic, assign) BOOL started;
@end

@implementation CGFlowController

-(void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self prefersStatusBarHidden];
    [self setNeedsStatusBarAppearanceUpdate];
    
    _started = false;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.definesPresentationContext = YES;
    self.providesPresentationContextTransitionStyle = YES;
    self.interactor = [CGFlowInteractor new];
    [self.interactor setFlowController:self];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.flowedController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CGFlowInitialScene"];
    } else {
        self.flowedController = [[UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil] instantiateViewControllerWithIdentifier:@"CGFlowInitialScene"];
    }
    
    if (_flowedController) {
        [self addChildViewController:_flowedController];
        _flowedController.view.frame = self.view.bounds;
        [self.view addSubview:_flowedController.view];
        [self.flowedController didMoveToParentViewController:self];
        _flowedController.flowController = self;
        _statusController = _flowedController;
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!_started) {
        self.flowedController.transitioning = YES;
        [self.flowedController beginAppearanceTransition:YES animated:NO];
        self.flowedController.transitioning = NO;
    }
}

-(void)viewDidAppear:(BOOL)animated {
    if (!_started) {
        _started = true;
        self.flowedController.transitioning = YES;
        [self.flowedController endAppearanceTransition];
        self.flowedController.transitioning = NO;
    }
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}


-(void)flowToViewController:(UIViewController *)viewController withAnimation:(kCGFlowAnimationType)animation completion:(Completion)completion {
    BOOL animated = YES;
    if (animation == kCGFlowAnimationNone) {
        animated = NO;
    }
    
    _statusController = viewController;
    UIViewController *tempController = viewController;
    if ([viewController isKindOfClass:[UISplitViewController class]]) {
        UISplitHackController *splitController = [[UISplitHackController alloc] init];
        [splitController setSplitController:(UISplitViewController *)viewController];
        tempController = (UIViewController *)splitController;
    }
    
    tempController.transitioning = YES;
    [tempController viewWillAppear:animated];
    tempController.transitioning = NO;
    
    self.flowedController.transitioning = YES;
    [self.flowedController beginAppearanceTransition:NO animated:animated];
    self.flowedController.transitioning = NO;
    
    tempController.transitioningDelegate = self;
    tempController.modalPresentationStyle = UIModalPresentationCustom;
    _animationType = animation;
    self.interactive = NO;
    _currentCompletion = completion;
    [self presentViewController:tempController animated:animated completion:^{}];
}

-(void)flowInteractivelyToViewController:(UIViewController *)viewController withAnimation:(kCGFlowAnimationType)animation completion:(Completion)completion {
    BOOL animated = YES;
    if (animation == kCGFlowAnimationNone) {
        animated = NO;
    }
    
    _statusController = viewController;
    UIViewController *tempController = viewController;
    if ([viewController isKindOfClass:[UISplitViewController class]]) {
        UISplitHackController *splitController = [[UISplitHackController alloc] init];
        [splitController setSplitController:(UISplitViewController *)viewController];
        tempController = (UIViewController *)splitController;
    }
    
    tempController.transitioning = YES;
    [tempController viewWillAppear:animated];
    tempController.transitioning = NO;
    
    self.flowedController.transitioning = YES;
    [self.flowedController viewWillDisappear:animated];
    self.flowedController.transitioning = NO;
    
    tempController.transitioningDelegate = self;
    tempController.modalPresentationStyle = UIModalPresentationCustom;
    _animationType = animation;
    self.interactive = YES;
    _currentCompletion = completion;
    [self presentViewController:tempController animated:animated completion:^{}];
}

-(void)flowModalViewController:(UIViewController *)viewController completion:(Completion)completion {
    self.flowedController.view.userInteractionEnabled = NO;
    
    viewController.transitioning = YES;
    [viewController viewWillAppear:YES];
    viewController.transitioning = NO;
    
    viewController.transitioningDelegate = self;
    viewController.modalPresentationStyle = UIModalPresentationCustom;
    _animationType = kCGFlowAnimationModalPresent;
    self.interactive = NO;
    
    _currentCompletion = completion;
    [self presentViewController:viewController animated:YES completion:^{}];
}

-(void)flowDismissModalViewControllerWithCompletion:(Completion)completion {
    if (self.modalController) {
        _modalController.transitioning = YES;
        [_modalController viewWillDisappear:YES];
        _modalController.transitioning = NO;
        
        _modalController.transitioningDelegate = self;
        _modalController.modalPresentationStyle = UIModalPresentationCustom;
        _animationType = kCGFlowAnimationModalDismiss;
        self.interactive = NO;
        
        _currentCompletion = completion;
        [self dismissViewControllerAnimated:YES completion:^{}];
    }
}

-(void)setFlowedController:(UIViewController<CGFlowInteractiveDelegate> *)flowedController {
    _flowedController = flowedController;
    [self.flowedController setFlowController:self];
    _flowedController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
}

-(void)startTransition:(UIViewController *)vc {
    [self.flowedController willMoveToParentViewController:nil];
}

-(void)cancelTransition:(UIViewController *)vc {
    _statusController = _flowedController;
    [self prefersStatusBarHidden];
    [self setNeedsStatusBarAppearanceUpdate];
    
    self.interactive = NO;
    [vc setTransitioningDelegate:nil];
    [self dismissViewControllerAnimated:NO completion:^{
        [vc.view removeFromSuperview];
        [vc removeFromParentViewController];
    }];
}

-(void)finishTransition:(UIViewController *)vc {
    vc.transitioning = YES;
    [vc viewDidAppear:YES];
    vc.transitioning = NO;
    
    self.interactive = NO;
    __weak __block UIViewController *tempVc; // = vc;
    if ([vc isKindOfClass:[UISplitHackController class]]) {
        tempVc = ((UISplitHackController *)vc).splitController;
    } else {
        tempVc = vc;
    }
    
    __weak __block CGFlowController *safeSelf = self;
    [self dismissViewControllerAnimated:NO completion:^{
        [tempVc willMoveToParentViewController:nil];
        [tempVc.view removeFromSuperview];
        [tempVc removeFromParentViewController];
        
        [safeSelf addChildViewController:tempVc];
        [safeSelf.view addSubview:tempVc.view];
        
        [safeSelf.flowedController setTransitioningDelegate:nil];
        [safeSelf.flowedController.view removeFromSuperview];
        
        safeSelf.flowedController.transitioning = YES;
        [safeSelf.flowedController viewDidDisappear:YES];
        safeSelf.flowedController.transitioning = NO;
        
        [safeSelf.flowedController removeFromParentViewController];
        safeSelf.flowedController = tempVc;
        safeSelf.flowedController.flowController = safeSelf;
        [safeSelf.flowedController didMoveToParentViewController:safeSelf];
        
        [self prefersStatusBarHidden];
        [self setNeedsStatusBarAppearanceUpdate];
    }];
}

-(void)finishTransitionModal:(UIViewController *)vc appearing:(BOOL)appearing {
    if (appearing) {
        vc.transitioning = YES;
        [vc viewDidAppear:YES];
        vc.transitioning = NO;
        
        self.interactive = NO;
        self.modalController = vc;
        self.modalController.flowController = self;
        [self.modalController didMoveToParentViewController:self];
    } else {
        [self.flowedController.view setUserInteractionEnabled:YES];
        [self.modalController.view removeFromSuperview];
        [self.modalController removeFromParentViewController];
        self.modalController = nil;
    }
}

-(void)proceedToNextViewControllerWithTransition:(kCGFlowInteractionType)type {
    [self.flowedController proceedToNextViewControllerWithTransition:type];
}

-(BOOL)shouldAutomaticallyForwardAppearanceMethods {
    return YES;
}

#pragma mark - UIStatusBar

-(UIViewController *)childViewControllerForStatusBarHidden {
    return _statusController;
}

#pragma mark - UIViewControllerTransitioningDelegate

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    CGFlowAnimation *animator = [CGFlowAnimation new];
    animator.animationType = _animationType;
    animator.interactive = _interactive;
    [animator setFlowController:self];
    return animator;
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    CGFlowAnimation *animator = [CGFlowAnimation new];
    animator.animationType = _animationType;
    animator.interactive = _interactive;
    [animator setFlowController:self];
    return animator;
}

-(id<UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id<UIViewControllerAnimatedTransitioning>)animator {
    if (_interactive) {
        return self.interactor;
    }
    return nil;
}

-(id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator {
    if (_interactive) {
        return self.interactor;
    }
    return nil;
}

#pragma mark - Memory Methods

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

@interface CGFlowAnimation()

@end

@implementation CGFlowAnimation
@synthesize animationType=_animationType;
@synthesize interactive=_interactive;

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.4;
}

#pragma mark - UIViewControllerAnimatedTransitioning

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    
    if (!(self.animationType == kCGFlowAnimationModalPresent || self.animationType == kCGFlowAnimationModalDismiss)) {
        [toVC.view removeFromSuperview];
        [self.flowController startTransition:toVC];
        toVC.view.bounds = containerView.bounds;
        [containerView addSubview:toVC.view];
    }
    
    
    
    [CGFlowAnimations flowAnimation:self.animationType fromSource:fromVC toDestination:toVC withContainer:containerView andDuration:[self transitionDuration:transitionContext] withOrientation:[fromVC interfaceOrientation] interactively:_interactive completion:^(BOOL finished) {
        if (finished) {
            [transitionContext completeTransition:YES];
            if ([transitionContext transitionWasCancelled]) {
                if (!(self.animationType == kCGFlowAnimationModalPresent || self.animationType == kCGFlowAnimationModalDismiss)) {
                    [self.flowController cancelTransition:toVC];
                }
            } else {
                if (self.animationType == kCGFlowAnimationModalPresent) {
                    [self.flowController finishTransitionModal:toVC appearing:YES];
                } else if (self.animationType == kCGFlowAnimationModalDismiss) {
                    [self.flowController finishTransitionModal:toVC appearing:NO];
                } else {
                    [self.flowController finishTransition:toVC];
                }
            }
        }
    }];
}

@end

@interface CGFlowInteractor() <UIGestureRecognizerDelegate>
@property (nonatomic, assign) kCGFlowInteractionType interactorType;
@end

@implementation CGFlowInteractor

-(void)setFlowController:(CGFlowController *)flowController {
    _flowController = flowController;
    _interactorType = kCGFlowInteractionNone;
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [panGesture setCancelsTouchesInView:NO];
    [_flowController.view addGestureRecognizer:panGesture];
}

#pragma mark - Gesture Handler

-(void)handleGesture:(UIGestureRecognizer *)gr {
    CGFloat percentage = [CGFlowInteractions percentageOfGesture:gr withInteractor:_interactorType];
    switch (gr.state) {
        case UIGestureRecognizerStateBegan:
            _interactorType = [CGFlowInteractions determineInteractorType:gr];
            [self.flowController proceedToNextViewControllerWithTransition:_interactorType];
            break;
        case UIGestureRecognizerStateChanged: {
            if (percentage >= 1.0)
                percentage = 0.99;
            [self updateInteractiveTransition:percentage];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            _interactorType = kCGFlowInteractionNone;
            if (percentage < 0.5) {
                self.completionSpeed = 0.5f;
                [self cancelInteractiveTransition];
            } else {
                self.completionSpeed = 1.0f;
                [self finishInteractiveTransition];
            }
        default:
            break;
    }
}

@end

#pragma mark - UISplitHackController

@implementation UISplitHackController
@synthesize splitController=_splitController;
-(void)setSplitController:(UISplitViewController *)splitController {
    _splitController = splitController;
    [self.view addSubview:_splitController.view];
}
@end

#pragma mark - UIViewController(CGFlowAnimation) Category

static char flowKey;
static char transitioningKey;
static char lowestLevelKey;

@interface UIViewController() {
    CGFlowController *flowController;
    BOOL transitioning;
    BOOL lowestLevel;
}
@property (nonatomic, weak) CGFlowController *flowController;
@property (nonatomic, assign) BOOL transitioning;
@property (nonatomic, assign) BOOL lowestLevel;
@end

@implementation UIViewController (CGFlowInteractor)

-(void)proceedToNextViewControllerWithTransition:(kCGFlowInteractionType)type {
    UIViewController *tempController = self;
    if (!([tempController isKindOfClass:[UINavigationController class]] || [tempController isKindOfClass:[UITabBarController class]] || [tempController isKindOfClass:[UISplitViewController class]] || [tempController isKindOfClass:[UISplitHackController class]])) {
        // Returns if the method isn't overridden by the bottom controller
        if (self.lowestLevel) {
            self.lowestLevel = false;
            return;
        }
        self.lowestLevel = true;
    } else {
        self.lowestLevel = false;
    }
    
    while ([tempController isKindOfClass:[UINavigationController class]] || [tempController isKindOfClass:[UITabBarController class]] || [tempController isKindOfClass:[UISplitViewController class]] || [tempController isKindOfClass:[UISplitHackController class]]) {
        if ([tempController isKindOfClass:[UINavigationController class]]) {
            tempController = ((UINavigationController *)tempController).topViewController;
        } else if ([tempController isKindOfClass:[UITabBarController class]]) {
            tempController = ((UITabBarController *)tempController).selectedViewController;
        } else if ([tempController isKindOfClass:[UISplitViewController class]]) {
            tempController = ((UIViewController *)((UISplitViewController *)tempController).delegate);
        } else if ([tempController isKindOfClass:[UISplitHackController class]]) {
            tempController = ((UISplitHackController *)tempController).splitController;
        }
    }
    [tempController proceedToNextViewControllerWithTransition:type];
}

-(void)setFlowController:(CGFlowController *)flowCon {
    objc_setAssociatedObject(self, &flowKey, flowCon, OBJC_ASSOCIATION_ASSIGN);
    for (UIViewController *childController in self.childViewControllers) {
        [childController setFlowController:flowCon];
    }
}

-(CGFlowController *)flowController {
    CGFlowController *flowCon = objc_getAssociatedObject(self, &flowKey);
    UIViewController *parent = self.parentViewController;
    while (parent && !flowCon) {
        flowCon = parent.flowController;
        parent = parent.parentViewController;
    }
    return flowCon;
}

-(void)setTransitioning:(BOOL)transition {
    NSNumber *number = [NSNumber numberWithBool:transition];
    objc_setAssociatedObject(self, &transitioningKey, number, OBJC_ASSOCIATION_RETAIN);
    for (UIViewController *childController in self.childViewControllers) {
        [childController setTransitioning:transition];
    }
}

-(BOOL)transitioning {
    NSNumber *number = objc_getAssociatedObject(self, &transitioningKey);
    return [number boolValue];
}

-(void)setLowestLevel:(BOOL)lowest {
    NSNumber *number = [NSNumber numberWithBool:lowest];
    objc_setAssociatedObject(self, &lowestLevelKey, number, OBJC_ASSOCIATION_RETAIN);
}

-(BOOL)lowestLevel {
    NSNumber *number = objc_getAssociatedObject(self, &lowestLevelKey);
    return [number boolValue];
}

@end
